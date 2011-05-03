package ISGA::Site;
#------------------------------------------------------------------------
=pod

=head1 NAME

ISGA::Site contains class methods that aid ISGA installation from
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

Returns the base URI to be used during the build process.

=item public [string] getErrorNotificationEmail();

Returns the error 

=item public string getMasonComponentRoot();

Returns the path to the mason component root.

=item public string getMailSender();

Returns the string to be used as the from header in email sent by the system.

=item public string getGBrowseDirectory();

Returns the directory for Gbrowse config and databases.

=item public string getServerName();

Returns the name of this ISGA server. Used in communication.

=cut
#------------------------------------------------------------------------
sub getBaseURI { return "___base_uri___"; }

sub getErrorNotificationEmail { return ___ERRORNOTIFICATIONEMAIL___; }

sub getMasonComponentRoot { return '___package_masoncomp___'; }

sub getMailSender { return '___mail_sender___'; }

sub getGBrowseDirectory { return '___gbrowse_directory___'; }

sub getServerName { return '___SERVERNAME___'; }

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
