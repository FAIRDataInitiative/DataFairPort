package DCAT::CatalogRecord;
use strict;
use Carp;
use vars qw($AUTOLOAD @ISA);
use lib "..";
use DCAT::NAMESPACES;

use vars qw /$VERSION/;
$VERSION = sprintf "%d.%02d", q$Revision: 1.5 $ =~ /: (\d+)\.(\d+)/;

=head1 NAME

DCAT::Distribution - a module for working with DCAT CatalogRecord

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

	my %_attr_data =    #     				DEFAULT    	ACCESSIBILITY
	  (
		title => [ undef, 'read/write' ],
		description => [ undef, 'read/write' ],
		issued => [ undef, 'read/write' ],
		modified => [ undef, 'read/write' ],
		type => [DCAT."CatalogRecord", 'read'],
		_primarytopic  => [undef, 'read/write'],
		_URI => ["http://datafairport.org/sampledata/catalogrecord/$ug1", 'read'],

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

sub has_primaryTopic {
	my ($self, $topic) = @_;
	die "not a dc:Dataset (foaf:primarytopic)" unless $topic->type eq RDF::NS->new->dc('Dataset');
	$self->_primarytopic($topic);
	return $self->_primarytopic;

	
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
