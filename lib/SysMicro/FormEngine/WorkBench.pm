package SysMicro::FormEngine::WorkBench;
#------------------------------------------------------------------------

=head1 NAME

SysMicro::FormEngine::WorkBench - provide forms for workbench tools.

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

  my $form = SysMicro::FormEngine->new($args);
  $form->set_skin_obj('SysMicro::FormEngine::SkinUniform');

	## block1: preset values 
  my @database_names = ( 'NCBI: nr', 'UniRef100 ', 'JCVI: NIAA' );

  my @database_values = ( 'nr', 'asgard', 'all_group' );
	
	my @blast_program = ( 'blastn', 'blastp', 'blastx', 'tblastn', 'tblastx');
	my @e_values = ( 0.0001, 0.001, 0.01, 0.1, 1, 10 );
	my @alignment_options = ( 'alignment', 'tabular');
	## block1: end

  my @form = 
	(
		{
		templ => 'fieldset',
		TITLE => 'Database',
		sub =>
			[
				{
				templ => 'select',
				NAME => 'sequence_database',
				MULTIPLE => 1,
				TITLE => 'Select Databases',
				SIZE => 3,
				OPTION => \@database_names,
				OPT_VAL => \@database_values,
				ERROR => 'not_null',
				HINT => 'hold on SHIFT to select more than 1 database',
				TIP  => 'a different tip',
				},	
			]
		},
		{
		templ => 'fieldset',
		TITLE => 'Query Sequence',
		sub =>
			[
				{
				templ => 'textarea',
				NAME => 'query_sequence',
				SIZE => 5,
				ERROR => 'not_null'
				},
				{
				templ => 'upload',
				NAME => 'upload_file',
				TITLE => 'Upload File',
				ERROR => 'not_null'
				}
			]
		},
		{
		templ => 'fieldset',
		TITLE => 'Parameters',
		sub =>
			[
				{
				templ => 'select',
				NAME => 'blast_program',
				TITLE => 'BLAST program',
				SIZE => 1,
				OPTION => \@blast_program,
				ERROR => 'not_null',
				},
				{ 
				templ => 'select',
				NAME => 'e_value',
				TITLE => 'Expect Threshold',
				SIZE => 1,
				OPTION => \@e_values,
				ERROR => 'not_null',
				},
				{
				templ => 'select',
				NAME => 'alignment_view',
				TITLE => 'Alignment view',
				SIZE => 1,
				OPTION => \@alignment_options,
				ERROR => 'not_null',
				}
			]
		}
	);

	$form->conf( { ACTION => '/submit/WorkBench/Blast',
		FORMNAME => 'workbench_blast',
		SUBMIT => 'Query Sequences',
		ENCTYPE => 'multipart/form-data',
		sub => \@form } );

	$form->make;
	return $form;
}

sub Results::Blast{

  my ($class, $args) = @_;

  my $form = SysMicro::FormEngine->new($args);
  $form->set_skin_obj('SysMicro::FormEngine::SkinUniform');


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
