#!/usr/bin/perl
use strict;
use lib "../";
use lib "/home/biordf/perl5/lib/perl5/";
use warnings;
use DCAT::Profile::Parser;
use LWP::Simple;
use RDF::Query;
use Ontology::Views::SKOS::NAMESPACES;
use Ontology::Views::SKOS::conceptSchemeBuilder;
use strict;
use warnings;
use Template;

my $config = {
    INCLUDE_PATH => ['./Templates/', './'],  
    POST_CHOMP   => 1,               # cleanup whitespace 
    RELATIVE  => 1,
};


my $template = Template->new($config) || die $Template::ERROR, "\n";


print "Content-type: text/html\n\n";

$template->process("header", {title => "FAIRport Metadata Capture Demo"}) || die $template->error();


my $parser = DCAT::Profile::Parser->new(filename => "http://biordf.org/DataFairPort/ProfileSchemas/DemoMicroarrayProfileScheme.rdf"); 
my $Profile = $parser->parse;

# all we are going to do is iterate over each class in the Profile
# and render the properties of those classes according
# to their value constraints in the DCAT Profile
my $classes = $Profile->has_class;

my $margin = 20; # properties that have classes as their value-range will be indented inside of the parent's DIV element

foreach my $class(@$classes){
    &parseClass($class, $margin);    
}

$template->process("footer") || die $template->error();
exit 1;




sub parseClass {
    my ($class, $margin) = @_;
    my $background = join "" => "#", map { sprintf "%02x", (rand 55)+200 } 1 .. 3;  # random background color for every DIV
    my $title = $class->label;

    $template->process("newsection.tt", {title => $title, margin => $margin, background => $background}) || die $template->error(); # the main title for that section
    
    my @embeddedclasses; # stack-up external classes for display aesthetics - they will be rendered last

    foreach my $property(@{$class->has_property}){  # iterate over every property declared for that DCAT class
        my $values = $property->allowed_values; # what are the value restrictions on that property?
        foreach my $valueURL(@$values){  # what comes back are the URLs to either...
	    
            if (isScalar($valueURL)) {  # the URL of an XSD Datatype
		$template->process("scalar.tt", {property => $property, xsd_type => isScalar($valueURL)}) || die $template->error();  # render it

            } elsif (isConceptScheme($valueURL)) {  # the URL to a SKOS Concept Scheme
		my $b = Ontology::Views::SKOS::conceptSchemeBuilder->new();  # retrieve it
		my $scheme = $b->parseFile($valueURL);
		$template->process("dropdown.tt", {property => $property, concepts => $scheme->Concepts}) || die $template->error();  # render it
		
	    } elsif (isDCATModel($valueURL)) { # the URL to another DCAT Profile
		push @embeddedclasses, [$property, $valueURL];  # stack them up and deal with them later (for layout purposes only)
		
	    } else {
                print "<i>$valueURL</i> is not an XML Schema datatype, a SKOS Concept Scheme or a DCAT Profile<br/>\n";
            }
        }
    }
    # now we have to deal with the embedded DCAT Profiles
    foreach my $pair(@embeddedclasses){
        my ($property, $classurl) = @{$pair};
        my $parser = DCAT::Profile::Parser->new(filename => $classurl);  # parse the remote profile
        my $Profile = $parser->parse;
        
        my $classes = $Profile->has_class;  # get it's DCAT Profile Classes
	$template->process("externalclass.tt", {property => $property}) || die $template->error(); # print the property name that connects these classes to the parent
        $margin = $margin + 60;  # indent
        foreach my $class(@$classes){  # start rendering the classes in this model, exactly as we rendered the classes in the parent model
            &parseClass($class, $margin);    
        }                    
    }
    $template->process("divend",) || die $template->error();

}

sub isScalar {
    my ($value) =  @_;
    if ($value =~ m'http://www.w3.org/2001/XMLSchema#(.\S+)'){
        return $1;	
    } else {
	return 0
    }
}

sub isDCATModel {
    my ($URL) = @_;
    my $store = RDF::Trine::Store::Memory->new();
    my $model = RDF::Trine::Model->new($store);
    RDF::Trine::Parser->parse_url_into_model($URL, $model );
    my $query = RDF::Query->new( "SELECT ?o WHERE {<$URL> a ?o}" );  # what is at the other end of that URL?
    my $iterator = $query->execute( $model );
    my $profile;
    while (my $row = $iterator->next) {
	my $type = $row->{ 'o' }->value;
	next if ($type =~ m'/owl#Ontology');
	my $dctsschematype = DCTS."DPSProfile";
	if ($type =~ m"$dctsschematype") {
	    return $URL;
	}
    }
}

sub isConceptScheme {
    my ($URL) = @_;
    my $store = RDF::Trine::Store::Memory->new();
    my $model = RDF::Trine::Model->new($store);
    RDF::Trine::Parser->parse_url_into_model($URL, $model );
    my $query = RDF::Query->new( "SELECT ?o WHERE {<$URL> a ?o}" );  # what is at the other end of that URL?
    my $iterator = $query->execute( $model );
    my $profile;
    while (my $row = $iterator->next) {
	my $type = $row->{ 'o' }->value;
	next if ($type =~ m'/owl#Ontology');
	return $URL if ($type =~ m'http://www.w3.org/2004/02/skos/core#ConceptScheme');
    }
}