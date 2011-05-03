package SysMicro::ErgatisRunStatus;
#------------------------------------------------------------------------

=head1 NAME

<SysMicro::ErgatisRunStatus> manages obtaining cluster run status from Ergatis

=head1 SYNOPSIS

=head1 DESRIPTION

=head1 METHODS

=cut
#------------------------------------------------------------------------

use strict;
use warnings;

use Date::Manip;
use XML::Twig;

{

#========================================================================

=back

=head2 CONSTRUCTORS

=over 4

=cut
#========================================================================

#------------------------------------------------------------------------

=item public SysMicro::ErgatisRunStatus new(Ergatis_ID $ergatis_id, hashref $finished_components);

Initialize the ErgatisRunStatus object corresponding to the supplied cluster.

=cut
#------------------------------------------------------------------------
  sub new {
    
    my ($self, $ergatis_id, $finished_components) = @_; 

    # path to runs pipeline.xml
    my $pipeline_xml = '___ergatis_runtime_directory___' . $ergatis_id . '/pipeline.xml';
    
    my %status;
    #  my $twig_root = {commandSet};
    # set twig handler. This is the subroutine that will process the xml
    my $twig_handlers = {'commandSet' =>
			 sub { _summarizePipeline(@_, \%status, $finished_components); } };

    # create new twig with handler
    my $twig = new XML::Twig(TwigHandlers => $twig_handlers);

    my $xml;

    {
      local( $/ ) ;
      open my $fh, '<', $pipeline_xml 
	or X::File->throw( message => "unable to open $pipeline_xml" );
      $xml = <$fh>;
    }
  
    # parse pipeline.xml using twig
    $twig->parse($xml) or X->throw( message => "unable to parse $pipeline_xml" );

    # get rid of twig
    $twig->dispose;
    return \%status;
    
  }
  
#------------------------------------------------------------------------

=item PRIVATE null _summarizePipelie( XML::Twig $twig, XML::Twig::Entity $command, hashref $summary );

Used to process <commandSet> xml tags. Stores useful information in a
hash reference with the component names as a key.

=cut
#------------------------------------------------------------------------
  sub _summarizePipeline {
    
    my ($twig, $command, $summary, $finished_components) = @_;

    my $name = $command->first_child('name')->text;
    
    # kludge to only process our components
    return if ( $name ne 'start pipeline:' and $name !~ /\./ );

    return if exists $finished_components->{$name};
    
    my %fields = ( state => $command->first_child('state')->text );
    return if $fields{state} eq 'incomplete';

    my $startTime = $command->first_child('startTime');
    $startTime and $fields{startTime} = UnixDate( ParseDate($startTime->text), '%Y-%m-%d %H:%M:%S');
    
    my $endTime = $command->first_child('endTime');
    $endTime and $fields{endTime} = UnixDate( ParseDate( $endTime->text ), '%Y-%m-%d %H:%M:%S');
    
    if ( $command->first_child('name')->text ne 'start pipeline:' ) {
      
      foreach my $command ( $command->children('command') ) {
	$fields{total}++;
	$command->first_child('state')->text eq 'complete' and $fields{complete}++;
      }     
      
      my $fileName = $command->first_child('commandSet')->first_child('fileName');

      # now load the file-based subflow
      if (-e $fileName->text || -e $fileName->text . '.gz') {
	my ($c, $t) = _parseCommandFile($fileName->text );
	$fields{total} += $t;
	$fields{complete} += $c;
      }
    }

    $$summary{$name} = \%fields;
  }  
  
  sub _parseCommandFile {

    my ($cD_xml,$total,$complete) = @_;

    my $xml;
    {
      local ( $/ ); 

      my $cD_xml_fh;
      if ($cD_xml =~ /\.gz/) {
	open($cD_xml_fh, "<:gzip", "$cD_xml") || die "can't read $cD_xml: $!"; 
      } elsif ( ! -e $cD_xml && -e "$cD_xml.gz" ) {
	open($cD_xml_fh, "<:gzip", "$cD_xml.gz") || die "can't read $cD_xml: $!"; 
      } else {
	open($cD_xml_fh, "<$cD_xml") || die "can't read $cD_xml: $!";       
      }
      $xml = <$cD_xml_fh>;
    } 

    my $twig = new XML::Twig;
    $twig->parse($xml);

    return _parseCommandSet( $twig->root->first_child('commandSet'), $cD_xml );
  }

  sub _parseCommandSet {

    my ($commandSet, $fileparsed) = @_;

    my ($complete, $total) = ( 0, 0);

    ## we need to get the status counts.  iterate through the commands and
    ##  get the states for each.  distributed subflow groups will count as
    ##  one command each here (mostly for parsing speed purposes)
    foreach my $command ( $commandSet->children('command') ) {
      $total++;
      $command->first_child('state')->text eq 'complete' and $complete++;
    }

    ## all iterative components will have at least one commandSet to parse 
    ##(file-based subflow iN.xml)
    #   these will be linked via fileName elements withinin commandSets
    if ( $fileparsed =~ /component.xml/) {
      for my $subflowCommandSet ( $commandSet->children('commandSet') ) {
        
	## this command set should contain a fileName element
	my $fileName = $subflowCommandSet->first_child("fileName") || 0;

	if ($fileName) {
	  if (-e $fileName->text || -e $fileName->text . '.gz') {
	    my ($c, $t) = _parseIteratorFile($fileName->text);
	    $complete += $c;
	    $total += $t;
	  }
	}
      }
    }
    
    return ($complete, $total);
  }
  
  sub _parseIteratorFile {

    ## this file should be the component's iN.xml
    my ($iN_xml) = @_;
    
    my ($complete, $total) = (0,0);

    my $xml;
    {
      local ( $/ ); 

      my $iN_xml_fh;
      if ($iN_xml =~ /\.gz/) {
	open($iN_xml_fh, "<:gzip", "$iN_xml") || die "can't read $iN_xml: $!"; 
      } elsif ( ! -e $iN_xml && -e "$iN_xml.gz" ) {
	open($iN_xml_fh, "<:gzip", "$iN_xml.gz") || die "can't read $iN_xml: $!"; 
      } else {
	open($iN_xml_fh, "<$iN_xml") || die "can't read $iN_xml: $!";       
      }
      $xml = <$iN_xml_fh>;
    } 

    ## all the commandSet elements in the iN.xml file will reference groups (gN.xml) files
    #   via fileName elements
    my $twig = XML::Twig->new(
			      twig_roots => {
					     'commandSet/fileName' => sub {
					       _parseGroupFile( $_[1]->text, $complete, $total );
					       $_[0]->purge();
					     },
					     'commandSet/commandSet/state' => sub {
					       $_[1]->text eq 'complete' and $complete++;
					       $total++;
					     },
					    },
			     );
    $twig->parse($xml);

    return ($complete, $total);
  }
  
  sub _parseGroupFile {
    ## this file should be a single gN.xml file
    #   it will have both commands and commandSets.  the commands should simply
    #   be counted by the commandSets reference gN.iter.xml files via fileName elements
    my ($gN_xml, $complete, $total) = @_;
    
    my $xml;
    {
      local ( $/ ); 
      my $gN_xml_fh;
      if ($gN_xml =~ /\.gz/) {
	open($gN_xml_fh, "<:gzip", "$gN_xml") || die "can't read $gN_xml: $!"; 
      } elsif ( ! -e $gN_xml && -e "$gN_xml.gz" ) {
	open($gN_xml_fh, "<:gzip", "$gN_xml.gz") || die "can't read $gN_xml: $!"; 
      } else {
	open($gN_xml_fh, "<$gN_xml") || die "can't read $gN_xml: $!";       
      }
      $xml = <$gN_xml_fh>;
    }

    my $twig;
    
    $twig = XML::Twig->new(
			   twig_roots => {
					  'command/state' => sub {
					    $_[1]->text eq 'complete' and $complete++;
					    $total++;
					    $_[0]->purge();
					  },
					 },
			  );
    $twig->parse($xml);
  }

#------------------------------------------------------------------------

=item private twig handler retrieve_status(status, %status)

Used to process <commandSet> xml tags.  Places <name> text value and <state>
test value in %status as the key and value repectively.

=cut
#------------------------------------------------------------------------
  sub retrieve_status {
    my ($twig, $command, $status) = @_;
    # save the over pipeline state.
    if($command->first_child('name')->text eq "start pipeline:"){
      $$status{pipelineState} = $command->first_child('state')->text;
    # otherwise save the state of individual components
    }else{
      return if($command->first_child('name')->text !~ /\./);
      $$status{$command->first_child('name')->text} = $command->first_child('state')->text;
    }
  }

  
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
