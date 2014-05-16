package DCAT::Profile::Schema::Property;
use strict;
use Carp;
use lib "../../../";
use DCAT::Base;
use DCAT::NAMESPACES;
use Data::UUID::MT;
use vars qw($AUTOLOAD @ISA);

use base 'DCAT::Base';

use vars qw /$VERSION/;
$VERSION = sprintf "%d.%02d", q$Revision: 1.5 $ =~ /: (\d+)\.(\d+)/;

=head1 NAME

DCAT::Distribution - a module for working with DCAT Distributions

=head1 SYNOPSIS

=cut

=head1 DESCRIPTION



=cut

=head1 AUTHORS

Mark Wilkinson (markw at illuminae dot com)

=cut

=head1 METHODS


=head2 new

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

		type => [['http://dcat.profile.schema/Property'], 'read'],
	
		_URI => [undef, 'read'],

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
	$self->{_URI} = ("http://datafairport.org/sampledata/profileschemaproperty/$ug1");

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
