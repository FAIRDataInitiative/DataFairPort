use strict;
use warnings;
use lib "../";

use Ontology::Views::SKOS::conceptSchemeBuilder;

my $b = Ontology::Views::SKOS::conceptSchemeBuilder->new(
	server => 'http://localhost',
	port => '9031',
	schemeURI => "http://datafairport.org/conceptSchemes/EDAM_Data_Format",
	);

$b->topConcept('http://edamontology.org/format_1915');

$b->createConceptScheme();
