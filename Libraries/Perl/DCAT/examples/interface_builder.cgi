#!/usr/bin/perl
use strict;
use lib "../";
use warnings;
use DCAT::Profile::Parser;
use LWP::Simple;
use RDF::Query;
use Ontology::Views::SKOS::NAMESPACES;
use Ontology::Views::SKOS::conceptSchemeBuilder;
use strict;
use warnings;
use Template;

# some useful options (see below for full list)
my $config = {
    INCLUDE_PATH => ['./Templates/', './'],  # or list ref
    POST_CHOMP   => 1,               # cleanup whitespace 
    RELATIVE  => 1,
};


my $template = Template->new($config) || die $Template::ERROR, "\n";


print "Content-type: text/html\n\n";

$template->process("header", {title => "FAIRport Metadata Capture Demo"}) || die $template->error();


my $parser = DCAT::Profile::Parser->new(filename => "http://biordf.org/DataFairPort/ProfileSchemas/DemoMicroarrayProfileScheme.rdf"); 
my $Profile = $parser->parse;

my $classes = $Profile->has_class;
my $margin = 20;
foreach my $class(@$classes){
    &parseClass($class, $margin);    
}

$template->process("footer") || die $template->error();


sub parseClass {
    my ($class, $margin) = @_;
    my $background = join "" => "#", map { sprintf "%02x", (rand 55)+200 } 1 .. 3;
    my $title = $class->label;

    $template->process("newsection.tt", {title => $title, margin => $margin, background => $background}) || die $template->error();
    
    my @embeddedclasses; # stack-up external classes for display aesthetics

    foreach my $property(@{$class->has_property}){
        my $values = $property->allowed_values;
        foreach my $valueURL(@$values){
	    
            if (isScalar($valueURL)) {
		$template->process("scalar.tt", {property => $property, xsd_type => isScalar($valueURL)}) || die $template->error();

            } elsif (isConceptScheme($valueURL)) {
		my $b = Ontology::Views::SKOS::conceptSchemeBuilder->new();
		my $scheme = $b->parseFile($valueURL);
		$template->process("dropdown.tt", {property => $property, concepts => $scheme->Concepts}) || die $template->error();
		
	    } elsif (isDCATModel($valueURL)) {
		push @embeddedclasses, [$property, $valueURL];  # stack them up and deal with them later for layout purposes
		
	    } else {
                print "<i>$valueURL</i> is not an XML Schema datatype, a SKOS Concept Scheme or a DCAT Profile<br/>\n";
            }
        }
    }
    # now we have to deal with the referenced classes
    foreach my $pair(@embeddedclasses){
        my ($property, $classurl) = @{$pair};
        my $parser = DCAT::Profile::Parser->new(filename => $classurl);
        my $Profile = $parser->parse;
        
        my $classes = $Profile->has_class;
	$template->process("externalclass.tt", {property => $property}) || die $template->error();
        $margin = $margin + 60;  # indent
        foreach my $class(@$classes){
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