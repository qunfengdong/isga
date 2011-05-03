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

=item public void EditDescription();

Method to edit the description for a pipeline builder

=cut
#------------------------------------------------------------------------
sub File::EditDescription {

  my $self = shift;
  my $web_args = $self->args;
  my $form = SysMicro::FormEngine::File->EditDescription($web_args);
  
  my $file = $web_args->{file};

  # make sure this is my file.
  $file->getCreatedBy == SysMicro::Login->getAccount 
    or X::User::Denied->throw();

  if ($form->canceled( )) {

    $self->redirect( uri => "/File/View?file=$file" );
  }

  if ( $form->ok ) {

    $file->edit( Description => $form->get_input('description') );

    $self->redirect
      ( uri => "/File/View?file=$file" );
  }
  
  $self->_save_arg( 'form', $form);
  $self->redirect( uri => "/File/EditDescription?file=$file" );
}

#------------------------------------------------------------------------

=item public void Upload();

Method to upload a file.

=cut
#------------------------------------------------------------------------
sub File::Upload {

  my $self = shift;
  my $web_args = $self->args;
  my $form = SysMicro::FormEngine::File->Upload($web_args);
  
  $form->canceled and $self->redirect( uri => '/File/BrowseMy' );

  if ( $form->ok ) {
    my $upload = $self->apache_req->upload('file_name');

    my %args = ( UserName => $form->get_input('file_name'),
		 Type => $form->get_input('file_type'),
		 Format => $form->get_input('file_format'),
		 Description => $form->get_input('description'),
		 CreatedBy => SysMicro::Login->getAccount,
		 CreatedAt => SysMicro::Timestamp->new,
		 IsHidden => 0 );

    my $file = SysMicro::FileResource->upload( $upload->fh, %args );

    if ( $file->isa( 'SysMicro::File' ) ) {
      $self->redirect( uri => "/File/View?file=$file" );
    } else {
      $self->redirect( uri => "/FileCollection/View?file_collection=$file" );
    }
   } 

  # bounce!!!!!
  $self->_save_arg( 'form', $form);
  $self->redirect( uri => '/File/Upload' );
}  


#------------------------------------------------------------------------

=item public void Hide();

Method to mark a file as hidden.

=cut
#------------------------------------------------------------------------
sub File::Hide {

  my $self = shift;

  my $file = $self->args->{file};

  # make sure this is my file.
  $file->getCreatedBy == SysMicro::Login->getAccount 
    or X::User::Denied->throw();

  $file->isHidden or $file->edit( IsHidden => 1 );

  $self->redirect( uri => "/File/View?file=$file" );
}

#------------------------------------------------------------------------

=item public void Restore();

Method to mark a file as hidden.

=cut
#------------------------------------------------------------------------
sub File::Restore {

  my $self = shift;

  my $file = $self->args->{file};

  # make sure this is my file.
  $file->getCreatedBy == SysMicro::Login->getAccount 
    or X::User::Denied->throw();

  $file->isHidden and $file->edit( IsHidden => 0 );

  $self->redirect( uri => "/File/View?file=$file" );
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
