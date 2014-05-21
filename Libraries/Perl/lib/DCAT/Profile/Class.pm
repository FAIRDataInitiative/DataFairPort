package DCAT::Profile::Class;
use strict;
use Carp;
use lib "../../";
use DCAT::Base;
use DCAT::NAMESPACES;
use vars qw($AUTOLOAD @ISA);

use base 'DCAT::Base';

#use vars qw /$VERSION/;
#$VERSION = sprintf "%d.%02d", q$Revision: 1.5 $ =~ /: (\d+)\.(\d+)/;


=head1 NAME

DCAT::Profile::Class - a module representing a DCAT Profile Class

=head1 SYNOPSIS

 use DCAT::Profile::Class;
 use DCAT::Profile::Property;
 
 my $ProfileClass = DCAT::Profile::Class->new(
    class_type => DCAT."dataset",  # DCAT is an exported constant
    URI => "http://example.org//ProfileClasses/ThisClass.rdf",
    label => "core metadata for the thesis submission"
   );

 my $TitleProperty = DCAT::Profile::Property->new(
    property_type => DCT.'title', # DCT is an exported constant
    allow_multiple => "false",
 );
 $TitleProperty->set_RequirementStatus('required');
 $TitleProperty->add_ValueRange(XSD."string");
 $ProfileClass->add_Property($TitleProperty);

 
=cut

=head1 DESCRIPTION

DCAT Class describes a group of metadata elements that should be
associated with a given information entity.  They ARE NOT containers for this metadata,
they only describe what that metadata should look like (meta-meta-data :-) )

Effectively, this module groups-together a set of properties and their value-constraints.

=cut

=head1 AUTHORS

Mark Wilkinson (markw at illuminae dot com)

=cut

=head1 METHODS


=head2 new

 Title : new
 Usage : my $Class = DCAT::Profile::Class->new();
 Function: Builds a new DCAT::Profile::Class
 Returns : DCAT::Profile::Class
 Args : label => $string
	class_type => $URI (possibly an OWL class URI)
	URI => $URI (optional - a unique URI will be auto-generated)


=cut

=head2 label

 Title : label
 Usage : $label = $Class->label($label);
 Function: get/set the RDF label for this object when serialized
 Returns : string
 Args : string

=cut

=head2 class_type

 Title : class_type
 Usage : $class_type = $Class->class_type($class_type);
 Function: get/set the class type (should be a URI, e.g. of an ontology class)
 Returns : string
 Args : string

=cut


=head2 URI

 Title : URI
 Usage : $uri = $Class->URI($uri);
 Function: get/set the URI for this Class - the URI in the RDF
 Returns : string  (should be a URI)
 Args : string   (should be a URI)
 notes:  if this is not supplied, a unique URI will be automatically generated

=cut


=head2 add_Property

 Title : add_Property
 Usage : $Class->add_Property($Property);
 Function: add a new DCAT::Profile::Property to the Profile Class
 Returns : boolean (1 for success)
 Args : DCAT::Profile::Property

=cut


=head2 has_property

 Title : has_property
 Usage : $Class->has_property();
 Function: Retrieve all properties of the Class
 Returns : listref of DCAT::Profile::Property objects
 Args : none
 Note:  the capitalization of the method name
        matches the capitalization of the RDF predicate...

=cut



{

	# Encapsulated:
	# DATA
	#___________________________________________________________
	#ATTRIBUTES

	my %_attr_data =    #     				DEFAULT    	ACCESSIBILITY
	  (
		_has_property => [ undef, 'read/write' ],  # a list
		label => ['Descriptor Profile Schema Class', 'read'],
		type => [['http://dcat.profile.schema/Class'], 'read'],
		class_type => [undef, 'read/write'],  # this is a URI to an OWL class or RDFS class
		-has_property => [ undef, 'read/write' ],  # a list
		
		URI => [undef, 'read/write'],

	  );

	#_____________________________________________________________
	# METHODS, to operate on encapsulated class data
	# Is a specified object attribute accessible in a given mode
	sub _accessible {
		my ( $self, $attr, $mode ) = @_;
		$_attr_data{$attr}[1] =~ /$mode/;
	}

	# Classwide default value for a specified object attribute
	sub _default_for {
		my ( $self, $attr ) = @_;
		$_attr_data{$attr}[0];
	}

	# List of names of all specified object attributes
	sub _standard_keys {
		keys %_attr_data;
	}

}

sub new {
	my ( $caller, %args ) = @_;
	my $caller_is_obj = ref( $caller );
	return $caller if $caller_is_obj;
	my $class = $caller_is_obj || $caller;
	my $proxy;
	my $self = bless {}, $class;
	foreach my $attrname ( $self->_standard_keys ) {
		if ( exists $args{$attrname} ) {
			$self->{$attrname} = $args{$attrname};
		} elsif ( $caller_is_obj ) {
			$self->{$attrname} = $caller->{$attrname};
		} else {
			$self->{$attrname} = $self->_default_for( $attrname );
		}
	}
	my $ug1 = Data::UUID::MT->new( version => 4 );
	$ug1 = $ug1->create_string;
	$self->{URI} =("http://datafairport.org/sampledata/profileschemaclass/$ug1") unless $self->{URI};
	return $self;
}


sub add_Property {   
	my ($self, $p) = @_;
	die "not a DCAT Profile Schema Property" unless ('http://dcat.profile.schema/Property' ~~ $p->type);
	my $ps = $self->_has_property;
	push @$ps, $p;
	$self->_has_property($ps);
	return 1;
}

sub has_property {
	my ($self) = shift;
	if (@_) {
		print STDERR "YOU CANNOT ADD PROPERTIES USING THE ->has_property method;  use add_Property instead!\n";
		return 0;
	}
	return $self->_has_property;
}


sub AUTOLOAD {
	no strict "refs";
	my ( $self, $newval ) = @_;
	$AUTOLOAD =~ /.*::(\w+)/;
	my $attr = $1;
	if ( $self->_accessible( $attr, 'write' ) ) {
		*{$AUTOLOAD} = sub {
			if ( defined $_[1] ) { $_[0]->{$attr} = $_[1] }
			return $_[0]->{$attr};
		};    ### end of created subroutine
###  this is called first time only
		if ( defined $newval ) {
			$self->{$attr} = $newval;
		}
		return $self->{$attr};
	} elsif ( $self->_accessible( $attr, 'read' ) ) {
		*{$AUTOLOAD} = sub {
			return $_[0]->{$attr};
		};    ### end of created subroutine
		return $self->{$attr};
	}

	# Must have been a mistake then...
	croak "No such method: $AUTOLOAD";
}
sub DESTROY { }
1;
