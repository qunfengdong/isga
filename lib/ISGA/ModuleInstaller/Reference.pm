package ISGA::ModuleInstaller::Reference;

#------------------------------------------------------------------------

=head1 NAME

B<ISGA::ModuleInstaller::Component> provides methods for
installing reference information for a pipeline.

=head1 SYNOPSIS

=head1 DESRIPTION

=head1 METHODS

=cut
#------------------------------------------------------------------------
use strict;
use warnings;

use base 'ISGA::ModuleInstaller::Base';

use YAML;

#========================================================================

=head2 CLASS METHODS

=over 4

=cut
#========================================================================

#------------------------------------------------------------------------

=item public string getYAMLFile();

Returns the name of the yaml file for this class.

=cut 
#------------------------------------------------------------------------
sub getYAMLFile { return "reference.yaml"; }

#------------------------------------------------------------------------

=item public HashRef extractKey( ModuleLoader $ml, HashRef $tuple );

Returns a subset of tuple attributes that forms a key for the class.

=cut 
#------------------------------------------------------------------------
sub extractKey {
  
  my ($class, $ml, $tuple) = @_;
  
  return { Name => $tuple->{Name} };
}

#------------------------------------------------------------------------

=item public void insert( ModuleLoader $ml, HashRef $tuple );

Inserts the supplied tuple into the database.

=cut 
#------------------------------------------------------------------------
sub insert {

  my ($class, $ml, $t) = @_;
  
  my %args = ( Path => '', Name => $t->{Name}, Description => $t->{Description} );
  exists $t->{Link} and $args{Link} = $t->{Link};

  my $o = ISGA::Reference->create(%args);
  my $pipeline = ISGA::GlobalPipeline->new( Name => $ml->getPipelineName(), Version => $ml->getVersion());

  my %ps_args = (Reference => $o,
		 Pipeline => $pipeline
		);

  $ps_args{Note} = $t->{Note} if exists $t->{Note};

  ISGA::PipelineReference->create(%ps_args);
}

#------------------------------------------------------------------------

=item public void insert( ModuleLoader $ml, Component $obj, HashRef $tuple );

Updates the supplied tuple into the database.

=cut 
#------------------------------------------------------------------------
sub update {

  my ($class, $ml, $o, $t) = @_;
  
  my %args = (Name => $t->{Name}, Description => $t->{Description} );
  exists $t->{Link} and $args{Link} = $t->{Link};

  $o->edit(%args);

  my $pipeline = ISGA::GlobalPipeline->new( Name => $ml->getPipelineName(), Version => $ml->getVersion());

  my $ps = ISGA::PipelineReference->new( Pipeline => $pipeline, Reference => $o );
  my %ps_args = {};
  $ps_args{Note} = ( exists $t->{Note} ? $t->{Note} : undef );
  
  $ps->edit(%ps_args);
}

#------------------------------------------------------------------------

=item public void checkEquality( ModuleLoader $ml, Component $ct, HashRef $tuple );

Returns true if the supplied tuple matches the supplied Component object.

=cut 
#------------------------------------------------------------------------
sub checkEquality {
  
  my ($class, $ml, $o, $t) = @_;

  $o->getName ne $t->{Name} and
    X::API->throw( message => "Name does not match entry for Reference $t->{Name}\n" );
  $o->getDescription ne $t->{Description} and
    X::API->throw( message => "Description does not match entry for Reference $t->{Name}\n" );

  my $link = $o->getLink();
  ( defined $link xor exists $t->{Link} ) and
    X::API->throw( message => "Link does not match entry for Reference $t->{Name}\n" );   
  defined $link and $link ne $t->{Link} and
    X::API->throw( message => "Link does not match entry for Reference $t->{Name}\n" );   

  # add the mapping
  my $pipeline = ISGA::GlobalPipeline->new( Name => $ml->getPipelineName(), Version => $ml->getVersion());

  my %ps_args = (Reference => $o,
		 Pipeline => $pipeline
		);
  
  $ps_args{Note} = $t->{Note} if exists $t->{Note};  
  ISGA::PipelineReference->create(%ps_args);
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
