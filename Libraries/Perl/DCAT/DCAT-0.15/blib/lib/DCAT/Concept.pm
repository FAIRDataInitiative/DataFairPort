package DCAT::Concept;
{
  $DCAT::Concept::VERSION = '0.15';
}
use strict;
use Carp;
use DCAT::Base;
use RDF::NS;
use DCAT::NAMESPACES;
use vars qw($AUTOLOAD @ISA);

use base 'DCAT::Base';


=head1 NAME

DCAT::Concept - a module for working with the DCAT skos:Concept

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
	my $ns = RDF::NS->new();
	my %_attr_data =    #     				DEFAULT    	ACCESSIBILITY
	  (
		label => [undef, 'read/write'],
		type  => [[$ns->skos('Concept')], 'read'],

		_scheme => [undef, 'read/write'],
		URI => [ undef, 'read/write' ],
		'-inScheme' => [undef, 'read'],   # DO NOT USE!  These are only to trigger execution of the identically named subroutine when serializing to RDF
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

	my $URI = $args{'concept'};  # pass agent as an argument
	die "must pass concept URI" unless $URI;
	$args{'URI'} = $URI;

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


sub add_inScheme {
	my ($self, $scheme) = @_;
	die "not a skos:ConceptScheme" unless (RDF::NS->new->skos('ConceptScheme') ~~ @{$scheme->type});
	$self->_scheme($scheme);
	return [$self->_scheme];
}

sub inScheme {
	my ($self) = shift;
	if (@_) {
		print STDERR "YOU CANNOT ADD CONCEDPT SCHEMES USING THE ->inScheme method@  use add_inScheme method instead!\n";
		return 0;
	}
	return [$self->_scheme];	
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
