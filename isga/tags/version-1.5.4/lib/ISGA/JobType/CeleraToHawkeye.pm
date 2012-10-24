package ISGA::JobType::CeleraToHawkeye;
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
      TITLE => 'Celera to Hawkeye',
      ID => 'addField',
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
        TITLE => 'Provide ASM file',
        NAME => 'upload_asm_file',
        templ => 'upload'
       },
       {
        ERROR => ['Hawkeye::checkUploadFile'],
        TITLE => 'Provide FRG file',
        NAME => 'upload_frg_file1',
        templ => 'upload'
       },
      ]
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
      {
       NAME => 'add',
       VALUE => 'Add Another FRG File',
       TYPE => 'button',
       templ => 'button'
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
  my ($self, $webapp, $form, $job) = @_;
        use File::Path;

        my $web_args = $webapp->args;

        my $project = $form->get_input('project');
        my $asm_upload = $webapp->apache_req->upload('upload_asm_file');
        my $file_collection = $form->get_input('collection');
        my @frg_files = map( $webapp->apache_req->upload($_), grep(/^upload_frg_file\d/, keys %$web_args));

        $project =~ s/ /_/g;
        ## Hardcoded paths.
        my $tmp_dir = ISGA::SiteConfiguration->value('shared_tmp');
        my $files_path = "$tmp_dir/workbench/" . $job->getType->getName . "/";
        umask(0);
        mkpath($files_path );

        my $log_name  = $job->getType->getName . "_" .  $job->getId;
        my $out_directory = $files_path.$log_name;
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
           $asm_input_file = $job->buildQueryFile(%args);
           $asm_input_file->stage($out_directory);

           foreach(@frg_files){
               $args{Upload} = $_->fh;
               $args{Type} = 'Celera Assembler native format';
               $args{Format} = 'FRG';
               $args{ExistsOutsideCollection} = 1;
               $args{Username} = basename($_);
               my $frg_input_file = $job->buildQueryFile(%args);
               $frg_input_files{$_} = $frg_input_file;
               my $cat_cmd = "cat ".$frg_input_file->getPath." >> $out_directory/reads.frg";
               system("$cat_cmd") == 0 or X->throw(message => 'Failed to combine FRG files');
#               copy($sff_input_file->getPath, "$out_directory/".basename($_));
           }
        }

        my $sge_submit_script = "$out_directory/${log_name}_sge.sh";

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

        my $command = "$sge_submit_script";

        my $config = {};
        $config->{job_id} = $job->getId;
        $config->{output_file} = "$out_directory/$project.bnk.tar.gz";
        $config->{project} = $project;
        $job->buildConfigFile( $config );

        $job->addInputToCollection($asm_input_file);
        foreach(values %frg_input_files){
            $job->addInputToCollection($_);
        }

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
