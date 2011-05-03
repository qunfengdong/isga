## no critic
# we turn off perl critic because we package doesn't match file
package SysMicro::WebApp;
## use critic
#------------------------------------------------------------------------

=head1 NAME

SysMicro::WebApp manages the interface to MASON for SysMicro.

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
	my $form = SysMicro::FormEngine::WorkBench->Blast($web_args);

	if ( $form->canceled ) {
		$self->redirect( uri => '/WorkBench/Blast' );
	} 
  
	if ($form->ok) {
		my $sequences = $form->get_input('query_sequence');
		my $upload = $self->apache_req->upload('upload_file');
		#my $upload = "";

		## Hardcoded paths.
		my $database_path = '___database_path___';
		my $files_path = '___tmp_file_directory___'."workbench/blast/";
		my $pipeline_path = '___ergatis_output_repository___'.'cgb_format/';
		my %hash = (
								"pro.nr" => $database_path."NCBI-nr/nr-09-20-2009/nr",
								"nuc.nt" => $database_path."NCBI-nr/nr-09-20-2009/nt",
								"pro.uniref" => $database_path."Asgard/asgard_data-09-23-2009/UniRef100",
								"nuc.uniref" => '',
								"pro.allgroup" => $database_path."NIAA/NIAA-07-27-2009/AllGroup.niaa",
								"nuc.allgroup" => $database_path."NIAA/NIAA-07-27-2009/AllGroup.fasta",
							);


		my $e_value = $form->get_input('e_value');
		my $blast_program = $form->get_input('blast_program');
		my $sequence_database = $form->get_input('sequence_database');
		ref($sequence_database) eq 'ARRAY' or $sequence_database = [ $sequence_database ];
		
		my $time = time.$$;
		my $blast_output = $files_path.$time.'_blast_output';

		my @database_array;
		foreach (@$sequence_database){
			if (($blast_program eq "blastp") or ($blast_program eq "tblastn")){
				#warn "display me - '$_'";
				if ($_ =~ /[0-9]/){
					push(@database_array, $pipeline_path.$_."_workbench_prot/".$_."_run_result_prot_db");
				}else {
					push(@database_array, $hash{"pro.$_"});
				}
			} else {
				if ($_ =~ /[0-9]/){
					push(@database_array, $pipeline_path.$_."_workbench_nuc/".$_."_run_result_nuc_db");
				} else {
					push(@database_array, $hash{"nuc.$_"});
				}
			}
		}

		my $database = join(' ', @database_array);
		my %args = ( );
		
		$upload and $args{Upload} = $upload->fh;
		$sequences and $args{String} = $sequences;
		my $input_file = SysMicro::Job::BLAST->buildQueryFile(%args);

		my $sge=SysMicro::SGEScheduler->new(
			-executable  => {qsub=>'/cluster/sge/bin/sol-amd64/qsub -q seq', qstat=>'/cluster/sge/bin/sol-amd64/qstat'},
			-output_file => '___tmp_file_directory___'."workbench/sge_log/blast_".$time.".sgeout",
			-error_file => '___tmp_file_directory___'."workbench/sge_log/blast_".$time.".sgeerror",
			);

		my $inpath = $input_file->getPath;
		my $runpath = $files_path.$time.'_blast_input';
		copy($inpath, $runpath) or X->throw(message => 'Cannot copy file to tmp directory');

		system("/bioportal/sw/bin/cdbfasta -C $runpath") == 0 or warn "cdbfasta failed: $!\n";

		my $command = "/bioportal/sw/bin/blastall -p $blast_program -i $runpath -o $blast_output -e $e_value -d \"$database\"";
		warn "----> $command";
		$sge->command($command);
		my $pid = $sge->execute();
		my %sgejob_args =
    	(
      Pid => $pid,
      Status => 'Pending',
      Type => SysMicro::JobType->new( Name => 'Blast' ),
      CreatedBy => SysMicro::Login->getAccount,
      CreatedAt => SysMicro::Timestamp->new(),
      NotifyUser => 0
      );
		
		my $jobid;
		$jobid = SysMicro::Job->create(%sgejob_args) or X->throw(message => 'Error submitting job.');
		$jobid->addInputToCollection($input_file);
		$jobid->buildConfigFile( input => $input_file->getId, web_args => $web_args, databases => \@database_array, input_file => $runpath, output_file => $blast_output );

		$self->redirect( uri => "/WorkBench/Results/Blast?jobid=$jobid" );
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
	my $form = SysMicro::FormEngine::WorkBench->MSA($web_args);

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
		my $sequences = $form->get_input('query_sequence');

		my %args = ();
		$upload and $args{Upload} = $upload->fh;
		$sequences and $args{String} = $sequences;
		my $input_file = SysMicro::Job::MSA->buildQueryFile(%args);


		my $sge = SysMicro::SGEScheduler->new(
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

		warn ">>>> MSA command: $command"; 
		$sge->command($command);
		my $pid = $sge->execute();

		my %sgejob_args = 
			(
			Pid => $pid,
			Status => 'Pending',
			Type => SysMicro::JobType->new(Name => 'MSA'),
			CreatedBy => SysMicro::Login->getAccount,
			CreatedAt => SysMicro::Timestamp->new(),
			NotifyUser => 0
			);

		my $jobid;
		$jobid = SysMicro::Job->create(%sgejob_args) or X->throw(message => 'Error submitting job.');
		$jobid->addInputToCollection($input_file);
		$jobid->buildConfigFile( input => $input_file->getId, web_args => $web_args, input_file => $time, files_path => $files_path );
use Data::Dumper;
warn Dumper($jobid);
		$self->redirect( uri => "/WorkBench/Results/MSA?jobid=$jobid");

	}
	# bounce!!!!
	$self->_save_arg( 'form', $form);
	$self->redirect( uri => '/WorkBench/MSA' );
}

=comment
#####################################################
## ProtPars
#####################################################
sub WorkBench::ProtPars {
	my $self = shift;
	my $web_args = $self->args;
	my $form = SysMicro::FormEngine::WorkBench->ProtPars($web_args);

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
		my $sge = SysMicro::SGEScheduler->new(
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
			Type => SysMicro::JobType->new(Name => 'MSA'),
			CreatedBy => SysMicro::Login->getAccount,
			CreatedAt => SysMicro::Timestamp->new(),
			NotifyUser => 0
			);

		my $jobid;
		if($pid){
			$jobid = SysMicro::Job->create(%sgejob_args);
    
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
	my $form = SysMicro::FormEngine::WorkBench->ProtML($web_args);
	
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
		my $sge = SysMicro::SGEScheduler->new(
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
			Type => SysMicro::JobType->new(Name => 'MSA'),
			CreatedBy => SysMicro::Login->getAccount,
			CreatedAt => SysMicro::Timestamp->new(),
			NotifyUser => 0
			);

		my $jobid;
		if($pid){
			$jobid = SysMicro::Job->create(%sgejob_args);
    
		} else {
			$self->redirect( uri => "/Error" );
		}


		$self->redirect( uri => "/WorkBench/Results/ProtML?jobid=$jobid&infile=$infile");
	}


	# bounce!!!!
	$self->_save_arg( 'form', $form);
	$self->redirect( uri => '/WorkBench/MSA' );
}
=cut

#####################################################
## ProtDist
#####################################################

sub WorkBench::ProtDist {
	my $self = shift;
	my $web_args = $self->args;
	my $form = SysMicro::FormEngine::WorkBench->ProtDist($web_args);
	
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
		my $sge = SysMicro::SGEScheduler->new(
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
			Type => SysMicro::JobType->new(Name => 'MSA'),
			CreatedBy => SysMicro::Login->getAccount,
			CreatedAt => SysMicro::Timestamp->new(),
			NotifyUser => 0
			);

		my $jobid;
		if($pid){
			$jobid = SysMicro::Job->create(%sgejob_args);
    
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
	my $form = SysMicro::FormEngine::WorkBench->DnaDist($web_args);

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
		my $sge = SysMicro::SGEScheduler->new(
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
			Type => SysMicro::JobType->new(Name => 'MSA'),
			CreatedBy => SysMicro::Login->getAccount,
			CreatedAt => SysMicro::Timestamp->new(),
			NotifyUser => 0
			);

		my $jobid;
		if($pid){
			$jobid = SysMicro::Job->create(%sgejob_args);
    
		} else {
			$self->redirect( uri => "/Error" );
		}


		$self->redirect( uri => "/WorkBench/Results/DnaDist?jobid=$jobid&infile=$infile");
	}


	# bounce!!!!
	$self->_save_arg( 'form', $form);
	$self->redirect( uri => '/WorkBench/MSA' );
}

	

1;
