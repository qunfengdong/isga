package SysMicro::Handler::Gbrowse;
#------------------------------------------------------------------------

=head1 NAME

SysMicro::Handler::GBrowse is an apache handler for authenticating GBrowse sessions

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=cut
#------------------------------------------------------------------------
use warnings;
use strict;

use NEXT;

use MasonX::WebApp;
use Apache2::Request;

use Apache2::Const qw( OK REDIRECT );

use base 'MasonX::WebApp::ApacheHandler';

use SysMicro::Handler::WebApp;

{

  # we have an apache handler
  my $ah;

#========================================================================

=head2 CLASS METHODS

=over 4

=cut
#========================================================================

#------------------------------------------------------------------------

=item PRIVATE void _initialize();

Initialize the apache handler we are based upon. Arguments are passed along to HTML::Mason::ApacheHandler constructor.

=cut
#------------------------------------------------------------------------
  sub _initialize {

    my $class = shift;
    $ah = MasonX::WebApp::ApacheHandler->new(args_method => 'mod_perl', 
					     error_mode => 'fatal', 
					     @_);
  }

#------------------------------------------------------------------------

=item public static APACHE_STATUS handler(Apache2::Request r);

Called to process incoming apache requests. Manages sessions and
cookies and will attempt to process the request with your defined
WebApp implementation before calling Mason.

=cut
#------------------------------------------------------------------------
  sub handler {
    
    my $class = shift;

    my $r = Apache2::Request->new($class);
    my $args = $ah->request_args($r) || {};

    warn "\n*************************** NEW BROWSER REQUEST ", $r->uri, " ********************\n";

    # recycle database connection
    ___APP___::DB->_connect;

    # define session and login
    local $___APP___::Session = undef;

    # this should be handled in WebApp::_init
    ___APP___::Login->blank();

    # run the webapp, exit now if we redirected/aborted
    my $app;
    eval { $app = SysMicro::Handler::WebApp->new(apache_req => $r, args => $args ) };

    if ( $@ ) {
      warn "WEBAPP EXPLODED!!!!!!!!!!!!!!!";
      warn $@;
      UNIVERSAL::isa( $@, 'X' ) ? $@->rethrow : X::Dropped->new(error => $@)->throw;
    }

    # let's plugin a little session | username sanity check here
    # if username in session doesn't match us, throw a giant fit

    if ( $app->aborted ) {
      return $app->abort_status;
    }

    local $___APP___::WebApp = $app;

    # this method will capture abort and redirect exceptions
    # any exceptions are from autohandler or mason internals
    my $return = eval { $ah->handle_request($r) };

    # save the errors before we clean the session
    my $e = $@;
    $app->clean_session;

    # these are edge case exceptions, so go ahead and redirect to error page
    # rather than try to get them back into mason
    if ( $e ) {
      UNIVERSAL::isa( $e, 'X' ) or $e = X::Dropped->new(error => $e);
      eval { $app->_handle_exception($e)};
      return $app->abort_status; 
    }

    # return the status code
    return $return;
  }

  __PACKAGE__->_initialize(data_dir => '___MASONDATADIR___',
			   comp_root => '___package_masoncomp___' );

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
