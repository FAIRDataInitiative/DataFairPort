package DCAT::Profile::Schema;
use strict;
use Carp;
use lib "../../";
use DCAT::Base;
use DCAT::NAMESPACES;
use RDF::Trine::Store::Memory;
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
		label => ['Descriptor Profile Schema', 'read'],
		title => [ undef, 'read/write' ],
		description => [ undef, 'read/write' ],
		modified => [ undef, 'read/write' ],
                license => [ undef, 'read/write' ],
                issued => [ undef, 'read/write' ],
    		organization => [ undef, 'read/write' ],
		identifier => [ undef, 'read/write' ],
		schemardfs_URL => ["http://raw.githubusercontent.com/markwilkinson/DataFairPort/master/Schema/DCATProfile.rdfs", 'read/write'],
		_has_class => [undef, 'read/write'],
		type => [['http://dcat.profile.schema/Schema'], 'read'],
		
		_URI => [undef, 'read/write'],
		
		'-has_class' => [undef, 'read/write']

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
	$self->{_URI} = ("http://datafairport.org/sampledata/profileschema/$ug1");

	return $self;
}

sub add_Class {   
	my ($self, $class) = @_;
	die "not a DCAT Profile Schema Class" unless ('http://dcat.profile.schema/Class' ~~ $class->type);
	my $classes = $self->_has_class;
	push @$classes, $class;
	$self->_has_class($classes);
	return 1;
}

sub has_class {   
	my ($self) = shift;
	if (@_) {
		print STDERR "YOU CANNOT ADD CLASSES USING THE ->has_class method;  use add_Class instead!\n";
		return 0;
	}
	return $self->_has_class;
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
	my @triples = $self->toTriples;
	foreach my $statement(@triples){
		$model->add_statement($statement);
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
