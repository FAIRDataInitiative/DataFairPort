package FAIR::Profile::SerializableProperty;
$FAIR::Profile::SerializableProperty::VERSION = '0.216';

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

__END__

=pod

=encoding UTF-8

=head1 NAME

FAIR::Profile::SerializableProperty - a moose role that indicates that a certain property is intended to become part of the RDF serialization of the FAIR Profile.  All other properties are "utility" properties of the object

=head1 VERSION

version 0.216

=head1 AUTHOR

Mark Denis Wilkinson (markw [at] illuminae [dot] com)

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2015 by Mark Denis Wilkinson.

This is free software, licensed under:

  The Apache License, Version 2.0, January 2004

=cut
