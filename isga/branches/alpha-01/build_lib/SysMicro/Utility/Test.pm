package SysMicro::Utility::Test;
#------------------------------------------------------------------------

=head1 NAME

SysMicro::Utility::Test

=head1 SYNOPSIS

Test methods for the SysMicro::Utility class.

=head1 METHODS

=over 4

=item use

=back

=cut
#------------------------------------------------------------------------

use strict;
use warnings;

use Test::Deep qw(cmp_deeply bag);
use Test::Exception;
use Test::More;

use SysMicro::X;

use SysMicro::Utility;

use base 'Test::Class';

sub cleanEmail : Test( 5 ) {

  my $test = "chemmeri\@indiana.edu";
  is( SysMicro::Utility->cleanEmail($test), 'chemmeri@indiana.edu');

  # confirm that domain is case incensitive
  $test = "chemmeri\@INDIANA.EDU";
  is( SysMicro::Utility->cleanEmail($test), 'chemmeri@indiana.edu');

  # confirm that username is case sensitive
  $test = "CHEMMERI\@INDIANA.EDU";
  is( SysMicro::Utility->cleanEmail($test), 'CHEMMERI@indiana.edu');

  # survives + bug
  $test = "chemmeri+1\@indiana.edu";
  is( SysMicro::Utility->cleanEmail($test), 'chemmeri+1@indiana.edu');
 
  # check for exceptions
  $test = "chemmeri but not valid";
  throws_ok { SysMicro::Utility->cleanEmail($test) } 'X::API::Parameter::Invalid::MalformedEmail';

};


sub parseAndCleanEmails : Test( 8 ) {

  my $test = "chemmeri\@indiana.edu";
  cmp_deeply( SysMicro::Utility->parseAndCleanEmails($test), [ 'chemmeri@indiana.edu' ] );

  $test = "no email\@here";
  cmp_deeply( SysMicro::Utility->parseAndCleanEmails($test), [ ] );

  $test = "chemmeri+1\@indiana.edu";
  cmp_deeply( SysMicro::Utility->parseAndCleanEmails($test), [ 'chemmeri+1@indiana.edu' ] );

  # test for invalid addresses
  $test = "chemmeri\@indiana.edu, no email";
  cmp_deeply( SysMicro::Utility->parseAndCleanEmails($test), [ 'chemmeri@indiana.edu' ] );

  # test comma separated
  $test = "chemmeri\@indiana.edu, chemmeri\@a.com";
  cmp_deeply( SysMicro::Utility->parseAndCleanEmails($test), [ 'chemmeri@indiana.edu', 
							       'chemmeri@a.com' ] );

  # test white space separated
  # fails with Email::AddressParser
  $test = "chemmeri\@indiana.edu chemmeri\@a.com";
  cmp_deeply( SysMicro::Utility->parseAndCleanEmails($test), [ 'chemmeri@indiana.edu', 
							       'chemmeri@a.com' ] );

  # test newline separated
  # fails with Email::AddressParser
  $test = "a\@b.com, c\@d.com\nchemmeri+1\@indiana.edu";
  cmp_deeply( SysMicro::Utility->parseAndCleanEmails($test), [ 'a@b.com',
							     'c@d.com',
							     'chemmeri+1@indiana.edu' ] );

  # test case tools
  $test = "a\@B.com, C\@d.com\nchemmeri+1\@indiana.edu";
  cmp_deeply( SysMicro::Utility->parseAndCleanEmails($test), [ 'a@b.com',
							     'C@d.com',
							     'chemmeri+1@indiana.edu' ] );


};


sub extractSiteTags : Test( 6 ) {
  
  my $test = <<'END';
<h1>Run Setup</h1>

<sys:style type="text/css" media="screen"> 
  @import "/include/css/uni-form.css"; 
</sys:style>

END

  my $answer = <<'END';
<h1>Run Setup</h1>



END

  my $tags = SysMicro::Utility->extractSiteTags( \$test );

  is( $test, $answer );
  cmp_deeply( $tags, { style => [ '<style type="text/css" media="screen"> 
  @import "/include/css/uni-form.css"; 
</style>' ] } );
  

  $test = <<'END';
blargh wharble wharble <sys:meta http-equiv="refresh" content="30">asdasd
END

  $answer = <<'END';
blargh wharble wharble asdasd
END

  $tags = SysMicro::Utility->extractSiteTags( \$test );
  is( $test, $answer );
  cmp_deeply( $tags, { meta => [ '<meta http-equiv="refresh" content="30">' ] } );

  # test tag at beginning of string
  $test = '<sys:title>SysMicro Pipeline Service</sys:title> and stuff';
  $answer = ' and stuff';
  $tags = SysMicro::Utility->extractSiteTags( \$test );
  is( $test, $answer );
  cmp_deeply( $tags, { title => '<title>SysMicro Pipeline Service</title>' } );
  
  


}



1;
__END__

=back

=head1 DIAGNOSTICS

=over 4

=back
=head1 AUTHOR

Chris Hemmerich, biohelp@cgb.indiana.edu
