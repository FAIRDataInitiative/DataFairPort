package Ontology::Views::SKOS::conceptScheme;
{
  $Ontology::Views::SKOS::conceptScheme::VERSION = '0.13';
}
use Ontology::Views::SKOS::NAMESPACES;
use Ontology::Views::SKOS::Concept;
use RDF::Trine;
use RDF::Query;
use RDF::Trine::Serializer;

use strict;
use Carp;
use vars qw($AUTOLOAD @ISA);


=head1 NAME

Ontology::Views::SKOS::conceptScheme

=head1 SYNOPSIS


 
=cut

=head1 DESCRIPTION

A SKOS view of an ontology, as proposed by Jupp et al, 2013 "Taking a view on bio-ontologies"

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
		_imports => [ undef, 'read/write' ],  # a list
		label => ['SKOS Concept Scheme view of Ontology', 'read'],
		type => [['http://www.w3.org/2004/02/skos/core#ConceptScheme'], 'read'],
		topConcept => [ undef, 'read/write'],
		schemeURI => [undef, 'read/write'],
		schemeName => [undef, 'read/write'], # this is the label for the top concept
		_concepts => [undef, 'read/write'],  # listref
		
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


sub addConceptToScheme {   
	my ($self, $c) = @_;
	unless ('http://www.w3.org/2004/02/skos/core#Concept' ~~ $c->type){
		print "not a SKOS Concept - can't add to the scheme";
		return undef;
	}
	my $ps = $self->_concepts;
	push @$ps, $c;
	$self->_concepts($ps);
	return 1;
}

sub addImportsToScheme {
	my ($self, $uri) = @_;
	my $ps = $self->_imports;
	return 1 if ($uri ~~ $ps); # no duplicates
	push @$ps, $uri;
	$self->_imports($ps);
	return 1;	
}

sub serialize {
	my ($self, $format) = @_;
	$format ||='rdfxml';

	my $SKOS = RDF::Trine::Namespace->new( SKOS);
	my $RDFS = RDF::Trine::Namespace->new( RDFS);
	my $RDF = RDF::Trine::Namespace->new( RDF);
	my $OWL = RDF::Trine::Namespace->new( OWL);

	my $store = RDF::Trine::Store::Memory->new();
	my $model = RDF::Trine::Model->new($store);

	$self->_addOntologyHeaders($model);
	$self->_addSKOSDefinitions($model);
	
	foreach my $concept(@{$self->_concepts}) {
		
		#<skos:Concept rdf:about="&CL;CL_0000081">
		#    <rdf:type rdf:resource="&owl;NamedIndividual"/>
		#    <skos:broader rdf:resource="&CL;CL_0000988"/>
		#    <skos:broader rdf:resource="&efo;EFO_0000324"/>
		#    <skos:narrower rdf:resource="&efo;EFO_0002534"/>
		#    <skos:inScheme rdf:resource="&efo;skos/EFO_GWAS_view"/>
		#</skos:Concept>
		my $stm = statement($concept->ontologyTermURI, $RDF->type, $SKOS->Concept);
		$model->add_statement($stm);                                        
		$stm = statement($concept->ontologyTermURI, $RDFS->label, $concept->label);
		$model->add_statement($stm);                                        
		
		$stm = statement($concept->ontologyTermURI, $RDF->type, $OWL->NamedIndividual);
		$model->add_statement($stm);
		$stm = statement($concept->ontologyTermURI, $SKOS->inScheme, $concept->inSchemeURI);
		$model->add_statement($stm);                                        

		foreach my $b(@{$concept->_broader}){
			$stm = statement($concept->ontologyTermURI, $SKOS->broader, $b);
			$model->add_statement($stm);                                        
		}
		
	}
	my $serializer = RDF::Trine::Serializer->new($format);
	return $serializer->serialize_model_to_string($model);

	
}

sub _addOntologyHeaders {
	my ($self, $model, $namespaces) = @_;
	my @imports = @{$self->_imports};
	
	my $SKOS = RDF::Trine::Namespace->new( SKOS);
	my $RDFS = RDF::Trine::Namespace->new( RDFS);
	my $RDF = RDF::Trine::Namespace->new( RDF);
	my $OWL = RDF::Trine::Namespace->new( OWL);
		
	my $stm = statement($self->schemeURI, $RDF->type, $OWL->Ontology);
	$model->add_statement($stm);                                        

	foreach my $imp(@{$self->_imports}){
		my $stm = statement($self->schemeURI, $OWL->imports, $imp);		
		$model->add_statement($stm);                                        
	}
	
}


sub _addSKOSDefinitions {
	 
    #<owl:ObjectProperty rdf:about="&skos;broader"/>
    #<owl:ObjectProperty rdf:about="&skos;hasTopConcept"/>
    #<owl:ObjectProperty rdf:about="&skos;inScheme"/>
    #<owl:ObjectProperty rdf:about="&skos;narrower"/>
    #<owl:ObjectProperty rdf:about="&skos;topConceptOf"/>
    #<owl:Class rdf:about="&skos;Concept"/>
    #<owl:Class rdf:about="&skos;ConceptScheme"/>

	my ($self, $model) = @_;
	my $SKOS = RDF::Trine::Namespace->new( SKOS);
	my $RDFS = RDF::Trine::Namespace->new( RDFS);
	my $RDF = RDF::Trine::Namespace->new( RDF);
	my $OWL = RDF::Trine::Namespace->new( OWL);
		
	my $stm = statement($SKOS->broader, $RDF->type, $OWL->ObjectProperty);
	$model->add_statement($stm);                                        
	$stm = statement($SKOS->hasTopConcept, $RDF->type, $OWL->ObjectProperty);
	$model->add_statement($stm);                                        
	$stm = statement($SKOS->inScheme, $RDF->type, $OWL->ObjectProperty);
	$model->add_statement($stm);                                        
	$stm = statement($SKOS->narrower, $RDF->type, $OWL->ObjectProperty);
	$model->add_statement($stm);                                        
	$stm = statement($SKOS->topConceptOf, $RDF->type, $OWL->ObjectProperty);
	$model->add_statement($stm);                                        
	$stm = statement($SKOS->Concept, $RDF->type, $OWL->Class);
	$model->add_statement($stm);                                        
	$stm = statement($SKOS->ConceptScheme, $RDF->type, $OWL->Class);
	$model->add_statement($stm);                                        
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
