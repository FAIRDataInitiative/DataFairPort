use strict;
use warnings;
use lib "../";
use Ontology::Views::SKOS::ConceptSchemeBuilder;
open(IN, "/home/markw/apikey"); # your BioPortal API key 
my $apikey = <IN>;
close IN;

my $edam = Ontology::Views::SKOS::ConceptSchemeBuilder->new(
	schemeURI => "http://biordf.org/DataFairPort/ConceptSchemes/SIOOntologyImage81",
        schemeName => "SKOS view of the Image (SIO_000081) branch of the SIO Ontology",
apikey => $apikey,
	);
my $scheme = $edam->growConceptScheme('SIO', 'http://semanticscience.org/resource/SIO_000081'); # SIO:Image

open(OUT, ">SIOOntologyImage81") || die "can't open conceptscheme rdf $!";
print $scheme->serialize;
print OUT $scheme->serialize;
close OUT;


