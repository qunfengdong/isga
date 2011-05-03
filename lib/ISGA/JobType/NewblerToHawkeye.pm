package ISGA::JobType::NewblerToHawkeye;
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
      TITLE => 'Newbler to Hawkeye',
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
       {
#        ERROR => ['Hawkeye::checkUploadFile'],
        TITLE => 'Provide Metric file',
        NAME => 'upload_metric_file',
        templ => 'upload',
        SHOWDIV => 1
       },
       {
#        ERROR => ['Hawkeye::checkUploadFile'],
        TITLE => 'Provide Read File',
        NAME => 'upload_read_file',
        templ => 'upload',
        HINT => 'Each line in read file specifies:<br>[read prefix] [library name]<br>Download the perl script to create the read spec file: <a href="https://wiki.cgb.indiana.edu/download/attachments/25821247/makeReadSpec.pl">makeReadSpec.pl</a>|<a href="https://wiki.cgb.indiana.edu/display/brp/guide-makeReadSpec-script">Documentation</a>',
        SHOWDIV => 1
       },
       {
        NAME => 'library_name',
        TITLE => 'Library Name',
        SIZE => 60,
        MAXLEN => 60,
        REQUIRED => 1,
#        ERROR => 'not_null',
        HIDEDIV => 1
       },
       {
        NAME => 'average_length',
        TITLE => 'Average Read Length',
        SIZE => 60,
        MAXLEN => 60,
        REQUIRED => 1,
#        ERROR => 'not_null',
        HIDEDIV => 1
       },
       {
        NAME => 'stdev',
        TITLE => 'Read Length Standard Deviation',
        SIZE => 60,
        MAXLEN => 60,
        REQUIRED => 1,
#        ERROR => 'not_null',
        HIDEDIV => 1
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
  my ($self, $webapp, $form, $job) = @_;

        my $web_args = $webapp->args;

        my $project = $form->get_input('project');
        my $ace_upload = $webapp->apache_req->upload('upload_ace_file');
        my $agp_upload = $webapp->apache_req->upload('upload_agp_file');
        my $metric_upload = $webapp->apache_req->upload('upload_metric_file');
        my $read_upload = $webapp->apache_req->upload('upload_read_file');
        my $file_collection = $form->get_input('collection');
        my @sff_files = map( $webapp->apache_req->upload($_), grep(/^upload_sff_file\d/, keys %$web_args));

        $project =~ s/ /_/g;
        ## Hardcoded paths.
        my $files_path = "___tmp_file_directory___/workbench/newblertohawkeye/";

        my $log_name  = $job->getType->getName . "_" .  $job->getId;
#        my $time = time.$$;
        my $out_directory = $files_path.$log_name;
        my %args = ( Type => 'Newbler Assembler Output' );
        my ($ace_input_file, $agp_input_file, $metric_input_file, $read_input_file);

        mkdir($out_directory) or X->throw(message => 'output directory creation failed') if(! -e $out_directory);
        my %sff_input_files;
        unless ( $file_collection ) {
           $args{Upload} = $ace_upload->fh;
           $args{Format} = 'ACE';
           $args{Username} = basename($ace_upload);
           $args{Description} = 'Input ACE file for NewblerToHawkeye';
           $ace_input_file = $job->buildQueryFile(%args);
           $ace_input_file->stage($out_directory);

           $args{Upload} = $agp_upload->fh;
           $args{Format} = 'AGP';
           $args{Username} = basename($agp_upload);
           $args{Description} = 'Input AGP file for NewblerToHawkeye';
           $agp_input_file = $job->buildQueryFile(%args);
           $agp_input_file->stage($out_directory);

           if ($metric_upload){
               $args{Upload} = $metric_upload->fh;
               $args{Format} = 'Newbler Metric File';
               $args{Description} = 'Input Metric file for NewblerToHawkeye';
               $args{Username} = basename($metric_upload);
               $metric_input_file = $job->buildQueryFile(%args);
               $metric_input_file->stage($out_directory);

               $args{Upload} = $read_upload->fh;
               $args{Format} = 'Read File';
               $args{Username} = basename($read_upload);
               $args{Description} = 'Input read information file for NewblerToHawkeye';
               $read_input_file = $job->buildQueryFile(%args);
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

        my $sge_submit_script = "$out_directory/${log_name}_sge_hawkeye.sh";

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

        my $command = "$sge_submit_script";

        my $config = {};
        $config->{job_id} = $job->getId;
        $config->{output_file} = "$out_directory/$project.bnk.tar.gz";
        $config->{project} = $project;
        $job->buildConfigFile( $config );

        $job->addInputToCollection($ace_input_file);
        $job->addInputToCollection($agp_input_file);
        $job->addInputToCollection($metric_input_file) if ($metric_upload);
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
