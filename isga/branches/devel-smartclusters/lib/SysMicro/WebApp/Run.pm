## no critic
# we turn off perl critic because we package doesn't match file
package SysMicro::WebApp;
## use critic
#------------------------------------------------------------------------

=head1 NAME

SysMicro::WebApp manages the interface to MASON for SysMicro.

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

=item public void Submit();

Method to Submit a run.

=cut
#------------------------------------------------------------------------
sub Run::Submit {

  my $self = shift;
  my $args = $self->args;

  my $run_builder = $args->{run_builder} or X::API::Parameter::Missing->throw();

  # make sure this is my run_builder
  $run_builder->getCreatedBy == SysMicro::Login->getAccount
   or  X::User::Denied->throw( error => 'You do not own this.' );

  my $run = SysMicro::Run->submit($run_builder);

  # nuke the builder
  foreach ( @{$run_builder->getInputs} ) {
    $_->delete();
  }
  
  my $pipeline = $run_builder->getPipeline;

  # nuke it and redirect
  $run_builder->delete();

  $self->redirect( uri => "/Run/View?run=$run" );
}

sub Exception::Run::Submit {

  my $self = shift;

  my $old = '___ergatis_submit_directory___/' . $self->args->{run_builder}->getErgatisDirectory;
  my $new = $old . '-save-' . time;

  # send email about error

  # remove any existing files
  rename( $old, $new );
}


return 1;

__END__

=back

=head1 DIAGNOSTICS

=over 4

=back

=head1 AUTHOR

Center for Genomics and Bioinformatics, biohelp@cgb.indiana.edu

=cut
