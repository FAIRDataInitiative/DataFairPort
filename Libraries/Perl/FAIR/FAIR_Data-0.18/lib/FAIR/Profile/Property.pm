package FAIR::Profile::Property;
$FAIR::Profile::Property::VERSION = '0.18';


# ABSTRACT: to represent a Property in a FAIR Profile

use strict;
use Carp;
use Moose;
#use FAIR::Base; 
use FAIR::NAMESPACES;
use UUID::Generator::PurePerl;  # slower, but it will work on all setups!
use base 'FAIR::Base';
use FAIR::Profile::SerializableProperty;

















has label => (
	is => 'rw',
	isa => "Str",   # this should be forced to be a URI
	traits => ['Serializable'],
	required => 1,
	);	

has onPropertyType => (
	is => 'rw',
	isa => "Str",   # this should be forced to be a URI
	traits => ['Serializable'],
	required => 1,
	);

has allowedValues => (
	is => 'rw',
	isa => 'ArrayRef',  # one day make this a forced URI!
	traits =>  ['Serializable'],
	writer => '_add_AllowedValue',
);

has minCount => (
	is => 'rw',
	isa => "Int",
	traits => ['Serializable'],
	);

has maxCount => (
	is => 'rw',
	isa => "Int",
	traits => ['Serializable'],
	);

has type => (
	is => 'rw',
	isa => 'ArrayRef[Str]',
	traits => ['Serializable'],
	required => 1,
	default => sub {[FAIR.'FAIRProperty']},
	);

has URI => (
	is => 'rw',
	isa => "Str",
	traits => ['Serializable'],
	builder => '_generate_URI',
	required => 1,

	);


sub _generate_URI {
	my ($self, $newval) = @_;
	return $newval if $newval;
	
	my $ug = UUID::Generator::PurePerl->new();  
	my $ug1 = $ug->generate_v4()->as_string;
	return "http://datafairport.org/sampledata/profileschemaproperty/$ug1";
}


sub add_AllowedValue {   
	my ($self, $p) = @_;
	die "not a valid profile property-value range $p" unless ($p =~ /^https?:/);
	my $ps = $self->allowedValues;
	push @$ps, $p;
	$self->_add_AllowedValue($ps);
	return 1;
}



1;

__END__

=pod

=encoding UTF-8

=head1 NAME

FAIR::Profile::Property - to represent a Property in a FAIR Profile

=head1 VERSION

version 0.18

=head1 SYNOPSIS

 use FAIR::Profile::Class;
 use FAIR::Profile::Property;
 
 my $ProfileClass = FAIR::Profile::Class->new(
    class_type => FAIR."dataset",  # DCAT is an exported constant
    URI => "http://example.org//ProfileClasses/ThisClass.rdf",
    label => "core metadata for the thesis submission"
   );

 my $TitleProperty = FAIR::Profile::Property->new(
    property_type => DCT.'title', # DCT is an exported constant
    allow_multiple => "false",
 );
 $TitleProperty->set_RequirementStatus('required');
 $TitleProperty->add_ValueRange(XSD."string");
 $ProfileClass->add_Property($TitleProperty);

=head1 DESCRIPTION

FAIR Property describes a single metadata element, and its possible values.
It IS NOT a containers for this metadata,
it only describes what that metadata should look like (meta-meta-data :-) )

Effectively, in RDF terms, this is the predicate associated with the metadata, and it's ranges

=head1 NAME

FAIR::Profile::Property - a module representing a DCAT Profile Property

=head1 AUTHORS

Mark Wilkinson (markw at illuminae dot com)

=head1 METHODS

=head2 new

 Title : new
 Usage : my $Property = FAIR::Profile::Property->new();
 Function: Builds a new FAIR::Profile::Property
 Returns : FAIR::Profile::Property
 Args : label => $string
	property_type => $URI (possibly an OWL predicate URI)
	allow_multiple => $boolean ('true'/'false')
	URI => $URI (optional - a unique URI will be auto-generated)

=head2 label

 Title : label
 Usage : $label = $Property->label($label);
 Function: get/set the RDF label for this object when serialized
 Returns : string
 Args : string

=head2 property_type

 Title : property_type
 Usage : $property_type = $Property->property_type($property_type);
 Function: get/set the property type (should be a URI, e.g. of an ontology predicate)
 Returns : string (URI)
 Args : string (URI)

=head2 URI

 Title : URI
 Usage : $uri = $Property->URI($uri);
 Function: get/set the URI for this Property - the URI in the RDF
 Returns : string  (should be a URI)
 Args : string   (should be a URI)
 notes:  if this is not supplied, a unique URI will be automatically generated

=head2 set_MinCount

 Title : set_MinCount
 Usage : $req = $Property->set_MinCount($int);
 Function: minimum number of occurrences of this property
 Returns : int
 Args : int

=head2 set_MinCount

 Title : set_MaxCount
 Usage : $req = $Property->set_MaxCount($int);
 Function: maximum number of occurrences of this property
 Returns : int
 Args : int

=head2 add_ValueRange

 Title : add_ValueRange
 Usage : $Property->add_ValueRange($URI);
 Function: add a range restriction for this predicate
 Returns : none
 Args : string - the string should be a URI...
 Notes:  This is the "critical bit" of the FAIR Profile.  The ranges
         can be defined by one of:  the URI of an XSD datatype, the URI
	 to a SKOS view of a set of ontology terms (according to Jupp et al, 2013)
	 or the URI to another FAIR::Profile (in this way, profiles can be hierarchical)

=head2 allowedValues

 Title : allowedValues
 Usage : $req = $Property->allowedValues();
 Function: retrieve the value ranges for the property
 Returns : listref of URIs (see add_ValueRange for details)
 Args : none

=head1 AUTHOR

Mark Wilkinson (markw [at] illuiminae [dot] com)

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Mark Wilkinson.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
