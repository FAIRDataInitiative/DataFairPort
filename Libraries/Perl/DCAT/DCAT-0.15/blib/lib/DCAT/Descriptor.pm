package DCAT::Descriptor;
{
  $DCAT::Descriptor::VERSION = '0.15';
}
use strict;
use Carp;
#use DCAT::Base;
use DCAT::NAMESPACES;
use DCAT::CatalogRecord;
use DCAT::Agent;
use DCAT::Catalog;
use DCAT::ConceptScheme;
use DCAT::Dataset;
use DCAT::Distribution;

use vars qw($AUTOLOAD @ISA);
use base 'DCAT::Base';

=head1 NAME

DCAT::Descriptor - The container for all other DCAT objects,
to create a full metadata descriptor following the DCAT scheme

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
		Catalog => [ undef, 'read/write' ],
		Datasets => [ undef, 'read/write' ],
		Distributions => [ undef, 'read/write' ],
		CatalogRecords => [ undef, 'read/write' ],
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

sub add_Catalog {
	my ($self, $cat) = @_;
	die "not a DCAT Catalog" unless (DCAT."Catalog" ~~ $cat->type);
	$self->Catalog($cat);
	return 1;
}

sub add_Dataset {   # it isn't clear to me if DCAT descriptors are allowed to have Datasets independent of Catalogs
	my ($self, $dat) = @_;
	die "not a DCAT Catalog" unless (DCAT."Dataset" ~~ $dat->type);
	my $datasets = $self->Datasets;
	push @$datasets, $dat;
	$self->Datasets($datasets);
	return 1;
}

sub add_CatalogRecord {   # it isn't clear to me if DCAT descriptors are allowed to have Datasets independent of Catalogs
	my ($self, $cr) = @_;
	die "not a DCAT CatalogRecord" unless (DCAT."CatalogRecord" ~~ $cr->type);
	my $crs = $self->CatalogRecords;
	push @$crs, $cr;
	$self->CatalogRecords($crs);
	return 1;
}

sub add_Distribution {   # it isn't clear to me if DCAT descriptors are allowed to have Datasets independent of Catalogs
	my ($self, $dist) = @_;
	die "not a DCAT Distribution" unless (DCAT."Distribution" ~~ $dist->type);
	my $dists = $self->Distributions;
	push @$dists, $dist;
	$self->Distributions($dists);
	return 1;
}

sub serialize {
#ntriples
#nquads
#rdfxml
#rdfjson
#ntriples-canonical
#turtle
	my ($self, $format) = @_;
	$format ||='rdfxml';
	my $store = RDF::Trine::Store::Memory->new();
	my $model = RDF::Trine::Model->new($store);

	foreach my $object($self->Catalog, $self->Distributions, $self->Datasets, $self->CatalogRecords){
		next unless $object;	
		my @triples = $object->toTriples;
		foreach my $statement(@triples){
			$model->add_statement($statement);
		}
	}
	my $serializer = RDF::Trine::Serializer->new($format);
	return $serializer->serialize_model_to_string($model);
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
