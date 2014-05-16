package DCAT::Dataset;
use strict;
use lib "..";
use Carp;
use DCAT::Base;
use DCAT::NAMESPACES;
use vars qw($AUTOLOAD @ISA);

use base 'DCAT::Base';

use vars qw /$VERSION/;
$VERSION = sprintf "%d.%02d", q$Revision: 1.5 $ =~ /: (\d+)\.(\d+)/;

=head1 NAME

DCAT::Dataset - a module for working with DCAT Datasets

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
		title => [ undef, 'read/write' ],
		description => [ undef, 'read/write' ],
		issued => [ undef, 'read/write' ],
		modified => [ undef, 'read/write' ],
                identifier => [ undef, 'read/write' ],
                keyword => [ undef, 'read/write' ],   # TODO - shouldn't this be a list??
                language => [ undef, 'read/write' ],
                contactPoint => [ undef, 'read/write' ],
                temporal => [ undef, 'read/write' ],
    		spatial => [ undef, 'read/write' ],
		landingPage => [ undef, 'read/write' ],
                accrualPeriodicity => [ undef, 'read/write' ],
		type => [ [$ns->dc('Dataset'), DCAT."Dataset"], 'read/write' ],   # multiple RDF types...
		
		_themes  => [undef, 'read/write'],
		_publisher => ['undef', 'read/write'],
		_distributions => [undef, 'read/write'],
		_URI => [undef, 'read'],
		'-distribution' => [undef, 'read'],   # DO NOT USE!  These are only to trigger execution of the identically named subroutine when serializing to RDF
		'-theme' => [undef, 'read'],    # DO NOT USE!  These are only to trigger execution of the identically named subroutine when serializing to RDF
		'-publisher' => [undef, 'read'],    # DO NOT USE!  These are only to trigger execution of the identically named subroutine when serializing to RDF
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
	$self->_themes([]);
	$self->_distributions([]);
	my $ug1 = Data::UUID::MT->new( version => 4 );
	$ug1 = $ug1->create_string;
	$self->{_URI} = ("http://datafairport.org/sampledata/dataset/$ug1");
	return $self;
}


sub add_Distribution {
	my ($self, @themes) = @_;
	foreach my $set(@themes)
	{
		die "not a dcat:Distribution" unless (DCAT."Distribution" ~~ @{$set->type});
		my $sets = $self->_distributions;
		push @$sets, $set;
	}
	return $self->_distributions;
}


sub distribution {
	my ($self) = shift;
	if (@_) {
		print STDERR "YOU CANNOT ADD DISTRIBUTIONS USING THE ->distributions method@  use add_Distribution instead!\n";
		return 0;
	}
	return $self->_distributions;  # an arrayref
	
}

sub add_Theme {
	my ($self, @dists) = @_;
	foreach my $set(@dists)
	{
		die "not a skos:Concept" unless (RDF::NS->new->skos("Concept") ~~ @{$set->type});
		my $sets = $self->_themes;
		push @$sets, $set;
	}
	return $self->_themes;
}

sub theme {
	my ($self) = shift;
	if (@_) {
		print STDERR "YOU CANNOT ADD THEMES USING THE ->theme method@  use add_Distribution instead!\n";
		return 0;
	}
	return $self->_themes;
	
}

sub add_Publisher {
	my ($self, $publisher) = @_;
	die "not a foaf:Agent" unless (RDF::NS->new->foaf("Agent") ~~ @{$publisher->type});
	$self->_publisher($publisher);
	return [$self->_publisher];
}

sub publisher {
	my ($self) = shift;
	if (@_) {
		print STDERR "YOU CANNOT ADD PUBLISHERS USING THE ->publisher method@  use add_Publisher instead!\n";
		return 0;
	}
	return [$self->_publisher];	
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
