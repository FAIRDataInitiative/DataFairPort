use strict;
use warnings;
use lib "../";
use Ontology::Views::SKOS::ConceptSchemeBuilder;
open(IN, "/home/markw/apikey"); # your BioPortal API key 
my $apikey = <IN>;
close IN;

my $edam = Ontology::Views::SKOS::ConceptSchemeBuilder->new(
	schemeURI => "http://biordf.org/DataFairPort/ConceptSchemes/SequenceOntologyGene704",
        schemeName => "SKOS view of the Gene (SO_0000704) branch of the Sequence Ontology",
apikey => $apikey,
	);
my $scheme = $edam->growConceptScheme('SO', 'http://purl.obolibrary.org/obo/SO_0000704'); # edam:MicroarrayDataFormat

open(OUT, ">SequenceOntologyGene704") || die "can't open conceptscheme rdf $!";
print $scheme->serialize;
print OUT $scheme->serialize;
close OUT;


