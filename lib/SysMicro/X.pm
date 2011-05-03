package ___APP___::X;
#------------------------------------------------------------------------

=head1 NAME

B<SysMicro::X> provides error classes created for this project.

=head1 SYNOPSIS

=head1 DESRIPTION

=head1 METHODS

=cut
#------------------------------------------------------------------------

use strict;
use warnings;

use ___APP___::FoundationX;

use base qw( SysMicro::FoundationX );

use Exception::Class
(

 'X::TestError' => { isa => 'X' },


 'X::API::Parameter::Invalid::MalformedEmail' => { isa => 'X::API::Parameter::Invalid',
						   fields => [ 'email' ] },
 'X::File::Tar' => { isa => 'X::File' },
 'X::File::Tar::IllegalContent' => { isa => 'X::File::Tar', fields => [ 'content' ] },

 'X::Ergatis' => { isa => 'X' },
 'X::Ergatis::Submit' => { isa => 'X::Ergatis' },

);

#========================================================================

=back

=head2 ERROR MESSAGES

=over 4

=cut
#========================================================================

sub X::API::Parameter::Invalid::MalformedEmail::full_message {
  
  my $e = shift;
  my $email = $e->email;

  return "$email is not a valid email address.";
}

sub X::API::Parameter::Invalid::MalformedEmail::user_message {
  shift->full_message;
}

sub X::File::Tar::IllegalContent::user_message {
  my $e = shift;

  return $e->content . ' in the tar file ' . $e->name . ' is not a regular file. Links, directories, and other special file types are not allowed in tar files';
}

sub X::Ergatis::Submit::user_message {
  
  return 'There was a problem submitting your run for execution. Adminstrators have been notified, and will send you an email message when the service is restored. The configuration of your Run Builder has been saved for later use.';
}


1;

__END__

=head1 NAME X

B<X> manages the creation and heirarchy of exception classes for the ___APP___
scaffolding.

=head1 SYNOPSIS

=head1 DESCRIPTION

X implements exception classes.

=head1 ERROR CLASSES

=over 4

=back

=head2 METHODS

=over 4

=item public X caught();

Attempt to catch exceptions

=item public string lookup_pg_error()

Attempts to retrieve the exception class for a postgres error code.
