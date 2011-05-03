package SysMicro::Run::ProkaryoticAnnotation;
#------------------------------------------------------------------------

=head1 NAME

<SysMicro::Run::ProkaryoticAnnotation> manages runs of the prokaryotic annotation pipeline.

=head1 SYNOPSIS

=head1 DESRIPTION

=head1 METHODS

=cut
#------------------------------------------------------------------------

use File::Copy;
use base 'SysMicro::Run';
use File::Path;
use Digest::MD5  qw(md5_hex);
use Bio::Tools::GFF;

{

  my $gff_output = 
    SysMicro::ClusterOutput->new( FileLocation => 'bsml2gff3/___id____default/bsml2gff3.gff3.list');


  my %feature_name_map =
    (
     'contig' => SysMicro::GenomeFeaturePartition->new(Name => 'Contig'),
     'mrna' => SysMicro::GenomeFeaturePartition->new(Name => 'mRNA'),
     'rrna' => SysMicro::GenomeFeaturePartition->new(Name => 'rRNA'),
     'cds' => SysMicro::GenomeFeaturePartition->new(Name => 'CDS'),
     'gene' => SysMicro::GenomeFeaturePartition->new(Name => 'Gene'),
     'trna' => SysMicro::GenomeFeaturePartition->new(Name => 'tRNA'),
    );
  
#------------------------------------------------------------------------

=item public string parseAndLoadGFF();

=cut
#------------------------------------------------------------------------
  sub parseAndLoadGFF {

    my $self = shift;

    my $gff_file = SysMicro::RunOutput->new( ClusterOutput => $gff_output, 
					     Run => $self )->getFileResource; 
    
    my $id = $self->getId;
    my $dir = "___gbrowse_databases___$id";
    mkdir( $dir ) or X::File->throw( error => "Error creating directory $dir: $!" );
    open my $out_fh, '>', "$dir/$id.gff3";

    my $gff_in = Bio::Tools::GFF->new(-file => $gff_file->getPath, -gff_version => 3);
    my $gff_out = Bio::Tools::GFF->new(-fh => $out_fh, -gff_version => 3);

#    $gff_in->features_attached_to_seqs(1);      

    # save a lookup hash for parents
    my %parent_lookup;

    my %contig_lookup;

    my $seq_id;

    my $dummy_seq = 'AA';
    
    my $feature;
    while($feature = $gff_in->next_feature()) {

      $seq_id = $feature->seq_id();

      my $feature_type = lc($feature->primary_tag());
      next if $feature_type eq 'exon';

      $feature_type = $feature_name_map{$feature_type};

      my $start = $feature->start;
      my $end = $feature->end;

      my ($name) = $feature->get_tag_values('ID');

      my @features = ($feature_type, $name, $start, $end, ($feature->strand ? '+' : '-'));
      
      my $id = SysMicro::DB->insert_into_sequence("INSERT INTO genomefeature (genomefeaturepartition_id, genomefeature_uniquename, genomefeature_start, genomefeature_end, genomefeature_strand) VALUES ( ?, ?, ?, ?, ?)", 
						  \@features, 
						  'genomefeature_genomefeature_id_seq');

      $parent_lookup{ $name } = $id;

      # if the genomefeature is a contig
      if ( $feature_type eq 'Contig' ) {

	$contig_lookup{ $seq_id } = $id;

	SysMicro::DB->do(
"INSERT INTO contig (genomefeature_id, sequence_id, run_id) VALUES (?,(SELECT get_sequence_id(?,?,?)),?)", 
			 [ $id, $dummy_seq, md5_hex(uc($dummy_seq)), length($dummy_seq), $self ]);

      # if the genomefeature is a gene
      } elsif ($feature_type eq 'Gene') {

	my ($dbxref) = $feature->get_tag_values('Dbxref');
	SysMicro::DB->do(
"INSERT INTO gene ( genomefeature_id, gene_locus, gene_contig ) VALUES (?, ?, ?)", 
			 [ $id, $dbxref, $contig_lookup{ $seq_id } ]);

      # if the genomefeature is a cds
      } elsif ($feature_type eq 'CDS') {

	SysMicro::DB->do("INSERT INTO cds (genomefeature_id) VALUES (?)", [ $id ]);

	if ( $feature->has_tag('Parent') ) {
	  my ($parent) = $feature->get_tag_values('Parent');
	  SysMicro::DB->do("UPDATE cds SET parent_id = ? WHERE genomefeature_id = ?",
			   [ $parent_lookup{$parent}, $id ])
	  }

	if ( $feature->has_tag('top_cog_hit') ) {
	  my ($tch) = $feature->get_tag_values('top_cog_hit');
	  SysMicro::DB->do("UPDATE cds SET cds_topcoghit = ? WHERE genomefeature_id = ?",
			   [ $tch, $id ])
	  }
	
      # if the genomefeature is a trna
      } elsif ($feature_type eq 'tRNA') {

	my ($score) = $feature->get_tag_values('score');
	my ($tac) = $feature->get_tag_values('tRNA_anti-codon');
	SysMicro::DB->do(
"INSERT INTO trna (genomefeature_id, trna_score, trna_trnaanticodon, trna_contig) VALUES (?, ?, ?, ?)", 
			 [ $id, $score, $tac, $contig_lookup{ $seq_id } ]);

	if ( $feature->has_tag('Note') ) {
	  my ($note) = $feature->get_tag_values('Note');
	  SysMicro::DB->do("UPDATE trna SET trna_note = ? WHERE genomefeature_id = ?", 
			   [$note, $id]);
	}
      
      # if the genomefeature is an rrna
      } elsif ($feature_type eq 'rRNA') {

	my ($score) = $feature->get_tag_values('score');
	SysMicro::DB->do(			 
"INSERT INTO rrna (genomefeature_id, rrna_score, rrna_contig) VALUES (?, ?, ?)",
			 [$id, $score, $contig_lookup{ $seq_id }]);

	if ( $feature->has_tag('Note') ) {
	  my ($note) = $feature->get_tag_values('Note');
	  SysMicro::DB->do("UPDATE rrna SET rrna_note = ? WHERE genomefeature_id = ?", 
			   [$note, $id]);
	}
	
      # if the genomefeature is an mrna
      } elsif ($feature_type eq 'mRNA') {
	
	my ($parent) = $feature->get_tag_values('Parent');
	exists $parent_lookup{$parent} or die "Can't find $parent in my parent hash!";

	SysMicro::DB->do("INSERT INTO mrna (genomefeature_id, parent_id) VALUES (?, ?)",
			 [ $id, $parent_lookup{$parent} ]);	

	if ( $feature->has_tag('Note') ) {
	  my ($note) = $feature->get_tag_values('Note');
	  SysMicro::DB->do("UPDATE mrna SET mrna_note = ? WHERE genomefeature_id = ?", 
			   [$note, $id]);
	}	

	if ( $feature->has_tag('gene_symbol') ) {
	  my ($var) = $feature->get_tag_values('gene_symbol');
	  SysMicro::DB->do("UPDATE mrna SET mrna_genesymbol = ? WHERE genomefeature_id = ?", 
			   [$var, $id]);
	}	

	if ( $feature->has_tag('gene_product_name_source') ) {
	  my ($var) = $feature->get_tag_values('gene_product_name_source');
	  SysMicro::DB->do("UPDATE mrna SET mrna_geneproductnamesource = ? WHERE genomefeature_id = ?", 
			   [$var, $id]);
	}	
       
	if ( $feature->has_tag('gene_symbol_source') ) {
	  my ($var) = $feature->get_tag_values('gene_symbol_source');
	  SysMicro::DB->do("UPDATE mrna SET mrna_genesymbolsource = (SELECT get_exref_id('gene_symbol_source', ?)) WHERE genomefeature_id = ?", 
			   [$var, $id]);
	}

	if ( $feature->has_tag('TIGR_role') ) {
	  my ($var) = $feature->get_tag_values('TIGR_role');
	  SysMicro::DB->do("UPDATE mrna SET mrna_tigrrole = (SELECT get_exref_id('TIGR_role', ?)) WHERE genomefeature_id = ?", 
			   [$var, $id]);
	}

	if ( $feature->has_tag('EC') ) {
	  my ($var) = $feature->get_tag_values('EC');
	  SysMicro::DB->do("UPDATE mrna SET mrna_ec = (SELECT get_exref_id('EC', ?)) WHERE genomefeature_id = ?", 
			   [$var, $id]);
	}

	if ( $feature->has_tag('GO') ) {

	  foreach ( $feature->get_tag_values('GO') ) {
	    SysMicro::DB->do("INSERT INTO mrnaexref (genomefeature_id, exref_id) VALUES (?, (SELECT get_exref_id('GO', ?)));", [ $id, $_ ]);
	  }	
	}
      }
      
      # write to our new GFF file
      $feature->add_tag_value('db_id', $id);
      $gff_out->write_feature($feature);
    }

    foreach ( $gff_in->get_seqs ) {

      my $name = $_->display_id();
      next unless exists $contig_lookup{ $name };
      
      my $seq = $_->seq;
      
      SysMicro::DB->do(
"UPDATE contig SET sequence_id = (SELECT get_sequence_id(?,?,?)) WHERE genomefeature_id = ?",
		     [ $seq, md5_hex(uc($seq)), length($seq), $contig_lookup{$name} ] );

    }

    return $seq_id;
  }

#------------------------------------------------------------------------

=item public bool hasGbrowseInstallation();

Returns true if a gbrowse configuration has been created for this run.

=cut
#------------------------------------------------------------------------
  sub hasGbrowseInstallation {
    
    my $self = shift;
    
    -f "___gbrowse_config___$self.conf" and return 1;
    
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

  my $file = "___gbrowse_config___$id.conf";
  -f $file and unlink($file);
}

#------------------------------------------------------------------------

=item public void deleteGbrowseDatabase();

=cut
#------------------------------------------------------------------------
sub deleteGbrowseDatabase {

  my $self = shift;
  my $id = $self->getId;

  my $dir = "___gbrowse_databases___$id";

  -d $dir and rmtree($dir);
}

#------------------------------------------------------------------------

=item public void writeGbrowseConfigurationFile();

=cut
#------------------------------------------------------------------------
  sub writeGbrowseConfigurationFile {

    my ($self, $contig) = @_;

    # read the template for the config file
    open my $fh, '<', "___include_root___/gbrowse.conf-template"
      or X::File->throw( error => "___include_root___/gbrowse.conf-template : $!" );
    my $conf = do { local $/; <$fh> };
    close $fh;     
    
    my $id = $self->getId;
    my $name = $self->getName;
    
    # customize the template
    $conf =~ s{___DATABASE_DIR___}{___gbrowse_databases___$id};
    $conf =~ s{___LANDMARK___}{$contig};
    $conf =~ s{___DESCRIPTION___}{$name};
    
    SysMicro::Utility->writeFile("___gbrowse_config___$id.conf", $conf);
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

  
