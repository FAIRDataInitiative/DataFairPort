package FAIR::Profile::Property;

use lib "../../../lib/";

use strict;
use Carp;
use FAIR::Base; 
use FAIR::NAMESPACES;
use Data::UUID::MT;
use vars qw($AUTOLOAD @ISA);

use base 'FAIR::Base';


=head1 NAME

FAIR::Profile::Property - a module representing a DCAT Profile Property

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

 
=cut

=head1 DESCRIPTION

FAIR Property describes a single metadata element, and its possible values.
It IS NOT a containers for this metadata,
it only describes what that metadata should look like (meta-meta-data :-) )

Effectively, in RDF terms, this is the predicate associated with the metadata, and it's ranges

=cut

=head1 AUTHORS

Mark Wilkinson (markw at illuminae dot com)

=cut

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


=cut

=head2 label

 Title : label
 Usage : $label = $Property->label($label);
 Function: get/set the RDF label for this object when serialized
 Returns : string
 Args : string

=cut

=head2 property_type

 Title : property_type
 Usage : $property_type = $Property->property_type($property_type);
 Function: get/set the property type (should be a URI, e.g. of an ontology predicate)
 Returns : string (URI)
 Args : string (URI)

=cut



=head2 URI

 Title : URI
 Usage : $uri = $Property->URI($uri);
 Function: get/set the URI for this Property - the URI in the RDF
 Returns : string  (should be a URI)
 Args : string   (should be a URI)
 notes:  if this is not supplied, a unique URI will be automatically generated

=cut

=head2 set_MinCount

 Title : set_MinCount
 Usage : $req = $Property->set_MinCount($int);
 Function: minimum number of occurrences of this property
 Returns : int
 Args : int

=cut

=head2 set_MinCount

 Title : set_MaxCount
 Usage : $req = $Property->set_MaxCount($int);
 Function: maximum number of occurrences of this property
 Returns : int
 Args : int

=cut


=head2  add_ValueRange

 Title : add_ValueRange
 Usage : $Property->add_ValueRange($URI);
 Function: add a range restriction for this predicate
 Returns : none
 Args : string - the string should be a URI...
 Notes:  This is the "critical bit" of the FAIR Profile.  The ranges
         can be defined by one of:  the URI of an XSD datatype, the URI
	 to a SKOS view of a set of ontology terms (according to Jupp et al, 2013)
	 or the URI to another FAIR::Profile (in this way, profiles can be hierarchical)

=cut


=head2 allowedValues

 Title : allowedValues
 Usage : $req = $Property->allowedValues();
 Function: retrieve the value ranges for the property
 Returns : listref of URIs (see add_ValueRange for details)
 Args : none

=cut



{

	# Encapsulated:
	# DATA
	#___________________________________________________________
	#ATTRIBUTES

	my %_attr_data =    #     				DEFAULT    	ACCESSIBILITY
	  (
		#_requirement_status => [ 'optional', 'read/write' ],  # 'optional' or 'required'
		onPropertyType => [ undef, 'read/write' ],  # a URI referring to an ontological predicate
		_allowedValues => [undef, 'read/write' ],   # this is a list of URL references to either other Profiles, or to SKOS view on an ontology (Jupp et al, 2013)
		label => ['FAIR Profile Property', 'read'],
		#allow_multiple => ['true', 'read/write'],   # can this property appear multiple times?
		_minCount => [undef, 'read/write' ],
		_maxCount => [undef, 'read/write' ],
		-minCount => [undef, 'read/write' ],
		-maxCount => [undef, 'read/write' ],

		type => [[FAIR.'FAIRProperty'], 'read'],
	
		URI => [undef, 'read'],

		'-allowedValues'  => [undef, 'read/write' ],
		#'-requirement_status' => [undef, 'read/write'],
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
	$self->{URI} = ("http://datafairport.org/sampledata/profileschemaproperty/$ug1")  unless $self->{URI};

	return $self;
}


sub add_ValueRange {   
	my ($self, $p) = @_;
	die "not a valid profile property-value range $p" unless ($p =~ /^https?:/);
	my $ps = $self->_allowedValues;
	push @$ps, $p;
	$self->_allowedValues($ps);
	return 1;
}

sub allowedValues {
	my ($self) = shift;
	if (@_) {
		print STDERR "YOU CANNOT ADD PROPERTY RANGES USING THE ->allowedValues method;  use add_ValueRange instead!\n";
		return 0;
	}
	return $self->_allowedValues;
}


sub set_MinCount {   
	my ($self, $p) = @_;
	$self->_minCount($p);
	return [$self->_minCount()];
}

sub minCount {
	my ($self) = shift;
	if (@_) {
		print STDERR "YOU CANNOT SET minValue using ->minValue method;  use set_MinValue instead!\n";
		return 0;
	}
	return [$self->_minCount];
}

sub maxCount {
	my ($self) = shift;
	if (@_) {
		print STDERR "YOU CANNOT SET  minValue using ->maxValue method;  use set_MaxValue  instead!\n";
		return 0;
	}
	return [$self->_maxCount];
}

sub set_MaxCount {   
	my ($self, $p) = @_;
	$self->_maxCount($p);
	return [$self->_maxCount()];
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
