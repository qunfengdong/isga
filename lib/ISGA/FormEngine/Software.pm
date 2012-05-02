package ISGA::FormEngine::Software;
#------------------------------------------------------------------------

=head1 NAME

ISGA::FormEngine::Software - provide software forms.

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

=item public hashref form AddRelease();

Build a FormEngine object for adding a new software release.

=cut
#------------------------------------------------------------------------
sub AddRelease {

  my ($class, $args) = @_;

  my $form = ISGA::FormEngine->new($args);
  $form->set_skin_obj('ISGA::FormEngine::SkinUniform');
  
  my $status_ids = ISGA::PipelineStatus->query( OrderBy => 'Name' );
  my $status_names = [map { $_->getName } @$status_ids];
  my $software = $args->{software};
  
  my @form =
    (
     {
      templ => 'fieldset',
      TITLE => 'Release Information',
      sub =>     
      [
       {
	NAME => 'software',
	TITLE => 'Software',
	templ => 'print',
	VALUE => $software->getName,
       },
       {
	NAME => 'version',
	TITLE => 'Version',
	SIZE => 25,
	MAXLEN => 25,
	ERROR => ['not_null', 'Text::checkHTML'],
       },
       {
	NAME => 'release',
	TITLE => 'Release Date',
	SIZE => 10,
	MAXLEN => 10,
	HINT  => 'YYYY-MM-DD',
	ERROR => ['not_null', 'Text::checkDate'],
       },
       
       # status
       {
	NAME => 'pipeline_status',
	TITLE => 'Status',
	templ => 'select',
	OPTION => $status_names,
	OPT_VAL => $status_ids,
       },
       
       # path
       {
	NAME => 'path',
	TITLE => 'Path',
	HINT => 'Path to directory containing executables',
	SIZE => 60,
	ERROR => [ 'not_null', 'File::isAbsolutePath' ],
       },
       
      ]
     },
     { templ => 'hidden',
       NAME => 'software',
       VALUE => $software
     }
    );
  
  $form->conf( { ACTION => '/submit/Software/AddRelease',
		 FORMNAME => 'software_add_release',
		 SUBMIT => 'Add Release',
		 sub => \@form } );
  
  $form->make;
  return $form;
};

#------------------------------------------------------------------------

=item public hashref form EditRelease();

Build a FormEngine object for editing software release.

=cut
#------------------------------------------------------------------------

1;
__END__

=back

=head1 DIAGNOSTICS

=over 4

=back

=head1 AUTHOR

Center for Genomics and Bioinformatics, biohelp@cgb.indiana.edu

=cut
