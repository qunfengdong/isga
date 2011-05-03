#! /usr/bin/perl

=head1 NAME

download_file_to_repository.pl - Downloads a file from a supplied URL and adds it to the ISGA repository.

=head1 SYNOPSIS

USAGE: download_file_to_repository.pl
       [ --help
       ]

=head1 OPTIONS

B<--upload_request>
  The upload request object to be processed.

B<--help>
  This help message

=head1 DESCRIPTION

This script won't scale to a large system as it only handles a single
request per execution. If this ever becomes a real problem, it's
probably time to move to POE.

=head1 INPUT

=head1 OUTPUT

=head1 CONTACT

=cut

use strict;
use warnings;

use ISGA;
use Getopt::Long qw(:config no_ignore_case no_auto_abbrev pass_through);
use Pod::Usage;

use LWP::UserAgent;
use HTTP::Request;
use HTTP::Status qw(status_message);
use File::Temp;

eval { 

  my %options = ();
  my $result = GetOptions(\%options,
			  'upload_request=i',
			  'help|h') || pod2usage();

  ## display documentation
  if( $options{help} ) {
    pod2usage( {-exitval=> 0, -verbose => 2, -output => \*STDERR} );
  }
  
  # grab the first pending request or we're done
  my ($request) = @{ISGA::UploadRequest->query( Status => 'Pending' )};
  $request or exit(0);
  
  # mark this request as being processed
  $request->edit( Status => 'Running' );
  
  my $account = $request->getAccount();
  
  eval {
    
    ISGA::DB->begin_work();
    
    # retrieve the file
    my $ua = LWP::UserAgent->new();
    my $req = HTTP::Request->new( GET => $request->getURL() );
    my $bytes_received = 0;
    
    # create temporary file name
    my $tmp_fh = File::Temp::tempfile();
    
    sub callback {
      
      my ($chunk, $res) = @_;
      $bytes_received += length($chunk);
      
      print $tmp_fh $chunk;
    }
    
    my $res = $ua->request($req, \&callback, 1024 * 16);
    
    my $file_name = $request->getUserName();
    
    if ( $res->is_success ) {
      $file_name ||= $res->filename();
    } else {
      
      my $code = $res->code();

      # this is a user error
      X::User::HTTP::Request->throw( url => $request->getURL(), status_code => $code,
				     status_text => status_message($code) );
    }
    
    # seek to the beginning of the file handle so that we can read from it later
    seek($tmp_fh,0,0);


    # are we a run builder
    if ( $request->isa('ISGA::RunBuilderUploadRequest') ) {
      
      my $pipeline = $request->getPipeline();
      
      my %args = (UserName => $file_name,
		  CreatedBy => $account,
		  PipelineInput => $request->getPipelineInput());
      
      if ( my $description = $request->getDescription() ) {
	$args{Description} = $description;
      }
      
      $pipeline->uploadInputFile($tmp_fh, %args);
    } elsif ( $request->isa('ISGA::JobUploadRequest') ) {
      
      
    } else {
      X::API->throw( error => ref($request) . " is not a valid UploadRequest type" );
    }
    
    $request->edit( Status => 'Finished' );
    
    # ask to notify the user
    ISGA::AccountNotification->create(Account => $account, Var1 => $request,
	       Type => ISGA::NotificationType->new(Name => 'Upload Request Complete'));
    
    # commit
    ISGA::DB->commit();
    
  };
  
  if ( $@ ) {
    
    # end transaction
    ISGA::DB->rollback();
    
    my $e = ( X->caught() ? $@ : X::Dropped->new(error => $@) );   
    
    $request->edit( Status => 'Failed',
		    Exception => $e->full_message() );
    
    # notify the user
    ISGA::AccountNotification->create(Account => $account, Var1 => $request,
				      Type => ISGA::NotificationType->new( Name => 'Upload Request Failed'));
    
    
    # if it 
    $e->isa( 'X::User') or $e->rethrow();
  }

};

if ( $@ ) {

  my $e = ( X->caught() ? $@ : X::Dropped->new(error => $@) ); 

  # build message
  my $message  .= "Message: " . $e->full_message . "\n";
  $message .= $e->trace . "\n\n";

  ISGA::Log->alert($message);
}



