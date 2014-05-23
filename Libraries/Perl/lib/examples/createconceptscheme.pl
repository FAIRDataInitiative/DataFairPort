use strict;
use warnings;
use lib "../";

use Ontology::Views::SKOS::conceptSchemeBuilder;

my $b = Ontology::Views::SKOS::conceptSchemeBuilder->new(
	schemeURI => "http://datafairport.org/conceptSchemes/EDAM_Data_Format",
        schemeName => "SKOS view of the EDAM Data Format ontology branch",
apikey => '24e04058-54e0-11e0-9d7b-005056aa3316',
	);
my $scheme = $b->growConceptScheme('EDAM', 'http://edamontology.org/format_2056'); # edam:MicroarrayDataFormat

# my $scheme = $b->growConceptScheme('edam', 'http://edamontology.org/format_1915');  # edam:Format

open(OUT, ">conceptscheme.rdf") || die "can't open conceptscheme rdf $!";
print $scheme->serialize;
print OUT $scheme->serialize;
close OUT;

my $b2 = Ontology::Views::SKOS::conceptSchemeBuilder->new();
my $scheme2 = $b2->parseFile('conceptscheme.rdf');
open(OUT, ">conceptscheme2.rdf") || die "can't open conceptscheme rdf $!";
print $scheme2->serialize;
print OUT $scheme2->serialize;
close OUT;

