use strict;
use warnings;
use lib "../";
use Ontology::Views::SKOS::ConceptSchemeBuilder;
open(IN, "/tmp/apikey"); # your BioPortal API key 
my $apikey = <IN>;
close IN;

my $edam = Ontology::Views::SKOS::ConceptSchemeBuilder->new(
	schemeURI => "http://biordf.org/DataFairPort/ConceptSchemes/EDAM_Microarray_Data_Format",
        schemeName => "SKOS view of the EDAM Data Format ontology branch",
apikey => $apikey,
	);
my $scheme = $edam->growConceptScheme('EDAM', 'http://edamontology.org/format_2056'); # edam:MicroarrayDataFormat

# my $scheme = $b->growConceptScheme('edam', 'http://edamontology.org/format_1915');  # edam:Format

open(OUT, ">EDAM_Microarray_Data_Format") || die "can't open conceptscheme rdf $!";
print $scheme->serialize;
print OUT $scheme->serialize;
close OUT;


my $efo = Ontology::Views::SKOS::ConceptSchemeBuilder->new(
	schemeURI => "http://biordf.org/DataFairPort/ConceptSchemes/EFO_Gene_Expression_Protocol",
        schemeName => "SKOS view of the Experimental Factor Ontology Gene Expression Protocols",
        apikey => $apikey,
	);
my $scheme2 = $efo->growConceptScheme('EFO', 'http://www.ebi.ac.uk/efo/EFO_0003788'); # edam:MicroarrayDataFormat

# my $scheme = $b->growConceptScheme('edam', 'http://edamontology.org/format_1915');  # edam:Format

open(OUT, ">EFO_Gene_Expression_Protocol") || die "can't open conceptscheme rdf $!";
print $scheme2->serialize;
print OUT $scheme2->serialize;
close OUT;

#
#
#
#my $b2 = Ontology::Views::SKOS::conceptSchemeBuilder->new();
#my $scheme2 = $b2->parseFile('conceptscheme.rdf');
#open(OUT, ">conceptscheme2.rdf") || die "can't open conceptscheme rdf $!";
#print $scheme2->serialize;
#print OUT $scheme2->serialize;
#close OUT;

