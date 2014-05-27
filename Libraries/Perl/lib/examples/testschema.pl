#!perl -w
use lib "../";
use DCAT::Profile;
use DCAT::Profile::Class;
use DCAT::Profile::Property;
use DCAT::Base;
use DCAT::NAMESPACES;


my $MicroarrayDatasetSchema = DCAT::Profile->new(
                label => 'Microarray Deposition for Fairport Demo',
		title => "A very very simple data deposition descriptor", 
		description => "This DCAT Profile defines a schema that will have a DCAT Dataset with title, description, issued, and distribution properties",
                license => "Anyone may use this freely",
                issued => "May 26, 2014",
    		organization => "wilkinsonlab.info",
		identifier => "doi:2222222222",
                URI => "http://biordf.org/DataFairPort/ProfileSchemas/DemoMicroarrayProfileScheme.rdf",
                );

my $ORCIDSchema = DCAT::Profile->new(
                label => 'Metadata around an ORCID record',
		title => "Simple ORCID record descriptor", 
		description => "Just the ORCID ID and its resolvable URL",
                license => "Anyone may use this freely",
                issued => "May 26, 2014",
    		organization => "wilkinsonlab.info",
		identifier => "doi:33333333333",
                URI => "http://biordf.org/DataFairPort/ProfileSchemas/DemoORCIDProfileScheme.rdf",
                );


# ==  ORCID Class

my $ORCIDClass = DCAT::Profile::Class->new(
    #class_type => "http://biordf.org/DataFairPort/ProfileSchemas/DemoORCIDProfileScheme.rdf",
    URI => "http://biordf.org/DataFairPort/ProfileSchemas/DemoORCIDProfileScheme.rdf#ORCID",
    label => "ORCID Records",
   );

    
    my $IDProperty = DCAT::Profile::Property->new(
        property_type => 'http://datafairport.org/examples/ProfileSchemas/Examples/ORCID_Class#orcid_id',
        allow_multiple => "false",
        label => "ORCID ID",
    );
    $IDProperty->set_RequirementStatus('required');
    $IDProperty->add_ValueRange(XSD."string");
    $ORCIDClass->add_Property($IDProperty);
    
    my $ORCID_URL = DCAT::Profile::Property->new(
        property_type => 'http://datafairport.org/examples/ProfileSchemas/Examples/ORCID_Class#orcid_url',
        allow_multiple => "false",
        label => "ORCID URL",

    );
    $ORCID_URL->set_RequirementStatus('required');
    $ORCID_URL->add_ValueRange(XSD."anyURI");
    $ORCIDClass->add_Property($ORCID_URL);


# ===== DCAT Distribution Class
my $DCATDistributionClass = DCAT::Profile::Class->new(
    class_type => DCAT."Distribution",
    URI => "http://biordf.org/DataFairPort/ProfileSchemas/DemoMicroarrayProfileScheme.rdf#CoreMicroarrayDistributionMetadata",
    label => "Core Microarray Data Distribution Metadata",
   );

    my $TitleProperty = DCAT::Profile::Property->new(
        property_type => DCT.'title',
        allow_multiple => "false",
        label => "Title",
    );
    $TitleProperty->set_RequirementStatus('required');
    $TitleProperty->add_ValueRange(XSD."string");
    $DCATDistributionClass->add_Property($TitleProperty);
    
    
    my $DescrProperty = DCAT::Profile::Property->new(
        property_type => DCT.'description',
        allow_multiple => "false",
        label => "Description",
    );
    $DescrProperty->set_RequirementStatus('required');
    $DescrProperty->add_ValueRange(XSD."string");
    $DCATDistributionClass->add_Property($DescrProperty);
    
    
    my $IssuedProperty = DCAT::Profile::Property->new(
        property_type => DCT.'mediaType',
        allow_multiple => "false",
        label => "mediaType (controlled vocabulary)",
    );
    $IssuedProperty->set_RequirementStatus('required');
    $IssuedProperty->add_ValueRange("http://biordf.org/DataFairPort/ConceptSchemes/EDAM_Microarray_Data_Format");
    $DCATDistributionClass->add_Property($IssuedProperty);
#------------------------------

# ==== Extended Authorship Class
my $ExtendedAuthorshipClass = DCAT::Profile::Class->new(
    class_type => "http://biordf.org/DataFairPort/ProfileSchemas/DemoMicroarrayProfileScheme.rdf#ExtendedAuthorship",
    URI => "http://biordf.org/DataFairPort/ProfileSchemas/DemoMicroarrayProfileScheme.rdf#ExtendedAuthorship",
    label => "Extended Authorship Information",
   );

    my $AuthorProperty = DCAT::Profile::Property->new(
        property_type => DC.'Creator',
        allow_multiple => "false",
        label => "Creator (free)",
    );
    $AuthorProperty->set_RequirementStatus('required');
    $AuthorProperty->add_ValueRange(XSD."string");
    $ExtendedAuthorshipClass->add_Property($AuthorProperty);
    
    
    my $ExtendedAuthorProperty = DCAT::Profile::Property->new(
        property_type => "http://datafairport.org/examples/ProfileSchemas/ExtendedAuthorshipMetadata.rdf#author_details",
        allow_multiple => "false",
        label => "Author ORCID",
    );
    $ExtendedAuthorProperty->set_RequirementStatus('required');
    $ExtendedAuthorProperty->add_ValueRange("http://biordf.org/DataFairPort/ProfileSchemas/DemoORCIDProfileScheme.rdf");
    $ExtendedAuthorshipClass->add_Property($ExtendedAuthorProperty);
#----------------------------


#============= Microarray Metadata

my $MicroarrayMetadataClass = DCAT::Profile::Class->new(
    class_type => "http://biordf.org/DataFairPort/ProfileSchemas/DemoMicroarrayProfileScheme.rdf#MicroarrayMetadata",
    URI => "http://biordf.org/DataFairPort/ProfileSchemas/DemoMicroarrayProfileScheme.rdf#MicroarrayMetadata",
    label => "Microarray Generation Protocol Metadata",
   );

    
    my $ProtocolProperty = DCAT::Profile::Property->new(
        property_type => 'http://datafairport.org/examples/ProfileSchemas/MicroarrayMetadata.rdf#generated_by_protocol',
        allow_multiple => "false",
        label => "generated by protocol (free text)",
    );
    $ProtocolProperty->set_RequirementStatus('optional');
    $ProtocolProperty->add_ValueRange(XSD."string");
    $MicroarrayMetadataClass->add_Property($ProtocolProperty);
    
    my $ProtocolType = DCAT::Profile::Property->new(
        property_type => 'http://datafairport.org/examples/ProfileSchemas/MicroarrayMetadata.rdf#protocol_type',,
        allow_multiple => "true",
        label => "generated by prootocol type (limited by EFO ontology)",
    );
    $ProtocolType->set_RequirementStatus('required');
    $ProtocolType->add_ValueRange('http://biordf.org/DataFairPort/ConceptSchemes/EFO_Gene_Expression_Protocol');
    $MicroarrayMetadataClass->add_Property($ProtocolType);
#-----------------------


# add the three metadata classes to the Microarray profile
$MicroarrayDatasetSchema->add_Class($MicroarrayMetadataClass);
$MicroarrayDatasetSchema->add_Class($ExtendedAuthorshipClass);
$MicroarrayDatasetSchema->add_Class($DCATDistributionClass);

my $schemardf =  $MicroarrayDatasetSchema->serialize;
open(OUT, ">DemoMicroarrayProfileScheme.rdf") or die "Can't open the output file to write the profile schema$!\n";
print OUT $schemardf;
close OUT;

#-------------

# add the single metadata class to the ORCID profile
$ORCIDSchema->add_Class($ORCIDClass);

my $schema2rdf =  $ORCIDSchema->serialize;
open(OUT, ">DemoORCIDProfileScheme.rdf") or die "Can't open the output file to write the profile schema$!\n";
print OUT $schema2rdf;
close OUT;
    


