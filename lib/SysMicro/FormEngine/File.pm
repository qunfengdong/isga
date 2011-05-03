package SysMicro::FormEngine::File;
#------------------------------------------------------------------------

=head1 NAME

SysMicro::FormEngine::RunBuilder - provide forms for managing files.

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

=item public hashref form Upload();

Build a FormEngine object for uploading a file.

=cut
#------------------------------------------------------------------------
sub Upload {

  my ($class, $args) = @_;

  my $form = SysMicro::FormEngine->new($args);
  $form->set_skin_obj('SysMicro::FormEngine::SkinUniform');

  my @types = map { [ $_->getName, $_ ] } @{SysMicro::FileType->query( OrderBy => 'Name' )};
  my @formats = map { [ $_->getName, $_ ] } @{SysMicro::FileFormat->query( OrderBy => 'Name' )};

  my @form = 
    (
     { 
      templ => 'fieldset',
      TITLE => 'Required Parameters',
      sub => 
      [
       {
	templ => 'select',
	NAME => 'file_type',
	TITLE => 'File Type',
	SIZE => 1,
	OPTION => ['Select a file type...', map { $_->[0] } @types ],
	OPT_VAL => [undef, map { $_->[1] } @types ],
	ERROR => 'not_null',
       },
       {
	templ => 'select',
	NAME => 'file_format',
	TITLE => 'File Format',
	SIZE => 1,
	OPTION => ['Select a file format...', map { $_->[0] } @formats ],
	OPT_VAL => [undef, map { $_->[1] } @formats ],
	ERROR => 'not_null',
       },


       {
	templ   => 'upload',
	NAME    => 'file_name',
	TITLE   => 'File',
	ERROR   => ['not_null', 'Text::checkHTML', 'File::isUniqueName'],
       },
       {
	templ => 'textarea',
	NAME  => 'description',
	TITLE => 'Description',
	LABEL => 'description',
	ERROR => 'Text::checkHTML',
       },       
      ]
     },
    );
  
  $form->conf( { ACTION => '/submit/File/Upload',
		 FORMNAME => 'file_upload',
                 ENCTYPE => 'multipart/form-data',
		 SUBMIT => 'Upload File',
		 sub => \@form } );

  $form->make;
  return $form;
}

#------------------------------------------------------------------------

=item public hashref form EditDescription();

Build a FormEngine object for editing the details on customized pipelines.

=cut
#------------------------------------------------------------------------
sub EditDescription {

  my ($class, $args) = @_;
  
  my $file = $args->{file};

  my $form = SysMicro::FormEngine->new($args);
  $form->set_skin_obj('SysMicro::FormEngine::SkinUniform');  

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
