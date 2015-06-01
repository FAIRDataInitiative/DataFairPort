package FAIR::NAMESPACES;
$FAIR::NAMESPACES::VERSION = '0.18';

# ABSTRACT: a utility object that contains the namespaces commonly used by FAIR profiles.  This shoudl probably be replaced by RDF::NS one day, because it is horribly hacky!

use strict;
use vars qw(@ISA @EXPORT);
use Exporter;

BEGIN {
	@ISA = qw( Exporter );

	# Constants for FAIR Namespaces - I know that this is an AWFUL way to do this!  SORRY TO THE FUTURE!
	@EXPORT = qw(
        DCAT
        DC
        DCTYPE
        FOAF
        RDF
        RDFS
        SKOS
        VCARD
        XSD
	FAIR
	);
}

#---- Constant definitions
# Node types
sub DCAT ()  {return 'http://www.w3.org/ns/dcat#' }    
sub DC ()   {return 'http://purl.org/dc/terms/' }
sub DCTYPE (){return 'http://purl.org/dc/dcmitype/' }
sub FOAF ()  {return 'http://xmlns.com/foaf/0.1/' }
sub RDF ()   {return 'http://www.w3.org/1999/02/22-rdf-syntax-ns#' }
sub RDFS ()  {return 'http://www.w3.org/2000/01/rdf-schema#' }
sub SKOS ()  {return 'http://www.w3.org/2004/02/skos/core#' }
sub VCARD () {return 'http://www.w3.org/2006/vcard/ns#' }
sub XSD ()   {return 'http://www.w3.org/2001/XMLSchema#' }

#sub FAIR() {return 'http://fairdata.org/ontology/FAIR-Data#'}
sub FAIR() {return 'https://github.com/FAIRDataInitiative/DataFairPort/blob/master/Schema/FAIR-schema.owl#'}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

FAIR::NAMESPACES - a utility object that contains the namespaces commonly used by FAIR profiles.  This shoudl probably be replaced by RDF::NS one day, because it is horribly hacky!

=head1 VERSION

version 0.18

=head1 AUTHOR

Mark Wilkinson (markw [at] illuiminae [dot] com)

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Mark Wilkinson.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
