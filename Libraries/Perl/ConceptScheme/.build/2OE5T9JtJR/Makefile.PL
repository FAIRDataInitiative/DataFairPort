
use strict;
use warnings;



use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "modules for creating SKOS ConceptSchemes representing slices of ontologies",
  "AUTHOR" => "Mark Wilkinson (markw [at] illuiminae [dot] com)",
  "BUILD_REQUIRES" => {},
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "Ontology-Views-SKOS-ConceptScheme",
  "EXE_FILES" => [],
  "LICENSE" => "perl",
  "NAME" => "Ontology::Views::SKOS::ConceptScheme",
  "PREREQ_PM" => {
    "Data::UUID::MT" => 0,
    "JSON" => 0,
    "LWP::Simple" => 0,
    "RDF::NS" => 0,
    "RDF::Query" => 0,
    "RDF::Trine::Model" => 0,
    "RDF::Trine::Parser" => 0,
    "RDF::Trine::Serializer" => 0,
    "URI::Escape" => 0
  },
  "TEST_REQUIRES" => {
    "File::Slurp" => 0,
    "IO::String" => 0
  },
  "VERSION" => "0.15",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.63_03) } ) {
  my $tr = delete $WriteMakefileArgs{TEST_REQUIRES};
  my $br = $WriteMakefileArgs{BUILD_REQUIRES};
  for my $mod ( keys %$tr ) {
    if ( exists $br->{$mod} ) {
      $br->{$mod} = $tr->{$mod} if $tr->{$mod} > $br->{$mod};
    }
    else {
      $br->{$mod} = $tr->{$mod};
    }
  }
}

unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



