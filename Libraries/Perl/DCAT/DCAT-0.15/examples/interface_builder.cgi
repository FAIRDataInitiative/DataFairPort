#!/usr/bin/perl
use strict;
use lib "../";
use warnings;
use DCAT::Profile::Parser;
use LWP::Simple;
use RDF::Query;
use Ontology::Views::SKOS::NAMESPACES;
use Ontology::Views::SKOS::conceptSchemeBuilder;


print "Content-type: text/html\n\n";


my $parser = DCAT::Profile::Parser->new(filename => "http://biordf.org/DataFairPort/ProfileSchemas/DemoMicroarrayProfileScheme.rdf"); 
my $Profile = $parser->parse;

my $classes = $Profile->has_class;
my $left = 20;
foreach my $class(@$classes){
    &parseClass($class, $left);    
}

&printCode();


sub parseClass {
    my ($class, $left) = @_;
    my $background = join "" => "#", map { sprintf "%02x", (rand 55)+200 } 1 .. 3;
    html ("<div style='margin-left:$left"."px; background-color:$background'>");
    my $title = $class->label;
    html("<h1>$title</h1> <span style='font-size:.5em;'>(* = required field)</span><br/><br/>");

    my @embeddedclasses; # stack-up external classes for display prettyness

    foreach my $property(@{$class->has_property}){
        my $values = $property->allowed_values;
        foreach my $value(@$values){
            # print STDERR "about to retrieve $value\n";
            if ($value =~ m'http://www.w3.org/2001/XMLSchema#(.\S+)') {
                if (${$property->requirement_status}[0] eq 'required') {
                    html("* ");
                }
                html("<b>".$property->label.":</b> ");
                html("<input type='text' name='".$property->property_type." value='$1'/><br/>");
            } else {
                my $store = RDF::Trine::Store::Memory->new();
                my $model = RDF::Trine::Model->new($store);
		RDF::Trine::Parser->parse_url_into_model($value, $model );
                my $query = RDF::Query->new( "SELECT ?o WHERE {<$value> a ?o}" );  # what is at the other end of that URL?
        	my $iterator = $query->execute( $model );
        	my $profile;
                while (my $row = $iterator->next) {
                    my $URI = $row->{ 'o' }->value;
                    next if ($URI =~ m'/owl#Ontology');
                    my $dctsschematype = DCTS."DPSProfile";
                    if ($URI =~ m"$dctsschematype") {
                        push @embeddedclasses, [$property, $value];  # stack them up and deal with them later for layout purposes
                    } elsif ($URI =~ m'http://www.w3.org/2004/02/skos/core#ConceptScheme') {
                        my $b2 = Ontology::Views::SKOS::conceptSchemeBuilder->new();
                        my $scheme2 = $b2->parseFile($value);
                        if (${$property->requirement_status}[0] eq 'required') {
                            html("* ");
                        }
                        html("<b>".$property->label.":</b> ");
                        html("<select name='".$property->property_type."'>");
                        foreach my $concept(@{$scheme2->Concepts}){
                            html("<option value='".$concept->ontologyTermURI."'>".$concept->label."</option>");
                        }
                        html("</select><br/><br/>");
                    } else {
                        html ("<i>$value</i> is not a SKOS Concept Scheme nor a DCAT Profile<br/>\n");
                    }
                }
            }
            
        }
    }
    # now we have to deal with the referenced classes
    foreach my $pair(@embeddedclasses){
        my ($property, $classurl) = @{$pair};
        my $parser = DCAT::Profile::Parser->new(filename => $classurl);
        my $Profile = $parser->parse;
    
        my $classes = $Profile->has_class;
        if (${$property->requirement_status}[0] eq 'required') {
            html("* ");
        }
        html("<b>".$property->label.":</b> ");
        my $left = $left + 60;  # indent
        foreach my $class(@$classes){
            &parseClass($class, $left);    
        }                    
    }


    html("</div>");
    
}

sub html {
    print "@_\n";
}

sub printCode {

print <<'EOF';

THE CODE THAT GENERATED THIS PAGE IS (ugly!):



use strict;
use lib "../";
use warnings;
use DCAT::Profile::Parser;
use LWP::Simple;
use RDF::Query;
use Ontology::Views::SKOS::NAMESPACES;
use Ontology::Views::SKOS::conceptSchemeBuilder;


print "Content-type: text/html\n\n";


my $parser = DCAT::Profile::Parser->new(filename => "http://biordf.org/DataFairPort/ProfileSchemas/DemoMicroarrayProfileScheme.rdf"); 
my $Profile = $parser->parse;

my $classes = $Profile->has_class;
my $left = 20;
foreach my $class(@$classes){
    &parseClass($class, $left);    
}

&printCode();


sub parseClass {
    my ($class, $left) = @_;
    my $background = join "" => "#", map { sprintf "%02x", (rand 55)+200 } 1 .. 3;
    html ("<div style='margin-left:$left"."px; background-color:$background'>");
    my $title = $class->label;
    html("<h1>$title</h1> <span style='font-size:.5em;'>(* = required field)</span><br/><br/>");

    my @embeddedclasses; # stack-up external classes for display prettyness

    foreach my $property(@{$class->has_property}){
        my $values = $property->allowed_values;
        foreach my $value(@$values){
            # print STDERR "about to retrieve $value\n";
            if ($value =~ m'http://www.w3.org/2001/XMLSchema#(.\S+)') {
                if (${$property->requirement_status}[0] eq 'required') {
                    html("* ");
                }
                html("<b>".$property->label.":</b> ");
                html("<input type='text' name='".$property->property_type." value='$1'/><br/>");
            } else {
                my $store = RDF::Trine::Store::Memory->new();
                my $model = RDF::Trine::Model->new($store);
		RDF::Trine::Parser->parse_url_into_model($value, $model );
                my $query = RDF::Query->new( "SELECT ?o WHERE {<$value> a ?o}" );  # what is at the other end of that URL?
        	my $iterator = $query->execute( $model );
        	my $profile;
                while (my $row = $iterator->next) {
                    my $URI = $row->{ 'o' }->value;
                    next if ($URI =~ m'/owl#Ontology');
                    my $dctsschematype = DCTS."DPSProfile";
                    if ($URI =~ m"$dctsschematype") {
                        push @embeddedclasses, [$property, $value];  # stack them up and deal with them later for layout purposes
                    } elsif ($URI =~ m'http://www.w3.org/2004/02/skos/core#ConceptScheme') {
                        my $b2 = Ontology::Views::SKOS::conceptSchemeBuilder->new();
                        my $scheme2 = $b2->parseFile($value);
                        if (${$property->requirement_status}[0] eq 'required') {
                            html("* ");
                        }
                        html("<b>".$property->label.":</b> ");
                        html("<select name='".$property->property_type."'>");
                        foreach my $concept(@{$scheme2->Concepts}){
                            html("<option value='".$concept->ontologyTermURI."'>".$concept->label."</option>");
                        }
                        html("</select><br/><br/>");
                    } else {
                        html ("<i>$value</i> is not a SKOS Concept Scheme nor a DCAT Profile<br/>\n");
                    }
                }
            }
            
        }
    }
    # now we have to deal with the referenced classes
    foreach my $pair(@embeddedclasses){
        my ($property, $classurl) = @{$pair};
        my $parser = DCAT::Profile::Parser->new(filename => $classurl);
        my $Profile = $parser->parse;
    
        my $classes = $Profile->has_class;
        if (${$property->requirement_status}[0] eq 'required') {
            html("* ");
        }
        html("<b>".$property->label.":</b> ");
        my $left = $left + 60;  # indent
        foreach my $class(@$classes){
            &parseClass($class, $left);    
        }                    
    }


    html("</div>");
    
}

sub html {
    print "@_\n";
}


EOF
}