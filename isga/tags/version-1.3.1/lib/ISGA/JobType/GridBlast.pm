package ISGA::JobType::GridBlast;
#------------------------------------------------------------------------

=head1 NAME

<ISGA::JobType::BLAST> provides methods for working with BLAST jobs.


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
  
  my $form = ISGA::FormEngine->new($args);
  $form->set_skin_obj('ISGA::FormEngine::SkinUniform');

  my $db_path = "/N/gpfs/abuechle/blastdb";
  my @database_names = ( 'GenBank protein: nr' ); 
  my @database_values = ( "${db_path}/nr" ); 

  my @blast_program = ( 'blastn', 'blastp', 'blastx', 'tblastn');

  my @form_params =
  (
    {
      TITLE => 'BLAST',
      templ => 'fieldset',
      sub => [
                  {
                    'SIZE' => 1,
                    'NAME' => 'sequence_database',
                    'templ' => 'select',
                    'OPTION' => \@database_names,
                    'OPT_VAL' => \@database_values,
                    'ERROR' => 'Blast::isDatabaseSelected',
                    'TITLE' => 'Select database'
                  },
                  {
                    'ERROR' => ['Blast::compatibleBlastProgramAndDB'],
                    'OPTION' => \@blast_program,
                    'SIZE' => 1,
                    'TITLE' => 'BLAST program',
                    'NAME' => 'blast_program',
                    'templ' => 'select'
                  },
                  {
                    'SIZE' => 60,
                    'VALUE' => '1e-5',
                    'NAME' => 'evalue',
                    'LABEL' => 'evalue',
                    'MAXLEN' => 60,
                    'ERROR' => ['Number::isScientificNotation', 'not_null', 'Text::checkHTML'],
                    'TITLE' => 'E-value',
                  },
                  {
                    'OPTION' => ['yes', 'no'],
                    'VALUE' => 'yes',
                    'NAME' => 'blastfilter',
                    'LABEL' => 'blastfilter',
                    'templ' => 'select',
                    'TITLE' => 'Low complexity region filter',
                  },
                  {
                    'NAME' => 'nummatches',
                    'TITLE' => 'Matches per Query Sequence',
                    'LABEL' => 'nummatches',
                    'VALUE' => '150',
                    'ERROR' => ['digitonly'],
                  },
                  {
                    'NAME' => 'numdescirptions',
                    'TITLE' => 'Descriptions per Query Sequence',
                    'LABEL' => 'numdescirptions',
                    'VALUE' => '150',
                    'ERROR' => ['digitonly'],
                  },
                  {
                    'OPTION' => ['Standard', 'Tabular (no comment lines)', 'Tabular (with comment lines)', 'XML'],
                    'OPT_VAL' => ['0', '6', '7', '5'],
                    'VALUE' => '0',
                    'NAME' => 'outputformat',
                    'LABEL' => 'outputformat',
                    'templ' => 'select',
                    'TITLE' => 'Output Format',
                  },
                  {
                    'HINT' => '<a href="https://wiki.cgb.indiana.edu/download/attachments/25821247/nucleotide_blast_sample.fna">Sample DNA File</a> | <a href="https://wiki.cgb.indiana.edu/download/attachments/25821247/amino_acid_blast_sample.fsa">Sample Protein File</a>',
                    'ERROR' => ['Blast::checkUploadFile', 'Blast::sanityFastaChecks'],
                    'SIZE' => 5,
                    'VALUE' => $content,
                    'TITLE' => 'Enter query sequence in <a target="_blank" href="http://www.ncbi.nlm.nih.gov/blast/fasta.shtml">FASTA format</a>',
                    'NAME' => 'query_sequence',
                    'templ' => 'textarea'
                  },
                  {
                    'ERROR' => ['Blast::checkUploadFile', 'Blast::sanityFastaChecks'],
                    'TITLE' => 'Or upload query sequence file',
                    'NAME' => 'upload_file',
                    'templ' => 'upload'
                  },
                  {
                    'TITLE' => 'Email me when job completes',
                    'NAME' => 'notify_user',
                    'templ' => 'check',
                    'VALUE' => 0,
                    'OPT_VAL' => 1,
                    'OPTION' => '',
                    'HINT' => 'Check this box to receive email notification when your job completes.'

                  },
      ],
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

        my $web_args = $webapp->args;

        my $sequences = $form->get_input('query_sequence');
        my $upload = $webapp->apache_req->upload('upload_file');

        ## Hardcoded paths.
        my $files_path = "/N/u/abuechle/Quarry/twistertest/data/workbench/blast/";

        my $blastfilter = $form->get_input('blastfilter');
        my $scoringmatrix = $form->get_input('scoringmatrix');
        my $evalue = $form->get_input('evalue');
        my $blast_program = $form->get_input('blast_program');
        my $nummatches = $form->get_input('nummatches');
        my $descriptions = $form->get_input('numdescirptions');
        my $outputformat = $form->get_input('outputformat');
        my $sequence_database = $form->get_input('sequence_database');
        ref($sequence_database) eq 'ARRAY' or $sequence_database = [ $sequence_database ];

        my $log_name  = $job->getType->getName . "_" .  $job->getId;

        my $out_directory = $files_path.$log_name;
        mkdir($out_directory) or X->throw(message => 'output directory creation failed') if(! -e $out_directory);

        my $blast_output = $out_directory."/${log_name}_blast_output.blout";

        my @database_array;

        foreach (@$sequence_database){
          push(@database_array, $_);
        }

        my $database = join(' ', @database_array);

        my %args = ( );
        $upload and $args{Upload} = $upload->fh;
        $sequences and $args{String} = $sequences;
        $args{Type} = $blast_program =~ /(^blastp$|^tblastn$)/ ? "Amino Acid Sequence" : "Nucleotide Sequence";
        $args{Format} = "FASTA";
        $args{Description} = 'Input file for BLAST job';
        $args{Username} = $upload ? basename($upload) : $log_name.'_blast_input';

        my $input_file = $job->buildQueryFile(%args);

        $input_file->stage($out_directory);

        my $runpath = "$out_directory/" . $input_file->getName();

        my $command;
        my $sge_submit_script = "$out_directory/${log_name}_sge_blast.sh";

        my $workflow_ini = "$out_directory/quarry_test.ini";
        open my $ini, '>', $workflow_ini or X->throw(message => 'Error creating workflow ini');
        print $ini qq(; Config file for testing simple workflow

[1]


[1.1]
param.command=time
arg=/N/soft/linux-rhel4-x86_64/ncbi-blast-2.2.23+/bin/blastx -db /N/gpfs/abuechle/blastdb/nr
flag=-query
flag=-out
; Unix Command Flow Comand set

;DCE Specification
dceSpec.type = twister
dceSpec.twisterSpec.twisterLocation = /N/u/abuechle/Quarry/twistertest/twister-0.8
dceSpec.twisterSpec.appDir = /N/u/abuechle/Quarry/twistertest/twister-0.8/apps
dceSpec.twisterSpec.dataDir = /N/u/abuechle/Quarry/twistertest/data
dceSpec.twisterSpec.pubSubBroker = NaradaBrokering
dceSpec.twisterSpec.daemonPort = 12500
dceSpec.twisterSpec.brokerHost = 156.56.96.179
dceSpec.twisterSpec.brokerPort = 3045
dceSpec.twisterSpec.commType = niotcp
dceSpec.twisterSpec.nodesFile = /N/u/abuechle/Quarry/twistertest/data/bin/nodes
dceSpec.twisterSpec.brokerLocation = /research/projects/isga/vtest/workflow-3.1.x-cgbr0/twister/NaradaBrokering-4.2.2
dceSpec.twisterSpec.workersPerDaemon = 24
dceSpec.twisterSpec.daemonsPerNode = 1

dceSpec.twisterSpec.partitionFile = /N/u/abuechle/Quarry/twistertest/data/partition/blast.pf
dceSpec.twisterSpec.mapTaskNum = 8
dceSpec.twisterSpec.reduceTaskNum = 0
dceSpec.twisterSpec.subDataDir = /blast
dceSpec.twisterSpec.fileExtension = .fa
dceSpec.twisterSpec.linesPerUnit = 2
dceSpec.twisterSpec.originalFile = $runpath
dceSpec.twisterSpec.originalFileLines = 2000
);

=for comment
  Steps
  1. Have NB running
  2. make output directory on quarry
  3. copy query to quarry
  4. reserve nodes (>qsub -I -l nodes=2:ppn=8,walltime=24:00:00 -q pg)
  5. find reserved nodes (>more $PBS_NODEFILE)
     * pg2
     * pg4
  6. rewrite nodes files on both local and quarry
  7. write workflow xml
  8. run workflow
  9. check status
 10. retrieve output
=cut
        open my $fh, '>', $sge_submit_script or X->throw(message => 'Error creating sge shell script.');
        print $fh '#!/bin/bash'."\n\n";
        print $fh 'export TWISTER_HOME=/research/projects/isga/vtest/workflow/twister/twister-0.8'."\n";
        print $fh 'export NBHOME=/research/projects/isga/vtest/workflow/twister/NaradaBrokering-4.2.2'."\n";
        print $fh 'export WF_ROOT_INSTALL=/research/projects/isga/vtest/workflow'."\n";
 
        print $fh "ssh abuechle\@quarry.uits.indiana.edu \"mkdir -p $out_directory\"\n\n";
        print $fh "ssh abuechle\@quarry.uits.indiana.edu \"qsub -l nodes=1:ppn=4,walltime=01:00:00 -q pg ~/magic\"\n\n";

        print $fh "/research/projects/isga/vtest/workflow/create_workflow -c $out_directory/quarry_test.ini -t /research/projects/isga/vtest/workflow-3.1.x-cgbr0/twister/dce_task/quarry_test_template.xml -i $out_directory/quarry_test.xml --delete-old\n";

        print $fh "/research/projects/isga/vtest/workflow/run_workflow -c $out_directory/quarry_test.ini -t /research/projects/isga/vtest/workflow-3.1.x-cgbr0/twister/dce_task/quarry_test_template.xml -i $out_directory/quarry_test.xml -l $out_directory/quarry_test.log\n";
        
        print $fh "/research/projects/isga/vtest/workflow/check_workflow -c $out_directory/quarry_test.ini -t /research/projects/isga/vtest/workflow-3.1.x-cgbr0/twister/dce_task//quarry_test_template.xml -i $out_directory/quarry_test.xml > $out_directory/response.txt\n";
        
        #print $fh "until grep \'No workflow based on /research/projects/isga/vtest/workflow-3.1.x-cgbr0/twister/dce_task/quarry_test.xml is running.\' $out_directory/response.txt\n";
        print $fh "until grep \'No workflow based on .* is running.\' $out_directory/response.txt\n";
        print $fh "do\n";
        print $fh "  /research/projects/isga/vtest/workflow/check_workflow -c $out_directory/quarry_test.ini -t /research/projects/isga/vtest/workflow-3.1.x-cgbr0/twister/dce_task//quarry_test_template.xml -i $out_directory/quarry_test.xml > $out_directory/response.txt\n";
        print $fh "  sleep 60\n";
        print $fh "done\n";

        
        print $fh "ssh abuechle\@quarry.uits.indiana.edu \"~/kill_magic\"\n\n";
        print $fh "ssh abuechle\@quarry.uits.indiana.edu \"cat $out_directory/*.out > $out_directory/grid_blast.blout\"\n\n";
        print $fh "scp abuechle\@quarry.uits.indiana.edu:$out_directory/grid_blast.blout $out_directory\n\n";
        close $fh;
        chmod(0755, $sge_submit_script);
        $command = "$sge_submit_script";

        my @params;
        foreach (keys %{$web_args}) {
          unless ($_ eq 'query_sequence' || $_ eq 'upload_file' || $_ eq 'sequence_database' || $_ eq 'workbench' || $_ eq 'progress_id' || $_ eq 'notify_user' || $_ eq 'job_type'){
            push(@params, {$_ => ${$web_args}{$_}});
          }
        }

        my $config = {};
        $config->{job_id} = $job->getId;
        $config->{input_file} = $input_file->getUserName;
        $config->{input_file_path} = $runpath;
        $config->{output_file} = $blast_output;
        push @{$config->{databases}}, @database_array;
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
  return 'BLAST Raw Results';
}
#------------------------------------------------------------------------

=item public File getOutputType( );

Return the appropriate output type for this job type.

=cut
#------------------------------------------------------------------------

sub getOutputType {
  my ($self, $args) = @_;
  return 'BLAST Search Result';
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
