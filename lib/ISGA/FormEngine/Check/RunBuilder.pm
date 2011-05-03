package ISGA::FormEngine::Check::RunBuilder;
#------------------------------------------------------------------------

=head1 NAME

ISGA::FormEngine::Check provides convenient form verification
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

my %valid_schemes = ( http => [], https => [], ftp => [] );

#------------------------------------------------------------------------

=item public string isValidUploadURL(string value, Form form);

Returns an error if the supplied url is not valid or does not have a
legal unix filename.

=cut
#------------------------------------------------------------------------
sub isValidUploadURL {

  my ($value, $form) = @_;
  
  my $uri = URI->new($value);

  # check scheme
  my $scheme = $uri->scheme();
  
  (defined $scheme and exists $valid_schemes{$scheme}) or
  return "URL is not a valid web or ftp link.";

  # make a head request to the link
  my $ua = LWP::UserAgent->new();
  my $r = $ua->head($value);

  # make sure file is available
  $r->is_success() or return "Unable to follow the supplied link";

  warn "result filename is ", $r->filename();

  # check name, using override or last portion of uri
  my $name = $form->get_input('new_file_name');
  $name ||= $r->filename();

  if ( $name !~ /^[-A-Za-z0-9_ \.]+$/ ) {
    return "File name $name contains illegal special characters.";
  }  

  return '';
}

#------------------------------------------------------------------------

=item public string isUniqueName(string value);

Enforces rule that runbuilder names must be unique within an account.

=cut 
#------------------------------------------------------------------------
sub isUniqueName {

  my ($data, $form) = @_;

  my $message = 'You have already created a run with this name.';

  # first check runs
  ISGA::Run->exists( Name => $data, CreatedBy => ISGA::Login->getAccount)
      and return $message;

  # then check other run builders
  my ($rb) = 
    @{ISGA::RunBuilder->query( Name => $data, CreatedBy => ISGA::Login->getAccount)};

  if ( $rb ) {

    if ( $form->get_formname eq 'run_builder_create' ) {
      my $pipeline = $form->get_input('pipeline');
      $rb->getPipeline == $pipeline or return $message;
    } else {
     $form->get_input('run_builder') == $rb or return $message;
   }
  }

  return '';
}

#------------------------------------------------------------------------

=item public string isFileProvided(string value, FormEngine $form);

Checks that either a file is being uploaded or a previous file selected

=cut 
#------------------------------------------------------------------------
sub isFileProvided {

  my ($data, $form) = @_;

  $form->get_input('upload_url') or $form->get_input('file_name') or $form->get_input('file') 
    or return 'You must either upload a file from your computer or submit a url where ISGA can retrieve the file from.';

  return '';
}

ISGA::FormEngine::SkinUniform->_register_check('RunBuilder::isValidUploadURL');
ISGA::FormEngine::SkinUniform->_register_check('RunBuilder::isUniqueName');
ISGA::FormEngine::SkinUniform->_register_check('RunBuilder::isFileProvided');

1;
__END__

=back

=head1 DIAGNOSTICS

=over 4

=back

=head1 AUTHOR

Center for Genomics and Bioinformatics, biohelp@cgb.indiana.edu

=cut
