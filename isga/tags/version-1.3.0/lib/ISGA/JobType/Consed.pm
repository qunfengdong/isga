package ISGA::JobType::Consed;
#------------------------------------------------------------------------

=head1 NAME

<ISGA::JobType::Consed> provides methods for working with Consed jobs.


=head1 SYNOPSIS

=head1 DESRIPTION

=head1 METHODS

=over

=cut
#------------------------------------------------------------------------

use base 'ISGA::Job';
use File::Basename;

{

#------------------------------------------------------------------------

=item public File buildForm( );

Build the appropriate FormEngine data structure for this Job.

=cut
#------------------------------------------------------------------------

sub buildForm {
  my ($self, $args) = @_;

  my $form = ISGA::FormEngine->new($args);
  $form->set_skin_obj('ISGA::FormEngine::SkinUniform');

  my @form_params =
    (
     {
      templ => 'fieldset',
      TITLE => 'Newbler Scaffold for Consed',
      sub =>
      [  
       {
        ERROR => ['Hawkeye::checkUploadFile'],
        TITLE => 'Provide ACE file',
        NAME => 'upload_ace_file',
        templ => 'upload'
       },
       {
        ERROR => ['Hawkeye::checkUploadFile'],
        TITLE => 'Provide AGP file',
        NAME => 'upload_agp_file',
        templ => 'upload'
       },
      ]
      },
    );

  return \@form_params;
}

#------------------------------------------------------------------------

=item public Form Job buildWebAppCommand( form=>$form, job=>$job );

Build the appropriate WebApp command for this Job.

=cut
#------------------------------------------------------------------------

sub buildWebAppCommand {
        use File::Path;
        my ($self, $webapp, $form, $job) = @_;

        my $web_args = $webapp->args;
        my $agp_upload = $webapp->apache_req->upload('upload_agp_file');
        my $ace_upload = $webapp->apache_req->upload('upload_ace_file');

        ## Hardcoded paths.
#        my $files_path = "___tmp_file_directory___/workbench/newblertoconsed/";
        my $files_path = "___tmp_file_directory___/workbench/" . $job->getType->getName . "/";
        umask(0);
        mkpath($files_path );

        my $log_name  = $job->getType->getName . "_" .  $job->getId;
        my $out_directory = $files_path.$log_name;
        my %args = ( Type => 'Newbler Assembler Output' );
        my ($agp_input_file, $ace_input_file);

        mkdir($out_directory) or X->throw(message => 'output directory creation failed') if(! -e $out_directory);
        $args{Upload} = $agp_upload->fh;
        $args{Format} = 'AGP';
        $args{Username} = basename($agp_upload);
        $agp_input_file = $job->buildQueryFile(%args);
        $agp_input_file->stage($out_directory);

        $args{Upload} = $ace_upload->fh;
        $args{Format} = 'ACE';
        $args{Username} = basename($ace_upload);
        $ace_input_file = $job->buildQueryFile(%args);
        $ace_input_file->stage($out_directory);

        my $sge_submit_script = "$out_directory/${log_name}_sge.sh";

        open my $fh, '>', $sge_submit_script or X->throw(message => 'Error creating sge shell script.');
        print $fh '#!/bin/bash'."\n\n";
        print $fh "cd $out_directory\n\n";

        print $fh 'echo "starting newbler_scaffold4consed.pl" 1>&2'."\n";
        print $fh "___scripts_bin___newbler_scaffold4consed.pl -a $out_directory/".$agp_input_file->getName()." -i $out_directory/".$ace_input_file->getName()." -o $out_directory/${log_name}_modified.ace";
        close $fh;
        chmod(0755, $sge_submit_script);

        my $command = "$sge_submit_script";

        my $config = {};
        $config->{job_id} = $job->getId;
        $config->{output_file} = "$out_directory/${log_name}_modified.ace";
        $job->buildConfigFile( $config );

        $job->addInputToCollection($ace_input_file);
        $job->addInputToCollection($agp_input_file);



  return $command;
}

#------------------------------------------------------------------------

=item public File getOutputFormat( );

Return the appropriate output format for this job type.

=cut
#------------------------------------------------------------------------

sub getOutputFormat {
  my ($self, $args) = @_;
  return 'ACE';
}
#------------------------------------------------------------------------

=item public File getOutputType( );

Return the appropriate output type for this job type.

=cut
#------------------------------------------------------------------------

sub getOutputType {
  my ($self, $args) = @_;
  return 'Consed Input';
}

}

1;

__END__

=back

=head1 DIAGNOSTICS

=over 4

=back

=head1 AUTHOR

Center for Genomics and Bioinformatics, biohelp@cgb.indiana.edu

=cut
