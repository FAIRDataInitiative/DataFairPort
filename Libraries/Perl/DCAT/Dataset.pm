package DCAT::Dataset;
use strict;
use RDF::NS '20131205';
use Carp;
use vars qw($AUTOLOAD @ISA);
use lib "..";
use DCAT::NAMESPACES;

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
	use Data::UUID::MT; 
	my $ug1 = Data::UUID::MT->new( version => 4 );

	my %_attr_data =    #     				DEFAULT    	ACCESSIBILITY
	  (
		title => [ undef, 'read/write' ],
		description => [ undef, 'read/write' ],
		issued => [ undef, 'read/write' ],
		modified => [ undef, 'read/write' ],
                identifier => [ undef, 'read/write' ],
                keyword => [ undef, 'read/write' ],
                contactPoint => [ undef, 'read/write' ],
                temporal => [ undef, 'read/write' ],
    		spatial => [ undef, 'read/write' ],
		landingPage => [ undef, 'read/write' ],
                accrualPeriodicity => [ undef, 'read/write' ],
		type => [ $ns->dc->Dataset, 'read/write' ],
		_themes  => [[], 'read/write'],
		_publisher => ['undef', 'read/write'],
		_distributions => [[], 'read/write'],
		_URI => ["http://datafairport.org/sampledata/dataset/$ug1", 'read'],
		
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


sub add_Theme {
	my ($self, @themes) = @_;
	foreach my $set(@themes)
	{
		die "not a skos:Concept" unless $set->type eq RDF::NS->new->skos("Concept");
		my $sets = $self->_distributions;
		push @$sets, $set;
	}
	return $self->_distributions;
}


sub add_Distribution {
	my ($self, @dists) = @_;
	foreach my $set(@dists)
	{
		die "not a dcat:Distribution" unless $set->type eq DCAT."Distribution";
		my $sets = $self->_themes;
		push @$sets, $set;
	}
	return $self->_themes;
}


sub add_Publisher {
	my ($self, $publisher) = @_;
	die "not a foaf:Agent" unless $publisher->type eq RDF::NS->new->foaf("Agent");
	$self->_publisher($publisher);
	return $self->_publisher;
}

sub toTriples {
	my ($self) = @_;
	my $store = RDF::Trine::Store::Memory->new();
	my $model = RDF::Trine::Model->new($store);

	my $dct = RDF::Trine::Namespace->new( DCT);
	my $dcat = RDF::Trine::Namespace->new( DCAT);

	my $sub = $self->_URI;

	my @facets = qw(title description issued modified identifier keyword language contactPoint temporal spatial accrualPeriodicity landingPage);

	foreach my $facet(@facets){
		my $pred  =$dcat->$facet;
		my $obj = $self->$facet;
		next unless $obj;
		my $stm = statement($sub, $pred, $obj);
		$model->add_statement($stm);
	}
	
	$model->add_statement(statement($sub, RDF."type", $self->type));
	if (@{$self->_distributions}[0]) {
		foreach my $dist(@{$self->_distributions}){
			my $stm = statement($sub, DCAT."distribution", $dist->_URI);
			$model->add_statement($stm);
		}
	}
	$model->add_statement(statement($sub, DCT."publisher", $self->publisher->agent));
	if (@{$self->_themes}[0]) {
		foreach my $theme(@{$self->_themes}){
			my $stm = statement($sub, DCAT."theme", $theme->concept);
			$model->add_statement($stm);
		}
	}
	
	my $iter = $model->get_statements();
	my @statements;
	while (my $st = $iter->next) {
		push @statements, $st;    
	}
	return @statements;
}
	


sub statement {
	my ($s, $p, $o) = @_;
	unless (ref($s) =~ /Trine/){
		$s =~ s/[\<\>]//g;
		$s = RDF::Trine::Node::Resource->new($s);
	}
	unless (ref($p) =~ /Trine/){
		$p =~ s/[\<\>]//g;
		$p = RDF::Trine::Node::Resource->new($p);
	}
	unless (ref($o) =~ /Trine/){
		if ($o =~ /http\:\/\//){
			$o =~ s/[\<\>]//g;
			$o = RDF::Trine::Node::Resource->new($o);
		} elsif ($o =~ /\D/) {
			$o = RDF::Trine::Node::Literal->new($o);
		} else {
			$o = RDF::Trine::Node::Literal->new($o);				
		}
	}
	my $statement = RDF::Trine::Statement->new($s, $p, $o);
	return $statement;
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
