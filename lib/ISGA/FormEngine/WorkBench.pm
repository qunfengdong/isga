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
  my @database_names = ( 'GenBank DNA: nt', 'GenBank protein: nr' );
  my @database_values = ( 'nt', 'nr' );

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
                    'HINT' => '<a href="/nucleotide_blast_sample.fna">Sample DNA File</a> | <a href="/amino_acid_blast_sample.fsa">Sample Protein File</a>',
                    'ERROR' => ['Blast::checkUploadFile', 'Blast::checkFastaHeader'],
                    'SIZE' => 5,
                     'VALUE' => $content,
                    'TITLE' => 'Enter query sequence in <a href="http://www.ncbi.nlm.nih.gov/blast/fasta.shtml">FASTA format</a>',
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

#-------------------------------------------------------------------------

=item public hashref form Results::Blast();

Build a FormEngine object for Blast results.

=cut
#------------------------------------------------------------------------

sub Results::Blast{

  my ($class, $args) = @_;

  my $form = ISGA::FormEngine->new($args);
  $form->set_skin_obj('ISGA::FormEngine::SkinUniform');
	
}

#------------------------------------------------------------------------

=item public hashref form MSA();

Build a FormEngine object for MSA queries.

=cut
#------------------------------------------------------------------------
sub MSA {
	my ($class, $args) = @_;

  my $form = ISGA::FormEngine->new($args);
  $form->set_skin_obj('ISGA::FormEngine::SkinUniform');

	my $select_sequence = $args->{select_sequence};
	my $job = $args->{job};
	my $content;

	if ($job){
		use Data::Dumper;
		my $collection = $job->getCollection;
		my $contents = $collection->getContents;
		
		my $list;
		foreach (@$contents){
			if ($_->getType->getName eq 'Toolbox Job Configuration'){
				use YAML;
				$list = YAML::LoadFile($_->getPath);
			}
		}
		my $input = $list->{'input_file_path'};
		my $database = $list->{'databases'};
		push(@$database, $input);
		my $sequence = '';
		my $command;
		
		foreach my $id (@$select_sequence) {
			foreach my $db (@$database) {
				$command = "/bioportal/sw/bin/cdbyank \"$db.cidx\" -a \"$id\" ";
				$sequence = `$command`;
				next if ($sequence eq '');
				warn "-- command -- $command\n";
				$content .= $sequence;
				last if ($sequence);
			}
			undef $sequence;
		}
	}

	my $account = ISGA::Login->getAccount;
	my $runs = ISGA::Run->query( CreatedBy => $account, OrderBy => 'CreatedAt' );

	my @sequence_type_options = ('Nucleotide', 'Amino acid');
	my @sequence_type_values = ('dna', 'protein');
	my @output_format_options = ('default', 'GCG', 'GDE', 'PHYLIP', 'PIR');
	my @output_format_values = ('def', 'GCG', 'GDE', 'PHYLIP', 'PIR');
	my @output_tree_options = ('None', 'NJ', 'PHYLIP', 'Distance');
	my @output_tree_values = ('none', 'nj', 'ph', 'dst');
	my @weight_matrix_options = ('BLOSUM (aa)','PAM (aa)', 'GONNET (aa)', 'ID (aa)', 'IUB (nuc)', 'CLUSTAL (nuc)');
	my @weight_matrix_values = ('blosum', 'pam', 'gonnet', 'id', 'iub', 'clustalw');
	my @alignment_options = ('Pairwise Alignment','Multiple Sequence Alignment');
	my @alignment_values = ('pair', 'multi');

	my @form =
	(
		{
		templ =>'fieldset',
		TITLE => 'CLUSTALw parameters',
		sub => 
			[
				{
				templ => 'select',
				NAME => 'sequence_type', 
				MULTIPLE => 0,
				TITLE => 'Sequence Type',
				SIZE => 2,
				OPTION => \@sequence_type_options,
				OPT_VAL => \@sequence_type_values,
				ERROR => 'not_null',
				},
				{
				templ => 'select',
				NAME => 'output_format',
				MULTIPLE => 0,
				TITLE => 'Output Format',
				SIZE => 3,
				OPTION => \@output_format_options,
				OPT_VAL => \@output_format_values,
				ERROR => 'not_null',
				},
				{
				templ => 'select',
				NAME => 'output_tree',
				MULTIPLE => 0,
				TITLE => 'Output Tree',
				SIZE => 3,
				OPTION => \@output_tree_options,
				OPT_VAL => \@output_tree_values,
				ERROR => 'not_null',
				},
				{
				templ => 'select',
				NAME => 'weight_matrix',
				MULTIPLE => 0,
				TITLE => 'Weight Matrix',
				SIZE => 3,
				OPTION => \@weight_matrix_options,
				OPT_VAL => \@weight_matrix_values,
				ERROR => 'not_null',
				},
				{
				templ => 'radio',
				NAME => 'alignment',
				TITLE => 'Alignment',
				OPTION => \@alignment_options,
				OPT_VAL => \@alignment_values
				},
				{
				templ => 'text',
				NAME => 'gap_open',
				TITLE => 'Gap Open Penalty',
				SIZE => 5,
				MAXLEN => 5,
				VALUE => 'def',
				},
				{
				templ => 'text',
				NAME => 'gap_extension',
				TITLE => 'Gap Extension Penalty',
				SIZE => 5,
				MAXLEN => 5,
				VALUE => 'def',
				}
			]
		},
		{
		templ => 'fieldset',
		TITLE => 'Upload sequences',
		sub =>
			[
				{
				templ => 'textarea',
				NAME => 'query_sequence',
				TITLE => 'Sequences',
				SIZE => 10,
				VALUE => $content,
				},
				{
				templ => 'upload',
				NAME => 'upload_file',
				TITLE => 'Upload File',
				ERROR => '',
				HINT => '<a href="">Sample file</a>',
				}
			]
		}
	);

	$form->conf( { ACTION => '/submit/WorkBench/MSA',
		FORMNAME => 'workbench_msa',
		SUBMIT => 'Submit',
		ENCTYPE => 'multipart/form-data',
		sub => \@form } );

	$form->make;
	return $form;

}
#------------------------------------------------------------------------

=item public hashref form ProtPars();

Build a FormEngine object for ProtPars queries.

=cut
#------------------------------------------------------------------------
sub ProtPars {
	my ($class, $args) = @_;

	my $form = ISGA::FormEngine->new($args);
	$form->set_skin_obj('ISGA::FormEngine::SkinUniform');

	my $infile = $args->{infile};

	my @form = 
	(
		{
		templ => 'fieldset',
		TITLE => 'Parsimony Method',
		sub =>
			[
				{
				templ => 'select',
				NAME => 'U',
				MULTIPLE => 0,
				TITLE => 'U - Search for Best Tree?',
				SIZE => 2,
				OPTION => ['Yes', 'No'],
				OPT_VAL => ['Y', 'N']
				},
				{
				templ => 'select',
				NAME => 'J',
				MULTIPLE => 0,
				TITLE => 'J - Randomize Input order of Sequences?',
				SIZE => 2,
				OPTION => ['Yes', 'No'],
				OPT_VAL => ['Y', 'N']
				},
				{
				templ => 'select',
				NAME => 'O',
				TITLE => 'O - Outgroup root?',
				SIZE => 2,
				OPTION => ['Yes', 'No'],
				OPT_VAL => ['Y', 'N']
				},
				{
				templ => 'select',
				NAME => 'T',
				TITLE => 'T - Use Threshold Parsimony?',
				SIZE => 2,
				OPTION => ['Yes', 'No'],
				OPT_VAL => ['Y', 'N']
				},
				{
				templ => 'select',
				NAME => 'C',
				TITLE => 'C - Use of Genetic Code?',
				SIZE => 3,
				OPTION => ['Universal', 'Mitochondrial', 'Vertebrate', 'Fly', 'Yeast'],
				OPT_VAL => ['U', 'M', 'V', 'F', 'Y']
				},
				{
				templ => 'select',
				NAME => 'W',
				TITLE => 'W - Sites Weighted?',
				SIZE => 2,
				OPTION => ['Yes', 'No'],
				OPT_VAL => ['Y', 'N']
				},
				{
				templ => 'select',
				NAME => 'M',
				TITLE => 'M - Analyze Multiple Data Sets?',
				SIZE => 3,
				OPTION => ['No', 'Yes - Multiple Datasets (D)', 'Yes - Multiple Weights (M)'],
				OPT_VAL => ['N', 'Y_D', 'Y_M'],
				},
				{
				templ => 'select',
				NAME => 'I',
				TITLE => 'I - Input sequence interleaved?',
				SIZE => 2,
				OPTION => ['Yes', 'No'],
				OPT_VAL => ['Y', 'N']
				}
			]
		},
		{
		templ => 'hidden',
		NAME => 'infile',
		VALUE => $infile,
		}
	);

	$form->conf( { ACTION => '/submit/WorkBench/ProtPars',
		FORMNAME => 'workbench_protpars',
		SUBMIT => 'Results',
		ENCTYPE => 'multipart/form-data',
		sub => \@form } );
	
	$form->make;
	return $form;
}

#------------------------------------------------------------------------

=item public hashref form ProtML();

Build a FormEngine object for ProtML queries.

=cut
#------------------------------------------------------------------------


sub ProtML {
	my ($class, $args) = @_;

	my $form = ISGA::FormEngine->new($args);
	$form->set_skin_obj('ISGA::FormEngine::SkinUniform');

	my $infile = $args->{infile};

	my @form = 
	(
		{
		templ => 'fieldset',
		TITLE => 'Maximum Likelihood Method',
		sub =>
			[
				{
				templ => 'select',
				NAME => 'U',
				MULTIPLE => 0,
				TITLE => 'U - Search for Best Tree?',
				SIZE => 2,
				OPTION => ['Yes', 'No'],
				OPT_VAL => ['Y', 'N']
				},
				{
				templ => 'select',
				NAME => 'L',
				MULTIPLE => 0,
				TITLE => 'L - Use lengths from User Trees',
				SIZE => 2,
				OPTION => ['Yes', 'No'],
				OPT_VAL => ['Y', 'N']
				},
				{
				templ => 'select',
				NAME => 'P',
				MULTIPLE => 0,
				TITLE => 'P - Probability Model',
				SIZE => 3,
				OPTION => ['Jones-Taylor-Thorton (JTT)', 'Henikoff/Tillier (PMB)', 'Daykoff (PAM)'],
				OPT_VAL => ['def', 'P', 'PxP']
				},
				{
				templ => 'select',
				NAME => 'C',
				MULTIPLE => 0,
				TITLE => 'C - One category of Sites',
				SIZE => 2,
				OPTION => ['Yes', 'No'],
				OPT_VAL => ['Y', 'N']
				},
				{
				templ => 'text',
				NAME => 'C_number',
				TITLE => 'Number of Categories (1-9)',
				SIZE => 5,
				MAXLEN => 1
				},
				{
				templ => 'text',
				NAME => 'C_rate',
				TITLE => 'Rate for each category ((separated by space)',
				SIZE => 5,
				MAXLEN => 20,
				},
				{
				templ => 'select',
				NAME => 'R',
				MULTIPLE => 0,
				TITLE => 'R - Rate variation among sites',
				SIZE => 4,
				OPTION => ['constant rate of change', 'Gamma distributed rates', 'Gamma+invariant sites', 'user-defined HMM rates'],
				OPT_VAL => ['constant', 'gamma', 'gamma_invariant', 'user']
				},
				{
				templ => 'text',
				NAME => 'A',
				TITLE => 'A - Rate of adjacent sites correlated',
				SIZE => 5,
				MAXLEN => 5,
				},
				{
				templ => 'select',
				NAME => 'S',
				MULTIPLE => 0,
				TITLE => 'S - Sppeder but rougher analysis',
				OPTION => ['Yes', 'No'],
				OPT_VAL => ['Y', 'N']
				},
				{
				templ => 'select',
				NAME => 'J',
				MULTIPLE => 0,
				TITLE => 'J - Randomize Input order of Sequences?',
				SIZE => 2,
				OPTION => ['Yes', 'No'],
				OPT_VAL => ['Y', 'N']
				},
				{
				templ => 'select',
				NAME => 'O',
				TITLE => 'O - Outgroup root?',
				SIZE => 2,
				OPTION => ['Yes', 'No'],
				OPT_VAL => ['Y', 'N']
				},
				{
				templ => 'select',
				NAME => 'G',
				TITLE => 'G - Global Rearrangement?',
				SIZE => 2,
				OPTION => ['Yes', 'No'],
				OPT_VAL => ['Y', 'N']
				},
				{
				templ => 'select',
				NAME => 'W',
				TITLE => 'W - Sites Weighted?',
				SIZE => 2,
				OPTION => ['Yes', 'No'],
				OPT_VAL => ['Y', 'N']
				},
				{
				templ => 'select',
				NAME => 'M',
				TITLE => 'M - Analyze Multiple Data Sets?',
				SIZE => 3,
				OPTION => ['No', 'Yes - Multiple Datasets (D)', 'Yes - Multiple Weights (M)'],
				OPT_VAL => ['N', 'Y_D', 'Y_M'],
				},
			]
		},
		{
		templ => 'hidden',
		NAME => 'infile',
		VALUE => $infile,
		}
	);

	$form->conf( { ACTION => '/submit/WorkBench/ProtML',
		FORMNAME => 'workbench_protml',
		SUBMIT => 'Results',
		ENCTYPE => 'multipart/form-data',
		sub => \@form } );
	
	$form->make;
	return $form;
}

#------------------------------------------------------------------------

=item public hashref form ProtDist();

Build a FormEngine object for ProtDist queries.

=cut
#------------------------------------------------------------------------
sub ProtDist {
	my ($class, $args) = @_;

	my $form = ISGA::FormEngine->new($args);
	$form->set_skin_obj('ISGA::FormEngine::SkinUniform');

	my $infile = $args->{infile};

	my @form = 
	(
		{
		templ => 'fieldset',
		TITLE => 'Distance Method',
		sub =>
			[
				{
				templ => 'select',
				NAME => 'P',
				MULTIPLE => 0,
				TITLE => 'P - Model?',
				SIZE => 3,
				OPTION => ['Jones-Taylor-Thorton (JTT)', 'Henikoff/Tillier (PMB)', 'Dayhoff (PAM)', 'Kimura formula', 'Similarity table'],
				OPT_VAL => ['def', 'P', 'PxP', 'PxPxP', 'PxPxPxP' ],
				VALUE => 'def',
				},	
				{
				templ => 'select',
				NAME => 'G',
				TITLE => 'G - Global Rearrangement?',
				SIZE => 2,
				OPTION => ['No', 'Yes', 'Gamma+Invariant'],
				OPT_VAL => ['def', 'G', 'GxG'],
				VALUE => 'def',
				},
				{
				templ => 'select',
				NAME => 'W',
				TITLE => 'W - Sites Weighted?',
				SIZE => 2,
				OPTION => ['Yes', 'No'],
				OPT_VAL => ['def', 'W'],
				VALUE => 'def',
				},
				{
				templ => 'select',
				NAME => 'M',
				TITLE => 'M - Analyze Multiple Data Sets?',
				SIZE => 3,
				OPTION => ['No', 'Yes - Multiple Datasets (D)', 'Yes - Multiple Weights (W)'],
				OPT_VAL => ['def', 'MxD', 'MxW'],
				VALUE => 'def',
				},
				{
				templ => 'text',
				NAME => 'datasets',
				TITLE => 'Number of datasets',
				SIZE => 5,
				MAXLEN => 5,
				VALUE => '100',
				},
			]
		},
		{
		templ => 'fieldset',
		TITLE => 'Neighbor joining',
		sub =>
			[
				{
				templ => 'select',
				NAME => 'N',
				MULTIPLE => 0,
				TITLE => 'N - Neighbor-Joining or UPGMA tree?',
				SIZE => 2,
				OPTION => ['Neighbor_Joining', 'UPGMA'],
				OPT_VAL => ['def', 'N'],
				VALUE => 'def',
				},
				{
				templ => 'select',
				NAME => 'L',
				MULTIPLE => 0,
				TITLE => 'L - Lower-triangular data matrix?',
				SIZE => 2,
				OPTION => ['Yes', 'No'],
				OPT_VAL => ['def', 'L'],
				VALUE => 'def',
				},
				{
				templ => 'select',
				NAME => 'R',
				MULTIPLE => 0,
				TITLE => 'R - Upper-triangular data matrix?',
				SIZE => 2,
				OPTION => ['Yes', 'No'],
				OPT_VAL => ['def', 'R'],
				VALUE => 'def',
				},
				{
				templ => 'select',
				NAME => 'S',
				MULTIPLE => 0,
				TITLE => 'S - Subreplicates?',
				SIZE => 2,
				OPTION => ['Yes', 'No'],
				OPT_VAL => ['def', 'S'],
				VALUE => 'def',
				}
			]
		},
		{
		templ => 'hidden',
		NAME => 'infile',
		VALUE => $infile,
		}
	);

	$form->conf( { ACTION => '/submit/WorkBench/ProtDist',
		FORMNAME => 'workbench_protdist',
		SUBMIT => 'Results',
		ENCTYPE => 'multipart/form-data',
		sub => \@form } );
	
	$form->make;
	return $form;
}

#------------------------------------------------------------------------

=item public hashref form DnaDist();

Build a FormEngine object for DnaDist queries.

=cut
#------------------------------------------------------------------------
sub DnaDist {
	my ($class, $args) = @_;

	my $form = ISGA::FormEngine->new($args);
	$form->set_skin_obj('ISGA::FormEngine::SkinUniform');

	my $infile = $args->{infile};

	my @form = 
	(
		{
		templ => 'fieldset',
		TITLE => 'Distance Method',
		sub =>
			[
				{
				templ => 'select',
				NAME => 'D',
				MULTIPLE => 0,
				TITLE => 'D - Distance?',
				SIZE => 5,
				OPTION => ['F84', 'Kimura 2-parameter', 'Jukes-Cantor', 'LogDet', 'Similarity table'],
				OPT_VAL => ['def', 'D', 'DxD', 'DxDxD', 'DxDxDxD' ],
				VALUE => 'def',
				},	
				{
				templ => 'select',
				NAME => 'L_dist',
				TITLE => 'L - Form of distance-matrix?',
				SIZE => 2,
				OPTION => ['No', 'Yes'],
				OPT_VAL => ['def', 'L'],
				VALUE => 'def',
				},
				{
				templ => 'select',
				NAME => 'W',
				TITLE => 'W - Sites Weighted?',
				SIZE => 2,
				OPTION => ['Yes', 'No'],
				OPT_VAL => ['def', 'W'],
				VALUE => 'def',
				},
				{
				templ => 'select',
				NAME => 'M',
				TITLE => 'M - Analyze Multiple Data Sets?',
				SIZE => 3,
				OPTION => ['No', 'Yes - Multiple Datasets (D)', 'Yes - Multiple Weights (W)'],
				OPT_VAL => ['def', 'MxD', 'MxW'],
				VALUE => 'def',
				},
				{
				templ => 'text',
				NAME => 'datasets',
				TITLE => 'Number of datasets',
				SIZE => 5,
				MAXLEN => 5,
				VALUE => '100',
				},
			]
		},
		{
		templ => 'fieldset',
		TITLE => 'Neighbor joining',
		sub =>
			[
				{
				templ => 'select',
				NAME => 'N',
				MULTIPLE => 0,
				TITLE => 'N - Neighbor-Joining or UPGMA tree?',
				SIZE => 2,
				OPTION => ['Neighbor_Joining', 'UPGMA'],
				OPT_VAL => ['def', 'N'],
				VALUE => 'def',
				},
				{
				templ => 'select',
				NAME => 'L',
				MULTIPLE => 0,
				TITLE => 'L - Lower-triangular data matrix?',
				SIZE => 2,
				OPTION => ['Yes', 'No'],
				OPT_VAL => ['def', 'L'],
				VALUE => 'def',
				},
				{
				templ => 'select',
				NAME => 'R',
				MULTIPLE => 0,
				TITLE => 'R - Upper-triangular data matrix?',
				SIZE => 2,
				OPTION => ['Yes', 'No'],
				OPT_VAL => ['def', 'R'],
				VALUE => 'def',
				},
				{
				templ => 'select',
				NAME => 'S',
				MULTIPLE => 0,
				TITLE => 'S - Subreplicates?',
				SIZE => 2,
				OPTION => ['Yes', 'No'],
				OPT_VAL => ['def', 'S'],
				VALUE => 'def',
				}
			]
		},
		{
		templ => 'hidden',
		NAME => 'infile',
		VALUE => $infile,
		}
	);

	$form->conf( { ACTION => '/submit/WorkBench/DnaDist',
		FORMNAME => 'workbench_dnadist',
		SUBMIT => 'Results',
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
