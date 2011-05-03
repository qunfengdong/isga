package ISGA::FormEngine::WorkBench;
#------------------------------------------------------------------------

=head1 NAME

ISGA::FormEngine::WorkBench - provide forms for workbench tools.

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=cut
#------------------------------------------------------------------------
use strict;
use warnings;

#========================================================================

=head2 CLASS METHODS

=over 4

=cut
#========================================================================

#------------------------------------------------------------------------

=item public hashref form Blast();

Build a FormEngine object for Blast queries.

=cut
#------------------------------------------------------------------------
sub Blast {

  my ($class, $args) = @_;

  my $form = ISGA::FormEngine->new($args);
  $form->set_skin_obj('ISGA::FormEngine::SkinUniform');

	## block1: preset values 
  my @database_names = ( 'GenBank DNA: nt', 'GenBank protein: nr', 'Arabidopsis Tair9 cdna', 'Arabidopsis Tair9 Pep' );
  my @database_values = ( 'nt', 'nr', 'tair9_cdna', 'tair9_pep' );

	my $account = ISGA::Login->getAccount;
	my $runs = ISGA::Run->query( CreatedBy => $account, Status => 'Complete', OrderBy => 'CreatedAt', IsHidden => 0 );
	foreach my $run(@$runs){
		push(@database_names, "Run ".$run->getName.": predicted gene");
		push(@database_values, "Run".$run->getErgatisKey."_workbench_nuc/".$run->getErgatisKey."_run_result_nuc_db");
		push(@database_names, "Run ".$run->getName.": predicted protein");
		push(@database_values, "Run".$run->getErgatisKey."_workbench_prot/".$run->getErgatisKey."_run_result_prot_db");
	}

        my $files = ISGA::File->query( CreatedBy => $account, OrderBy => 'CreatedAt', Type => 'Genome Sequence', IsHidden => 0 );
        foreach (@$files){
                push(@database_names, "Genome Sequence: ".$_->getUserName);
                push(@database_values, $_->getPath);
        }

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
			#warn "inside the cds feature";
		}
		
		for (my $i = 60; $i < length($content); $i = $i + 61 ){
			substr($content, $i, 0) = "\n";
		} 
	}
	

	my @blast_program = ( 'blastn', 'blastp', 'blastx', 'tblastn');
	## block1: end

my @form_params = 
(
    {
    TITLE => 'BLAST',
    templ => 'fieldset',
    sub => [
                  {
                    'SIZE' => 1,
                    'NAME' => 'sequence_database',
                    'templ' => 'select',
                    'OPTION' => \@database_names,
                    'OPT_VAL' => \@database_values,
                    'ERROR' => 'Blast::isDatabaseSelected',
                    'TITLE' => 'Select database'
                  },
                  {
                    'ERROR' => ['Blast::checkBlastProgram', 'Blast::compatibleBlastProgramAndDB'],
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
                    'HINT' => '<a href="https://wiki.cgb.indiana.edu/download/attachments/25821247/nucleotide_blast_sample.fna">Sample DNA File</a> | <a href="https://wiki.cgb.indiana.edu/download/attachments/25821247/amino_acid_blast_sample.fsa">Sample Protein File</a>',
                    'ERROR' => ['Blast::checkUploadFile', 'Blast::checkFastaHeader'],
                    'SIZE' => 5,
                     'VALUE' => $content,
                    'TITLE' => 'Enter query sequence in <a target="_blank" href="http://www.ncbi.nlm.nih.gov/blast/fasta.shtml">FASTA format</a>',
                    'NAME' => 'query_sequence',
                    'templ' => 'textarea'
                  },
                  {
                    'ERROR' => ['Blast::checkUploadFile', 'Blast::checkFastaHeader'],
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

	$form->conf( { ACTION => '/submit/WorkBench/Blast',
		FORMNAME => 'workbench_blast',
		SUBMIT => 'BLAST',
		ENCTYPE => 'multipart/form-data',
		sub => \@form_params } );

	$form->make;
	return $form;
}

#------------------------------------------------------------------------

=item public hashref form NewblerToHawkeye();

Build a FormEngine object for Newbler to Hawkeye conversion.

=cut
#------------------------------------------------------------------------
sub NewblerToHawkeye {

  my ($class, $args) = @_;

  my $form = ISGA::FormEngine->new($args);
  $form->set_skin_obj('ISGA::FormEngine::SkinUniform');

  my @form =
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

#       {
#        ERROR => ['Hawkeye::checkUploadFile'],
#        TITLE => 'Provide SFF file',
#        NAME => 'upload_sff_file1',
#        templ => 'upload'
#       },
      ]
      },
#      {
#       NAME => 'add',
#       VALUE => 'Add Another SFF File',
#       TYPE => 'button',
#       templ => 'button'
#      },
    );

  $form->conf( { ACTION => '/submit/WorkBench/NewblerToHawkeye',
                 FORMNAME => 'workbench_newblertohawkeye',
                 SUBMIT => 'Convert For Hawkeye',
                 ENCTYPE => 'multipart/form-data',
                 TOGGLELINK => 'Manually Enter Read Information',
                 sub => \@form } );

  $form->make;
  return $form;
}

#------------------------------------------------------------------------

=item public hashref form CeleraToHawkeye();

Build a FormEngine object for Celera to Hawkeye conversion.

=cut
#------------------------------------------------------------------------
sub CeleraToHawkeye {

  my ($class, $args) = @_;

  my $form = ISGA::FormEngine->new($args);
  $form->set_skin_obj('ISGA::FormEngine::SkinUniform');

  my @form =
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
       NAME => 'add',
       VALUE => 'Add Another FRG File',
       TYPE => 'button',
       templ => 'button'
      },
    );

  $form->conf( { ACTION => '/submit/WorkBench/CeleraToHawkeye',
                 FORMNAME => 'workbench_celeratohawkeye',
                 SUBMIT => 'Convert For Hawkeye',
                 ENCTYPE => 'multipart/form-data',
                 sub => \@form } );

  $form->make;
  return $form;
}

#------------------------------------------------------------------------

=item public hashref form MiraToHawkeye();

Build a FormEngine object for Mira to Hawkeye conversion.

=cut
#------------------------------------------------------------------------
sub MiraToHawkeye {

  my ($class, $args) = @_;

  my $form = ISGA::FormEngine->new($args);
  $form->set_skin_obj('ISGA::FormEngine::SkinUniform');

  my @form =
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
      ]
      },
    );

  $form->conf( { ACTION => '/submit/WorkBench/MiraToHawkeye',
                 FORMNAME => 'workbench_miratohawkeye',
                 SUBMIT => 'Convert For Hawkeye',
                 ENCTYPE => 'multipart/form-data',
                 sub => \@form } );

  $form->make;
  return $form;
}

#------------------------------------------------------------------------

=item public hashref form NewblerScaffold4Consed();

Build form for converting Newbler output for Consed

=cut
#------------------------------------------------------------------------
sub NewblerScaffold4Consed {

  my ($class, $args) = @_;

  my $form = ISGA::FormEngine->new($args);
  $form->set_skin_obj('ISGA::FormEngine::SkinUniform');

  my @form =
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

  $form->conf( { ACTION => '/submit/WorkBench/NewblerScaffold4Consed',
                 FORMNAME => 'workbench_newblerscaffold4consed',
                 SUBMIT => 'Convert For Consed',
                 ENCTYPE => 'multipart/form-data',
                 sub => \@form } );

  $form->make;
  return $form;
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
