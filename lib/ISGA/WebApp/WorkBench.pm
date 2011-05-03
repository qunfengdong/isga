
## no critic
# we turn off perl critic because we package doesn't match file
package ISGA::WebApp;
## use critic
#------------------------------------------------------------------------

=head1 NAME

ISGA::WebApp manages the interface to MASON for ISGA.

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=cut
#------------------------------------------------------------------------
use strict;
use warnings;
use CGI;

use Digest::MD5;
use Apache2::Upload;
use File::Copy;
use File::Basename;
#========================================================================

=head2 CLASS METHODS

=over 4

=cut
#========================================================================

#------------------------------------------------------------------------

=item public void Blast();

Run a Workbench Blast job using SGE nodes.

=cut
#------------------------------------------------------------------------
sub WorkBench::Blast {
    my $self = shift;
    my $web_args = $self->args;
    my $form = ISGA::FormEngine::WorkBench->Blast($web_args);
    
    if ( $form->canceled ) {
	$self->redirect( uri => '/WorkBench/Blast' );
    } 
    
    if ($form->ok) {
	my $sequences = $form->get_input('query_sequence');
	my $upload = $self->apache_req->upload('upload_file');
	#my $upload = "";
	
	## Hardcoded paths.
	my $files_path = "___tmp_file_directory___/workbench/blast/";
	my $pipeline_path = "___ergatis_output_repository___cgb_format/";
	my %hash = (
		    "pro.nr" => "___database_path___NCBI-nr/nr-09-20-2009/nr",
		    "nuc.nt" => "___database_path___NCBI-nr/nr-09-20-2009/nt",
		    "pro.uniref" => "___database_path___Asgard/asgard_data-09-23-2009/UniRef100",
		    "nuc.uniref" => '',
		    "pro.allgroup" => "___database_path___NIAA/NIAA-07-27-2009/AllGroup.niaa",
		    "nuc.allgroup" => "___database_path___NIAA/NIAA-07-27-2009/AllGroup.fasta",
                    "tair9_cdna" => "___database_path___Tair9/Tair9_cdna_20090619/Tair9_cdna",
                    "tair9_pep" => "___database_path___Tair9/TAIR9_pep_20090619/Tair9_pep",
		    );
	my $notify = $form->get_input('notify_user');
	my $blastfilter = $form->get_input('blastfilter');
	my $scoringmatrix = $form->get_input('scoringmatrix');
	my $evalue = $form->get_input('evalue');
	my $blast_program = $form->get_input('blast_program');
	my $sequence_database = $form->get_input('sequence_database');
	ref($sequence_database) eq 'ARRAY' or $sequence_database = [ $sequence_database ];
	
	my $time = time.$$;
	my $blast_output = $files_path.$time.'_blast_output.blout';
	
	my @database_array;
	foreach (@$sequence_database){
	    if (($blast_program eq "blastp") or ($blast_program eq "blastx")){
		if ($_ eq 'nr'){
		    push(@database_array, $hash{"pro.$_"});
                }elsif ($_ eq 'tair9_pep'){
                    push(@database_array, $hash{"$_"});
		}elsif ($_ =~ /^Run/){
		    $_ =~ s/Run//g;
		    #push(@database_array, $pipeline_path.$_."_workbench_prot/".$_."_run_result_prot_db");
		    push(@database_array, $pipeline_path.$_);
		}else {
		    my $formatdbpath = $files_path.$time.'_genome_sequence';
		    copy($_, $formatdbpath) or X->throw(message => 'Cannot copy file to tmp directory');
		    system("___formatdb_executable___ -i $formatdbpath -p F -o T") == 0 or X->throw(message => 'formatdb failed');
		    push(@database_array, $formatdbpath);
		}
	    } else {
		if ($_ eq 'nt'){
		    push(@database_array, $hash{"nuc.$_"});
                }elsif ($_ eq 'tair9_cdna'){
                    push(@database_array, $hash{"$_"});
		}elsif ($_ =~ /^Run/){
		    $_ =~ s/Run//g;
		    #push(@database_array, $pipeline_path.$_."_workbench_nuc/".$_."_run_result_nuc_db");
		    push(@database_array, $pipeline_path.$_);
		} else {
		    my $formatdbpath = $files_path.$time.'_genome_sequence';
		    copy($_, $formatdbpath) or X->throw(message => 'Cannot copy file to tmp directory');
		    system("___formatdb_executable___ -i $formatdbpath -p F -o T") == 0 or X->throw(message => 'formatdb failed');
		    push(@database_array, $formatdbpath);
		}
	    }
	}
	
	my $database = join(' ', @database_array);
	my %args = ( );
	
	$upload and $args{Upload} = $upload->fh;
	$sequences and $args{String} = $sequences;
	$args{Username} = $upload ? basename($upload) : $time.'_blast_input';
	my $input_file = ISGA::Job::BLAST->buildQueryFile(%args);
	
	my $sge=ISGA::SGEScheduler->new(
					-executable  => {qsub=>'___sge_executables___'.'/qsub -q ___SGE_QUEUE___', qstat=>'___sge_executables___'.'/qstat'},
					-output_file => '___tmp_file_directory___'."/workbench/sge_log/blast_".$time.".sgeout",
					-error_file => '___tmp_file_directory___'."/workbench/sge_log/blast_".$time.".sgeerror",
					);
	
	my $inpath = $input_file->getPath;
	my $runpath = $files_path.$time.'_blast_input';
	copy($inpath, $runpath) or X->throw(message => 'Cannot copy file to tmp directory');

	system("___cdbfasta_executable___ -C $runpath") == 0 or X->throw(message => 'cdbfasta failed');

        my $command;
        my $sge_submit_script = "$files_path/${time}_sge_blast.sh";

        if($database =~ /Tair9_cdna/og or $database =~ /Tair9_pep/og){
            open my $fh, '>', $sge_submit_script or X->throw(message => 'Error creating sge shell script.');
            print $fh '#!/bin/bash'."\n\n";
	    print $fh 'echo "starting blast" 1>&2'."\n";
            print $fh "___blast_executable___ -p $blast_program -i $runpath -o $blast_output -e $evalue -d \"$database\" -F $blastfilter\n\n";
            print $fh 'echo "starting preprocessing output" 1>&2'."\n";
            print $fh "___scripts_bin___parse_blast_output.pl $blast_output\n\n";
            close $fh;
            chmod(0755, $sge_submit_script);
            $command = "$sge_submit_script";
        } else {
            $command = "___blast_executable___ -p $blast_program -i $runpath -o $blast_output -e $evalue -d \"$database\" -F $blastfilter";
	}
	$sge->command($command);
	my $pid = $sge->execute();
	X->throw(message => 'Error submitting job.') unless($pid);
	my %sgejob_args =
	    (
	     Pid => $pid,
	     Status => 'Pending',
	     Type => ISGA::JobType->new( Name => 'Blast' ),
	     CreatedBy => ISGA::Login->getAccount,
	     CreatedAt => ISGA::Timestamp->new(),
	     NotifyUser => $notify
	     );

	my $job;
	$job = ISGA::Job->create(%sgejob_args) or X->throw(message => 'Error submitting job.');
	$job->addInputToCollection($input_file);
	$job->buildConfigFile( input => $input_file->getUserName, web_args => $web_args, databases => \@database_array, input_file => $runpath, output_file => $blast_output );
	
	$self->redirect( uri => "/WorkBench/Results/Blast?job=$job" );
    }
    # bounce!!!!!
    $self->_save_arg( 'form', $form);
    $self->redirect( uri => '/WorkBench/Blast' );
    
}

#------------------------------------------------------------------------

=item public void Notify();

Sets Notify to true for Workbench job 

=cut
#------------------------------------------------------------------------
sub WorkBench::Notify{
  my $self = shift;
  my $web_args = $self->args;
  my $account = ISGA::Login->getAccount;
  my $job = $web_args->{job};
  $job->edit( NotifyUser => 1 );
#  $self->redirect( uri => "/WorkBench/Results/Blast?job=$job" );

  if ($job->getType->getName eq 'Blast'){
    $self->redirect( uri => "/WorkBench/Results/Blast?job=$job" );
  }elsif ($job->getType->getName eq 'Hawkeye'){
    $self->redirect( uri => "/WorkBench/Results/Hawkeye?job=$job" );
  }
}

#------------------------------------------------------------------------

=item public void NewblerToHawkeye();

Convert Newbler output for use in Hawkeye

=cut
#------------------------------------------------------------------------
sub WorkBench::NewblerToHawkeye {
    my $self = shift;
    my $web_args = $self->args;
    my $form = ISGA::FormEngine::WorkBench->NewblerToHawkeye($web_args);
   
    if ( $form->canceled ) {
        $self->redirect( uri => '/WorkBench/NewblerToHawkeye' );
    }
   
    if ($form->ok) {

        my $project = $form->get_input('project');
        my $ace_upload = $self->apache_req->upload('upload_ace_file');
        my $agp_upload = $self->apache_req->upload('upload_agp_file');
        my $metric_upload = $self->apache_req->upload('upload_metric_file');
        my $read_upload = $self->apache_req->upload('upload_read_file');
        my $file_collection = $form->get_input('collection');
        my @sff_files = map( $self->apache_req->upload($_), grep(/^upload_sff_file\d/, keys %$web_args));

        $project =~ s/ /_/g;
        ## Hardcoded paths.
        my $files_path = "___tmp_file_directory___/workbench/newblertohawkeye/";
 
        my $time = time.$$;
        my $out_directory = $files_path.$time;
        my %args = ( Type => 'Newbler Assembler Output' );
        my ($ace_input_file, $agp_input_file, $metric_input_file, $read_input_file);

        mkdir($out_directory) or X->throw(message => 'output directory creation failed') if(! -e $out_directory);
        my %sff_input_files;
        unless ( $file_collection ) { 
           $args{Upload} = $ace_upload->fh;
           $args{Format} = 'ACE';
           $args{Username} = basename($ace_upload);
           $ace_input_file = ISGA::Job::Hawkeye->buildQueryFile(%args);
           $ace_input_file->stage($out_directory);

           $args{Upload} = $agp_upload->fh;
           $args{Format} = 'AGP';
           $args{Username} = basename($agp_upload);
           $agp_input_file = ISGA::Job::Hawkeye->buildQueryFile(%args);
           $agp_input_file->stage($out_directory);

           if ($metric_upload){
               $args{Upload} = $metric_upload->fh;
               $args{Format} = 'Newbler Metric File';
               $args{Username} = basename($metric_upload);
               $metric_input_file = ISGA::Job::Hawkeye->buildQueryFile(%args);
               $metric_input_file->stage($out_directory);

               $args{Upload} = $read_upload->fh;
               $args{Format} = 'Read File';
               $args{Username} = basename($read_upload);
               $read_input_file = ISGA::Job::Hawkeye->buildQueryFile(%args);
               $read_input_file->stage($out_directory);
           }
        }
        my $mate_pair_args = '';
        if ($metric_upload){
            open my $in, '<', "$out_directory/".$metric_input_file->getName() or X->throw(message => 'Error opening Metric File');
            open my $out, '>', "$out_directory/reads.lib" or X->throw(message => "Error creating reads.lib: $!");
            my ($name, $avg, $dev);
            while (<$in>){
                    next if /^#/ || /^\s*$/;
                    if    (/libraryName\s*=\s*"(.+)"/)        { $name = $1; }
                    elsif (/pairDistanceAvg\s*=\s*([\d\.]+)/) { $avg  = $1; }
                    elsif (/pairDistanceDev\s*=\s*([\d\.]+)/) { $dev  = $1; print $out "$name\t$avg\t$dev\n"; }
            }
            close($in);
            close($out);
            $mate_pair_args .= " -lib $out_directory/reads.lib";
            $mate_pair_args .= " -read $out_directory/" . $read_input_file->getName();
        }else{
            $mate_pair_args .= " -name " . $form->get_input('library_name') . " -avg " . $form->get_input('average_length') . " -stdev " . $form->get_input('stdev');
        }

        my $sge_submit_script = "$out_directory/${time}_sge_hawkeye.sh";

        open my $fh, '>', $sge_submit_script or X->throw(message => 'Error creating sge shell script.');
        print $fh '#!/bin/bash'."\n\n";
        print $fh "cd $out_directory\n\n";
        print $fh "pwd 1>&2\n\n";
        print $fh 'echo "starting ace2wu" 1>&2'."\n";
        print $fh "___scripts_bin___ace2wu -i $out_directory/".$ace_input_file->getName()." -U -o  $out_directory/reads.placed\n\n";
        print $fh 'echo "starting matepair_bambus.pl" 1>&2'."\n";
        print $fh "___scripts_bin___matepair_bambus.pl $mate_pair_args -i $out_directory/reads.placed -o $out_directory/reads.pair\n\n";
        print $fh 'echo "starting toAmos" 1>&2'."\n";
        print $fh "___toAmos_executable___ -m $out_directory/reads.pair -ace $out_directory/".$ace_input_file->getName()." -o $out_directory/contigs.amos\n\n";
        print $fh 'echo "starting agp2amos" 1>&2'."\n";
        print $fh "___scripts_bin___agp2amos.pl $out_directory/contigs.amos $out_directory/".$agp_input_file->getName()." $out_directory/scaffolds.amos\n\n";
        print $fh 'echo "starting banktransact" 1>&2'."\n";
        print $fh "___bank_transact_executable___ -b $out_directory/$project.bnk -m $out_directory/contigs.amos -c\n\n";
        print $fh "___bank_transact_executable___ -b $out_directory/$project.bnk -m $out_directory/scaffolds.amos\n\n";
        print $fh "tar -cvf $project.bnk.tar $project.bnk\n";
        print $fh "gzip $project.bnk.tar\n";
        close $fh;
        chmod(0755, $sge_submit_script);
        my $sge=ISGA::SGEScheduler->new(
                                        -executable  => {qsub=>'___sge_executables___'.'/qsub -q ___SGE_QUEUE___', qstat=>'___sge_executables___'.'/qstat'},
                                        -output_file => '___tmp_file_directory___'."/workbench/sge_log/newbler2hawkeye_".$time.".sgeout",
                                        -error_file => '___tmp_file_directory___'."/workbench/sge_log/newbler2hawkeye_".$time.".sgeerror",
                                        );

        my $command = "$sge_submit_script";
        $sge->command($command);
        my $pid = $sge->execute();
        X->throw(message => 'Error submitting job.') unless($pid);

        my %sgejob_args =
            (
             Pid => $pid,
             Status => 'Pending',
             Type => ISGA::JobType->new( Name => 'Hawkeye' ),
             CreatedBy => ISGA::Login->getAccount,
             CreatedAt => ISGA::Timestamp->new(),
             NotifyUser => 0
             );

        my $job;
        $job = ISGA::Job->create(%sgejob_args) or X->throw(message => 'Error submitting job.');
        $job->buildConfigFile( project => $project, output_file => "$out_directory/$project.bnk.tar.gz" );
        $job->addInputToCollection($ace_input_file);
        $job->addInputToCollection($agp_input_file);
        $job->addInputToCollection($metric_input_file) if ($metric_upload);

        $self->redirect( uri => "/WorkBench/Results/Hawkeye?job=$job" );
    }
    # bounce!!!!!
    $self->_save_arg( 'form', $form);
    $self->redirect( uri => '/WorkBench/NewblerToHawkeye' );

}

#------------------------------------------------------------------------

=item public void CeleraToHawkeye();

Convert Celera output for use in Hawkeye

=cut
#------------------------------------------------------------------------
sub WorkBench::CeleraToHawkeye {
    my $self = shift;
    my $web_args = $self->args;
    my $form = ISGA::FormEngine::WorkBench->CeleraToHawkeye($web_args);

    if ( $form->canceled ) {
        $self->redirect( uri => '/WorkBench/CeleraToHawkeye' );
    }

    if ($form->ok) {

        my $project = $form->get_input('project');
        my $asm_upload = $self->apache_req->upload('upload_asm_file');
        my $file_collection = $form->get_input('collection');
        my @frg_files = map( $self->apache_req->upload($_), grep(/^upload_frg_file\d/, keys %$web_args));

        $project =~ s/ /_/g;
        ## Hardcoded paths.
        my $files_path = "___tmp_file_directory___/workbench/celeratohawkeye/";

        my $time = time.$$;
        my $out_directory = $files_path.$time;
        my %args = ( Type => 'Celera Assembler Output' );
        my ($asm_input_file);

        mkdir($out_directory) or X->throw(message => 'output directory creation failed') if(! -e $out_directory);
        system("touch $out_directory/reads.frg") == 0 or X->throw(message => 'Failed to combine FRG files');

        my %frg_input_files;
        unless ( $file_collection ) {
           $args{Upload} = $asm_upload->fh;
           $args{Format} = 'ASM';
           $args{ExistsOutsideCollection} = 1;
           $args{Username} = basename($asm_upload);
           $asm_input_file = ISGA::Job::Hawkeye->buildQueryFile(%args);
           $asm_input_file->stage($out_directory);

           foreach(@frg_files){
               $args{Upload} = $_->fh;
               $args{Type} = 'Celera Assembler native format';
               $args{Format} = 'FRG';
               $args{ExistsOutsideCollection} = 1;
               $args{Username} = basename($_);
               my $frg_input_file = ISGA::Job::Hawkeye->buildQueryFile(%args);
               $frg_input_files{$_} = $frg_input_file;
               my $cat_cmd = "cat ".$frg_input_file->getPath." >> $out_directory/reads.frg";
               system("$cat_cmd") == 0 or X->throw(message => 'Failed to combine FRG files');
#               copy($sff_input_file->getPath, "$out_directory/".basename($_));
           }
        }

        my $sge_submit_script = "$out_directory/${time}_sge_hawkeye.sh";

        open my $fh, '>', $sge_submit_script or X->throw(message => 'Error creating sge shell script.');
        print $fh '#!/bin/bash'."\n\n";
        print $fh "cd $out_directory\n\n";
        print $fh 'echo "starting toAmos" 1>&2'."\n";
        print $fh "___toAmos_executable___ -f $out_directory/reads.frg -a $out_directory/".$asm_input_file->getName()." -o $out_directory/reads.amos\n\n";
        print $fh 'echo "starting banktransact" 1>&2'."\n";
        print $fh "___bank_transact_executable___ -b $out_directory/$project.bnk -m $out_directory/reads.amos -c\n\n";
        print $fh "tar -cvf $project.bnk.tar $project.bnk\n";
        print $fh "gzip $project.bnk.tar\n";
        close $fh;
        chmod(0755, $sge_submit_script);
        my $sge=ISGA::SGEScheduler->new(
                                        -executable  => {qsub=>'___sge_executables___'.'/qsub -q ___SGE_QUEUE___', qstat=>'___sge_executables___'.'/qstat'},
                                        -output_file => '___tmp_file_directory___'."/workbench/sge_log/newbler2hawkeye_".$time.".sgeout",
                                        -error_file => '___tmp_file_directory___'."/workbench/sge_log/newbler2hawkeye_".$time.".sgeerror",
                                        );

        my $command = "$sge_submit_script";

        $sge->command($command);
        my $pid = $sge->execute();
        X->throw(message => 'Error submitting job.') unless($pid);
        my %sgejob_args =
            (
             Pid => $pid,
             Status => 'Pending',
             Type => ISGA::JobType->new( Name => 'Hawkeye' ),
             CreatedBy => ISGA::Login->getAccount,
             CreatedAt => ISGA::Timestamp->new(),
             NotifyUser => 0
             );

        my $job;
        $job = ISGA::Job->create(%sgejob_args) or X->throw(message => 'Error submitting job.');
        $job->buildConfigFile( project => $project, output_file => "$out_directory/$project.bnk.tar.gz" );
        $job->addInputToCollection($asm_input_file);
        foreach(values %frg_input_files){
            $job->addInputToCollection($_);
        }

        $self->redirect( uri => "/WorkBench/Results/Hawkeye?job=$job" );
    }
    # bounce!!!!!
    $self->_save_arg( 'form', $form);
    $self->redirect( uri => '/WorkBench/CeleraToHawkeye' );

}

#------------------------------------------------------------------------

=item public void MiraToHawkeye();

Convert Mira output for use in Hawkeye

=cut
#------------------------------------------------------------------------
sub WorkBench::MiraToHawkeye {
    my $self = shift;
    my $web_args = $self->args;
    my $form = ISGA::FormEngine::WorkBench->MiraToHawkeye($web_args);

    if ( $form->canceled ) {
        $self->redirect( uri => '/WorkBench/MiraToHawkeye' );
    }

    if ($form->ok) {

        my $project = $form->get_input('project');
        my $ace_upload = $self->apache_req->upload('upload_ace_file');
        my $xml_upload = $self->apache_req->upload('upload_xml_file');
        my $mates_upload = $self->apache_req->upload('upload_mates_file');
        my $file_collection = $form->get_input('collection');

        $project =~ s/ /_/g;
        ## Hardcoded paths.
        my $files_path = "___tmp_file_directory___/workbench/miratohawkeye/";

        my $time = time.$$;
        my $out_directory = $files_path.$time;
        my %args = ( Type => 'Mira Assembler Output' );
        my ($ace_input_file, $xml_input_file, $mates_input_file);

        mkdir($out_directory) or X->throw(message => 'output directory creation failed') if(! -e $out_directory);
        unless ( $file_collection ) {
           $args{Upload} = $ace_upload->fh;
           $args{Format} = 'ACE';
           $args{Username} = basename($ace_upload);
           $ace_input_file = ISGA::Job::Hawkeye->buildQueryFile(%args);
           $ace_input_file->stage($out_directory);

           $args{Upload} = $xml_upload->fh;
           $args{Format} = 'XML';
           $args{Username} = basename($xml_upload);
           $xml_input_file = ISGA::Job::Hawkeye->buildQueryFile(%args);
           $xml_input_file->stage($out_directory);

           $args{Upload} = $mates_upload->fh;
           $args{Format} = 'Bambus Mates';
           $args{Username} = basename($mates_upload);
           $mates_input_file = ISGA::Job::Hawkeye->buildQueryFile(%args);
           $mates_input_file->stage($out_directory);
        }

        my $sge_submit_script = "$out_directory/${time}_sge_hawkeye.sh";

        open my $fh, '>', $sge_submit_script or X->throw(message => 'Error creating sge shell script.');
        print $fh '#!/bin/bash'."\n\n";
        print $fh "cd $out_directory\n\n";
        print $fh "pwd 1>&2\n\n";
        print $fh 'echo "starting toAmos" 1>&2'."\n";
        print $fh "___toAmos_executable___ -m $out_directory/".$mates_input_file->getName()." -ace $out_directory/".$ace_input_file->getName()." -o $out_directory/contigs.amos\n\n";
        print $fh 'echo "starting bambus2amos" 1>&2'."\n";
        print $fh "___scripts_bin___bambus2amos.pl -a $out_directory/contigs.amos -x $out_directory/".$xml_input_file->getName()." -o $out_directory/scaffolds.amos";
        print $fh 'echo "starting banktransact" 1>&2'."\n";
        print $fh "___bank_transact_executable___ -b $out_directory/$project.bnk -m $out_directory/contigs.amos -c\n\n";
        print $fh "___bank_transact_executable___ -b $out_directory/$project.bnk -m $out_directory/scaffolds.amos\n\n";
        print $fh "tar -cvf $project.bnk.tar $project.bnk\n";
        print $fh "gzip $project.bnk.tar\n";
        close $fh;
        chmod(0755, $sge_submit_script);
        my $sge=ISGA::SGEScheduler->new(
                                        -executable  => {qsub=>'___sge_executables___'.'/qsub -q ___SGE_QUEUE___', qstat=>'___sge_executables___'.'/qstat'},
                                        -output_file => '___tmp_file_directory___'."/workbench/sge_log/newbler2hawkeye_".$time.".sgeout",
                                        -error_file => '___tmp_file_directory___'."/workbench/sge_log/newbler2hawkeye_".$time.".sgeerror",
                                        );

        my $command = "$sge_submit_script";

        $sge->command($command);

        my $pid = $sge->execute();

        X->throw(message => 'Error submitting job.') unless($pid);

        my %sgejob_args =
            (
             Pid => $pid,
             Status => 'Pending',
             Type => ISGA::JobType->new( Name => 'Hawkeye' ),
             CreatedBy => ISGA::Login->getAccount,
             CreatedAt => ISGA::Timestamp->new(),
             NotifyUser => 0
             );

        my $job;
        $job = ISGA::Job->create(%sgejob_args) or X->throw(message => 'Error submitting job.');
        $job->buildConfigFile( project => $project, output_file => "$out_directory/$project.bnk.tar.gz" );
        $job->addInputToCollection($ace_input_file);
        $job->addInputToCollection($xml_input_file);
        $job->addInputToCollection($mates_input_file);

        $self->redirect( uri => "/WorkBench/Results/Hawkeye?job=$job" );
    }
    # bounce!!!!!
    $self->_save_arg( 'form', $form);
    $self->redirect( uri => '/WorkBench/MiraToHawkeye' );

}

#------------------------------------------------------------------------

=item public void NewblerScaffold4Consed();

Convert Newbler output for Consed

=cut
#------------------------------------------------------------------------
sub WorkBench::NewblerScaffold4Consed {
    my $self = shift;
    my $web_args = $self->args;
    my $form = ISGA::FormEngine::WorkBench->NewblerScaffold4Consed($web_args);

    if ( $form->canceled ) {
        $self->redirect( uri => '/WorkBench/NewblerScaffoldForConsed' );
    }

    if ($form->ok) {

        my $agp_upload = $self->apache_req->upload('upload_agp_file');
        my $ace_upload = $self->apache_req->upload('upload_ace_file');

        ## Hardcoded paths.
        my $files_path = "___tmp_file_directory___/workbench/newblertoconsed/";

        my $time = time.$$;
        my $out_directory = $files_path.$time;
        my %args = ( Type => 'Newbler Assembler Output' );
        my ($agp_input_file, $ace_input_file);

        mkdir($out_directory) or X->throw(message => 'output directory creation failed') if(! -e $out_directory);
        $args{Upload} = $agp_upload->fh;
        $args{Format} = 'AGP';
        $args{Username} = basename($agp_upload);
        $agp_input_file = ISGA::Job::Consed->buildQueryFile(%args);
        $agp_input_file->stage($out_directory);

        $args{Upload} = $ace_upload->fh;
        $args{Format} = 'ACE';
        $args{Username} = basename($ace_upload);
        $ace_input_file = ISGA::Job::Consed->buildQueryFile(%args);
        $ace_input_file->stage($out_directory);

        my $sge_submit_script = "$out_directory/${time}_sge_newbler4consed.sh";

        open my $fh, '>', $sge_submit_script or X->throw(message => 'Error creating sge shell script.');
        print $fh '#!/bin/bash'."\n\n";
        print $fh "cd $out_directory\n\n";

        print $fh 'echo "starting newbler_scaffold4consed.pl" 1>&2'."\n";
        print $fh "___scripts_bin___newbler_scaffold4consed.pl -a $out_directory/".$agp_input_file->getName()." -i $out_directory/".$ace_input_file->getName()." -o $out_directory/${time}_modified.ace";
        close $fh;
        chmod(0755, $sge_submit_script);
        my $sge=ISGA::SGEScheduler->new(
                                        -executable  => {qsub=>'___sge_executables___'.'/qsub -q ___SGE_QUEUE___', qstat=>'___sge_executables___'.'/qstat'},
                                        -output_file => '___tmp_file_directory___'."/workbench/sge_log/newbler4consed_".$time.".sgeout",
                                        -error_file => '___tmp_file_directory___'."/workbench/sge_log/newbler4consed_".$time.".sgeerror",
                                        );

        my $command = "$sge_submit_script";

        $sge->command($command);

        my $pid = $sge->execute();

        X->throw(message => 'Error submitting job.') unless($pid);

        my %sgejob_args =
            (
             Pid => $pid,
             Status => 'Pending',
             Type => ISGA::JobType->new( Name => 'Consed' ),
             CreatedBy => ISGA::Login->getAccount,
             CreatedAt => ISGA::Timestamp->new(),
             NotifyUser => 0
             );

        my $job;
        $job = ISGA::Job->create(%sgejob_args) or X->throw(message => 'Error submitting job.');
        $job->buildConfigFile( output_file => "$out_directory/${time}_modified.ace" );
        $job->addInputToCollection($ace_input_file);
        $job->addInputToCollection($agp_input_file);

        $self->redirect( uri => "/WorkBench/Results/NewblerForConsed?job=$job" );
    }
    # bounce!!!!!
    $self->_save_arg( 'form', $form);
    $self->redirect( uri => '/WorkBench/NewblerForConsed' );

}


#------------------------------------------------------------------------

=item public void SffToFasta();

Convert SFF files to FASTA

=cut
#------------------------------------------------------------------------
sub WorkBench::SffToFasta {
    my $self = shift;
    my $web_args = $self->args;
    my $form = ISGA::FormEngine::WorkBench->SffToFasta($web_args);

    if ( $form->canceled ) {
        $self->redirect( uri => '/WorkBench/SffToFasta' );
    }

    if ($form->ok) {

        my $sff_upload = $self->apache_req->upload('upload_sff_file');

        ## Hardcoded paths.
        my $files_path = "___tmp_file_directory___/workbench/sfftofasta/";

        my $time = time.$$;
        my $out_directory = $files_path.$time;
        my %args = ( Type => 'Native 454 format' );
        my ($sff_input_file);

        mkdir($out_directory) or X->throw(message => 'output directory creation failed') if(! -e $out_directory);
        my $basename = basename($sff_upload);
        $args{Upload} = $sff_upload->fh;
        $args{Format} = 'SFF';
        $args{Username} = $basename;
        $sff_input_file = ISGA::Job::SffToFasta->buildQueryFile(%args);
        $sff_input_file->stage($out_directory);

        $basename =~s/\.[A-z]+$//;
        my $sge_submit_script = "$out_directory/${time}_sge_sfftofasta.sh";

        open my $fh, '>', $sge_submit_script or X->throw(message => 'Error creating sge shell script.');
        print $fh '#!/bin/bash'."\n\n";

        print $fh "cd $out_directory\n\n";
        print $fh 'echo "starting sffToCa" 1>&2'."\n";
        if ($$web_args{linker} eq 'flx' or $$web_args{linker} eq 'titanium' ){
          print $fh "___sffToCA_executable___ -linker$$web_args{linker} -insertsize \"$$web_args{insertsizeavg} -libraryname $$web_args{library} -clear $$web_args{clear} -trim $$web_args{trim}  $$web_args{insertsizestd}\" -output $out_directory/$basename.frg $out_directory/".$sff_input_file->getName()."\n\n";
        } else {
          print $fh "___sffToCA_executable___  -libraryname $$web_args{library} -clear $$web_args{clear} -trim $$web_args{trim} -output $out_directory/$basename.frg $out_directory/".$sff_input_file->getName()."\n\n";
        }
        print $fh 'echo "starting toAmos" 1>&2'."\n";
        print $fh "___toAmos_executable___ -f $out_directory/$basename.frg -o $out_directory/$basename.afg ".'|| { echo "command failed"; exit 1; }'."\n\n";
        print $fh 'echo "starting amos2sq" 1>&2'."\n";
        print $fh "___amos2sq_executable___ -i $out_directory/$basename.afg -o $out_directory/$basename.fsa ".'|| { echo "command failed"; exit 1; }'."\n";

        close $fh;
        chmod(0755, $sge_submit_script);
        my $sge=ISGA::SGEScheduler->new(
                                        -executable  => {qsub=>'___sge_executables___'.'/qsub -q ___SGE_QUEUE___', qstat=>'___sge_executables___'.'/qstat'},
                                        -output_file => '___tmp_file_directory___'."/workbench/sge_log/sff2fasta_".$time.".sgeout",
                                        -error_file => '___tmp_file_directory___'."/workbench/sge_log/sff2fasta_".$time.".sgeerror",
                                        );

        my $command = "$sge_submit_script";

        $sge->command($command);

        my $pid = $sge->execute();

        X->throw(message => 'Error submitting job.') unless($pid);

        my %sgejob_args =
            (
             Pid => $pid,
             Status => 'Pending',
             Type => ISGA::JobType->new( Name => 'SffToFasta' ),
             CreatedBy => ISGA::Login->getAccount,
             CreatedAt => ISGA::Timestamp->new(),
             NotifyUser => 0
             );

        my $job;
        $job = ISGA::Job->create(%sgejob_args) or X->throw(message => 'Error submitting job.');
        $job->buildConfigFile( output_file => "$out_directory/$basename.fsa.seq", output_type => "Genome Sequence", output_format => "FASTA" );
        $job->addInputToCollection($sff_input_file);

        $self->redirect( uri => "/WorkBench/Results/SffToFasta?job=$job" );
    }
    # bounce!!!!!
    $self->_save_arg( 'form', $form);
    $self->redirect( uri => '/WorkBench/SffToFasta' );

}


1;


__END__
