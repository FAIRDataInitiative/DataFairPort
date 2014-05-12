package DCAT;
use RDF::NS '20131205';
use strict;
use lib "./";
use DCAT::Base;
use DCAT::Catalog; 
use DCAT::CatalogRecord; 
use DCAT::Concept;
use DCAT::ConceptScheme;
use DCAT::Dataset; 
use DCAT::Distribution;
use DCAT::Agent;
use RDF::Trine;

use vars qw /$VERSION/;
$VERSION = sprintf "%d.%02d", q$Revision: 0.1 $ =~ /: (\d+)\.(\d+)/;

1;

