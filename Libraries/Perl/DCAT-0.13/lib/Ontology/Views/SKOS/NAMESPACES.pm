package Ontology::Views::SKOS::NAMESPACES;
{
  $Ontology::Views::SKOS::NAMESPACES::VERSION = '0.13';
}
use strict;
use vars qw( $VERSION @ISA @EXPORT @NodeNames);
require Exporter;

#$VERSION = sprintf "%d.%02d", q$Revision: 0.1 $ =~ /: (\d+)\.(\d+)/;

BEGIN {
	@ISA = qw( Exporter );

	# Constants for DCAT Namespaces
	@EXPORT = qw(
        DCAT
        DCT
        DCTYPE
        FOAF
        RDF
        RDFS
        SKOS
        VCARD
        XSD
	DCTS
	SKOS
	OWL
	);
}

#---- Constant definitions
# Node types
sub DCAT ()  {return 'http://www.w3.org/ns/dcat#' }    
sub DCT ()   {return 'http://purl.org/dc/terms/' }
sub DCTYPE (){return 'http://purl.org/dc/dcmitype/' }
sub FOAF ()  {return 'http://xmlns.com/foaf/0.1/' }
sub RDF ()   {return 'http://www.w3.org/1999/02/22-rdf-syntax-ns#' }
sub RDFS ()  {return 'http://www.w3.org/2000/01/rdf-schema#' }
sub SKOS ()  {return 'http://www.w3.org/2004/02/skos/core#' }
sub VCARD () {return 'http://www.w3.org/2006/vcard/ns#' }
sub XSD ()   {return 'http://www.w3.org/2001/XMLSchema#' }
sub OWL () {return "http://www.w3.org/2002/07/owl#" }

# for our DCAT Profile Schema
sub DCTS() {return 'https://raw.githubusercontent.com/markwilkinson/DataFairPort/master/Schema/DCATProfile.rdfs#'}

1;
