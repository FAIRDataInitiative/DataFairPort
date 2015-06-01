package Fair::Profile::SerializableProperty;
$Fair::Profile::SerializableProperty::VERSION = '0.18';

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

Fair::Profile::SerializableProperty - a moose role that indicates that a certain property is intended to become part of the RDF serialization of the FAIR Profile.  All other properties are "utility" properties of the object

=head1 VERSION

version 0.18

=head1 AUTHOR

Mark Wilkinson (markw [at] illuiminae [dot] com)

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Mark Wilkinson.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
