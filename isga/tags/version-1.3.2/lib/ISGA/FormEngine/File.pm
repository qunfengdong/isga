package ISGA::FormEngine::File;
#------------------------------------------------------------------------

=head1 NAME

ISGA::FormEngine::RunBuilder - provide forms for managing files.

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

=item public hashref form EditDescription();

Build a FormEngine object for editing the details on customized pipelines.

=cut
#------------------------------------------------------------------------
sub EditDescription {

  my ($class, $args) = @_;
  
  my $file = $args->{file};

  my $form = ISGA::FormEngine->new($args);
  $form->set_skin_obj('ISGA::FormEngine::SkinUniform');  

  my @form =
    (
     {
      templ => 'fieldset',
      TITLE => 'Required Parameters',
      sub => 
      [
       { templ => 'print',
	 TITLE => 'Name',
	 VALUE => $file->getUserName,
       },
       {
	templ => 'textarea',
	NAME  => 'description',
	TITLE => 'Description',
	LABEL => 'description',
	ERROR => 'Text::checkHTML',
	VALUE => $file->getDescription,
       },
      ]
     },
     {
      templ => 'hidden',
      NAME => 'file',
      VALUE => $file,
     },

    );

  $form->conf( { ACTION => '/submit/File/EditDescription',
		 FORMNAME => 'file_edit_description',
		 SUBMIT => 'Save',
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
