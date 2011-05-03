#! /usr/bin/perl

=head1 NAME

create_isga_user.pl - Creates a new isga user

=head1 SYNOPSIS

USAGE: create_isga_user.pl
         --email=email address
         --name=name
         --password=password
         --institution=institution
       [ --news_admin
         --run_admin
         --account_admin
         --policy_admin
         --help
       ]

=head1 OPTIONS

B<--email>
    Email address of the person using the account.

B<--name>
    Name of the person using the account.

B<--password>
    Password for the account.

B<--institution>
    Institution the account is part of.

B<--news_admin>
    Optional. Adds the account to the news administrator group.

B<--run_admin>
    Optional. Adds the account to the run administrator group.

B<--account_admin>
    Optional. Adds the account to the account administrator group.

B<--policy_admin>
    Optional. Adds the account to the policy administrator group.

B<--help,-h> 
    This help message

=head1 DESCRIPTION

=head1 INPUT

=head1 OUTPUT

=head1 CONTACT

=cut

use strict;
use warnings;

use ISGA;
use Getopt::Long qw(:config no_ignore_case no_auto_abbrev pass_through);
use Pod::Usage;

my %options = ();
my $result = GetOptions (\%options,
			 'email=s',
			 'name=s',
			 'password=s',
			 'institution=s',
			 'news_admin',
			 'run_admin',
			 'account_admin',
			 'policy_admin',
			 'help|h') || pod2usage();

## display documentation
if( $options{help} ) {
  pod2usage( {-exitval=> 0, -verbose => 2, -output => \*STDERR} );
}

&check_parameters(\%options);

my $uc = ISGA::UserClass->new( Name => ISGA::SiteConfiguration->value('default_user_class') );

# create the account
my $account = 
  ISGA::Account->create( Email => $options{email},
			 Password => Digest::MD5::md5_hex($options{password}),
			 Name => $options{name}, Institution => $options{institution},
			 IsPrivate => 1, IsWalkthroughDisabled => 0, UserClass => $uc,
			 IsWalkthroughHidden => 0, Status => ISGA::PartyStatus->new('Active'));

my %admin_map = ( news_admin => 'News Administrators',
		  run_admin => 'Run Administrators',
		  account_admin => 'Account Administrators',
		  policy_admin => 'Policy Administrators' );

while ( my ($key, $value) = each %admin_map ) {

  if ( exists $options{$key} ) {
    my $group = ISGA::AccountGroup->new( Name => $value );
    $account->addGroup($group);
  }
}
  
sub check_parameters {

  my ($options) = @_;

}

