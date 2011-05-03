package SysMicro::FormEngine::Run;
#------------------------------------------------------------------------

=head1 NAME

SysMicro::FormEngine::Run - provide run forms.

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

  my $account = SysMicro::Login->getAccount;

  my $form = SysMicro::FormEngine->new($args);
  $form->set_skin_obj('SysMicro::FormEngine::SkinUniform');

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

1;
__END__

=back

=head1 DIAGNOSTICS

=over 4

=back

=head1 AUTHOR

Center for Genomics and Bioinformatics, biohelp@cgb.indiana.edu

=cut
