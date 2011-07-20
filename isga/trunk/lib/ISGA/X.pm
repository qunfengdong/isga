package ___APP___::X;
#------------------------------------------------------------------------

=head1 NAME

B<ISGA::X> provides error classes created for this project.

=head1 SYNOPSIS

=head1 DESRIPTION

=head1 METHODS

=cut
#------------------------------------------------------------------------

use strict;
use warnings;

use ___APP___::FoundationX;

use base qw( ISGA::FoundationX );

use Exception::Class
(

 'X::TestError' => { isa => 'X' },


 'X::API::Parameter::Invalid::MalformedEmail' => { isa => 'X::API::Parameter::Invalid',
						   fields => [ 'email' ] },
 'X::File::Tar' => { isa => 'X::File' },
 'X::File::Tar::IllegalContent' => { isa => 'X::File::Tar', fields => [ 'content' ] },


 'X::API::Configuration' => { isa => 'X::API', fields => [ 'variable' ] },
 'X::API::Configuration::Missing' => { isa => 'X::API::Configuration' },


 'X::File::FASTA' => { isa => 'X::File' },
 'X::File::FASTA::Binary' => { isa => 'X::File::FASTA' },
 'X::File::FASTA::Header' => { isa => 'X::File::FASTA', fields => ['line'] },
 'X::File::FASTA::Header::BeginningSpace' => { isa => 'X::File::FASTA::Header' },
 'X::File::FASTA::Header::BeginningNumber' => { isa => 'X::File::FASTA::Header' },
 'X::File::FASTA::Header::Duplicate' => { isa => 'X::File::FASTA::Header' },
 'X::File::FASTA::Header::MissingSymbol' => { isa => 'X::File::FASTA::Header' },
 'X::File::FASTA::Sequence::IllegalCharacter' => { isa => 'X::File::FASTA',
						   fields => [ 'line', 'character', 'alphabet' ] },

 'X::SGE' => { isa => 'X' },
 'X::SGE::Job' => { isa => 'X::SGE', fields => [ 'id' ] },

 'X::Ergatis' => { isa => 'X' },
 'X::Ergatis::Submit' => { isa => 'X::Ergatis' },

 # User Errors
 'X::User::HTTP::Request' => { isa => 'X::User', 
			       fields => [ 'url', 'status_code', 'status_text' ] },

 'X::GBrowse' => { isa => 'X' },
 'X::GBrowse::IncompleteInstallation' => => { isa => 'X::GBrowse' },

);

#========================================================================

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

# since this is X::User user_message() defaults to message().
sub X::User::HTTP::Request::message {
  my $e = shift;

  return 'Error retrieving ' . $e->url . ' HTTP status was (' . $e->status_code . ') ' . 
    $e->status_text;
}


# FASTA File error messages

sub X::File::FASTA::user_message {
  return shift->message();
}

sub X::File::FASTA::Binary::message {
  my $e = shift;
  my $name = $e->name;

  return "File $name contains binary data, but Fasta format requires text files.";
}

sub X::File::FASTA::Header::BeginningSpace::message {
  my $e = shift;
  my $line = $e->line;
  my $name = $e->name;

  return "Fasta header does not allow whitespace between '>' and name at line $line in $name.";
}

sub X::File::FASTA::Header::BeginningNumber::message {
  my $e = shift;
  my $line = $e->line;
  my $name = $e->name;

  return "Fasta header should not begin with a number after '>' at line $line in $name.";
}

sub X::File::FASTA::Header::Duplicate::message {
  my $e = shift;
  my $line = $e->line;
  my $name = $e->name;

  return "Fasta headers should be unique at line $line in $name.";
}

sub X::File::FASTA::Header::MissingSymbol::message {
  my $e = shift;
  my $line = $e->line;
  my $name = $e->name;

  return "Fasta file $name sequence must be preceded by header and header must begin with '>' character.";
}

sub X::File::FASTA::Sequence::IllegalCharacter::message {
  my $e = shift;
  my $line = $e->line;
  my $c = $e->character;
  my $a = $e->alphabet || 'fasta';
  my $name = $e->name;
  
  return "Illegal $a character '$c' at line $line of Fasta file $name.";
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
