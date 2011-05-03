package ISGA::JobType::SffToFasta;
#------------------------------------------------------------------------

=head1 NAME

<ISGA::JobType::SffToFasta> provides methods for working with FileConverison jobs.


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
      TITLE => 'SFF To FASTA Conversion',
      sub =>
      [  
       {
        ERROR => ['Hawkeye::checkUploadFile'],
        TITLE => 'Provide SFF file',
        NAME => 'upload_sff_file',
        templ => 'upload'
       },
       {
        NAME => 'library',
        TITLE => 'Library Name'
       },
       {
        templ => 'select',
        NAME => 'clear',
        TITLE => 'Clear',
        OPTION => ['Use the whole read (all)', 'Use the 454 clear ranges as is (454)', 'Use the whole read up to the first N (n)', 'Use the whole read up to the first pair of Ns (pair-of-n)', 'Delete the read if there is an N in the clear range (discard-n)'],
        OPT_VAL => ['all', '454', 'n', 'pair-of-n', 'discard-n']
       },
       {
        templ => 'select',
        NAME => 'trim',
        TITLE => 'Trim',
        OPTION => ['Use the whole read regardless of clear settings (none).', 'OBT and ECR can increase the clear range (soft).', 'OBT can only shrink the clear range, but ECR can extend (hard).', 'Erase sequence outside the clear range (chop).'],
        OPT_VAL => ['none', 'soft', 'hard', 'chop']
       },
       {
        templ => 'radio',
        NAME => 'linker',
        TITLE => 'Linker',
        OPTION => ['none', 'flx', 'titanium'],
        OPT_VAL => [' ', 'flx', 'titanium'],
        ERROR => ['Cluster::linkerRequired', 'Cluster::linkerInsertSizeDependency' ]
       },
       {
        NAME => 'insertsizeavg',
        TITLE => 'Insert Size Average',
        VALUE => '3000',
        ERROR => ['Cluster::insertSizeAvgStdDependency']
       },
       {
        NAME => 'insertsizestd',
        TITLE => 'Insert Size Standard Deviation',
        VALUE => '300',
        ERROR => ['Cluster::insertSizeAvgStdDependency']
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
        my $sff_upload = $webapp->apache_req->upload('upload_sff_file');

        ## Hardcoded paths.
#        my $files_path = "___tmp_file_directory___/workbench/sfftofasta/";
        my $files_path = "___tmp_file_directory___/workbench/" . $job->getType->getName . "/";
        umask(0);
        mkpath($files_path );

        my $log_name  = $job->getType->getName . "_" .  $job->getId;
        my $out_directory = $files_path.$log_name;
        my %args = ( Type => 'Native 454 format' );
        my ($sff_input_file);

        mkdir($out_directory) or X->throw(message => 'output directory creation failed') if(! -e $out_directory);
        my $basename = basename($sff_upload);
        $args{Upload} = $sff_upload->fh;
        $args{Format} = 'SFF';
        $args{Username} = $basename;
        $sff_input_file = $job->buildQueryFile(%args);
        $sff_input_file->stage($out_directory);

        $basename =~s/\.[A-z]+$//;
        my $sge_submit_script = "$out_directory/${log_name}_sge.sh";

        open my $fh, '>', $sge_submit_script or X->throw(message => 'Error creating sge shell script.');
        print $fh '#!/bin/bash'."\n\n";

        print $fh "cd $out_directory\n\n";
        print $fh 'echo "starting sffToCa" 1>&2'."\n";
        if ($$web_args{linker} eq 'flx' or $$web_args{linker} eq 'titanium' ){
          print $fh "___sffToCA_executable___ -linker $$web_args{linker} -insertsize $$web_args{insertsizeavg} $$web_args{insertsizestd} -libraryname $$web_args{library} -clear $$web_args{clear} -trim $$web_args{trim} -output $out_directory/$basename.frg $out_directory/".$sff_input_file->getName()."\n\n";
        } else {
          print $fh "___sffToCA_executable___  -libraryname $$web_args{library} -clear $$web_args{clear} -trim $$web_args{trim} -output $out_directory/$basename.frg $out_directory/".$sff_input_file->getName()."\n\n";
        }
        print $fh 'echo "starting toAmos" 1>&2'."\n";
        print $fh "___toAmos_executable___ -f $out_directory/$basename.frg -o $out_directory/$basename.afg ".'|| { echo "command failed"; exit 1; }'."\n\n";
        print $fh 'echo "starting amos2sq" 1>&2'."\n";
        print $fh "___amos2sq_executable___ -i $out_directory/$basename.afg -o $out_directory/$basename.fsa ".'|| { echo "command failed"; exit 1; }'."\n";

        close $fh;
        chmod(0755, $sge_submit_script);

        my $command = "$sge_submit_script";

        my @params;
        foreach (keys %{$web_args}) {
          unless ($_ eq 'query_sequence' || $_ eq 'upload_file' || $_ eq 'sequence_database' || $_ eq 'workbench' || $_ eq 'progress_id' || $_ eq 'notify_user' || $_ eq 'job_type'){
            push(@params, {$_ => ${$web_args}{$_}});
          }
        }

        my $config = {};
        $config->{job_id} = $job->getId;
        $config->{input_file} = $sff_input_file->getUserName;
        $config->{output_file} = "$out_directory/$basename.fsa.seq";
        push @{$config->{params}}, @params;
        $job->buildConfigFile( $config );

#        $job->addInputToCollection($sff_input_file);


  return $command;
}

#------------------------------------------------------------------------

=item public File getOutputFormat( );

Return the appropriate output format for this job type.

=cut
#------------------------------------------------------------------------

sub getOutputFormat {
  my ($self, $args) = @_;
  return 'FASTA';
}
#------------------------------------------------------------------------

=item public File getOutputType( );

Return the appropriate output type for this job type.

=cut
#------------------------------------------------------------------------

sub getOutputType {
  my ($self, $args) = @_;
  return 'Genome Sequence';
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
