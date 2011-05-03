package SysMicro::FormEngine::Check::UserGroup;
#------------------------------------------------------------------------

=head1 NAME

SysMicro::FormEngine::Check provides convenient form verification
methods tied to the FormEngine system.

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

=item public String nameIsAvailable(String value, String name, Form form);

Asserts that the name supplied to the form isAvailable for the class

=cut 
#------------------------------------------------------------------------
sub nameIsAvailable {

  my ($data, $form) = @_;
  
  my $name = $form->get_input('name'));

  my $error = "This name is already in use.";

  # check values
  return  ( SysMicro::Party->exists(Name => $name) ? $error : '' );
}

#------------------------------------------------------------------------

=item public String isMine(UserGroup value);

Asserts that the UserGroup supplied is owned by the account logged
in. Assumes that user_group apache var name is used to ensure variable
is a UserGroup

=cut 
#------------------------------------------------------------------------
sub isMine {
  shift->getOwnedBy == SysMicro::Login->getAccount ? '' : 'You do not own this group.';
}

#------------------------------------------------------------------------

=item public String ownsInvitation(Invitation invitiation, Form form);

Makes sure the supplied invitation is tied to this group.

=cut 
#------------------------------------------------------------------------
sub ownsInvitation {

  my ($invite, $form) = @_;

  my $group = $form->get_input('user_group');

  $group == $invite->getUserGroup ? '' : 'This invitation is for a different group';
}

#
#
# Register all methods below
#

SysMicro::FormEngine::SkinUniform->_register_check('UserGroup::nameIsAvailable');
SysMicro::FormEngine::SkinUniform->_register_check('UserGroup::isMine');
SysMicro::FormEngine::SkinUniform->_register_check('UserGroup::ownsInvitation');


1;
__END__

=back

=head1 DIAGNOSTICS

=over 4

=back

=head1 AUTHOR

Chris Hemmerich, chemmeri@cgb.indiana.edu

=cut
