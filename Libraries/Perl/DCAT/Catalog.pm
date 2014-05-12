package DCAT::Catalog;
use strict;
use Carp;
use lib "..";
use DCAT::Base;
use DCAT::NAMESPACES;
use vars qw($AUTOLOAD @ISA);
use base 'DCAT::Base';


use vars qw /$VERSION/;
$VERSION = sprintf "%d.%02d", q$Revision: 1.5 $ =~ /: (\d+)\.(\d+)/;

=head1 NAME

DCAT::Catalog - a module for working with the DCAT specification

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
	use Data::UUID::MT;
	my $ug1 = Data::UUID::MT->new( version => 4 );
	$ug1 = $ug1->create_string;

	my %_attr_data =    #     				DEFAULT    	ACCESSIBILITY
	  (
		title => [ undef, 'read/write' ],
		description => [ undef, 'read/write' ],
		issued => [ undef, 'read/write' ],
		modified => [ undef, 'read/write' ],
		language => [ undef, 'read/write' ],
		license => [ undef, 'read/write' ],
		rights => [ undef, 'read/write' ],
		spatial => [ undef, 'read/write' ],
		homepage => [ undef, 'read/write' ],
		_themeTaxonomy => [undef, 'read/write'],
		_publisher => [undef, 'read/write'],
		_datasets => [[], 'read/write'],
		_catalogrecords => [[], 'read/write'],
		_URI => ["http://datafairport.org/sampledata/catalog/$ug1", 'read'],

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

sub add_themeTaxonomy {
	my ($self, $tax) = @_;
	die "not a Skos concept scheme" unless $tax->type eq RDF::NS->new->skos('ConceptScheme');
	$self->_themeTaxonomy($tax);
	return $self->_themeTaxonomy;
	
}

sub themeTaxonomy {
	my ($self) = shift;
	if (@_) {
		print STDERR "YOU CANNOT ADD THEME TAXONOMIES USING THE ->themeTaxonomn method@  use add_themeTaxonomy method instead!\n";
		return 0;
	}
	return $self->_themeTaxonomy;	
}

sub add_Publisher {
	my ($self, $agent) = @_;
	die "not a foaf:Agent" unless $agent->type eq RDF::NS->new->foaf('Agent');
	$self->_publisher($agent);
	return $self->_publisher;
}

sub publisher {
	my ($self) = shift;
	if (@_) {
		print STDERR "YOU CANNOT ADD Publishers USING THE ->publisher method@  use add_Publisher method instead!\n";
		return 0;
	}
	return $self->_publisher;	
}

sub add_Dataset {
	my ($self, @datasets) = @_;
	foreach my $set(@datasets)
	{
		die "not a Dataset" unless $set->type eq RDF::NS->new->dc('Dataset');
		my $sets = $self->_datasets;
		push @$sets, $set;
	}
	return $self->_datasets;
}

sub dataset {
	my ($self) = shift;
	if (@_) {
		print STDERR "YOU CANNOT ADD DATASETS USING THE ->dataset method@  use add_Dataset method instead!\n";
		return 0;
	}
	return $self->_datasets;	
}


sub add_Record {
	my ($self, @records) = @_;
	foreach my $set(@records)
	{
		die "not a CatalogRecord" unless $set->type eq DCAT."CatalogRecord";
		my $sets = $self->_catalogrecords;
		push @$sets, $set;
	}
	return $self->_catalogrecords;
}

sub record {
	my ($self) = shift;
	if (@_) {
		print STDERR "YOU CANNOT ADD RECORDS USING THE ->record method@  use add_Record method instead!\n";
		return 0;
	}
	return $self->_catalogrecords;	
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
