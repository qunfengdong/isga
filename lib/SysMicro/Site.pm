package SysMicro::Site;
#------------------------------------------------------------------------
=pod

=head1 NAME

SysMicro::Site contains class methods that aid SysMicro installation from
server to server.  Such as getting the base uri for a server.

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

=item public string getBaseURI();

Returns the BaseUri for to be used during the build process.

=item public [string] getErrorNotificationEmail();

Returns the e

=cut
#------------------------------------------------------------------------
sub getBaseURI { return "___base_uri___"; }

sub getErrorNotificationEmail { return ___ERRORNOTIFICATIONEMAIL___; }





#------------------------------------------------------------------------

1;

__END__

=back

=head1 DIAGNOSTICS

=over 4

=item X::API::Parameter

=item X::API::Compare

=back

=head1 AUTHOR

Center for Genomics and Bioinformatics,  biohelp@cgb.indiana.edu

=cut
