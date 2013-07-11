package ISGA::Utility;
#------------------------------------------------------------------------
=pod

=head1 NAME

ISGA::Utility contains class methods that havent been properly
planned. Like that drawer in your kitchen, everything here should have
a better home.

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=cut
#------------------------------------------------------------------------
use strict;
use warnings;

use Email::Find;
use Email::Valid;

my %validSiteTags =
  ( 
   'title' => { has_close => 1, unique => 1 },
   'script' => { has_close => 1, unique => 0 },
   'style' => { has_close => 1, unique => 0 },
   'link' => { has_close => 1, unique => 0 },
   'rightmenu' => { has_close => 1, unique => 1 },
   'meta' => { has_close => 0, unique => 0 },
  );

#========================================================================

=head2 CLASS METHODS

=over 4

=cut
#========================================================================

#------------------------------------------------------------------------

=item public string printSize(int size);

Converts a number of bytes into a human readable file size.

=cut
#------------------------------------------------------------------------
sub printSize {

  my ($class, $size) = @_;

  my $suffix = 'Bytes';

  if ( $size > 1024 ) {

    $size /= 1024;
    $suffix = 'KB';

    if ( $size > 1024 ) {
      
      $size /= 1024;
      $suffix = 'MB';

      if ( $size > 1024 ) {

	$size /= 1024;
	$suffix = 'GB';
      }
    }
  }

  return sprintf( "%.2f %s", $size, $suffix );
}


#------------------------------------------------------------------------

=item public string cleanEmail(string $email);

Cleans up an email address so that it can be compared to other
versions of itself.

Throws an X::API::Parameter::Invalid::MalformedEmail exception if the
string is not a valid email address.

=cut
#------------------------------------------------------------------------
sub cleanEmail {

  my ($class, $string) = @_;

  my ($address, $object) = Email::Valid->address($string);
  $address or X::API::Parameter::Invalid::MalformedEmail->throw( $string );

  return lc($object->user) . '@' . lc( $object->host );
}

#------------------------------------------------------------------------

=item public [string] parseAndCleanEmails(string $content);

Extracts and cleans email messages in the supplied text. They are
returned as a reference to an array.

=cut
#------------------------------------------------------------------------
sub parseAndCleanEmails {

  my ($class, $string) = @_;

  my @tmp;
  my @emails;

  my $finder = Email::Find->new( sub { push @tmp, $_[0] } );
  $finder->find(\$string);

  foreach ( @tmp ) {
    push @emails, lc($_->user) . '@' . lc($_->host);
  }

  return \@emails;
}
  
#------------------------------------------------------------------------

=item public {SiteTags} extractSiteTags(string $html);

Extracts custom tags to be passed up the chain. We dont need to deal
with nested tags or other fancy things requiring an expensive
tokenizer and parser.

=cut
#------------------------------------------------------------------------
sub extractSiteTags {

  my ($class, $html) = @_;

  my %siteTags;

  my %duplicateTags;

  # our pointer into the html text
  my $p = 0;
  
  # find the first instance of a custom tag
  while ( defined( my $i = index($$html,'<sys:', $p) ) ) {
    last unless $i >= 0;
    $p = $i;

    # remove sys:
    substr($$html, $i+1,4,'');

    # make sure we recognize this tag
    my $close = index($$html, '>', $i);
    $close >= 0 or X::HTML::SiteTag::Malformed->throw();

    my $taglength = $close-($i+1);

    my $tag = substr($$html, $i+1, $taglength);
    $tag =~ /^([a-z]+)/;
    my $closeTag = $1;

    exists $validSiteTags{ $closeTag } or 
      X::HTML::SiteTag::Illegal->throw( tag => $closeTag );
    
    my $c = 0;
    my $siteTag;

    if ( $validSiteTags{$closeTag}{has_close} ) {

      # find the closing tag
      $c = index($$html, "</sys:$closeTag>", $close);
      $c >= 0 or X::HTML::SiteTag::Malformed->throw();
      substr($$html, $c+2,4,'');

      # excise the tag from the html document and save it for site tags
      $siteTag = substr($$html, $i, $c-$i+length($closeTag)+3, '');

    } else {
      $siteTag = substr($$html, $i, $close-$i+1, '');
    }

    if ( $validSiteTags{$closeTag}{unique} == 1 ) {
      $siteTags{ $closeTag } = $siteTag;
    } else {
      
      if ( ! exists $duplicateTags{$siteTag} ) {
	push @{$siteTags{ $closeTag }}, $siteTag;
	$duplicateTags{$siteTag} = 1;
      }
    }

  }

  return \%siteTags;
}

#------------------------------------------------------------------------

=item public string url( Path => string, Query => hashref );

Writes the supplied contents to the supplied file.

=cut
#------------------------------------------------------------------------
sub url {

 my ($class, %args) = @_;

 my $uri = URI->new;

 $uri->path($args{Path});

 my %query = $args{Query} ? @{$args{Query}} : ();

 # $uri->query_form doesn't handle hash ref values properly
 while ( my ( $key, $value ) = each %query ) {
     $query{$key} = ref $value eq 'HASH' ? [ %$value ] : $value;
 }

 $uri->query_form(%query) if %query;

 return $uri->canonical;
}


#------------------------------------------------------------------------

=item public void writeFile(string $file, string $contents);

Writes the supplied contents to the supplied file.

=cut
#------------------------------------------------------------------------
sub writeFile {

  my ($self, $name, $contents) = @_;

  open my $fh, '>', $name or X->throw( error => "$name - $!" );
  print $fh $contents;
  close $fh;
}

#------------------------------------------------------------------------
=item public void countFileLines(string $file);

Return the number of lines in a file

=cut
#------------------------------------------------------------------------
sub countFileLines {
  my ($self, $name) = @_;
  my $count = 0;
  open my $fh, '<', $name or X->throw( error => "$name - $!" );
  $count++ while(<$fh>);
  close $fh;
  return $count;
}
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
