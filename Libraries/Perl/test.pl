use strict;
use warnings;

use DCAT;

my $Descriptor = DCAT::Descriptor->new();

my $publisher1 = DCAT::Agent->new(agent => "http://people.com/Markwilkinson", label => 'Mark Wilkinson');
my $publisher2 = DCAT::Agent->new(agent => "http://people.com/MarkwilkinsonII", label => 'Mark Wilkinson II');
my $concept1 = DCAT::Concept->new(concept => "http://people/com/People/Professor", label => "Professor");
my $concept2 = DCAT::Concept->new(concept => "http://people/com/People/UPMPRofessors", label => "Professors at UPM");
my $conceptscheme1 = DCAT::ConceptScheme->new(conceptscheme => "http://people/com/People/employmentCategories", label => "Categories of Employment");

print "\n\nadding inConceptScheme to a scheme\n\n";
$concept1->add_inScheme($conceptscheme1);


print "\n\n\nDISTRIBUTION\n\n\n";
my $dist = DCAT::Distribution->new(
		title => "My Distribution",
		description => "an example of a DCAT Distribution",
		issued => "1/23/2014",
		modified => "2/24/2014",
		license => "CC-by-AA",
		rights => "silly rights",
		accessURL => "http://wilkinsonlab.info/data.rdf",
		downloadURL => 'http://wilkinsonlab.info/datadownload.rdf',
		mediaType => "application/rdf+xml",
		format => "arbitrary rdf",
		byteSize => "256",
);
foreach my $key($dist->_standard_keys){
	next if $key =~ /^_/;
	next if $key =~ /^-/;
	print "$key = ".($dist->$key)."\n";
}

print "\n\n\nDATASET\n\n\n";
# ======================= DATASET ====================

my $ds = DCAT::Dataset->new(
		title => "My Dataset",
		description => "an example of a DCAT Dataset",
		issued => "1/23/2014",
		modified => "2/24/2014",
		identifier => "asfjhasdfjh",
		keyword => "silly",
		language => "en",
		contactPoint => 'markw@illuminae.com',
		temporal => "nothing special",
		spatial => "2.3.4 W 3.4.5 E",
		landingPage => "http://wilkinsonlab.info/dataquery",
		accrualPeriodicity => "daily",
);
foreach my $key($ds->_standard_keys){
	next if $key =~ /^_/;
	next if $key =~ /^-/;
	print "$key = ".($ds->$key)."\n";

}

print "\n\nadding Distribution\n\n";
$ds->add_Distribution($dist, $dist);

print "\n\nadding Theme\n\n";
$ds->add_Theme($concept1);

print "\n\nadding Publisher\n\n";
$ds->add_Publisher($publisher1);


print "\n\n\nCATALOGRECORD\n\n\n";
my $catrec = DCAT::CatalogRecord->new(title => "My Catalog",
			description => "an example of a DCAT catalog",
		issued => "1/23/2014",
		modified => "2/24/2014",
);

foreach my $key($catrec->_standard_keys){
	next if $key =~ /^_/;
	next if $key =~ /^-/;
	print "$key = ".($catrec->$key)."\n";
}

print "\n\nadding Dataset\n\n";
$catrec->add_primaryTopic($ds);


print "\n\n\nCATALOG\n\n\n";
my $cat = DCAT::Catalog->new(title => "My Catalog",
			description => "an example of a DCAT catalog",
		issued => "1/23/2014",
		modified => "2/24/2014",
		language => "en",
		license => "CC-by-A",
		rights => "nothing special",
		spatial => "2.3.4 W 3.4.5 E",
		homepage => "http://wilkinsonlab.info",);

foreach my $key($cat->_standard_keys){
	next if $key =~ /^_/;
	next if $key =~ /^-/;
	print "$key = ".($cat->$key)."\n";
}

print "\n\nadding record\n\n";
$cat->add_Record($catrec);


print "\n\nadding dataset\n\n";
$cat->add_Dataset($ds);


print "\n\nadding themeTaxonomy\n\n";
$cat->add_themeTaxonomy($conceptscheme1);

print "\n\nadding publisher\n\n";
$cat->add_Publisher($publisher2);
print "\n\n\n\n\n\n\n\n";


$Descriptor->add_Catalog($cat);
print $Descriptor->serialize('rdfxml');

print "\n\n\nDONE\n\n\n";