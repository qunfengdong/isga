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
use File::Copy;
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
       templ => 'fieldset',
       TITLE => 'Required Parameters',
       NESTED => '1',
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
       	  VALUE => '1.0',
          NAME => 'c_ratio',
          ERROR => ['Number::isNumber', 'not_null', 'Text::checkHTML'],
          TITLE => 'Conservation ratio',
         
        },
       ]
       },
       {
       templ => 'fieldset',
       TITLE => 'Optional User Uploads',
       JSHIDE => 'optional_hide',
       NESTED => '1',
       sub => 
       [
        {
         TITLE => 'Upload genome protein sequence',
         NAME  => 'genome_seq_file',
         templ => 'upload',
         ERROR => 'PhyloEGGS::checkGenomeFile'
        },
        {
         TITLE => 'Upload ptt file',
         NAME  => 'ptt_file',
         templ => 'upload',
         ERROR => 'PhyloEGGS::checkPttFile'
        },
        {
         TITLE => 'Upload 16SRNA file',
         NAME  => '16sRNA_file',
         templ => 'upload',
         ERROR => 'PhyloEGGS::checkSRNAFile'
        },
        {
         TITLE => 'Newick Phylogenetic Tree',
         NAME => 'upload_newick_file',
         templ => 'upload'
        },
        ]
      }
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
    use File::Path;

    my $web_args = $webapp->args;
    my $newick_upload = $webapp->apache_req->upload('upload_newick_file');
    my $c_ratio=$form->get_input('c_ratio');
    my $organisms = $form->get_input('organisms');
    ref($organisms) eq 'ARRAY' or $organisms = [ $organisms ];

    ## genome  user uploaded 
    my $genome_upload = $webapp->apache_req->upload('genome_seq_file');
    my $ptt_upload =    $webapp->apache_req->upload('ptt_file');
    my $SRNA_upload=  $webapp->apache_req->upload('16sRNA_file');
    my $perllib="/research/projects/isga/perllib/share/perl/5.8.8";

	
    ## Hardcoded paths.
    my $files_path = "___tmp_file_directory___/workbench/" . $job->getType->getName . "/";
    umask(0);
    mkpath($files_path );

    my $bacteria_directory = "/research/projects/isga/ftp/Bacteria"; # Talk to Chris about database for this garbage.
    my $reduced = "/research/projects/isga/ftp/Bacteria/reduced/result";
    
    my $log_name  = $job->getType->getName . "_" .  $job->getId;
    my $out_directory = $files_path.$log_name;
    
    mkdir($out_directory) or X->throw(message => 'output directory creation failed') if(! -e $out_directory);
    mkdir("$out_directory/Cmp") or X->throw(message => 'output directory creation failed') if(! -e "$out_directory/Cmp");
    
    mkdir("$out_directory/cmp") or X->throw(message => 'output directory creation failed') if(! -e "$out_directory/cmp");
    mkdir("$out_directory/faaptt") or X->throw(message => 'output directory creation failed') if(! -e "$out_directory/faaptt");
    mkdir("$out_directory/post") or X->throw(message => 'output directory creation failed') if(! -e "$out_directory/post");
    mkdir("$out_directory/blast") or X->throw(message => 'output directory creation failed') if(! -e "$out_directory/blast");
    
    my ($user_genome, $user_genome_filename, $user_genome_name, $user_ptt, $user_srna);
	
    if ( ($genome_upload ne '') && ($ptt_upload ne '')  ){
      my %Genome_args,my %Ptt_args,my %SRNA_args;
      $Genome_args{Upload} = $genome_upload->fh;
      $Genome_args{Format} = 'FASTA';
      $Genome_args{Type} = 'Amino Acid Sequence';
      $Genome_args{Username} = basename($genome_upload);
      my $genome_input_file = $job->buildQueryFile(%Genome_args);
      $genome_input_file->stage($out_directory."/Cmp/");
      my $user_genome_temp = $out_directory."/Cmp/".$genome_input_file->getName();
  
      $user_genome_filename=basename($genome_upload);
      $user_genome=$out_directory."/Cmp/".$user_genome_filename;
      move($user_genome_temp,$user_genome);
      $user_genome_name=$user_genome_filename;
      $user_genome_name =~ s/\.faa$//;

      $Ptt_args{Upload} = $ptt_upload->fh;
      $Ptt_args{Format} = 'PTT';
      $Ptt_args{Type} = 'Protein Features';
      $Ptt_args{Username} = basename($ptt_upload);
      my $ptt_input_file = $job->buildQueryFile(%Ptt_args);
      $ptt_input_file->stage($out_directory."/Cmp/");
      my $user_ptt_temp = $out_directory."/Cmp/".$ptt_input_file->getName();
      $user_ptt=$out_directory."/Cmp/".$user_genome_name.".ptt";
      move($user_ptt_temp,$user_ptt);
      
      if($SRNA_upload ne ''){
        $SRNA_args{Upload} = $SRNA_upload->fh;
        $SRNA_args{Format} = 'FASTA';
        $SRNA_args{Type} = '16s RNA';
        $SRNA_args{Username} = basename($SRNA_upload);
        my $SRNA_input_file = $job->buildQueryFile(%SRNA_args);
        $SRNA_input_file->stage($out_directory);
        $user_srna = $out_directory."/".$SRNA_input_file->getName();
      }
    }

    my $tree;
    if($newick_upload ne '') {
        my %args;
        $args{Upload} = $newick_upload->fh;
        $args{Format} = 'Newick';
        $args{Type} = 'Phylogenetic Tree';
        $args{Username} = basename($newick_upload);
        my $newick_input_file = $job->buildQueryFile(%args);
        $newick_input_file->stage($out_directory);
        $tree = $out_directory."/".$newick_input_file->getName();
    }

    foreach my $org (@$organisms){
       copy("$reduced/$org.faa", "$out_directory/Cmp/") or X->throw(message =>$!." ".$@. "Cannot copy $reduced/$org.faa  file to $out_directory/Cmp directory");
       copy("$reduced/$org.ptt", "$out_directory/Cmp/") or X->throw(message => 'Cannot copy ptt file to Cmp directory');
    }

    my $sge_submit_script = "$out_directory/${log_name}_sge.sh";
 
    open my $fh, '>', $sge_submit_script or X->throw(message => 'Error creating sge shell script.');
    print $fh '#!/bin/bash'."\n\n";

    print $fh "export PERL5LIB=$perllib \n\n";

    print $fh "cd $out_directory\n\n";
    unless ($newick_upload){
      print $fh "cat";
      foreach my $org (@$organisms){
        print $fh " ".$reduced."/".$org.".fasta";
      }

      if($user_srna ne ""){
        print $fh " ".$user_srna;
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
    if (($genome_upload ne '') && ($ptt_upload ne '') ){
      ## format user input genome
      print $fh "___formatdb_executable___ -i $user_genome -p T ".'|| { echo "command failed"; exit 1; }'."\n\n";
     
      for(my $i =0; $i <scalar @$organisms; $i++){
        ## do blast search
        print $fh "___blast_executable___ -p blastp -e 1e-5 -d  $reduced/$$organisms[$i].faa -m8 -i $user_genome -o $out_directory/blast/$user_genome_filename.$$organisms[$i].faa.cmp "."\n\n";
        
        print $fh "___blast_executable___ -p blastp -e 1e-5 -d  $user_genome -i $reduced/$$organisms[$i].faa -m8 -o $out_directory/blast/$$organisms[$i].faa.$user_genome_filename.cmp "."\n\n";
        
        print $fh "perl ___scripts_bin___/extract_gi_num.pl -i $out_directory/blast/$user_genome_filename.$$organisms[$i].faa.cmp -o $out_directory/Cmp/$user_genome_filename.$$organisms[$i].faa.cmp ".'|| { echo "command failed"; exit 1; }'."\n\n";
        
        print $fh "perl ___scripts_bin___/extract_gi_num.pl -i $out_directory/blast/$$organisms[$i].faa.$user_genome_filename.cmp -o $out_directory/Cmp/$$organisms[$i].faa.$user_genome_filename.cmp ".'|| { echo "command failed"; exit 1; }'."\n\n";
         
        print $fh "perl ___scripts_bin___/find-reciprocal-hit.pl -q1 $$organisms[$i] -q2 $user_genome_name -cmp1 $out_directory/Cmp/$$organisms[$i].faa.$user_genome_filename.cmp -cmp2 $out_directory/Cmp/$user_genome_filename.$$organisms[$i].faa.cmp -s e-value -col 10 -cutoff 1e-5 -method SBH > $out_directory/Cmp/$$organisms[$i].faa.$user_genome_filename.bbh ".'|| { echo "command failed"; exit 1; }'."\n\n";
         
        print $fh "perl ___scripts_bin___/find-reciprocal-hit.pl -q1 $user_genome_name -q2 $$organisms[$i] -cmp1 $out_directory/Cmp/$user_genome_filename.$$organisms[$i].faa.cmp -cmp2 $out_directory/Cmp/$$organisms[$i].faa.$user_genome_filename.cmp -s e-value -col 10 -cutoff 1e-5 -method SBH > $out_directory/Cmp/$user_genome_filename.$$organisms[$i].faa.bbh ".'|| { echo "command failed"; exit 1; }'."\n\n";
        
        print $fh "perl ___scripts_bin___/eggs-new-generic-evalue_new.pl -tmp $out_directory/Trash/ -session 1209 -input1 $$organisms[$i] -input2 $user_genome_name -distance 300 -sim 300 -clust_dist1 1000 -clust_dist2 4000 -pair_score 200 -addclust_dist 100000 -min_clust_size 2 ".'|| { echo "command failed"; exit 1; }'."\n\n";
        
        print $fh "perl ___scripts_bin___/eggs-new-generic-evalue_new.pl -tmp $out_directory/Trash/ -session 1209 -input1 $user_genome_name -input2 $$organisms[$i] -distance 300 -sim 300 -clust_dist1 1000 -clust_dist2 4000 -pair_score 200 -addclust_dist 100000 -min_clust_size 2 ".'|| { echo "command failed"; exit 1; }'."\n\n";
      }
      print $fh "cd $out_directory \n";
    }
    print $fh "mv $out_directory/Cmp/*.cmp $out_directory/cmp/\n";
    print $fh "mv $out_directory/Cmp/*.bbh $out_directory/cmp/\n";
    print $fh "mv $out_directory/Cmp/*.faa $out_directory/faaptt/\n";
    print $fh "mv $out_directory/Cmp/*.ptt $out_directory/faaptt/\n";
    print $fh "mv $out_directory/Trash/*.post $out_directory/post/\n\n";
    
    print $fh "java -jar ___scripts_bin___/PhyloEGGS.jar $tree $out_directory/cmp/ $out_directory/post/ $out_directory/faaptt/ $out_directory/out/ $c_ratio ".'|| { echo "command failed"; exit 1; }'."\n\n";
	
	print $fh "mv $out_directory/faaptt/* $out_directory/out/\n";
    print $fh "tar -cvf ${log_name}_output.tar out/\n";
    print $fh "gzip ${log_name}_output.tar\n";

    close $fh;
    chmod(0755, $sge_submit_script);
 
    my $command = "$sge_submit_script";

    my @params;
    foreach (keys %{$web_args}) {
      unless ($_ eq 'query_sequence' || $_ eq 'upload_file' || $_ eq 'sequence_database' || $_ eq 'workbench' || $_ eq 'progress_id' || $_ eq 'notify_user' || $_ eq 'job_type'){
        push(@params, {$_ => ${$web_args}{$_}});
      }
    }
 
    my $config = {};
    $config->{job_id} = $job->getId;
    $config->{output_file} = "$out_directory/${log_name}_output.tar.gz";
    push @{$config->{params}}, @params;

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
