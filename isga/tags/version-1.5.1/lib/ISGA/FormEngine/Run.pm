package ISGA::FormEngine::Run;
#------------------------------------------------------------------------

=head1 NAME

ISGA::FormEngine::Run - provide run forms.

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

=item public hashref form Cancel();

Build a FormEngine object to cancel runs.

=cut
#------------------------------------------------------------------------
sub Cancel {

  my ($class, $args) = @_;

  my $account = ISGA::Login->getAccount;

  my $form = ISGA::FormEngine->new($args);
  $form->set_skin_obj('ISGA::FormEngine::SkinUniform');

  my $run = $args->{run};

  my @form =
    (
     {
      templ => 'fieldset',
      TITLE => 'Cancelation Details',
      sub =>
      [
       {
	templ => 'print',
	TITLE => 'Canceled By',
	VALUE => $account->getName,
       },     
       {
	templ => 'textarea',
	NAME  => 'comment',
	TITLE => 'Cancelation Note',
	ERROR => 'not_null',
	HINT  => 'This note will be displayed on the canceled run and sent to the user via email',
       },      
      ]
     },
     { templ => 'hidden',
       NAME  => 'run',
       VALUE => $run,
     }
    );	     
  
  $form->conf( { ACTION => '/submit/Run/Cancel',
		 FORMNAME => 'run_cancel',
		 SUBMIT => 'Cancel Run',
		 sub => \@form } );
  
  $form->make;
  return $form;
}

#------------------------------------------------------------------------

=item public hashref form Clone();

Build a FormEngine object to cancel runs.

=cut
#------------------------------------------------------------------------
sub Clone {

  my ($class, $args) = @_;

  my $account = ISGA::Login->getAccount;

  my $form = ISGA::FormEngine->new($args);
  $form->set_skin_obj('ISGA::FormEngine::SkinUniform');

  my $run = $args->{run};

  my @form =
    (
     {
      templ => 'fieldset',
      TITLE => 'Clone Details',
      sub =>
      [
       {
	templ => 'print',
	TITLE => 'Old Ergatis ID',
	VALUE => $run->getErgatisKey,
       },
       {
	templ => 'print',
	TITLE => 'Cloned By',
	VALUE => $account->getName,
       },     
       {
	templ => 'text',
	NAME  => 'newid',
	TITLE => 'New Ergatis Id',
	ERROR => [ 'not_null', 'digitonly', 'Run::isErgatisPipeline' ]
       },      
      ]
     },
     { templ => 'hidden',
       NAME  => 'run',
       VALUE => $run,
     }
    );	     
  
  $form->conf( { ACTION => '/submit/Run/Clone',
		 FORMNAME => 'run_clone',
		 SUBMIT => 'Clone Run',
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
