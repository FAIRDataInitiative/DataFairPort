package FAIR::Accessor::MetaRecord;
use strict;
use Moose;
use UUID::Generator::PurePerl;
use RDF::Trine::Store::Memory;
use RDF::Trine::Model;
use FAIR::Accessor::Distribution;

with 'FAIR::CoreFunctions';


has 'MetaData' => (
    isa => "HashRef",
    is => "rw",
    default => sub {my $h = {}; return $h}
);


has 'FreeFormRDF' => (
    is => 'rw',
    isa => "RDF::Trine::Model"
);

has 'NS' => (
    is => 'rw',
    required => 'true',
);

has 'ID' => (
      is => 'rw',
      isa => 'Str',
      required => 'true',
);

has 'Distributions' => (
      is => 'rw',
      isa => 'ArrayRef[FAIR::Accessor::Distribution]',
);



sub addMetadata {
    my ($self, $metadata) = @_;
    my %datahash = %$metadata;
    my %existing = %{$self->MetaData};
    foreach my $key(keys %datahash){
        $existing{$key} = $datahash{$key};
    }
    $self->MetaData(\%existing);
    
}

sub addDistribution {
      my ($self, %ARGS) = @_;  #
      my $currentDistributions = $self->Distributions;
      my @currentDistributions;
      if ($currentDistributions) {
         @currentDistributions = @$currentDistributions;   
      }
      
      my $Distribution = FAIR::Accessor::Distribution->new();
      $Distribution->NS($self->NS);
      $Distribution->downloadURL($ARGS{downloadURL});
      $Distribution->availableformats($ARGS{availableformats});

      if ($ARGS{source}) {  # this is very dangerous... we assume that the user sends all parameters... if not, we don't check and Moose constraints will be violated
            # these are only for TPF
            $Distribution->source($ARGS{source});
            $Distribution->subjecttemplate($ARGS{subjecttemplate});
            $Distribution->subjecttype($ARGS{subjecttype});
            $Distribution->predicate($ARGS{predicate});
            $Distribution->objecttemplate($ARGS{objecttemplate});
            $Distribution->objecttype($ARGS{objecttype});
      }
      
      push @currentDistributions, $Distribution;
      $self->Distributions(\@currentDistributions);
}


1;
