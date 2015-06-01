package FAIR::Profile::Class;
$FAIR::Profile::Class::VERSION = '0.18';


# ABSTRACT: A FAIR Class is a meta representation of a data resources Class

use strict;
use Carp;
use Moose;
use FAIR::NAMESPACES;
use vars qw($AUTOLOAD @ISA);
use FAIR::Profile::SerializableProperty;

use base 'FAIR::Base';
no if $] >= 5.017011, warnings => 'experimental::smartmatch';  # perl 5.18 warns about smartmatch... 

#use vars qw /$VERSION/;
#$VERSION = sprintf "%d.%02d", q$Revision: 1.5 $ =~ /: (\d+)\.(\d+)/;
















has URI => (
	is => 'rw',
	isa => "Str",
	builder => '_generate_URI',
	);

has type => (
	is => 'rw',
	isa => 'ArrayRef[Str]',
	traits => [qw/Serializable/],  # it is, but it is handled differently than most serializable traits
	default => sub {[FAIR.'FAIRClass']},
	);

has label => (
	is => 'rw',
	isa => "Str",
	default => 'FAIR Profile Class',
	traits => [qw/Serializable/],
	);

has hasProperty => (
	is => 'rw',
#	isa => 'ArrayRef[Fair::Profile::Property]',
	isa => 'ArrayRef',
	traits => [qw/Serializable/],
	writer => '_add_Property',
	default => sub {[]},
	);


has onClassType => (  # represents the OWL Class URI 
	is => 'rw',
	isa => "Str",  # TODO - this should be constrained to be a URI
	traits => [qw/Serializable/],
	);

#has template => (  # represents the OWL Class URI 
#	is => 'rw',
#	isa => "Str",  # TODO - this should be constrained to be a URI
#	);

sub _generate_URI {
	my ($self, $newval) = @_;
	return $newval if $newval;
	
	my $ug = UUID::Generator::PurePerl->new();  
	my $ug1 = $ug->generate_v4()->as_string;
	return "http://datafairport.org/sampledata/profileschemaclass/$ug1";
}

sub add_Property {   
	my ($self, $p) = @_;
	# print STDERR "ADD PROPERTY TYPE:", $p->meta->name, "\n";
	die "not a FAIR Profile Schema Property " .($p->type)."\n" unless (FAIR.'FAIRProperty' ~~ $p->type);
	my $ps = $self->hasProperty;
	push @$ps, $p;
	$self->_add_Property($ps);
	return 1;
}


#sub get_Template {   # redundant...
#	my ($self) = @_;
#	return $self->template();
#}


1;

__END__

=pod

=encoding UTF-8

=head1 NAME

FAIR::Profile::Class - A FAIR Class is a meta representation of a data resources Class

=head1 VERSION

version 0.18

=head1 SYNOPSIS

 use FAIR::Profile::Class;
 use FAIR::Profile::Property;
 
 my $ProfileClass = FAIR::Profile::Class->new(
    class_type => DCAT."dataset",  # DCAT is an exported constant
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

DCAT Class describes a group of metadata elements that should be
associated with a given information entity.  They ARE NOT containers for this metadata,
they only describe what that metadata should look like (meta-meta-data :-) )

Effectively, this module groups-together a set of properties and their value-constraints.

=head1 NAME

FAIR::Profile::Class - a module representing a FAIR Profile Class

=head1 AUTHORS

Mark Wilkinson (markw at illuminae dot com)

=head1 METHODS

=head2 new

 Title : new
 Usage : my $Class = FAIR::Profile::Class->new();
 Function: Builds a new FAIR::Profile::Class
 Returns : FAIR::Profile::Class
 Args : label => $string
	class_type => $URI (possibly an OWL class URI)
	URI => $URI (optional - a unique URI will be auto-generated)

=head2 label

 Title : label
 Usage : $label = $Class->label($label);
 Function: get/set the RDF label for this object when serialized
 Returns : string
 Args : string

=head2 onClassType

 Title : onClassType
 Usage : $class_type = $Class->onClassType($class_type);
 Function: get/set the class type (should be a URI, e.g. of an ontology class)
 Returns : string
 Args : string

=head2 URI

 Title : URI
 Usage : $uri = $Class->URI($uri);
 Function: get/set the URI for this Class - the URI in the RDF
 Returns : string  (should be a URI)
 Args : string   (should be a URI)
 notes:  if this is not supplied, a unique URI will be automatically generated

=head2 add_Property

 Title : add_Property
 Usage : $Class->add_Property($Property);
 Function: add a new FAIR::Profile::Property to the Profile Class
 Returns : boolean (1 for success)
 Args : FAIR::Profile::Property

=head2 hasProperty

 Title : hasProperty
 Usage : $Class->hasProperty();
 Function: Retrieve all properties of the Class
 Returns : listref of FAIR::Profile::Property objects
 Args : none

=head1 AUTHOR

Mark Wilkinson (markw [at] illuiminae [dot] com)

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Mark Wilkinson.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
