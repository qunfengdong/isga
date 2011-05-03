
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

=item public void EditMyDetails();

Edit account details.

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
	my $database_path = '___database_path___';
	my $files_path = '___tmp_file_directory___'."/workbench/blast/";
	my $pipeline_path = '___ergatis_output_repository___'.'cgb_format/';
	my %hash = (
		    "pro.nr" => $database_path."NCBI-nr/nr-09-20-2009/nr",
		    "nuc.nt" => $database_path."NCBI-nr/nr-09-20-2009/nt",
		    "pro.uniref" => $database_path."Asgard/asgard_data-09-23-2009/UniRef100",
		    "nuc.uniref" => '',
		    "pro.allgroup" => $database_path."NIAA/NIAA-07-27-2009/AllGroup.niaa",
		    "nuc.allgroup" => $database_path."NIAA/NIAA-07-27-2009/AllGroup.fasta",
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
					-executable  => {qsub=>'___sge_executables___'.'/qsub -q seq', qstat=>'___sge_executables___'.'/qstat'},
					-output_file => '___tmp_file_directory___'."/workbench/sge_log/blast_".$time.".sgeout",
					-error_file => '___tmp_file_directory___'."/workbench/sge_log/blast_".$time.".sgeerror",
					);
	
	my $inpath = $input_file->getPath;
	my $runpath = $files_path.$time.'_blast_input';
	copy($inpath, $runpath) or X->throw(message => 'Cannot copy file to tmp directory');
	
	system("___cdbfasta_executable___ -C $runpath") == 0 or X->throw(message => 'cdbfasta failed');
	
	my $command = "___blast_executable___ -p $blast_program -i $runpath -o $blast_output -e $evalue -d \"$database\" -F $blastfilter";
	#warn "command - $command";
	
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
	$job->buildConfigFile( input => $input_file->getId, web_args => $web_args, databases => \@database_array, input_file => $runpath, output_file => $blast_output );
	
	$self->redirect( uri => "/WorkBench/Results/Blast?job=$job" );
    }
    # bounce!!!!!
    $self->_save_arg( 'form', $form);
    $self->redirect( uri => '/WorkBench/Blast' );
    
}

####################################################
## WorkBench :: MSA
##
####################################################
sub WorkBench::MSA {
    my $self = shift;
    my $web_args = $self->args;
    my $form = ISGA::FormEngine::WorkBench->MSA($web_args);

	if ($form->canceled){
		$self->redirect(uri => '/WorkBench/MSA');
	}
	if ($form->ok){
		
		my $time = time.$$;
		## Hard coded path
		my $files_path = '___tmp_file_directory___'."workbench/msa/";
		my $pipeline_path = '___ergatis_output_repository___'.'cgb_format/';
		##

		my $sequence_type = $form->get_input('sequence_type');
		my $output_format = $form->get_input('output_format');
		my $output_tree = $form->get_input('output_tree');
		my $weight_matrix = $form->get_input('weight_matrix');
		my $alignment = $form->get_input('alignment');
		my $gap_open = $form->get_input('gap_open');
		my $gap_extension = $form->get_input('gap_extension');

		my $upload = $self->apache_req->upload('upload_file');
		#my $upload = '';
		my $sequences = $form->get_input('query_sequence');

		my %args = ();
		$upload and $args{Upload} = $upload->fh;
		$sequences and $args{String} = $sequences;
		my $input_file = ISGA::Job::MSA->buildQueryFile(%args);


		my $sge = ISGA::SGEScheduler->new(
			-executable => {qsub=>'/cluster/sge/bin/sol-amd64/qsub -q seq', qstat=>'/cluster/sge/bin/sol-amd64/qstat'},
			-output_file => '___tmp_file_directory___'."workbench/sge_log/msa_".$time.".sgeout",
			-error_file => '___tmp_file_directory___'."workbench/sge_log/msa_".$time.".sgeerror",
		);

		my $inpath = $input_file->getPath;
		my $runpath = $files_path.$time.'_msa_input';
		my $outfile = $files_path.$time.'_msa_output';
		copy($inpath, $runpath) or X::File->throw(error => 'Cannot copy file to tmp directory');

		my $command = "/bioportal/sw/bin/clustalw -INFILE=$runpath -type=$sequence_type -MATRIX=$weight_matrix -OUTFILE=$outfile";
		$command .= " -tree -outputtree=$output_tree -bootstrap=1000 " if ($output_tree ne "none");
		$command .= " -OUTPUT=$output_format" if ($output_format ne "def");

		$sge->command($command);
		my $pid = $sge->execute();

		my %sgejob_args = 
			(
			Pid => $pid,
			Status => 'Pending',
			Type => ISGA::JobType->new(Name => 'MSA'),
			CreatedBy => ISGA::Login->getAccount,
			CreatedAt => ISGA::Timestamp->new(),
			NotifyUser => 0
			);

		my $jobid;
		$jobid = ISGA::Job->create(%sgejob_args) or X->throw(message => 'Error submitting job.');
		$jobid->addInputToCollection($input_file);
		$jobid->buildConfigFile( input => $input_file->getId, web_args => $web_args, input_file => $time, files_path => $files_path );

		$self->redirect( uri => "/WorkBench/Results/MSA?jobid=$jobid");

	}
	# bounce!!!!
	$self->_save_arg( 'form', $form);
	$self->redirect( uri => '/WorkBench/MSA' );
}


#####################################################
## ProtDist
#####################################################

sub WorkBench::ProtDist {
	my $self = shift;
	my $web_args = $self->args;
	my $form = ISGA::FormEngine::WorkBench->ProtDist($web_args);
	
	my $infile = $form->get_input('infile');
	my $files_path = '___tmp_file_directory___'.'workbench/msa/';
	my $neighbor_infile;

	# Below commands might me need if they resubmit the same infile.
	my $dist_infile = $files_path.$infile."_msa_output";
	my $dist_outfile = $files_path.$infile."_dist_outfile";
	my $dist_outtree = $files_path.$infile."_dist_outtree";
	my $neighbor_outfile = $files_path.$infile.'_neighbor_outfile';
	my $neighbor_outtree = $files_path.$infile.'_neighbor_outtree';	
	`rm $dist_outfile` if(-e $dist_outfile);
	`rm $dist_outtree` if(-e $dist_outtree);
	`rm $neighbor_outfile` if (-e $neighbor_outfile);
	`rm $neighbor_outtree` if (-e $neighbor_outtree);

	## Danger
	## Danger
	## Danger
	## Danger
	## Remove the below line 
	## This is here only because the protpars was giving problem with 'U' in the file
	## God knows why.
	`sed -e s/U/A/g $dist_infile > $dist_infile.old; mv $dist_infile.old $dist_infile`;

	my $dist_options ='';
	my @dist_array = ('P', 'G', 'W', 'M');
	my $key;
	my $code;
	foreach $code (@dist_array){
		$key = $form->get_input($code);
		#warn "checking key (dist) here $key";
		if ($key ne 'def'){
			#warn "key key key = $key <<<<<<< $code";
			$dist_options .= $key."x";
			$dist_options .= $form->get_input('datasets')."x" if($code eq 'M');
		}
	}
	$dist_options .= "Y";
	#warn "options : $dist_options";
	$dist_options = "Y";

	my $neighbor_options ='';
	my @neighbor_array = ('N', 'L', 'R', 'S');
	foreach $code (@neighbor_array){
		$key = $form->get_input($code);
		if ($key ne 'def'){
			#warn "key key key = $key <<<<<<< $code";
			$neighbor_options .= $key."x";
		}
	}
	$neighbor_options .= "Y";
	#warn "neighbor options - '$neighbor_options'";


	if($form->canceled){
		$self->redirect( uri => '/WorkBench/ProtDist');
	}
	if ($form->ok){
		my $script_path = '___scripts_bin___';
		my $exec_script = $script_path.'runProtDist.pl';
		my $exec_neighbor = $script_path.'runNeighbor.pl';

		my $command = "
			perl $exec_script -i $dist_infile -c $dist_options; 
			perl $exec_neighbor -i $dist_outfile -c $neighbor_options;
			";
		#warn $command;

		my $time = time . $$;
		my $sge = ISGA::SGEScheduler->new(
			-executable => {qsub=>'/cluster/sge/bin/sol-amd64/qsub -q seq', qstat=>'/cluster/sge/bin/sol-amd64/qstat'},
			-output_file => '___tmp_file_directory___'."workbench/sge_log/phylip_".time.$$.".sgeout",
			-error_file => '___tmp_file_directory___'."workbench/sge_log/phylip_".time.$$.".sgeerror"
		);
		
		$sge->command($command);
		my $pid = $sge->execute();

		my %sgejob_args =
			(
			Pid => $pid,
			Status => 'Pending',
			Type => ISGA::JobType->new(Name => 'MSA'),
			CreatedBy => ISGA::Login->getAccount,
			CreatedAt => ISGA::Timestamp->new(),
			NotifyUser => 0
			);

		my $jobid;
		if($pid){
			$jobid = ISGA::Job->create(%sgejob_args);
    
		} else {
			$self->redirect( uri => "/Error" );
		}


		$self->redirect( uri => "/WorkBench/Results/ProtDist?jobid=$jobid&infile=$infile");
	}


	# bounce!!!!
	$self->_save_arg( 'form', $form);
	$self->redirect( uri => '/WorkBench/MSA' );
}

#####################################################
## DnaDist
#####################################################

sub WorkBench::DnaDist {
	my $self = shift;
	my $web_args = $self->args;
	my $form = ISGA::FormEngine::WorkBench->DnaDist($web_args);

	my $infile = $form->get_input('infile');
	my $files_path = '___tmp_file_directory___'.'/workbench/msa/';
	my $neighbor_infile;

	# Below commands might me need if they resubmit the same infile.
	my $dist_infile = $files_path.$infile."_msa_output";
  my $dist_outfile = $files_path.$infile."_dist_outfile";
	my $dist_outtree = $files_path.$infile."_dist_outtree";
	my $neighbor_outfile = $files_path.$infile.'_neighbor_outfile';
	my $neighbor_outtree = $files_path.$infile.'_neighbor_outtree';	
	`rm $dist_outfile` if(-e $dist_outfile);
	`rm $dist_outtree` if(-e $dist_outtree);
	`rm $neighbor_outfile` if (-e $neighbor_outfile);
	`rm $neighbor_outtree` if (-e $neighbor_outtree);

	## Danger
	## Danger
	## Danger
	## Danger
	## Remove the below line 
	## This is here only because the protpars was giving problem with 'U' in the file
	## God knows why.
	`sed -e s/U/A/g $dist_infile > $dist_infile.old; mv $dist_infile.old $dist_infile`;

	my $dist_options ='';
	my @dist_array = ('D', 'L_dist', 'W', 'M'); ## dist is added because there is L in both the forms
	my $key;
	my $code;
	foreach $code (@dist_array){
		$key = $form->get_input($code);
		#warn "key from code : ($key) ($code)";
		if ($key ne 'def'){
			#warn "key key key = $key <<<<<<< $code";
			$dist_options .= $key."x";
			$dist_options .= $form->get_input('datasets')."x" if($code eq 'M');
		}
	}
	$dist_options .= "Y";
	#warn "options : $dist_options";
	$dist_options = "Y";

	my $neighbor_options ='';
	my @neighbor_array = ('N', 'L', 'R', 'S');
	foreach $code (@neighbor_array){
		$key = $form->get_input($code);
		if ($key ne 'def'){
			#warn "key key key = $key <<<<<<< $code";
			$neighbor_options .= $key."x";
		}
	}
	$neighbor_options .= "Y";
	#warn "neighbor options - '$neighbor_options'";


	if($form->canceled){
		$self->redirect( uri => '/WorkBench/ProtDist');
	}
	if ($form->ok){
		my $script_path = '___scripts_bin___';
		my $exec_script = $script_path.'runDnaDist.pl';
		my $exec_neighbor = $script_path.'runNeighbor.pl';

		my $command = "
			perl $exec_script -i $dist_infile -c $dist_options; 
			perl $exec_neighbor -i $dist_outfile -c $neighbor_options;
			";
		#warn $command;

		my $time = time . $$;
		my $sge = ISGA::SGEScheduler->new(
			-executable => {qsub=>'/cluster/sge/bin/sol-amd64/qsub -q seq', qstat=>'/cluster/sge/bin/sol-amd64/qstat'},
			-output_file => '___tmp_file_directory___'."workbench_sge/phylip_$time.sgeout",
			-error_file => '___tmp_file_directory___'."workbench_sge/phylip_$time.sgeerror"
		);
		
		$sge->command($command);
		my $pid = $sge->execute();

		my %sgejob_args =
			(
			Pid => $pid,
			Status => 'Pending',
			Type => ISGA::JobType->new(Name => 'MSA'),
			CreatedBy => ISGA::Login->getAccount,
			CreatedAt => ISGA::Timestamp->new(),
			NotifyUser => 0
			);

		my $jobid;
		if($pid){
			$jobid = ISGA::Job->create(%sgejob_args);
    
		} else {
			$self->redirect( uri => "/Error" );
		}


		$self->redirect( uri => "/WorkBench/Results/DnaDist?jobid=$jobid&infile=$infile");
	}


	# bounce!!!!
	$self->_save_arg( 'form', $form);
	$self->redirect( uri => '/WorkBench/MSA' );
}
#------------------------------------------------------------------------

=item public void Notify();

Update Hide and Show walkthrough 

=cut
#------------------------------------------------------------------------
sub WorkBench::Notify{
  my $self = shift;
  my $web_args = $self->args;
  my $account = ISGA::Login->getAccount;
  my $job = $web_args->{job};
  $job->edit( NotifyUser => 1 );
  $self->redirect( uri => "/WorkBench/Results/Blast?job=$job" );
}

	

1;


__END__

#####################################################
## ProtPars
#####################################################
sub WorkBench::ProtPars {
	my $self = shift;
	my $web_args = $self->args;
	my $form = ISGA::FormEngine::WorkBench->ProtPars($web_args);

	my $infile = $form->get_input('infile');

	## Danger
	## Danger
	## Danger
	## Danger
	## Remove the below line 
	## This is here only because the protpars was giving problem with 'U' in the file
	## God knows why.
	`sed -e s/U/A/g $infile > $infile.old; mv $infile.old $infile`;

	# Below commands might me need if they resubmit the same infile.
  my $outfile_present = $infile."_protpars_output";
	my $outtree_present = $infile."_protpars_tree";
	`rm $outfile_present` if(-e $outfile_present);
	`rm $outtree_present` if(-e $outtree_present);
	## Danger
	## Danger
	# delete till here.

	my $options ='';
	my $key = $form->get_input('C');
	if($key ne 'U'){
		$options .= "Cx".$key."x";
	}
	$options .= "Y";
		

	if($form->canceled){
		$self->redirect( uri => '/WorkBench/ProtPars');
	}
	if ($form->ok){
		my $script_path = '___scripts_bin___';
		my $perl_file = $script_path.'runProtPars.pl';
		my $files_path = '___tmp_file_directory___'.'/workbench/phylip/';

		my $command = "perl $perl_file -i $infile -c $options";

		my $time = time . $$;
		my $sge = ISGA::SGEScheduler->new(
			-executable => {qsub=>'/cluster/sge/bin/sol-amd64/qsub -q seq', qstat=>'/cluster/sge/bin/sol-amd64/qstat'},
			-output_file => '___tmp_file_directory___'."workbench_sge/phylip_$time.sgeout",
			-error_file => '___tmp_file_directory___'."workbench_sge/phylip_$time.sgeerror"
		);
		
		$sge->command($command);
		my $pid = $sge->execute();

		my %sgejob_args =
			(
			Pid => $pid,
			Status => 'Pending',
			Type => ISGA::JobType->new(Name => 'MSA'),
			CreatedBy => ISGA::Login->getAccount,
			CreatedAt => ISGA::Timestamp->new(),
			NotifyUser => 0
			);

		my $jobid;
		if($pid){
			$jobid = ISGA::Job->create(%sgejob_args);
    
		} else {
			$self->redirect( uri => "/Error" );
		}


		$self->redirect( uri => "/WorkBench/Results/ProtPars?jobid=$jobid&infile=$time");
	}

	# bounce!!!!
	$self->_save_arg( 'form', $form);
	$self->redirect( uri => '/WorkBench/MSA' );

}

#####################################################
## ProtML
#####################################################

sub WorkBench::ProtML {
	my $self = shift;
	my $web_args = $self->args;
	my $form = ISGA::FormEngine::WorkBench->ProtML($web_args);
	
	my $file
	my $infile = $form->get_input('infile');

	## Danger
	## Danger
	## Danger
	## Danger
	## Remove the below line 
	## This is here only because the protpars was giving problem with 'U' in the file
	## God knows why.
	`sed -e s/U/A/g $infile > $infile.old; mv $infile.old $infile`;

	# Below commands might me need if they resubmit the same infile.
  my $outfile_present = $infile."_protml_output";
	my $outtree_present = $infile."_protml_tree";
	`rm $outfile_present` if(-e $outfile_present);
	`rm $outtree_present` if(-e $outtree_present);
	## Danger
	## Danger
	# delete till here.

	my $options ='';
	#my $key = $form->get_input('C');
	#if($key ne 'U'){
	#	$options .= "Cx".$key."x";
	#}
	$options .= "Y";
		

	if($form->canceled){
		$self->redirect( uri => '/WorkBench/ProtML');
	}
	if ($form->ok){
		my $script_path = '___scripts_bin___';
		my $perl_file = $script_path.'runProtML.pl';
		my $files_path = '___tmp_file_directory___'."workbench/phylip/";

		my $command = "perl $perl_file -i $infile -c $options";

		my $time = time . $$;
		my $sge = ISGA::SGEScheduler->new(
			-executable => {qsub=>'/cluster/sge/bin/sol-amd64/qsub -q seq', qstat=>'/cluster/sge/bin/sol-amd64/qstat'},
			-output_file => '___tmp_file_directory___'."workbench_sge/phylip_$time.sgeout",
			-error_file => '___tmp_file_directory___'."workbench_sge/phylip_$time.sgeerror"
		);
		
		$sge->command($command);
		my $pid = $sge->execute();

		my %sgejob_args =
			(
			Pid => $pid,
			Status => 'Pending',
			Type => ISGA::JobType->new(Name => 'MSA'),
			CreatedBy => ISGA::Login->getAccount,
			CreatedAt => ISGA::Timestamp->new(),
			NotifyUser => 0
			);

		my $jobid;
		if($pid){
			$jobid = ISGA::Job->create(%sgejob_args);
    
		} else {
			$self->redirect( uri => "/Error" );
		}


		$self->redirect( uri => "/WorkBench/Results/ProtML?jobid=$jobid&infile=$infile");
	}


	# bounce!!!!
	$self->_save_arg( 'form', $form);
	$self->redirect( uri => '/WorkBench/MSA' );
}
