package Ontology::Views::SKOS::Concept;
use lib "../../../";
use Ontology::Views::SKOS::NAMESPACES;
use strict;
use Carp;
use vars qw($AUTOLOAD @ISA);


=head1 NAME

Ontology::Views::SKOS::Concept

=head1 SYNOPSIS


 
=cut

=head1 DESCRIPTION

A Concept within a SKOS view of an ontology, as proposed by Jupp et al, 2013 "Taking a view on bio-ontologies"

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
		label => [ undef, 'read/write' ],  # a list
		_broader => [ undef, 'read/write' ],  # a list
		_narrower => [undef, 'read'],
		type => [['http://www.w3.org/2004/02/skos/core#Concept'], 'read'],
		ontologyTermURI => [undef, 'read/write'],
		inSchemeURI => [undef, 'read/write'],
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
	return $self;
}


sub addBroader {   
	my ($self, $p) = @_;
	my $ps = $self->_broader;
	next if ($p ~~ $ps); # no dups
	push @$ps, $p;
	$self->_broader($ps);
	return 1;
}

sub addNarrower {
	my ($self, $p) = @_;
	my $ps = $self->_narrower;
	next if ($p ~~ $ps); # no dups
	push @$ps, $p;
	$self->_narrower($ps);
	return 1;
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
