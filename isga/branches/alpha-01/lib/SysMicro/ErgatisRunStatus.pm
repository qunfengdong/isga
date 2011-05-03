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

use Data::Dumper;

{

#========================================================================

=back

=head2 CONSTRUCTORS

=over 4

=cut
#========================================================================

#------------------------------------------------------------------------

=item public SysMicro::ErgatisRunStatus new(Ergatis_ID $ergatis_id);

Initialize the ErgatisRunStatus object corresponding to the supplied cluster.

=cut
#------------------------------------------------------------------------
  sub new {
    use XML::Twig;
    
    my ($self, $ergatis_id) = @_; 
    # path to runs pipelin.xml
    my $pipeline_xml = '/research/projects/sysmicro/ergatis/projects/sysmicro/workflow/runtime/pipeline/' 
      . $ergatis_id . '/pipeline.xml';
    
    my %status;
    #  my $twig_root = {commandSet};
    # set twig handler. This is the subroutine that will process the xml
    my $twig_handlers = {'commandSet' => sub { _summarizePipeline(@_, \%status); } };

    # create new twig with handler
    my $twig = new XML::Twig(TwigHandlers => $twig_handlers);

    # parse pipeline.xml using twig
    $twig->parsefile($pipeline_xml)
      or X->throw( error => "$pipeline_xml doesn't exist\n" );

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
    
    my ($twig, $command, $summary) = @_;
    
    my $name = $command->first_child('name')->text;
    
    # kludge to only process our components
    return if $name ne 'start pipeline:' and $name !~ /\./;
    
    my %fields = ( state => $command->first_child('state')->text );
    
    my $startTime = $command->first_child('startTime');
    $startTime and $fields{startTime} = UnixDate( ParseDate($startTime->text), '%Y-%m-%d %H:%M:%S');
    
    my $endTime = $command->first_child('endTime');
    $endTime and $fields{endTime} = UnixDate( ParseDate( $endTime->text ), '%Y-%m-%d %H:%M:%S');
    
    if ( $command->first_child('name')->text ne 'start pipeline:' ) {
      
      my $status = $command->first_child('status');
      
      if ( $status ) {
	$fields{total} = $status->first_child('total')->text;
	$fields{complete} = $status->first_child('complete')->text;
      }
      
    }
    
    $$summary{$name} = \%fields;
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
