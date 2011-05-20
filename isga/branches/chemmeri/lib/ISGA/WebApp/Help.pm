## no critic
# we turn off perl critic because we package doesn't match file
package ISGA::WebApp;
## use critic
#------------------------------------------------------------------------

=head1 NAME

ISGA::WebApp manages the interface to MASON for ISGA.

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=cut
#------------------------------------------------------------------------
use strict;
use warnings;

use Digest::MD5;

#========================================================================

=head2 CLASS METHODS

=over 4

=cut
#========================================================================

#------------------------------------------------------------------------

=item public void ContactUs();

Send Feedback to us.

=cut
#------------------------------------------------------------------------
sub Help::ContactUs {

  my $self = shift;
  my $web_args = $self->args;
  my $form = ISGA::FormEngine::Help->ContactUs($web_args);

  if ( $form->canceled ) {
    $self->redirect( uri => '/Account/MyAccount' );
  } elsif ( $form->ok ) { 

    my $content;
    
    if ( ISGA::Login->exists ) {
      
      my $account = ISGA::Login->getAccount;
      $content = 'Feedback from ' . $account->getName . '  ' . $account->getEmail . "\n";
    } else {
      $content = 'Feedback from ' . $form->get_input('name') . '  ' . $form->get_input('email') .
	"\n";
    }
    
    my $support_email = ISGA::SiteConfiguration->value('support_email');

    my %mail = 
      ( To => $support_email,
	FROM => "ISGA Feedback<$support_email>",
	Subject => 'ISGA Feedback: ' . $form->get_input('subject'),
	Message => $content . $form->get_input('message')
      );
    
    Mail::Sendmail::sendmail(%mail)
	or X::Mail::Send->throw( text => $Mail::Sendmail::error, message => \%mail );

    $self->redirect( uri => '/Help/FeedbackSent' );
  }

  # bounce!!!!!
  $self->_save_arg( 'form', $form);
  $self->redirect( uri => '/Help/ContactUs' );
}   

1;
__END__

=back

=head1 DIAGNOSTICS

=over 4

=back

=head1 AUTHOR

Chris Hemmerich, biohelp@cgb.indiana.edu

=cut
