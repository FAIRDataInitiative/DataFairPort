package Ontology::Views::SKOS::conceptSchemeBuilder;
use lib "../../../";
use Ontology::Views::SKOS::NAMESPACES;
use JSON qw( decode_json );
use strict;
use Carp;
use LWP::Simple;
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
		server => [ undef, 'read/write' ],  # a list
		port => ['Descriptor Profile Schema Class', 'read'],
		topConcept => [ undef, 'read/write'],
		schemeURI => [undef, 'read/write'],

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

sub createConceptScheme {
	my ($self, $class) = @_;
	$class||=$self->topConcept;
	unless ($class){
		print STDERR "I have nothing to work with here...";
		return undef;
	}
	my $subclasses = $self->getSubClasses($class);

	foreach my $sub(@$subclasses){
		next if $sub =~ /owl#Nothing/;
		my $label = $self->getLabel($sub);
		print "
    <skos:Concept rdf:about='$sub'>
        <rdfs:label>$label</rdfs:label>
        <rdf:type rdf:resource='&owl;NamedIndividual'/>
        <skos:inScheme rdf:resource='".($self->schemeURI)."'/>
    </skos:Concept>";
	}
}

sub getSubClasses {
	my ($self, $class) = @_;
	$class||=$self->topConcept;
	unless ($class){
		print STDERR "I have nothing to work with here...";
		return undef;
	}
	my $URL = $self->server.":".$self->port."/getSubClasses.json?id=".$class;
	my $result = get($URL);
	my $decoded_json = decode_json( $result );
	return $decoded_json;
}

sub getLabel{
	my ($self, $class) = @_;
	$class||=$self->topConcept;
	unless ($class){
		print STDERR "I have nothing to work with here...";
		return undef;
	}
	my $URL = $self->server.":".$self->port."/class.json?id=".$class;
	my $result = get($URL);
	$result =~ s/\[\]$//s; # a bug in owltools json output
	#print "RESULT $result*$URL*\n";
	my $decoded_json = decode_json( $result );
	return $decoded_json->{label};
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
