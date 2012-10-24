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

=item public void EditStatus();

Edit a global pipelines availability.

=cut
#------------------------------------------------------------------------
sub GlobalPipeline::EditStatus {

  my $self = shift;
  my $web_args = $self->args;

  # we need a user class
  exists $web_args->{pipeline_status} or X::API::Parameter::Missing->throw( parameter => 'PipelineStatus' );
  exists $web_args->{pipeline} or X::API::Parameter::Missing->throw( parameter => 'Pipeline' );
  my $pipeline_status = $web_args->{pipeline_status};
  my $pipeline = $web_args->{pipeline};

  # edit the user class
  $pipeline->edit(Status => $pipeline_status);

  # save result
  $self->_save_arg( echo => $pipeline_status->getName );
  
  # redirect to what
  $self->redirect( uri => '/Echo' );
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
