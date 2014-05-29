#!/usr/bin/perl

use strict;
use warnings;

use lib 't';
use lib 'lib';

use Test::Simple tests => 1;
use Log::Log4perl qw(:easy);
use Ontology::Views::SKOS::ConceptSchemeBuilder;


my $edam = Ontology::Views::SKOS::ConceptSchemeBuilder->new();
ok( 
    ($edam),
    'created Schema Builder'
);

