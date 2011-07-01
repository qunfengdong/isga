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
    
    my $nuc_ref = ISGA::ReferenceDB->query( ReferenceType => ISGA::ReferenceType->new( Name => 'BLAST Nucleotide Database' ), OrderBy => 'Name' );
    my $prot_ref = ISGA::ReferenceDB->query( ReferenceType => ISGA::ReferenceType->new( Name => 'BLAST Amino Acid Database' ), OrderBy => 'Name' );
    
    push @db_groups,
      (
       {
	LABEL => 'Global Nucleotide Databases',
	templ => 'group',
	OPTION => [map {$_->getName} @$nuc_ref],
	OPT_VAL => $nuc_ref
       },
       {
	LABEL => 'Global Protein Databases',
	templ => 'group',
	OPTION => [map {$_->getName} @$prot_ref],
	OPT_VAL => $prot_ref
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

    # grab necessary informationfrom request
    my $web_args = $webapp->args;  
    my $sequences = $form->get_input('query_sequence');
    my $upload = $webapp->apache_req->upload('upload_file');
    
    # retrieve our environment
    my $environment = $job->getEnvironment();
    my $user_class = $job->getCreatedBy->getUserClass();
    my $wd = $job->getWorkingDirectory();

    # copy the input file to the working directory
    $input_file->stage($wd);   
    my $input_path = $wd . '/' . $input_file->getName();

    # read the database we are searching against
    my $database = $form->get_input('sequence_database');

    # set the path to the output file
    my $blast_output = $wd . '/' . $job->getName . '_blast_output.blout';

    # start building the script that will execute the job
    my $fh = $environment->initializeScript(); 

    # is this a raw fasta file we need to index (i.e. genome file)
    if ( 0 == 1 ) {
      my $db_path = $wd . '/' . 'blast_database';
      copy($database,$db_path);
      print $fh ISGA::JobConfiguration->value( 'formatdb_executable', JobType => $self, UserClass => $user_class );
      print $fh "-i $db_path -p F -o T\n";
      $database = $db_path;
    }
    
    print $fh ISGA::JobConfiguration->value( 'blast_executable', JobType => $self, UserClass => $user_class );
    print $fh " -p $web_args{blast_program} -i $input_path -o $blast_output -e $web_args{evalue}";
    print $fh " -d \"$database\" -F $web_args{blastfilter} -b $web_args{nummatches} -v $web_args{descriptions}";

    if ( $web_args{outputformat} != 0 ) {
      print $fh " -m $web_args{outputformat}";
    }
    print $fh "\n";

    $environment->finalizeScript($fh);

    X->throw( message => "oops" );
    
    my @params;
    foreach (keys %{$web_args}) {
      unless ($_ eq 'query_sequence' || $_ eq 'upload_file' || $_ eq 'sequence_database' || $_ eq 'workbench' || $_ eq 'progress_id' || $_ eq 'notify_user' || $_ eq 'job_type'){
	push(@params, {$_ => ${$web_args}{$_}});
      }
    }
    
    # save configuration
    my $config = {};
    $config->{job_id} = $job->getId;
    $config->{input_file} = $input_file->getUserName;
    $config->{input_file_path} = $input_path;
    $config->{output_file} = $blast_output;
    $config->{database} = $database;
    push @{$config->{params}}, @params;
    $job->buildConfigFile( $config );
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
