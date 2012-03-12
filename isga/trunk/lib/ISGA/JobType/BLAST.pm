package ISGA::JobType::BLAST;
#------------------------------------------------------------------------

=head1 NAME

<ISGA::JobType::BLAST> provides methods for working with BLAST jobs.


=head1 SYNOPSIS

=head1 DESRIPTION

=head1 METHODS

=over

=cut
#------------------------------------------------------------------------

use base 'ISGA::Job';
use File::Basename;
use File::Copy;
use List::Util qw(min);

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

  my $db_path = "___database_path___";

  my @db_groups;

  my $nuc_ref = ISGA::ReferenceDB->query( Type => ISGA::ReferenceType->new( Name => 'BLAST Nucleotide Database' ), Status => ISGA::PipelineStatus->new( Name => 'Published' ) );
  my $prot_ref = ISGA::ReferenceDB->query( Type => ISGA::ReferenceType->new( Name => 'BLAST Amino Acid Database' ), Status => ISGA::PipelineStatus->new( Name => 'Published' ) );


  push @db_groups,
    (
     {
      LABEL => 'General Nucleotide Databases',
      templ => 'group',
      OPTION => [map { $_->getRelease->getReference->getTag->getName eq 'Collection' ? $_->getName : () } @$nuc_ref],
      OPT_VAL => [map { $_->getRelease->getReference->getTag->getName eq 'Collection' ? $_->getId : () } @$nuc_ref]
     },
     {
      LABEL => 'General Protein Databases',
      templ => 'group',
      OPTION => [map { $_->getRelease->getReference->getTag->getName eq 'Collection' ? $_->getName : () } @$prot_ref],
      OPT_VAL => [map { $_->getRelease->getReference->getTag->getName eq 'Collection' ? $_->getId : () } @$prot_ref]
     },
    );

  push @db_groups,
    (
     {
      LABEL => 'Organism Nucleotide Databases',
      templ => 'group',
      OPTION => [map { $_->getRelease->getReference->getTag->getName eq 'Organism' ? $_->getName : () } @$nuc_ref],
      OPT_VAL => [map { $_->getRelease->getReference->getTag->getName eq 'Organism' ? $_->getId : () } @$nuc_ref]
     },
     {
      LABEL => 'Organism Protein Databases',
      templ => 'group',
      OPTION => [map { $_->getRelease->getReference->getTag->getName eq 'Organism' ? $_->getName : () } @$prot_ref],
      OPT_VAL => [map { $_->getRelease->getReference->getTag->getName eq 'Organism' ? $_->getId : () } @$prot_ref]
     },
    );
  my $account = ISGA::Login->getAccount;
  my $runs = ISGA::Run->query( CreatedBy => $account, Status => 'Complete', 
			       OrderBy => 'CreatedAt', IsHidden => 0 );

  my %my_runs = ( LABEL => 'My Runs', OPTION => [], OPT_VAL => [], templ => 'group' );

  foreach my $run (@$runs) {
  
    # only process pipelines that produce blast results
    next unless $run->getGlobalPipeline->hasBlastDatabase();
    my ($names, $values) = $run->getBlastDatabases();

    push @{$my_runs{OPTION}}, @$names;
    push @{$my_runs{OPT_VAL}}, @$values;
  }

  # if there are runs, display them
  @{$my_runs{OPTION}} and push @db_groups, \%my_runs;

  my %shared_runs = ( LABEL => 'Shared Runs', OPTION => [], OPT_VAL => [], templ => 'group' );

  my $shared_runs = $account->getSharedRuns();

  foreach my $run (@$shared_runs) {
    
    # only process pipelines that produce blast results
    next unless $run->getGlobalPipeline->hasBlastDatabase();
    my ($names, $values) = $run->getBlastDatabases();
    
    my $owner = $run->getCreatedBy->getName();
    $_ = "$owner: $_" for @$names;

    push @{$shared_runs{OPTION}}, @$names;
    push @{$shared_runs{OPT_VAL}}, @$values;
  }

  # if there are runs, display them
  @{$shared_runs{OPTION}} and push @db_groups, \%shared_runs;
  
  
  my $files = ISGA::File->query( CreatedBy => $account, OrderBy => 'CreatedAt', Type => 'Genome Sequence', IsHidden => 0 );

  my %my_files = ( LABEL => 'My Genome Sequence Files', OPTION => [], OPT_VAL => [], templ => 'group' );

  foreach (@$files){
      push @{$my_files{OPTION}}, $_->getUserName;
      push @{$my_files{OPT_VAL}}, $_->getPath;
  }
  @{$my_files{OPTION}} and push @db_groups, \%my_files;



  my $id = $args->{feature_id};
  my $content = '';
  if ($id){
      my $upstream = $args->{upstream};
      my $downstream = $args->{downstream};
      my $feature = ISGA::GenomeFeature->new(Id => $id);

      if ($feature ->isa('ISGA::Gene')) {
          $content = ">". $feature->getLocus ."\n";
          $content .= $feature->getUpstream($upstream) if ($upstream);
          $content .= $feature->getResidues;
          $content .= $feature->getDownstream($downstream) if ($downstream);
      } else {
          my $gene = $feature->getmRNA->getGene;
          $content = ">". $gene->getLocus ."\n";
          $content .= $feature->getResidues;
      }
   
      for (my $i = 60; $i < length($content); $i = $i + 61 ){
          substr($content, $i, 0) = "\n";
      }
  }

  my @blast_program = ( 'blastn', 'blastp', 'blastx', 'tblastn');
  my @files =(['--- Not Selected ---', '']);
  push @files,
    sort { $a->[0] cmp $b->[0] }
      map { [ $_->getUserName, $_ ] }
        @{ISGA::File->query( CreatedBy => $account, Format => 'FASTA', IsHidden => 0 )};

  my @form_params =
  (
    {
      TITLE => 'BLAST',
      templ => 'fieldset',
      sub => [
	      {
	       'SIZE' => 1,
	       'NAME' => 'sequence_database',
	       'templ' => 'groupselect',
	       sub     => \@db_groups,
	       'ERROR' => 'Blast::isDatabaseSelected',
	       'TITLE' => 'Select database'
	      },
	      
	       {
                    'ERROR' => ['Blast::compatibleBlastProgramAndDB'],
                    'OPTION' => \@blast_program,
                    'SIZE' => 1,
                    'TITLE' => 'BLAST program',
                    'NAME' => 'blast_program',
                    'templ' => 'select'
                  },
                  {
                    'SIZE' => 60,
                    'VALUE' => '1e-5',
                    'NAME' => 'evalue',
                    'LABEL' => 'evalue',
                    'MAXLEN' => 60,
                    'ERROR' => ['Number::isScientificNotation', 'not_null', 'Text::checkHTML'],
                    'TITLE' => 'E-value',
                  },
                  {
                    'OPTION' => ['T', 'F'],
                    'VALUE' => 'T',
                    'NAME' => 'blastfilter',
                    'LABEL' => 'blastfilter',
                    'templ' => 'select',
                    'TITLE' => 'Low complexity region filter',
                  },
                  {
                    'NAME' => 'nummatches',
                    'TITLE' => 'Matches per Query Sequence',
                    'LABEL' => 'nummatches',
                    'VALUE' => '150',
                    'ERROR' => ['digitonly'],
                  },
                  {
                    'NAME' => 'numdescirptions',
                    'TITLE' => 'Descriptions per Query Sequence',
                    'LABEL' => 'numdescirptions',
                    'VALUE' => '150',
                    'ERROR' => ['digitonly'],
                  },
                  {
                    'OPTION' => ['Standard', 'Tabular (no comment lines)', 'Tabular (with comment lines)', 'XML'],
                    'OPT_VAL' => ['0', '8', '9', '7'],
                    'VALUE' => '0',
                    'NAME' => 'outputformat',
                    'LABEL' => 'outputformat',
                    'templ' => 'select',
                    'TITLE' => 'Output Format',
                  },
                  {
                    'HINT' => '<a href="https://wiki.cgb.indiana.edu/download/attachments/25821247/nucleotide_blast_sample.fna">Sample DNA File</a> | <a href="https://wiki.cgb.indiana.edu/download/attachments/25821247/amino_acid_blast_sample.fsa">Sample Protein File</a>',
                    'ERROR' => ['Blast::checkUploadFile', 'Blast::sanityFastaChecks'],
                    'SIZE' => 5,
                    'VALUE' => $content,
                    'TITLE' => 'Enter query sequence in <a target="_blank" href="http://www.ncbi.nlm.nih.gov/blast/fasta.shtml">FASTA format</a>',
                    'NAME' => 'query_sequence',
                    'templ' => 'textarea'
                  },
                  {
                    'ERROR' => ['Blast::checkUploadFile', 'Blast::sanityFastaChecks'],
                    'TITLE' => 'Or upload query sequence file',
                    'NAME' => 'upload_file',
                    'templ' => 'upload'
                  },
                  {
                   templ => 'select',
                   NAME => 'associated_file',
                   TITLE => 'Or select a previously associated file',
                   SIZE  => min( scalar(@files), 8),
                   OPTION => [map { $_->[0] } @files ],
                   OPT_VAL => [map { $_->[1] } @files ],
                   HINT => 'Do not highlight a file if you are uploading a file or pasting a sequnece in the text box',
                   ERROR => ['Blast::checkUploadFile', 'Blast::sanityFastaChecks'],
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
      ],
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

        my $sequences = $form->get_input('query_sequence');
        my $upload = $webapp->apache_req->upload('upload_file');
        my $file =  ISGA::FileResource->new( Id => $form->get_input('associated_file') ) if ($form->get_input('associated_file') and $form->get_input('associated_file') ne '');

        ## Hardcoded paths.
        my $tmp_dir = ISGA::SiteConfiguration->value('shared_tmp');
        my $files_path = "$tmp_dir/workbench/" . $job->getType->getName . "/";
        umask(0);
        mkpath($files_path );

        my $blastfilter = $form->get_input('blastfilter');
        my $scoringmatrix = $form->get_input('scoringmatrix');
        my $evalue = $form->get_input('evalue');
        my $blast_program = $form->get_input('blast_program');
        my $nummatches = $form->get_input('nummatches');
        my $descriptions = $form->get_input('numdescirptions');
        my $outputformat = $form->get_input('outputformat');
        my $sequence_database = $form->get_input('sequence_database');
        ref($sequence_database) eq 'ARRAY' or $sequence_database = [ $sequence_database ];

        my $log_name  = $job->getType->getName . "_" .  $job->getId;

        my $out_directory = $files_path.$log_name;
        mkdir($out_directory) or X->throw(message => 'output directory creation failed') if(! -e $out_directory);

        my $blast_output = $out_directory."/${log_name}_blast_output.blout";

        my @database_array;
        my $refdb_flag = 0;
        foreach (@$sequence_database){
          my $db = $_;
          if ($db =~ /^\d+$/o){
            my $refdb = ISGA::ReferenceDB->new( Id => $db );
            $db = $refdb->getFullPath;
            $refdb_flag = 1;
          }
            
          if ($refdb_flag or $db =~ /cgb_annotation.cds.fna$/ or $db =~ /cgb_annotation.aa.fsa$/ ){
            push(@database_array, $db);
          } else {
            my $formatdbpath = $out_directory."/${log_name}_genome_sequence";
            copy($db, $formatdbpath) or X->throw(message => 'Cannot copy file to tmp directory');
            system("___formatdb_executable___ -i $formatdbpath -p F -o T") == 0 or X->throw(message => 'formatdb failed');
            push(@database_array, $formatdbpath);
          }
        }

        my $database = join(' ', @database_array);

        my %args = ( );
        $file and $args{File} = $file;
        $upload and $args{Upload} = $upload->fh;
        $sequences and $args{String} = $sequences;
        $args{Type} = $blast_program =~ /(^blastp$|^tblastn$)/ ? "Amino Acid Sequence" : "Nucleotide Sequence";
        $args{Format} = "FASTA";
        $args{Description} = 'Input file for BLAST job';
        $args{Username} = $upload ? basename($upload) : $log_name.'_blast_input';

        my $input_file = $job->buildQueryFile(%args);

        $input_file->stage($out_directory);

        my $runpath = "$out_directory/" . $input_file->getName();

#        my $command;
        my $sge_submit_script = "$out_directory/${log_name}_sge.sh";

        my $blast_command = "___blast_executable___ -p $blast_program -i $runpath -o $blast_output -e $evalue -d \"$database\" -F $blastfilter -b $nummatches -v $descriptions";
        $blast_command .= " -m $outputformat" if($outputformat != 0);

        if($database =~ /Tair9_cdna/og or $database =~ /Tair9_pep/og){
            open my $fh, '>', $sge_submit_script or X->throw(message => 'Error creating sge shell script.');
            print $fh '#!/bin/bash'."\n\n";
            print $fh 'echo "starting blast" 1>&2'."\n";
            print $fh "___blast_executable___ -p $blast_program -i $runpath -o $blast_output -e $evalue -d \"$database\" -F $blastfilter -b $nummatches -v $descriptions\n\n";
            print $fh 'echo "starting preprocessing output" 1>&2'."\n";
            print $fh "___scripts_bin___parse_blast_output.pl $blast_output\n\n";
            close $fh;
            chmod(0755, $sge_submit_script);
            $command = "$sge_submit_script";
        } else {
#            $command = $blast_command;
            open my $fh, '>', $sge_submit_script or X->throw(message => 'Error creating sge shell script.');
            print $fh '#!/bin/bash'."\n\n";
            print $fh 'echo "starting blast" 1>&2'."\n";
            print $fh "$blast_command\n\n";
            close $fh;
            chmod(0755, $sge_submit_script);
            $command = "$sge_submit_script";
        }

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
        $config->{input_file} = $input_file->getUserName;
        $config->{input_file_path} = $runpath;
        $config->{output_file} = $blast_output;
        push @{$config->{databases}}, @database_array;
        push @{$config->{params}}, @params;
        $job->buildConfigFile( $config );

        return $command;
}
#------------------------------------------------------------------------

=item public File getOutputFormat( );

Return the appropriate output format for this job type.

=cut
#------------------------------------------------------------------------

sub getOutputFormat {
  my ($self, $args) = @_;
  return 'BLAST Raw Results';
}
#------------------------------------------------------------------------

=item public File getOutputType( );

Return the appropriate output type for this job type.

=cut
#------------------------------------------------------------------------

sub getOutputType {
  my ($self, $args) = @_;
  return 'BLAST Search Result';
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
