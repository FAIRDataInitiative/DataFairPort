#!perl
use strict;
use lib "../";
use warnings;
use DCAT::Profile::Parser;

my $parser = DCAT::Profile::Parser->new(filename => "http://biordf.org/DataFairPort/ProfileSchemas/DemoMicroarrayProfileScheme.rdf"); 
my $Profile = $parser->parse;

my $classes = $Profile->has_class;
foreach my $class(@$classes){
    print $class;
}
