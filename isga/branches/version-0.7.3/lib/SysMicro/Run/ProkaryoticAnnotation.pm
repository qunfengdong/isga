package SysMicro::Run::ProkaryoticAnnotation;
#------------------------------------------------------------------------

=head1 NAME

<SysMicro::Run::ProkaryoticAnnotation> manages runs of the prokaryotic annotation pipeline.

=head1 SYNOPSIS

=head1 DESRIPTION

=head1 METHODS

=cut
#------------------------------------------------------------------------

use strict;
use warnings;

use File::Copy;
use base 'SysMicro::Run';
use File::Path;
use Digest::MD5  qw(md5_hex);
use Bio::Tools::GFF;

use List::Util qw(sum max min);

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

=item public int insertGenomeFeature(hashref $feature, GenomeFeaturePartition $type);

Writes the entry to the genomefeature table and returns the database id for the object.

=cut
#------------------------------------------------------------------------
  sub insertGenomeFeature {

    my ($self, $feature, $type) = @_;
    
    my $id = SysMicro::DB->insert_into_sequence('INSERT INTO genomefeature (genomefeaturepartition_id, genomefeature_uniquename, genomefeature_start, genomefeature_end, genomefeature_strand) VALUES ( ?, ?, ?, ?, ?)', 
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

    SysMicro::DB->do('INSERT INTO contig (genomefeature_id, sequence_id, run_id) VALUES (?,(SELECT get_sequence_id(?,?,?)),?)', 
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

    SysMicro::DB->do('INSERT INTO gene ( genomefeature_id, gene_locus, gene_contig, gene_note ) VALUES (?, ?, ?, ?)', 
		     [ $id, $gene->{locus}, $gene->{contig}, $gene->{note} ]);
    
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
    
    SysMicro::DB->do('INSERT INTO trna (genomefeature_id, trna_score, trna_trnaanticodon, trna_gene) VALUES (?, ?, ?, ?)', 
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
    
    SysMicro::DB->do('INSERT INTO rrna (genomefeature_id, rrna_score, rrna_gene) VALUES (?, ?, ?)', 
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
  
    SysMicro::DB->do("INSERT INTO mrna (genomefeature_id, mrna_geneproductnamesource,  mrna_gene) VALUES (?, ?, ?)",
		     [ $id, $mrna->{gpns}, $mrna->{gene} ]);	
    SysMicro::DB->do("UPDATE mrna SET mrna_genesymbol = ?, mrna_genesymbolsource = (SELECT get_exref_id('gene_symbol_source', ?)) WHERE genomefeature_id = ?", [$mrna->{gene_symbol}, $mrna->{gene_symbol_source}, $id]) if exists $mrna->{gene_symbol};
    SysMicro::DB->do("UPDATE mrna SET mrna_tigrrole = (SELECT get_exref_id('TIGR_role', ?)) WHERE genomefeature_id = ?", [$mrna->{tigr_role}, $id]) if exists $mrna->{tigr_role};
    SysMicro::DB->do("UPDATE mrna SET mrna_ec = (SELECT get_exref_id('EC', ?)) WHERE genomefeature_id = ?", [$mrna->{ec}, $id]) if exists $mrna->{ec};

    if ( exists $mrna->{go} ) {
      foreach ( @{$mrna->{go}} ) {
	SysMicro::DB->do("INSERT INTO mrnaexref (genomefeature_id, exref_id) VALUES (?, (SELECT get_exref_id('GO', ?)));", [ $id, $_ ]);
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
    
    SysMicro::DB->do("INSERT INTO cds (genomefeature_id, cds_mrna) VALUES (?, ?)", [ $id, $cds->{mrna} ]);
    SysMicro::DB->do("UPDATE cds SET cds_topcoghit = ? WHERE genomefeature_id = ?", [ $cds->{top_cog_hit}, $id ]) if exists $cds->{top_cog_hit};

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

  my $gff_file = SysMicro::RunOutput->new( ClusterOutput => $gff_output, 
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
      
      ($attr{note}) = $feature->get_tag_values('Note');
      ($attr{gpns}) = $feature->get_tag_values('gene_product_name_source');
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

=cut
#------------------------------------------------------------------------
sub processFeatures {

  my ($self, $features) = @_;

  my $dir = "___gbrowse_databases___$self";
  mkdir( $dir ) or X::File->throw( error => "Error creating directory $dir: $!" );
  open my $out_fh, '>', "$dir/$self.gff3";
  my $gff_out = Bio::Tools::GFF->new(-fh => $out_fh, -gff_version => 3);

  my $total_length = sum map { $_->{end} } values %{$features->{contig}};
  my $zoom = max(1, int($total_length / 50000));

  # cycle through contigs
  for my $contig ( values %{$features->{contig}} ) {
    
    warn "processing contig\n";

    # process contig
    my $c_id = $self->insertContig($contig);
    $contig->{feature}->add_tag_value('db_id', $c_id);
    $gff_out->write_feature($contig->{feature});
    
################################ CGVIEW BLOCK BEGIN ###############################################
    my $cgv_plus = '';
    my $cgv_minus = '';
################################# CGVIEW BLOCK END ################################################

    # process all tRNA
    while ( my ($pos, $trna) = each %{$features->{trna}{ $contig->{name} }} ) {
      
      warn "processing trna\n";

      # add the gene first
      my $gene = $features->{gene}{ $contig->{name} }{$pos} or X::API->throw();
      $gene->{contig} = $c_id;
      $gene->{note} = $trna->{note};
      my $g_id = $self->insertGene($gene);
      $gene->{feature}->add_tag_value('db_id', $g_id);
      $gff_out->write_feature($gene->{feature});
      
      # add the tRNA
      $trna->{gene} = $g_id;
      my $id = $self->insertTRNA($trna);
      $gene->{id} = $g_id;
      $trna->{feature}->add_tag_value('db_id', $id);
      $gff_out->write_feature($trna->{feature});
      
################################ CGVIEW BLOCK BEGIN ###############################################
      my $end = min($trna->{end}, $total_length);
      
      my $cgv = "<feature color=\"orange\" decoration=\"arc\" label=\"$gene->{locus}\" hyperlink=\"/GenomeFeature/View?genome_feature=$g_id\" mouseover=\"$trna->{note}\">\n"; 
      $cgv   .= "<featureRange start=\"$trna->{start}\" stop=\"$end\" />\n</feature>\n";
      
      # save the tRNA to the correct strand
      $trna->{strand} eq '+' ? $cgv_plus .= $cgv : $cgv_minus = $cgv;
################################# CGVIEW BLOCK END ################################################
    }
    
    # process all rRNA
    while ( my ($pos, $rrna) = each %{$features->{rrna}{ $contig->{name} }} ) {

      warn "processing rrna\n";
      
      # add the gene first
      my $gene = $features->{gene}{ $contig->{name} }{$pos} or X::API->throw();
      $gene->{contig} = $c_id;
      $gene->{note} = $rrna->{note};
      my $g_id = $self->insertGene($gene);
      $gene->{id} = $g_id;
      $gene->{feature}->add_tag_value('db_id', $g_id);
      $gff_out->write_feature($gene->{feature});
      
      # add the rRNA
      $rrna->{gene} = $g_id;
      my $id = $self->insertRRNA($rrna);
      $rrna->{feature}->add_tag_value('db_id', $id);
      $gff_out->write_feature($rrna->{feature});
      
################################ CGVIEW BLOCK BEGIN ###############################################
      my $end = min($rrna->{end}, $total_length);

      my $cgv = "<feature color=\"green\" decoration=\"arc\" label=\"$gene->{locus}\" hyperlink=\"/GenomeFeature/View?genome_feature=$g_id\" mouseover=\"$rrna->{note}\">\n"; 
      $cgv   .= "<featureRange start=\"$rrna->{start}\" stop=\"$end\" />\n</feature>\n";
      
      # save the tRNA to the correct strand
      $rrna->{strand} eq '+' ? $cgv_plus .= $cgv : $cgv_minus = $cgv;
################################# CGVIEW BLOCK END ################################################
    }
    
    # process all mRNA
    while ( my ($pos, $mrna) = each %{$features->{mrna}{ $contig->{name} }} ) {
      
      warn "processing mrna\n";

      # add the gene first
      my $gene = $features->{gene}{ $contig->{name} }{$pos} or X::API->throw();
      $gene->{contig} = $c_id;
      $gene->{note} = $mrna->{note};
      my $g_id = $self->insertGene($gene);
      $gene->{id} = $g_id;
      $gene->{feature}->add_tag_value('db_id', $g_id);
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
   
################################ CGVIEW BLOCK BEGIN ###############################################
      my $end = min($mrna->{end}, $total_length);

      my $cgv = " label=\"$gene->{locus}\" hyperlink=\"/GenomeFeature/View?genome_feature=$g_id\"  mouseover=\"$mrna->{note}\">\n";
      $cgv   .= "<featureRange start=\"$mrna->{start}\" stop=\"$end\" />\n</feature>\n";
      
      # save the mRNA to the correct strand
      if ( $mrna->{strand} eq '+' ) {
	$cgv_plus .= "<feature color=\"red\" decoration=\"clockwise-arrow\"" . $cgv;
      } else {
	$cgv_plus .= "<feature color=\"blue\" decoration=\"counterclockwise-arrow\"" . $cgv;
      }
################################# CGVIEW BLOCK END ################################################
    }

    warn "PLUS: $cgv_plus\n";
    warn "MINUS: $cgv_minus\n";

################################ CGVIEW BLOCK BEGIN ###############################################
    my $cg_conf = "___tmp_file_directory___cgview-$c_id.xml";

   open my $cgview, '>', $cg_conf or die "Unable to open $cg_conf: $!";
    
    print $cgview "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\n";
    print $cgview "<cgview backboneRadius=\"200\" sequenceLength=\"$total_length\" height=\"500\" width=\"500\" titleFont=\"SansSerif, plain, 18\" title=\"Strain K12, MG1655\" globalLabel=\"auto\" moveInnerLabelsToOuter=\"false\" featureThickness=\"xx-large\" tickLength=\"small\" shortTickColor=\"black\" longTickColor=\"black\" zeroTickColor=\"black\" showBorder=\"false\">\n";
    print $cgview "<legend position=\"upper-right\" font=\"SanSerif, plain, 10\" backgroundOpacity=\"0.8\">\n";
    print $cgview "<legendItem text=\"Features\" font=\"SanSerif, plain, 12\"/>\n";
    print $cgview "<legendItem text=\"+ Strand\" drawSwatch=\"true\" swatchColor=\"red\"/>\n";
    print $cgview "<legendItem text=\"- Strand\" drawSwatch=\"true\" swatchColor=\"blue\"/>\n";
    print $cgview "<legendItem text=\"tRNA\" drawSwatch=\"true\" swatchColor=\"orange\"/>\n";
    print $cgview "<legendItem text=\"rRNA\" drawSwatch=\"true\" swatchColor=\"green\"/>\n";
    print $cgview "</legend>\n";
    print $cgview "<featureSlot strand=\"direct\">\n";
    print $cgview $cgv_plus;
    print $cgview "</featureSlot>\n";
    print $cgview "<featureSlot strand=\"reverse\">\n";
    print $cgview $cgv_minus;
    print $cgview "</featureSlot>\n";
    print $cgview "</cgview>\n";
    close $cgview;
################################# CGVIEW BLOCK END ################################################ 

    # wrie files for all genes
    while ( my ($pos, $gene) = each %{$features->{gene}{ $contig->{name} }} ) {
      
      # calculate center of the gene
      my $center = int((($gene->{start} + $gene->{end})/2) + 0.5);
      my $locus = $gene->{locus};
      my $png = "___cgview_directory___$gene->{id}.png";
      my $html = "___cgview_directory___$gene->{id}.html";
      
      chdir('___scripts_bin___');

      `java -jar cgview.jar -i $cg_conf -o $png -f png -c $center -z $zoom -h $html -q $locus`;
      
      $? == 0 or X::API->throw( message => "Calling cgview returned $? for run $self" );

      warn "java -jar cgview.jar -i $cg_conf -o $png -f png -c $center -z $zoom -h $html -q $locus\n";

#      extractImageMap($gene->{id});
    }
  }
}  

#sub extractImageMap {
#
#  my ($self, $path) = @_;
#  open my $in_fh, '<', "$path" or die "Unable to open $path: $!";
#}  
  
  

#sub getImgMap {
#        my $mapFile = $_[0];
#          if (open(MAPFILE, '<', $mapFile)) {
#                my @mapFileContentLines = <MAPFILE>;
#                close(MAPFILE);
#                chomp(@mapFileContentLines);
#                my $mapFileContent = join(' ', @mapFileContentLines);
#                $mapFileContent =~ /<map id=\"cgviewmap\"
#name=\"cgviewmap\">(.+)<\/map>/;
#                my $mapContent = $1;
#                $mapContent;
#        }
#}

#------------------------------------------------------------------------

=item public string parseAndLoadGFF();

=cut
#------------------------------------------------------------------------
  sub parseAndLoadGFF {

    my $self = shift;

    my $features = $self->parseGFF();

    $self->processFeatures($features);

    X::API->throw( message => 'we did pretty well' );


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
    open my $fh, '<', "___package_include___/gbrowse.conf-template"
      or X::File->throw( error => "___package_include___/gbrowse.conf-template : $!" );
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

  
