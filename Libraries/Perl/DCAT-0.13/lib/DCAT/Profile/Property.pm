package DCAT::Profile::Property;
{
  $DCAT::Profile::Property::VERSION = '0.13';
}
use strict;
use Carp;
use DCAT::Base;
use DCAT::NAMESPACES;
use Data::UUID::MT;
use vars qw($AUTOLOAD @ISA);

use base 'DCAT::Base';


=head1 NAME

DCAT::Profile::Property - a module representing a DCAT Profile Property

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

DCAT Property describes a single metadata element, and its possible values.
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
 Usage : my $Property = DCAT::Profile::Property->new();
 Function: Builds a new DCAT::Profile::Property
 Returns : DCAT::Profile::Property
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


=head2 allow_multiple

 Title : allow_multiple
 Usage : $allow_multiple = $Property->allow_multiple('true');
 Function: get/set the "allow multiple" attribute - is this property allowed multiple times in a class?
 Returns : string ('true'/'false')
 Args : string ('true'/'false')

=cut


=head2 URI

 Title : URI
 Usage : $uri = $Property->URI($uri);
 Function: get/set the URI for this Property - the URI in the RDF
 Returns : string  (should be a URI)
 Args : string   (should be a URI)
 notes:  if this is not supplied, a unique URI will be automatically generated

=cut

=head2 requirement_status

 Title : requirement_status
 Usage : $req = $Property->requirement_status();
 Function: retrieve the 'required' or 'optional' status of this property
 Returns : string
 Args : none
 Note:  the capitalization of the method name
        matches the capitalization of the RDF predicate...

=cut


=head2 set_RequirementStatus

 Title : set_RequirementStatus
 Usage : $Property->set_RequirementStatus('optional');
 Function: set the 'required' or 'optional' status of this property
 Returns : none
 Args : string ('optional' or 'required')

=cut

=head2  add_ValueRange

 Title : add_ValueRange
 Usage : $Property->add_ValueRange($URI);
 Function: add a range restriction for this predicate
 Returns : none
 Args : string - the string should be a URI...
 Notes:  This is the "critical bit" of the DCAT Profile.  The ranges
         can be defined by one of:  the URI of an XSD datatype, the URI
	 to a SKOS view of a set of ontology terms (according to Jupp et al, 2013)
	 or the URI to another DCAT::Profile (in this way, profiles can be hierarchical)

=cut


=head2 allowed_values

 Title : allowed_values
 Usage : $req = $Property->allowed_values();
 Function: retrieve the value ranges for the property
 Returns : listref of URIs (see add_ValueRange for details)
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
		_requirement_status => [ 'optional', 'read/write' ],  # 'optional' or 'required'
		property_type => [ undef, 'read/write' ],  # a URI referring to an ontological predicate
		_allowed_values => [undef, 'read/write' ],   # this is a list of URL references to either other Profiles, or to SKOS view on an ontology (Jupp et al, 2013)
		label => ['Descriptor Profile Schema Property', 'read'],
		allow_multiple => ['true', 'read/write'],   # can this property appear multiple times?

		type => [[DCTS.'Property'], 'read'],
	
		URI => [undef, 'read'],

		'-allowed_values'  => [undef, 'read/write' ],
		'-requirement_status' => [undef, 'read/write'],
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
	die "not a valid profile property-value range $p" unless ($p =~ /^http:/);
	my $ps = $self->_allowed_values;
	push @$ps, $p;
	$self->_allowed_values($ps);
	return 1;
}

sub allowed_values {
	my ($self) = shift;
	if (@_) {
		print STDERR "YOU CANNOT ADD PROPERTY RANGES USING THE ->allowed_values method;  use add_ValueRange instead!\n";
		return 0;
	}
	return $self->_allowed_values;
}


sub set_RequirementStatus {   
	my ($self, $p) = @_;
	die "must be either 'optional' or 'required'; received $p for RequirementStatus" unless ($p eq 'optional' || $p eq 'required');
	$self->_requirement_status($p);
	return $self->_requirement_status();
}

sub requirement_status {
	my ($self) = shift;
	if (@_) {
		print STDERR "YOU CANNOT CHANGE PROPERTY REQUIREMENT STATUS USING THE ->requirement_status method;  use set_RequirementStatus instead!\n";
		return 0;
	}
	return [$self->_requirement_status];
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
