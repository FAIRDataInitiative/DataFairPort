package Fair::Profile::SerializableProperty;


# ABSTRACT: a moose role that indicates that a certain property is intended to become part of the RDF serialization of the FAIR Profile.  All other properties are "utility" properties of the object

use Moose::Role;

Moose::Util::meta_attribute_alias('Serializable');

has serialize => (
    is => 'ro',
    isa => "Int",
    default => '1',
    predicate => 'serializable'
);

1;

