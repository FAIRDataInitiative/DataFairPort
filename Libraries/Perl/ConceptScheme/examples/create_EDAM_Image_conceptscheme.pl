use strict;
use warnings;
use lib "../";
use Ontology::Views::SKOS::ConceptSchemeBuilder;
open(IN, "/home/markw/apikey"); # your BioPortal API key 
my $apikey = <IN>;
close IN;

my $edam = Ontology::Views::SKOS::ConceptSchemeBuilder->new(
	schemeURI => "http://biordf.org/DataFairPort/ConceptSchemes/EDAMOntologyImage2968",
        schemeName => "SKOS view of the Image (SO_0000704) branch of the EDAM Ontology",
apikey => $apikey,
	);
my $scheme = $edam->growConceptScheme('EDAM', 'http://edamontology.org/data_2968'); # edam:Image

open(OUT, ">EDAMOntologyImage2968") || die "can't open conceptscheme rdf $!";
print $scheme->serialize;
print OUT $scheme->serialize;
close OUT;


