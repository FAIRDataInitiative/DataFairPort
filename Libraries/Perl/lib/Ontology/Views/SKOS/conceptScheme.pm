package Ontology::Views::SKOS::conceptScheme;
use lib "../../../";
use Ontology::Views::SKOS::NAMESPACES;
use strict;
use Carp;
use vars qw($AUTOLOAD @ISA);


=head1 NAME

Ontology::Views::SKOS

=head1 SYNOPSIS


 
=cut

=head1 DESCRIPTION

A SKOS view of an ontology

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
		imports => [ undef, 'read/write' ],  # a list
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
