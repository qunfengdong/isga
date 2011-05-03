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
	} else {
		my $sequences = $form->get_input('query_sequence');
		my $upload = $self->apache_req->upload('upload_file');
		#my $upload = '';

		## Hardcoded paths
		my $database_path = '/research/projects/sysmicro/db/';
		my $files_path = '/data/web/sysmicro.cgb/repository/blastserver/';
		#-

		my $e_value = $form->get_input('e_value');
		my $blast_program = $form->get_input('blast_program');
		my $alignment_view = $form->get_input('alignment_view');
		my @sequence_database = $form->get_input('sequence_database');
		warn " ++++++  @sequence_database\n";

		my $output_file = 'kashi_output3';
		my $upload_file = $files_path.'kashi_test3';
		my $blout = $files_path.$output_file;
		my $database = '';
		my $database_dir = '';
		foreach my $dir (@sequence_database) {
			warn $dir;
			$database_dir .= $database_path.$dir."/";
			$database_dir .= "uniref100.fasta " if ($dir eq "asgard");
			$database_dir .= "nr " if($dir eq "nr");
			$database_dir .= "AllGroup.niaa " if ($dir eq "all_group");
		}
		$database .= "\"$database_dir\" ";

		warn $database;

		if ( $upload ) {
			open ( UPLOADFILE, ">$upload_file") or die "$!";
			binmode UPLOADFILE;
			my $fileHandle = $upload->fh;
			while (<$fileHandle>)  {
				print UPLOADFILE;
			}
			close UPLOADFILE;
		} else {
			open (FILE, ">$upload_file");
			print FILE $sequences;
			close FILE;
		}
                my $time = time;
		my $sge=SysMicro::SGEScheduler->new(
			-executable  => {qsub=>'/cluster/sge/bin/sol-amd64/qsub', qstat=>'/cluster/sge/bin/sol-amd64/qstat'},
			-output_file => "/research/projects/sysmicro/ergatis/tmp/workbench_sge/blast_$time.sgeout",
			-error_file => "/research/projects/sysmicro/ergatis/tmp/workbench_sge/blast_$time.sgeerror",
			);

		#system("/bioportal/sw/bin/blastall -p $blast_program -i $upload_file -o $blout -e $e_value -d $database");
		my $command = "/bioportal/sw/bin/blastall -p $blast_program -i $upload_file -o $blout -e $e_value -d $database";
		$sge->command($command);
		my $pid = $sge->execute();
                warn "SGE pid --- $pid\n";

                my %sgejob_args =
                (
                 Pid => $pid,
                 Status => 'Pending',
                 Type => SysMicro::JobType->new( Name => 'Blast' ),
                 CreatedBy => SysMicro::Login->getAccount,
                 CreatedAt => SysMicro::Timestamp->new(),
                );

                my $sgejob = SysMicro::Job->create(%sgejob_args);

	
		$self->redirect( uri => "/WorkBench/Results/Blast?blout=$output_file&sgejob=$sgejob" );
	}
	# bounce!!!!!
	$self->_save_arg( 'form', $form);
	$self->redirect( uri => '/Account/ChangeMyPassword' );
	
}

1;
