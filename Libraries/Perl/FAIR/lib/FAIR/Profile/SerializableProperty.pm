package Fair::Profile::SerializableProperty;
use Moose::Role;

Moose::Util::meta_attribute_alias('Serializable');

has serialize => (
    is => 'ro',
    isa => "Int",
    default => '1',
    predicate => 'serializable'
);

1;

