#!perl -w
use lib "./";
use DCAT::Profile;
use DCAT::Profile::Class;
use DCAT::Profile::Property;
use DCAT::Base;
use DCAT::NAMESPACES;


my $DatasetSchema = DCAT::Profile->new(
                label => 'Descriptor Profile Schema for FAIRPORT demo',
		title => "A very simple DCAT Dataset plus Distribution example", 
		description => "This Descriptor Profile schema template defines a schema that will have a DCAT Dataset with title, description, issued, and distribution properties",
                license => "Anyone may use this freely",
                issued => "May 16, 2014",
    		organization => "wilkinsonlab.info",
		identifier => "doi:2222222222",
                URI => "http://datafairport.org/examples/ProfileSchemas/FAIRportSimpleProfileExample.rdf",
                );

my $DCATDatasetClass = DCAT::Profile::Class->new(
    class_type => DCAT."dataset",
    URI => "http://datafairport.org/examples/ProfileSchemas/DCATDatasetExample.rdf",
   );

my $TitleProperty = DCAT::Profile::Property->new(
    property_type => DCT.'title',
    allow_multiple => "false",
);
$TitleProperty->set_RequirementStatus('required');
$TitleProperty->add_ValueRange(XSD."string");
$DCATDatasetClass->add_Property($TitleProperty);


my $DescrProperty = DCAT::Profile::Property->new(
    property_type => DCT.'description',
    allow_multiple => "false",

);
$DescrProperty->set_RequirementStatus('required');
$DescrProperty->add_ValueRange(XSD."string");
$DCATDatasetClass->add_Property($DescrProperty);


my $IssuedProperty = DCAT::Profile::Property->new(
    property_type => DCT.'issued',
    allow_multiple => "false",
);
$IssuedProperty->set_RequirementStatus('optional');
$IssuedProperty->add_ValueRange(XSD."date");
$DCATDatasetClass->add_Property($IssuedProperty);


my $DistributionProperty = DCAT::Profile::Property->new(
    property_type => DCAT.'distribution',
    allow_multiple => "true",
);
$DistributionProperty->set_RequirementStatus('optional');
$DistributionProperty->add_ValueRange(DCAT.'Distribution');
$DCATDatasetClass->add_Property($DistributionProperty);

$DatasetSchema->add_Class($DCATDatasetClass);

my $schema =  $DatasetSchema->serialize;
open(OUT, ">ProfileSchema.rdf") or die "Can't open the output file to write the profile schema$!\n";
print OUT $schema;
close OUT;



