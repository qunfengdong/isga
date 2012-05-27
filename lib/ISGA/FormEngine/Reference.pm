package ISGA::FormEngine::Reference;
#------------------------------------------------------------------------

=head1 NAME

ISGA::FormEngine::Reference - provide reference forms.

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
  my $reference = $args->{reference};
  
  # retrieve reference templates
  my $template_ids = ISGA::ReferenceTemplate->query( Reference => $reference );
  my $template_names;
  foreach ( @$template_ids ) {
    my $label = $_->getLabel;
    my $name = $_->getFormat;
    $label and $name .= " ($label)";

    push @$template_names, $name;
  }

  my @form =
    (
     {
      templ => 'fieldset',
      TITLE => 'Release Information',
      sub =>     
      [
       {
	NAME => 'reference',
	TITLE => 'Reference',
	templ => 'print',
	VALUE => $reference->getName,
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
       
       # templates
       {
	NAME => 'reference_template',
	TITLE => 'Templates',
	templ => 'select',
	SIZE => scalar(@$template_ids),
	OPTION => $template_names,
	OPT_VAL => $template_ids,
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
	ERROR => [ 'not_null', 'File::isPath' ],
       },
       
      ]
     },
     { templ => 'hidden',
       NAME => 'reference',
       VALUE => $reference
     }
    );
  
  $form->conf( { ACTION => '/submit/Reference/AddRelease',
		 FORMNAME => 'reference_add_release',
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
sub EditRelease {

  my ($class, $args) = @_;

  my $form = ISGA::FormEngine->new($args);
  $form->set_skin_obj('ISGA::FormEngine::SkinUniform');
  
  my $status_ids = ISGA::PipelineStatus->query( OrderBy => 'Name' );
  my $status_names = [map { $_->getName } @$status_ids];
  my $release = $args->{reference_release};
  my $reference = $release->getReference;

  my @form =
    (
     {
      templ => 'fieldset',
      TITLE => 'Release Information',
      sub =>     
      [
       {
	NAME => 'reference',
	TITLE => 'Reference',
	templ => 'print',
	VALUE => $reference->getName,
       },
       {
	NAME => 'version',
	TITLE => 'Version',
	SIZE => 25,
	MAXLEN => 25,
	VALUE => $release->getVersion,
	ERROR => ['not_null', 'Text::checkHTML'],
       },
       {
	NAME => 'release',
	TITLE => 'Release Date',
	SIZE => 10,
	MAXLEN => 10,
	VALUE => $release->getRelease->format('<YR>-<MN>-<DY>'),
	HINT  => 'YYYY-MM-DD',
	ERROR => ['not_null', 'Text::checkDate'],
       },
       
       # status
       {
	NAME => 'pipeline_status',
	TITLE => 'Status',
	templ => 'select',
	VALUE => $release->getStatus,
	OPTION => $status_names,
	OPT_VAL => $status_ids,
       },
       
       # path
       {
	NAME => 'path',
	TITLE => 'Path',
	HINT => 'Path to directory containing executables',
	VALUE => $release->getPath,
	SIZE => 60,
	ERROR => [ 'not_null', 'File::isPath' ],
       },
       
      ]
     },
     { templ => 'hidden',
       NAME => 'reference_release',
       VALUE => $release
     }
    );
  
  $form->conf( { ACTION => '/submit/Reference/EditRelease',
		 FORMNAME => 'reference_edit_release',
		 SUBMIT => 'Edit Release',
		 sub => \@form } );
  
  $form->make;
  return $form;
};


1;
__END__

=back

=head1 DIAGNOSTICS

=over 4

=back

=head1 AUTHOR

Center for Genomics and Bioinformatics, biohelp@cgb.indiana.edu

=cut
