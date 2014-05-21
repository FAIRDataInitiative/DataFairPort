#!/usr/bin/perl

use strict;
use warnings;

use lib 't';
use lib 'lib';

use Test::Simple tests => 1;
use Log::Log4perl qw(:easy);
use DCAT::Base;


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
ok( 
    ($DatasetSchema),
    'created Profile'
);

