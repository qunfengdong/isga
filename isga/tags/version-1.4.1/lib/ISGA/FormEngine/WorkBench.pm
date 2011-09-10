package ISGA::FormEngine::WorkBench;
#------------------------------------------------------------------------

=head1 NAME

ISGA::FormEngine::WorkBench - provide forms for workbench tools.

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=cut
#------------------------------------------------------------------------
use strict;
use warnings;

#========================================================================

=head2 CLASS METHODS

=over 4

=cut
#========================================================================


#------------------------------------------------------------------------

=item public hashref form Build();

Build a FormEngine object for WorkBench queries.  Chooses form based
on job type

=cut
#------------------------------------------------------------------------

sub Build {
  my ($class, $args) = @_;

  my $job_type = $args->{job_type};

  my $subclass = $job_type->getClass;

  my $form = ISGA::FormEngine->new($args);
  $form->set_skin_obj('ISGA::FormEngine::SkinUniform');
  
  my $form_params = $subclass->buildForm($args);

  push(@{$form_params}, {templ => 'hidden',
                         NAME => 'job_type',
                         VALUE => $args->{job_type}});

  $form->conf( { ACTION => '/submit/WorkBench/RunJob',
                 FORMNAME => 'workbench',
                 FORMATTR => [ 'onsubmit="return startEmbeddedProgressBar(this)"' ],
                 SUBMIT => 'Submit',
                 ENCTYPE => 'multipart/form-data',
                 sub => $form_params } );

  $form->make;
  return $form;
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
