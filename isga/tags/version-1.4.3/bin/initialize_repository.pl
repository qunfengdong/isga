#! /usr/bin/perl

use strict;
use warnings;

use ISGA;

use File::Path;

# test that file_repository is defined
my $file_repository = ISGA::SiteConfiguration->value('file_repository') 
    or die "You must define a file_repository location through the web interface before running this tool\n";

# declare hash
my @hash = qw( A B C D E F G H I J K L M N O P Q R S T U V W X Y Z a b c d e f g h i j k l m n o p q r s t u v w x y z 0 1 2 3 4 5 6 7 8 9 _ - );

# test that file_repository doesn't exist
if ( -e $file_repository ) {

  -r $file_repository and -w $file_repository and -x $file_repository
    or die "Repository does not have rwx permissions for this user.\n";

  foreach my $l1 ( @hash ) {
    foreach my $l2 ( @hash ) {
    -e "$file_repository/$l1/$l2" 
      or die "Repository subdirectory $l1/$l2 does not exist. Remove the repository or repair by hand.\n";
    -r "$file_repository/$l1/$l2" and -w "$file_repository/$l1/$l2" and -x "$file_repository/$l1/$l2" 
      or die "Repository subdirectory $l1/$l2 does not have rwx permissions for this user. Remove the repository or repair by hand.\n";
    }
  }

  foreach ( qw( databases downloads ) ) {
    -e "$file_repository/$_" or die "Repository subdirectory $_ does not exist. Remove the repository or repair by hand.\n";
    -r "$file_repository/$_" and -w "$file_repository/$_" and -x "$file_repository/$_" 
      or die "Repository subdirectory $_ does not have rwx permissions for this user. Remove the repository or repair by hand.\n";
  }
  
  print "Repository exists and is configured correctly.\n";
  exit 0;
}

foreach my $l1 ( @hash ) {
  foreach my $l2 ( @hash ) {
    File::Path::make_path( "$file_repository/$l1/$l2" );
  }
}

foreach ( qw( databases downloads ) ) {
  File::Path::make_path( "$file_repository/$_" );
}
  
