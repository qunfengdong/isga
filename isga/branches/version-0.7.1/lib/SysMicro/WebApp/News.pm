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

=item public void Create();

Method to Create a new run builder

=cut
#------------------------------------------------------------------------
sub News::Create {

  my $self = shift;
  my $web_args = $self->args;
  my $form = SysMicro::FormEngine::News->Create($web_args);

  my $args = $self->args;

  if ( $form->canceled() ) {
    $self->redirect( uri => "/News/Recent" );

  } elsif ( $form->ok ) {

    my %form_args =
      ( 
       Type => $form->get_input('news_type'),
       Title => $form->get_input('title'),
       Body  => $form->get_input('body'),
       CreatedBy => SysMicro::Login->getAccount,
       CreatedAt => SysMicro::Timestamp->new,
       IsArchived => 0);
    
    my $news = SysMicro::News->create(%form_args);
    $self->redirect( uri => "/News/Recent?active=$news" );
  } 

  $self->_save_arg( 'form', $form);
  $self->redirect( uri => "/News/Create" );
}     
 
1;
__END__

=back

=head1 DIAGNOSTICS

=over 4

=back

=head1 AUTHOR

Center for Genomics and Bioinformatics, biohelp@cgb.indiana.edu

=cut