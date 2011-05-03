package ISGA::Run::ProkaryoticAnnotation::Feb2011;
#------------------------------------------------------------------------

=head1 NAME

<ISGA::Run::ProkaryoticAnnotation::Feb2011> manages runs of the prokaryotic annotation pipeline.

=head1 SYNOPSIS

=head1 DESRIPTION

=head1 METHODS

=over

=cut
#------------------------------------------------------------------------

use strict;
use warnings;

use File::Copy;
use base 'ISGA::Run';
use File::Path;
use Digest::MD5  qw(md5_hex);
use Bio::Tools::GFF;

use ISGA::ClusterOutput;
use ISGA::GenomeFeaturePartition;
use ISGA::RunOutput;

use ISGA::SiteConfiguration;


use List::Util qw(sum max min);

{

  my $gbrowse_dir = ISGA::SiteConfiguration->value('gbrowse_directory');


  my $component = ISGA::Component->new( ErgatisInstall => ISGA::ErgatisInstall->new( Name => 'ergatis-v2r13-cgbr1' ),
					ErgatisName => 'bsml2gff3.default' );

  my $gff_output = 
    ISGA::ClusterOutput->new( FileLocation => 'bsml2gff3/___id____default/bsml2gff3.gff3.list', Component => $component);

  my %feature_name_map =
    (
     'contig' => ISGA::GenomeFeaturePartition->new(Name => 'Contig'),
     'mrna' => ISGA::GenomeFeaturePartition->new(Name => 'mRNA'),
     'rrna' => ISGA::GenomeFeaturePartition->new(Name => 'rRNA'),
     'cds' => ISGA::GenomeFeaturePartition->new(Name => 'CDS'),
     'gene' => ISGA::GenomeFeaturePartition->new(Name => 'Gene'),
     'trna' => ISGA::GenomeFeaturePartition->new(Name => 'tRNA'),
    );
   
#------------------------------------------------------------------------

=item public int insertGenomeFeature(hashref $feature, GenomeFeaturePartition $type);

Writes the entry to the genomefeature table and returns the database id for the object.

=cut
#------------------------------------------------------------------------
  sub insertGenomeFeature {

    my ($self, $feature, $type) = @_;
    
    my $id = ISGA::DB->insert_into_sequence('INSERT INTO genomefeature (genomefeaturepartition_id, genomefeature_uniquename, genomefeature_start, genomefeature_end, genomefeature_strand) VALUES ( ?, ?, ?, ?, ?)', 
						[$type, $feature->{name}, $feature->{start}, $feature->{end}, $feature->{strand}], 
						'genomefeature_genomefeature_id_seq');
    
    return $id;
  }

#------------------------------------------------------------------------

=item public int insertContig(hashref $contig);

Writes the entry to the contig table and sequence and returns the database id for the object.

=cut
#------------------------------------------------------------------------
  sub insertContig {

    my ($self, $contig) = @_;
    my $id = $self->insertGenomeFeature($contig, $feature_name_map{contig});

    ISGA::DB->do('INSERT INTO contig (genomefeature_id, sequence_id, run_id) VALUES (?,(SELECT get_sequence_id(?,?,?)),?)', 
		     [ $id, $contig->{seq}, md5_hex(uc($contig->{seq})), length($contig->{seq}), $self ]);
    
    return $id;
  }

#------------------------------------------------------------------------

=item public int insertGene(hashref $gene);

Writes the entry to the gene table and returns the database id for the object.

=cut
#------------------------------------------------------------------------
  sub insertGene {

    my ($self, $gene) = @_;
    my $id = $self->insertGenomeFeature($gene, $feature_name_map{gene});

    ISGA::DB->do('INSERT INTO gene ( genomefeature_id, gene_locus, gene_contig, gene_note, gene_type ) VALUES (?, ?, ?, ?, ?)', 
		     [ $id, $gene->{locus}, $gene->{contig}, $gene->{note}, $gene->{type} ]);
    
    return $id;
  }

#------------------------------------------------------------------------

=item public int insertTRNA(hashref $trna);

Writes the entry to the trna table and returns the database id for the object.

=cut
#------------------------------------------------------------------------
  sub insertTRNA {

    my ($self, $trna) = @_;

    # insert the tRNA      
    my $id = $self->insertGenomeFeature($trna, $feature_name_map{trna});
    
    ISGA::DB->do('INSERT INTO trna (genomefeature_id, trna_score, trna_trnaanticodon, trna_gene) VALUES (?, ?, ?, ?)', 
		     [ $id, $trna->{score}, $trna->{tac}, $trna->{gene} ]);  
    
    return $id;
  }

#------------------------------------------------------------------------

=item public int insertRRNA(hashref $rrna);

Writes the entry to the rRNA table and returns the database id for the object.

=cut
#------------------------------------------------------------------------
  sub insertRRNA {

    my ($self, $rrna) = @_;

    # insert the rRNA      
    my $id = $self->insertGenomeFeature($rrna, $feature_name_map{rrna});
    
    ISGA::DB->do('INSERT INTO rrna (genomefeature_id, rrna_score, rrna_gene) VALUES (?, ?, ?)', 
		     [ $id, $rrna->{score}, $rrna->{gene} ]);  
    
    return $id;
  }

#------------------------------------------------------------------------

=item public int insertMRNA(hashref $mrna);

Writes the entry to the mRNA table and returns the database id for the object.

=cut
#------------------------------------------------------------------------
  sub insertMRNA {

    my ($self, $mrna) = @_;

    # insert the rRNA      
    my $id = $self->insertGenomeFeature($mrna, $feature_name_map{mrna});
  
    ISGA::DB->do("INSERT INTO mrna (genomefeature_id, mrna_geneproductnamesource,  mrna_gene) VALUES (?, ?, ?)",
		     [ $id, $mrna->{gpns}, $mrna->{gene} ]);	
    ISGA::DB->do("UPDATE mrna SET mrna_genesymbol = ?, mrna_genesymbolsource = (SELECT get_exref_id('gene_symbol_source', ?)) WHERE genomefeature_id = ?", [$mrna->{gene_symbol}, $mrna->{gene_symbol_source}, $id]) if exists $mrna->{gene_symbol};
    ISGA::DB->do("UPDATE mrna SET mrna_tigrrole = (SELECT get_exref_id('TIGR_role', ?)) WHERE genomefeature_id = ?", [$mrna->{tigr_role}, $id]) if exists $mrna->{tigr_role};
    ISGA::DB->do("UPDATE mrna SET mrna_ec = (SELECT get_exref_id('EC', ?)) WHERE genomefeature_id = ?", [$mrna->{ec}, $id]) if exists $mrna->{ec};

    if ( exists $mrna->{go} ) {
      foreach ( @{$mrna->{go}} ) {
	ISGA::DB->do("INSERT INTO mrnaexref (genomefeature_id, exref_id) VALUES (?, (SELECT get_exref_id('GO', ?)));", [ $id, $_ ]);
      }	
    }  

    return $id;
  }

#------------------------------------------------------------------------

=item public int insertCDS(hashref $cds);

Writes the entry to the CDS table and returns the database id for the object.

=cut
#------------------------------------------------------------------------
  sub insertCDS {

    my ($self, $cds) = @_;
    
    # insert the rRNA      
    my $id = $self->insertGenomeFeature($cds, $feature_name_map{cds});
    
    ISGA::DB->do("INSERT INTO cds (genomefeature_id, cds_mrna) VALUES (?, ?)", [ $id, $cds->{mrna} ]);
    ISGA::DB->do("UPDATE cds SET cds_topcoghit = ? WHERE genomefeature_id = ?", [ $cds->{top_cog_hit}, $id ]) if exists $cds->{top_cog_hit};

    return $id;
  } 

#------------------------------------------------------------------------

=item public hashref parseGFF();

Parse the GFF version of the pipeline summary returns a reference to a
hash containing the genome features.

=cut
#------------------------------------------------------------------------
  sub parseGFF {

    my $self = shift;
    
    my $gff_file = ISGA::RunOutput->new( ClusterOutput => $gff_output, 
					 Run => $self )->getFileResource; 
    
    my $gff_in = Bio::Tools::GFF->new(-file => $gff_file->getPath, -gff_version => 3);
    
    my %features;
    
    while ( my $feature = $gff_in->next_feature()) {
      
      # exons are useless for microbial genomes
      my $feature_type = lc($feature->primary_tag());
      next if $feature_type eq 'exon';
      
      my ($name) = $feature->get_tag_values('ID');
      
      my %attr = ( start => $feature->start, end => $feature->end, name => $name,
		   strand => ($feature->strand == 1 ? '+' : '-'), feature => $feature  );
      
      if ( $feature_type eq 'contig' ) {
	$features{contig}{$name} = \%attr;
	next;
      }
      
      # identify the contig for this feature
      my $contig = $feature->seq_id();
      
      # create a string to identify this feature's position on the contig
      my $pos = $attr{start} . '..' . $attr{end};
      
      if ( $feature_type eq 'gene' ) {    
	
	# save the custom locus name
	my ($dbxref) = $feature->get_tag_values('Dbxref');
	$dbxref =~ s/TIGR_moore\://o;
	$attr{locus} = $dbxref;
	
	$features{gene}{$contig}{$pos} = \%attr;
	
      } elsif ( $feature_type eq 'cds' ) {
	
	($attr{top_cog_hit}) = $feature->get_tag_values('top_cog_hit') if $feature->has_tag('top_cog_hit');
	
	$features{cds}{$contig}{$pos} = \%attr;
	
      } elsif ( $feature_type eq 'trna' ) {
	
	($attr{score}) = $feature->get_tag_values('score');
	($attr{tac}) = $feature->get_tag_values('tRNA_anti-codon');
	($attr{note}) = $feature->get_tag_values('Note');
	
	$features{trna}{$contig}{$pos} = \%attr;
	
      } elsif ( $feature_type eq 'rrna' ) {
	
	($attr{score}) = $feature->get_tag_values('score');
	($attr{note}) = $feature->get_tag_values('Note');   
	
	$features{rrna}{$contig}{$pos} = \%attr;
	
      } elsif ( $feature_type eq 'mrna' ) {
	
	($attr{note}) = $feature->has_tag('Note') ? $feature->get_tag_values('Note') : '';
	($attr{gpns}) = $feature->has_tag('gene_product_name_source') ? $feature->get_tag_values('gene_product_name_source') : '';
	($attr{tigr_role}) = $feature->get_tag_values('TIGR_role') if $feature->has_tag('TIGR_role');
	($attr{ec}) = $feature->get_tag_values('EC') if $feature->has_tag('EC');
	$attr{go} = [$feature->get_tag_values('GO')] if $feature->has_tag('GO');
	if ( $feature->has_tag('gene_symbol') ) {
	  ($attr{gene_symbol}) = $feature->get_tag_values('gene_symbol');
	  ($attr{gene_symbol_source}) =  $feature->get_tag_values('gene_symbol_source');
	}
	
	$features{mrna}{$contig}{$pos} = \%attr;
      }
    }
    
    foreach ( $gff_in->get_seqs ) {
      
      my $name = $_->display_id();
      
      # save the sequence if this is a contig
      $features{contig}{$name}{seq} = $_->seq if exists $features{contig}{$name}; 
    }
    
    return \%features;
  }
  
#------------------------------------------------------------------------

=item public void processFeatures(hashref $features);

Processes addition of features to database.

=cut
#------------------------------------------------------------------------
sub processFeatures {

  my ($self, $features) = @_;

  my $dir = "$gbrowse_dir/databases/$self";
  mkdir( $dir ) or X::File->throw( error => "Error creating directory $dir: $!" );
  open my $out_fh, '>', "$dir/$self.gff3";
  my $gff_out = Bio::Tools::GFF->new(-fh => $out_fh, -gff_version => 3);

  # cycle through contigs
  for my $contig ( values %{$features->{contig}} ) {
    
    # process contig
    my $c_id = $self->insertContig($contig);
    $contig->{feature}->add_tag_value('db_id', $c_id);
    $gff_out->write_feature($contig->{feature});
    
    # process all tRNA
    while ( my ($pos, $trna) = each %{$features->{trna}{ $contig->{name} }} ) {
      
      # add the gene first
      my $gene = $features->{gene}{ $contig->{name} }{$pos} or X::API->throw();
      $gene->{contig} = $c_id;
      $gene->{note} = $trna->{note};
      $gene->{type} = 'tRNA';
      my $g_id = $self->insertGene($gene);
      $gene->{feature}->add_tag_value('db_id', $g_id);
      $gene->{feature}->add_tag_value('Name', $gene->{locus});
      $gene->{feature}->add_tag_value('Note', $trna->{note});
      $gff_out->write_feature($gene->{feature});
      
      # add the tRNA
      $trna->{gene} = $g_id;
      my $id = $self->insertTRNA($trna);
      $gene->{id} = $g_id;
      $trna->{feature}->add_tag_value('db_id', $id);
      $gff_out->write_feature($trna->{feature});      
    }
    
    # process all rRNA
    while ( my ($pos, $rrna) = each %{$features->{rrna}{ $contig->{name} }} ) {

      # add the gene first
      my $gene = $features->{gene}{ $contig->{name} }{$pos} or X::API->throw();
      $gene->{contig} = $c_id;
      $gene->{note} = $rrna->{note};
      $gene->{type} = 'rRNA';
      my $g_id = $self->insertGene($gene);
      $gene->{id} = $g_id;
      $gene->{feature}->add_tag_value('db_id', $g_id);
      $gene->{feature}->add_tag_value('Name', $gene->{locus});
      $gene->{feature}->add_tag_value('Note', $rrna->{note});
      $gff_out->write_feature($gene->{feature});
      
      # add the rRNA
      $rrna->{gene} = $g_id;
      my $id = $self->insertRRNA($rrna);
      $rrna->{feature}->add_tag_value('db_id', $id);
      $gff_out->write_feature($rrna->{feature});
    }
    
    # process all mRNA
    while ( my ($pos, $mrna) = each %{$features->{mrna}{ $contig->{name} }} ) {
      
      # add the gene first
      my $gene = $features->{gene}{ $contig->{name} }{$pos} or X::API->throw();
      $gene->{contig} = $c_id;
      $gene->{note} = $mrna->{note};
      $gene->{type} = 'mRNA';
      my $g_id = $self->insertGene($gene);
      $gene->{id} = $g_id;
      $gene->{feature}->add_tag_value('db_id', $g_id);
      $gene->{feature}->add_tag_value('Name', $gene->{locus});
      $gene->{feature}->add_tag_value('Note', $mrna->{note});
      $gff_out->write_feature($gene->{feature});
      
      # add the mrna
      $mrna->{gene} = $g_id;
      my $id = $self->insertMRNA($mrna);
      $mrna->{feature}->add_tag_value('db_id', $id);
      $gff_out->write_feature($mrna->{feature});
      
      # add the CDS
      my $cds = $features->{cds}{ $contig->{name} }{$pos} or X::API->throw();
      $cds->{mrna} = $id;
      my $cds_id = $self->insertCDS($cds);
      $cds->{feature}->add_tag_value('db_id', $cds_id);
      $gff_out->write_feature($cds->{feature});
   
    }
  }

  close $out_fh;
}  

#------------------------------------------------------------------------

=item public string parseAndLoadGFF();

=cut
#------------------------------------------------------------------------
  sub parseAndLoadGFF {

    my $self = shift;

    my $features = $self->parseGFF();

    $self->processFeatures($features);

    # return the name of the first contig
    my @contigs = keys %{$features->{contig}};
    return $contigs[0];
  }

#------------------------------------------------------------------------

=item public bool hasGbrowseInstallation();

Returns true if a gbrowse configuration has been created for this run.

=cut
#------------------------------------------------------------------------
  sub hasGbrowseInstallation {
    
    my $self = shift;
    
    -f "$gbrowse_dir/conf/$self.conf" and
       -f "$gbrowse_dir/databases/$self/$self.gff3" and 
       ISGA::Contig->exists( Run => $self ) and
       return 1;
    
    return 0;
  }
  
#------------------------------------------------------------------------

=item public void installGbrowseData();

Install Gbrowse config file and gff file.

=cut
#------------------------------------------------------------------------
  sub installGbrowseData {
  
    my $self = shift;
    
    # must be complete
    $self->getStatus eq 'Complete' or X::Error->throw();
    
    # must not have installation
    $self->hasGbrowseInstallation and return;

    # clean up incomplete installations
    $self->deleteGbrowseConfigurationFile();
    $self->deleteGbrowseDatabase();

    # install gene details
    my $contig = $self->parseAndLoadGFF();

    # create config file
    $self->writeGbrowseConfigurationFile($contig);
  }
  
#------------------------------------------------------------------------

=item public void deleteGbrowseConfigurationFile();

=cut
#------------------------------------------------------------------------
sub deleteGbrowseConfigurationFile {

  my $self = shift;
  my $id = $self->getId;

  my $file = "$gbrowse_dir/conf/$id.conf";
  -f $file and unlink($file);
}

#------------------------------------------------------------------------

=item public void deleteGbrowseDatabase();

=cut
#------------------------------------------------------------------------
sub deleteGbrowseDatabase {

  my $self = shift;
  my $id = $self->getId;

  my $dir = "$gbrowse_dir/databases/$id";

  -d $dir and rmtree($dir);
}

#------------------------------------------------------------------------

=item public void writeGbrowseConfigurationFile();

=cut
#------------------------------------------------------------------------
  sub writeGbrowseConfigurationFile {

    my ($self, $contig) = @_;

    my $include = ISGA::Site->getIncludePath();

    # read the template for the config file
    open my $fh, '<', "$include/gbrowse.conf-template"
      or X::File->throw( error => "$include/gbrowse.conf-template : $!" );
    my $conf = do { local $/; <$fh> };
    close $fh;     
    
    my $id = $self->getId;
    my $name = $self->getName;
    
    # customize the template
    $conf =~ s{___DATABASE_DIR___}{$gbrowse_dir/databases/$id};
    $conf =~ s{___LANDMARK___}{$contig};
    $conf =~ s{___DESCRIPTION___}{$name};
    
    ISGA::Utility->writeFile("$gbrowse_dir/conf/$id.conf", $conf);
  }
  
#------------------------------------------------------------------------

=item public ($database_names, $database_values) getBlastDatabases();

Returns two array refs, the first containing a list of database names
provided by this run, and the second a corresponding list of database
paths.

=cut
#------------------------------------------------------------------------
  sub getBlastDatabases {

    my $run = shift;

    my $name = $run->getName();
    my $pipeline = $run->getGlobalPipeline();

    my $names = [ "Run $name: predicted gene", "Run $name: predicted protein"];
    my $paths = [ join( '/', $pipeline->getErgatisOutputRepository(), 'asn2all', $run->getErgatisKey."_default", 'cgb_annotation.cds.fna'),
		  join( '/', $pipeline->getErgatisOutputRepository(), 'asn2all', $run->getErgatisKey."_default", 'cgb_annotation.aa.fsa')];
    
    return ( $names, $paths );
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

  
