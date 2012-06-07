package ISGA::JobType::MiraToHawkeye;
#------------------------------------------------------------------------

=head1 NAME

<ISGA::JobType::Hawkeye> provides methods for working with Hawkeye jobs.


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
      TITLE => 'Mira to Hawkeye',
      sub =>
      [  
       {
        NAME => 'project',
        TITLE => 'Project Name',
        SIZE => 60,
        MAXLEN => 60,
        REQUIRED => 1,
        ERROR => 'not_null',
       },
       {
        ERROR => ['Hawkeye::checkUploadFile'],
        TITLE => 'Provide ACE file',
        NAME => 'upload_ace_file',
        templ => 'upload'
       },
       {
        ERROR => ['Hawkeye::checkUploadFile'],
        TITLE => 'Provide Traceinfo XML file',
        NAME => 'upload_xml_file',
        templ => 'upload'
       },
       {
        ERROR => ['Hawkeye::checkUploadFile'],
        TITLE => 'Provide Bambus Mates file',
        NAME => 'upload_mates_file',
        templ => 'upload'
       },
       {
        'TITLE' => 'Email me when job completes',
        'NAME' => 'notify_user',
        'templ' => 'check',
        'VALUE' => 0,
        'OPT_VAL' => 1,
        'OPTION' => '',
        'HINT' => 'Check this box to receive email notification when your job completes.'
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
        my $project = $form->get_input('project');
        my $ace_upload = $webapp->apache_req->upload('upload_ace_file');
        my $xml_upload = $webapp->apache_req->upload('upload_xml_file');
        my $mates_upload = $webapp->apache_req->upload('upload_mates_file');
        my $file_collection = $form->get_input('collection');

        $project =~ s/ /_/g;
        ## Hardcoded paths.
        my $tmp_dir = ISGA::SiteConfiguration->value('shared_tmp');
        my $files_path = "$tmp_dir/workbench/" . $job->getType->getName . "/";
        umask(0);
        mkpath($files_path );

        my $log_name  = $job->getType->getName . "_" .  $job->getId;
#        my $time = time.$$;
        my $out_directory = $files_path.$log_name;
        my %args = ( Type => 'Mira Assembler Output' );
        my ($ace_input_file, $xml_input_file, $mates_input_file);

        mkdir($out_directory) or X->throw(message => 'output directory creation failed') if(! -e $out_directory);
        unless ( $file_collection ) {
           $args{Upload} = $ace_upload->fh;
           $args{Format} = 'ACE';
           $args{Username} = basename($ace_upload);
           $ace_input_file = $job->buildQueryFile(%args);
           $ace_input_file->stage($out_directory);

           $args{Upload} = $xml_upload->fh;
           $args{Format} = 'XML';
           $args{Username} = basename($xml_upload);
           $xml_input_file = $job->buildQueryFile(%args);
           $xml_input_file->stage($out_directory);

           $args{Upload} = $mates_upload->fh;
           $args{Format} = 'Bambus Mates';
           $args{Username} = basename($mates_upload);
           $mates_input_file = $job->buildQueryFile(%args);
           $mates_input_file->stage($out_directory);
        }

        my $sge_submit_script = "$out_directory/${log_name}_sge.sh";

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

        my $command = "$sge_submit_script";

        my $config = {};
        $config->{job_id} = $job->getId;
        $config->{output_file} = "$out_directory/$project.bnk.tar.gz";
        $config->{project} = $project;
        $job->buildConfigFile( $config );

        $job->addInputToCollection($ace_input_file);
        $job->addInputToCollection($xml_input_file);
        $job->addInputToCollection($mates_input_file);



  return $command;
}

#------------------------------------------------------------------------

=item public File getOutputFormat( );

Return the appropriate output format for this job type.

=cut
#------------------------------------------------------------------------

sub getOutputFormat {
  my ($self, $args) = @_;
  return 'Amos Bank';
}
#------------------------------------------------------------------------

=item public File getOutputType( );

Return the appropriate output type for this job type.

=cut
#------------------------------------------------------------------------

sub getOutputType {
  my ($self, $args) = @_;
  return 'Hawkeye Input';
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
