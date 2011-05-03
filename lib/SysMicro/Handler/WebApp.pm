package SysMicro::Handler::WebApp;

use strict;
use warnings;

use base 'SysMicro::WebApp';





#------------------------------------------------------------------------

=item public ___APP___::WebApp new();

Wrapper to do some custom work

=cut
#------------------------------------------------------------------------
  sub new {

    my ($class, %p) = @_;

    my $self =  bless { __apache_req__ => delete $p{apache_req},
			__args__       => delete $p{args},
		      }, $class;
    
    my $r = $self->apache_req;

    eval { 

      # we're always doing Gbrowse
      my $use = SysMicro::UseCase->new( Name => '/Browser' );

      # run this in eval in case parameter mapping dies
      $self->_init;

      # permissions check
      SysMicro::Login->do( $use );

      # make sure this is our run
      my $path = $r->path_info();

      my ($id) = $path =~ m{/(\d+)/};

      my $run = SysMicro::Run->new( Id => $id );

      $run->getCreatedBy == SysMicro::Login->getAccount
	or X::User::Denied->throw();

    }; 
   
    if ( my $e = MasonX::WebApp::Exception::Abort->caught ) {
      return $self;

    } elsif ( $e = X::User::Denied::RequiresLogin->caught ) {
      $self->_save_arg( error => $e );
      return $self;
      
    } elsif ( $e = X->caught() || $@) {
      UNIVERSAL::isa( $e, 'X' ) or $e = X::Dropped->new(error => $e);
      eval { $self->_handle_exception($e) };
      if ( $@ ) {
	if ( ! MasonX::WebApp::Exception::Abort->caught ) {
	  UNIVERSAL::isa( $@, 'X' ) ? $@->rethrow : X::Dropped->throw(error => $@);
	}
      }  
    }
    return $self;
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
