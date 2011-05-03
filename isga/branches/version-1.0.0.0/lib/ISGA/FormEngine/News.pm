package ISGA::FormEngine::News;
#------------------------------------------------------------------------

=head1 NAME

ISGA::FormEngine::News - provide forms for managing news.

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=cut
#------------------------------------------------------------------------
use strict;
use warnings;

use ISGA::NewsType;
use ISGA::News;

{

  my ($type_ids, $type_names);

  { 
    my $types = ISGA::NewsType->query( OrderBy => 'Name' );
    $type_ids = [map { "$_" } @$types];
    $type_names = [ map { $_->getName } @$types];
  }

#========================================================================

=head2 CLASS METHODS

=over 4

=cut
#========================================================================

#------------------------------------------------------------------------

=item public hashref form Create();

Build a FormEngine object for creating news entries.

=cut
#------------------------------------------------------------------------
  sub Create {

    my ($class, $args) = @_;
    
    my $form = ISGA::FormEngine->new($args);
    $form->set_skin_obj('ISGA::FormEngine::SkinUniform');
    
    my @form =
      (
       {
	templ => 'fieldset',
	TITLE => 'News parameters',
	sub => 
	[
	 {
	  templ   => 'select',
	  NAME    => 'news_type',
	  TITLE   => 'Type',
	  OPTION  => $type_names,
	  OPT_VAL => $type_ids,
	  ERROR   => 'not_null',
	 },
	 {
	  NAME  => 'title',
	  TITLE => 'Title',
	  ERROR => 'not_null',
	 },
	 {
	  templ => 'textarea',
	  NAME  => 'body',
	  TITLE => 'Body',
	  ERROR => 'not_null',
	 },
	 {
	  NAME  => 'archive_on',
	  TITLE => 'Archive On',
	  HINT  => 'This should be a date picker',
	 },
	]
       });


    $form->conf( { ACTION => '/submit/News/Create',
		   FORMNAME => 'news_create',
		   SUBMIT => 'Post News',
		   sub => \@form } );
    
    $form->make;
    return $form;
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

