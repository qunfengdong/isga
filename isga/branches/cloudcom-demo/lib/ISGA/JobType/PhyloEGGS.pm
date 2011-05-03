package ISGA::JobType::PhyloEGGS;
#------------------------------------------------------------------------

=head1 NAME

<ISGA::JobType::PhyloEGGS> provides methods for working with PhyloEGGS jobs.


=head1 SYNOPSIS

=head1 DESRIPTION

=head1 METHODS

=over

=cut
#------------------------------------------------------------------------

use base 'ISGA::Job';
use File::Basename;

{

#------------------------------------------------------------------------

=item public File buildForm( );

Build the appropriate FormEngine data structure for this Job.

=cut
#------------------------------------------------------------------------

sub buildForm {
  my ($self, $args) = @_;
  use YAML;

  my $organisms = YAML::LoadFile('___package_include___/bacteria_info.yaml');
  my @organism_names;
  my @organism_values;
  foreach my $accesion (sort { ${$$organisms{$a}}[1] cmp ${$$organisms{$b}}[1] } keys %$organisms){
    push(@organism_names, ${$$organisms{$accesion}}[1]);
    push(@organism_values, $accesion);
  }

  my $form = ISGA::FormEngine->new($args);
  $form->set_skin_obj('ISGA::FormEngine::SkinUniform');

  my @form_params =
    (
     {
      templ => 'fieldset',
      TITLE => 'PhyloEGGS',
      sub =>
      [  
       {
        TITLE => 'Select Organisms',
        NAME => 'organisms',
        templ => 'select',
        SIZE => 8,
        MULTIPLE => 1,
        OPTION => \@organism_names,
        OPT_VAL => \@organism_values
       },
       {
        TITLE => 'Newick Phylogenetic Tree',
        NAME => 'upload_newick_file',
        templ => 'upload'
       },
      ]
      },
    );

  return \@form_params;
}

#------------------------------------------------------------------------

=item public Form Job buildWebAppCommand( form=>$form, job=>$job );

Build the appropriate WebApp command for this Job.

=cut
#------------------------------------------------------------------------

sub buildWebAppCommand {
    my ($self, $webapp, $form, $job) = @_;
  
    use File::Copy;

    my $web_args = $webapp->args;
    my $newick_upload = $webapp->apache_req->upload('upload_newick_file');
    my $organisms = $form->get_input('organisms');
    ref($organisms) eq 'ARRAY' or $organisms = [ $organisms ];


    ## Hardcoded paths.
    my $files_path = "___tmp_file_directory___/workbench/phyloeggs/";
    
    my $bacteria_directory = "/research/projects/isga/ftp/Bacteria"; # Talk to Chris about database for this garbage.
    my $reduced = "/research/projects/isga/ftp/Bacteria/reduced/result";
    
    my $log_name  = $job->getType->getName . "_" .  $job->getId;
    my $out_directory = $files_path.$log_name;
    
    mkdir($out_directory) or X->throw(message => 'output directory creation failed') if(! -e $out_directory);
    mkdir("$out_directory/Cmp") or X->throw(message => 'output directory creation failed') if(! -e "$out_directory/Cmp");
    
    mkdir("$out_directory/cmp") or X->throw(message => 'output directory creation failed') if(! -e "$out_directory/cmp");
    mkdir("$out_directory/faaptt") or X->throw(message => 'output directory creation failed') if(! -e "$out_directory/faaptt");
    mkdir("$out_directory/post") or X->throw(message => 'output directory creation failed') if(! -e "$out_directory/post");
    my $tree;

    if($newick_upload ne '') {
        $args{Upload} = $newick_upload->fh;
        $args{Format} = 'Newick';
        $args{Type} = 'Phylogenetic Tree';
        $args{Username} = basename($newick_upload);
        $newick_input_file = $job->buildQueryFile(%args);
        $newick_input_file->stage($out_directory);
        $tree = $out_directory."/".$newickinput_file->getName();
    }
    foreach my $org (@$organisms){
       copy("$reduced/$org.faa", "$out_directory/Cmp/") or X->throw(message => 'Cannot copy faa file to Cmp directory');
       copy("$reduced/$org.ptt", "$out_directory/Cmp/") or X->throw(message => 'Cannot copy ptt file to Cmp directory');
    }

    my $sge_submit_script = "$out_directory/${log_name}_sge_phyloeggs.sh";
 
    open my $fh, '>', $sge_submit_script or X->throw(message => 'Error creating sge shell script.');
    print $fh '#!/bin/bash'."\n\n";
    print $fh "cd $out_directory\n\n";
    unless ($newick_upload){
      print $fh "cat";
      foreach my $org (@$organisms){
        print $fh " ".$reduced."/".$org.".fasta";
      }
      print $fh " > $out_directory/${log_name}_16s.fasta ".'|| { echo "command failed"; exit 1; }'."\n\n";
      print $fh 'echo "starting clustalw2" 1>&2'."\n";
      print $fh "___clustalw_executable___ -INFILE=$out_directory/${log_name}_16s.fasta -TYPE=DNA -MATRIX=BLOSUM -OUTFILE=$out_directory/${log_name}.aln -ALIGN -CLUSTERING=UPGMA -OUTPUT=PHYLIP -TREE -OUTPUTTREE=nj ".'|| { echo "clustalw2 command failed"; exit 1; }'."\n\n";
      print $fh "cp $out_directory/${log_name}.aln $out_directory/infile\n\n";
#      print $fh "mv $out_directory/${log_name}_16s.dnd $out_directory/${log_name}_16s.newick\n";

      print $fh "perl ___scripts_bin___/runDnaDist.pl -i $out_directory/infile -c DxDxY\n\n";
      print $fh "mv $out_directory/outfile $out_directory/infile\n\n";
      print $fh "perl ___scripts_bin___runNeighbor.pl -i $out_directory/infile -c NxY\n\n";
      print $fh "mv $out_directory/outtree $out_directory/${log_name}_16s.newick\n\n";

      $tree = "$out_directory/${log_name}_16s.newick";
    }

    for(my $i = 0; $i < scalar @$organisms; $i++){
       for(my $j = 0; $j < scalar @$organisms; $j++){
          next if $j <= $i;
          print $fh "perl ___scripts_bin___/extract_gi_num.pl -i $reduced/Cmp/$$organisms[$i].faa.$$organisms[$j].faa.cmp -o $out_directory/Cmp/$$organisms[$i].faa.$$organisms[$j].faa.cmp ".'|| { echo "command failed"; exit 1; }'."\n\n";
 
          print $fh "perl ___scripts_bin___/extract_gi_num.pl -i $reduced/Cmp/$$organisms[$j].faa.$$organisms[$i].faa.cmp -o $out_directory/Cmp/$$organisms[$j].faa.$$organisms[$i].faa.cmp ".'|| { echo "command failed"; exit 1; }'."\n\n";
 
          print $fh "perl ___scripts_bin___/find-reciprocal-hit.pl -q1 $$organisms[$i] -q2 $$organisms[$j] -cmp1 $out_directory/Cmp/$$organisms[$i].faa.$$organisms[$j].faa.cmp -cmp2 $out_directory/Cmp/$$organisms[$j].faa.$$organisms[$i].faa.cmp -s e-value -col 10 -cutoff 1e-5 -method SBH > $out_directory/Cmp/$$organisms[$i].faa.$$organisms[$j].faa.bbh ".'|| { echo "command failed"; exit 1; }'."\n\n";
 
          print $fh "perl ___scripts_bin___/find-reciprocal-hit.pl -q1 $$organisms[$j] -q2 $$organisms[$i] -cmp1 $out_directory/Cmp/$$organisms[$j].faa.$$organisms[$i].faa.cmp -cmp2 $out_directory/Cmp/$$organisms[$i].faa.$$organisms[$j].faa.cmp -s e-value -col 10 -cutoff 1e-5 -method SBH > $out_directory/Cmp/$$organisms[$j].faa.$$organisms[$i].faa.bbh ".'|| { echo "command failed"; exit 1; }'."\n\n";

         print $fh "perl ___scripts_bin___/eggs-new-generic-evalue_new.pl -tmp $out_directory/Trash/ -session 1209 -input1 $$organisms[$i] -input2 $$organisms[$j] -distance 300 -sim 300 -clust_dist1 1000 -clust_dist2 4000 -pair_score 200 -addclust_dist 100000 -min_clust_size 2 ".'|| { echo "command failed"; exit 1; }'."\n\n";

         print $fh "perl ___scripts_bin___/eggs-new-generic-evalue_new.pl -tmp $out_directory/Trash/ -session 1209 -input1 $$organisms[$j] -input2 $$organisms[$i] -distance 300 -sim 300 -clust_dist1 1000 -clust_dist2 4000 -pair_score 200 -addclust_dist 100000 -min_clust_size 2 ".'|| { echo "command failed"; exit 1; }'."\n\n";
 
      }
    }

    print $fh "mv $out_directory/Cmp/*.cmp $out_directory/cmp/\n";
    print $fh "mv $out_directory/Cmp/*.bbh $out_directory/cmp/\n";
    print $fh "mv $out_directory/Cmp/*.faa $out_directory/faaptt/\n";
    print $fh "mv $out_directory/Cmp/*.ptt $out_directory/faaptt/\n";
    print $fh "mv $out_directory/Trash/*.post $out_directory/post/\n\n";
    
    print $fh "java -jar ___scripts_bin___/PhyloEGGS.jar $tree $out_directory/cmp/ $out_directory/post/ $out_directory/faaptt/ $out_directory/out/ 1.0 ".'|| { echo "command failed"; exit 1; }'."\n\n";

    print $fh "tar -cvf out.tar out/\n";
    print $fh "gzip out.tar\n";

    close $fh;
    chmod(0755, $sge_submit_script);
 
    my $command = "$sge_submit_script";
 
    my $config = {};
    $config->{job_id} = $job->getId;
    $config->{output_file} = "$out_directory/out.tar.gz";

    $job->buildConfigFile( $config );
 
    return $command;
}

#------------------------------------------------------------------------

=item public File getOutputFormat( );

Return the appropriate output format for this job type.

=cut
#------------------------------------------------------------------------

sub getOutputFormat {
  my ($self, $args) = @_;
  return 'PhyloEGGS';
}
#------------------------------------------------------------------------

=item public File getOutputType( );

Return the appropriate output type for this job type.

=cut
#------------------------------------------------------------------------

sub getOutputType {
  my ($self, $args) = @_;
  return 'VizPhyloEGGS';
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
