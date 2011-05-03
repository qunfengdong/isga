package SysMicro::FormEngine::Help;
#------------------------------------------------------------------------

=head1 NAME

SysMicro::FormEngine::Help - provide support forms.

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

=item public hashref form ContactUs();

Build a FormEngine object to process site feedback.

=cut
#------------------------------------------------------------------------
sub ContactUs {

  my ($class, $args) = @_;

  my $form = SysMicro::FormEngine->new($args);
  $form->set_skin_obj('SysMicro::FormEngine::SkinUniform');

  my @fields = ();

  if ( SysMicro::Login->exists ) {

    my $account = SysMicro::Login->getAccount;

    push @fields, { templ => 'print', TITLE => 'Full Name', VALUE => $account->getName };
    push @fields, { templ => 'print', TITLE => 'Email Address', VALUE => $account->getEmail };

  } else {

    push @fields, (
		   {
		    NAME => 'name',
		    TITLE => 'Full Name',
		    SIZE => 60,
		    MAXLEN => 100,
		    REQUIRED => 1,
		    LABEL => 'name',
		    ERROR => ['not_null'],
		   },
		   
		   {
		    NAME => 'email',
		    TITLE => 'Email',
		    SIZE => 60,
		    MAXLEN => 60,
		    REQUIRED => 1,
		    LABEL => 'email',
		    ERROR => ['not_null'],
		   }
		  );
  }
  
  push @fields, (
		 {
		  NAME => 'subject',
		  TITLE => 'Subject',
		  SIZE => 60,
		  MAXLEN => 60,
		  REQUIRED => 1,
		  LABEL => 'subject',
		  ERROR => ['not_null'],
		 },
		 
		 { 
		  templ => 'textarea',
		  NAME  => 'message',
		  TITLE => 'Message',
		  LABEL => 'message',
		  ERROR => ['not_null'],
		 }
		);

  my @form =
    (
     { 
      templ => 'fieldset',
      TITLE => 'Required Parameters',
      sub => \@fields,
     }
    );

  $form->conf( { ACTION => '/submit/Help/ContactUs',
		 FORMNAME => 'help_contact_us',
		 SUBMIT => 'Send Feedback',
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

Chris Hemmerich, biohelp@cgb.indiana.edu

=cut
