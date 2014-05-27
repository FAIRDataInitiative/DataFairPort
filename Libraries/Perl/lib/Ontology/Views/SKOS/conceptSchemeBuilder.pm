package Ontology::Views::SKOS::conceptSchemeBuilder;
use Ontology::Views::SKOS::NAMESPACES;
use Ontology::Views::SKOS::conceptScheme; 
use RDF::Trine::Parser;
use RDF::Trine::Store::Memory;
use RDF::Trine::Model;
use URI::Escape;

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
	my $known_servers = {'edam' => ['http://biordf.org:3100', 'EDAM Ontology', 'http://edam.org/ontology/edo.owl'],};  # structure is {shortname => "host, port, ontologyuri"} and this should point to a webserver instance of OBO owltools

	my %_attr_data =    #     				DEFAULT    	ACCESSIBILITY
	  (
		servers => [ $known_servers , 'read/write' ],  # a list
		schemeName => [undef, 'read/write'],
		schemeURI => [undef, 'read/write'],
		ConceptScheme => [undef, 'read/write'],
		model => [undef, 'read/write'],
		apikey => [undef, 'read/write']
		
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
	$self->schemeName|| $self->schemeName('Auto-generated Concept Scheme');
	$self->schemeURI||$self->schemeURI("http://example.org/SKOSOntologyViewxxx");
	
	unless ($self->ConceptScheme){
		my $s = Ontology::Views::SKOS::conceptScheme->new(
			label => $self->schemeName,
			schemeURI => $self->schemeURI,
			schemeName => $self->schemeName,
			topConcept => $self->schemeURI,   # this will be the top concept, because we may have slices from different ontologies underneath, all will be narrower than this one
		);
		$self->ConceptScheme($s);
	}
	if ($self->apikey) {
		my $json = get('http://data.bioontology.org/ontologies/?apikey='.($self->apikey));
		my $ontologies = decode_json($json);
		my %known_ontologies;
		foreach my $ontology(@$ontologies){
			my $ontologyurl = $ontology->{'@id'};
			my $interface = $ontology->{'links'}->{'classes'};
			$ontologyurl =~ s'data.bioontology.org/ontologies/'purl.bioontology.org/ontology/';
			my ($acronym, $name) = ($ontology->{acronym}, $ontology->{name});
			$known_ontologies{$acronym} = [$name, $interface, $ontologyurl]
		}
		$self->servers(\%known_ontologies);
	}
	return $self;
}

sub _knownOntologies {
	my ($self) = @_;
	my $known = $self->servers;
	foreach my $key(keys %$known){
		print "$key\t$known->{$key}->[0]\t$known->{$key}->[2]\n";
	}
}

sub growConceptScheme {
	my ($self, $ontologyname, $class) = @_;

	unless ($class){
		print STDERR "I have nothing to work with here...\n";
		return undef;
	}
	unless ($self->servers->{$ontologyname}){
		print STDERR "I have no knowledge of the $ontologyname ontology...\n";
		return undef;
	}
	my ($name, $interface, $ontologyURI) = @{$self->servers->{$ontologyname}};
	
	my $label = $self->getLabel($ontologyname, $class);	
	my $concept = Ontology::Views::SKOS::Concept->new(
		label => $label||$class, 
		_broader => [$self->schemeURI],  # I know, I should use the accessor method!  LOL!
		ontologyTermURI => $class,
		inSchemeURI => $self->schemeURI,
		);
	$self->addConceptToScheme($concept);

	my $subclasses = $self->getSubClasses($ontologyname, $class);  # returns a hashref of URI => label

	if ($interface =~ /bioontology\.org/) {
		foreach my $sub(keys %{$subclasses}){
			next if $sub =~ /owl#Nothing/;
			next if $sub =~ /$class/;  # no dups; owlapi returns a class as a subclass of itself
			my $label = $subclasses->{$sub};
			my $concept = Ontology::Views::SKOS::Concept->new(
				label => $label||$sub, 
				_broader => [$class],  # I know, I should use the accessor method!  LOL!
				ontologyTermURI => $sub,
				inSchemeURI => $self->schemeURI,
			);
			$self->addConceptToScheme($concept);
			$self->addImportsToScheme($ontologyURI);
		}
	} else {
		#owltools
		foreach my $sub(@$subclasses){
			next if $sub =~ /owl#Nothing/;
			next if $sub =~ /$class/;  # no dups; owlapi returns a class as a subclass of itself
			my $label = $self->getLabel($ontologyname, $sub);
			my $concept = Ontology::Views::SKOS::Concept->new(
				label => $label||$sub, 
				_broader => [$class],  # I know, I should use the accessor method!  LOL!
				ontologyTermURI => $sub,
				inSchemeURI => $self->schemeURI,
			);
			$self->addConceptToScheme($concept);
			$self->addImportsToScheme($ontologyURI);
		}
	}
	return $self->ConceptScheme;
}

sub addConceptToScheme {
	my ($self, $concept) = @_;
	my $scheme = $self->ConceptScheme;
	return $scheme->addConceptToScheme($concept);
		
}


sub addImportsToScheme {
	my ($self, $concept) = @_;
	my $scheme = $self->ConceptScheme;
	return $scheme->addImportsToScheme($concept);
		
}

sub getSubClasses {
	my ($self, $ontologyname, $class) = @_;
	my ($name, $interface, $ontologyURI) = @{$self->servers->{$ontologyname}};

	unless ($class){
		print STDERR "[getLabel] I have nothing to work with here...\n";
		return undef;
	}
	if ($interface =~ /bioontology\.org/) {
		$class = uri_escape($class);
		my $URL = $interface."/".$class."/descendants?apikey=".($self->apikey);
		my $result = get($URL);
		my $decoded_json = decode_json($result);
		my $desc = $decoded_json->{collection};
		my %children;
		foreach my $child(@$desc){
			$children{$child->{'@id'}} = $child->{prefLabel};
		}
		return \%children;
#  do something useful here!		
	} else {
		# owltools
		my $URL = $interface."/getSubClasses.json?id=".$class;
		my $result = get($URL);
		my $decoded_json = decode_json( $result );
		return $decoded_json;
	}
}

sub getLabel{
	my ($self, $ontologyname, $class) = @_;
	my ($name, $interface, $ontologyURI) = @{$self->servers->{$ontologyname}};

	unless ($class){
		print STDERR "[getLabel] I have nothing to work with here...\n";
		return undef;
	}
	if ($interface =~ /bioontology\.org/) {
		$class = uri_escape($class);
		my $URL = $interface."/".$class."?apikey=".($self->apikey);
		my $result = get($URL);
		my $decoded_json = decode_json($result);
		return $decoded_json->{prefLabel};
	} else {
		# owltools
		my $URL = $interface."/class.json?id=".$class;
		my $result = get($URL);
		$result =~ s/\[\]$//s; # a bug in owltools json output
		#print "RESULT $result*$URL*\n";
		my $decoded_json = decode_json( $result );
		return $decoded_json->{label};
	}
}

sub parseFile {
	my ($self, $filename) = @_;
	my $content;
	if ($filename =~ m'http://') {
		$content = get($filename);
		die "no content at $filename\n" unless $content;
		#$return undef unless $content
	} else {	
		die "file $filename does not exist" unless (-e $filename);
		open(IN, "$filename") || die "can't open input file $!\n";
		my @content = <IN>;
		$content = join "", @content;
	}
	# the ConceptScheme is created by ->new so it already exists
	my $store = RDF::Trine::Store::Memory->new();
	my $model = RDF::Trine::Model->new($store);
	$self->model($model);

	my $parser = RDF::Trine::Parser->new('rdfxml');
	$parser->parse_into_model( "", $content, $model );
	
	$self->_getCoreIdentityFromScheme($model);
	$self->_getImportsFromScheme($model);
	$self->_getConceptsFromScheme($model);
	
	return $self->ConceptScheme;

}


sub _getCoreIdentityFromScheme {
	my ($self, $model) = @_;
	
	my $query = RDF::Query->new( 'SELECT ?s WHERE {?s <'.(RDF.'type').'> <'.(OWL.'Ontology').'>}' );
	my $iterator = $query->execute( $model );
	my $profile;
	while (my $row = $iterator->next) {
		my $URI = $row->{ 's' }->value;
		$self->ConceptScheme->schemeURI($URI);
		$self->ConceptScheme->topConcept($URI);
	}

}

sub _getImportsFromScheme {
	my ($self, $model) = @_;
	
	my $query = RDF::Query->new( 'SELECT ?o WHERE {?s <'.(OWL.'imports').'> ?o}' );
	my $iterator = $query->execute( $model );
	my $profile;
	while (my $row = $iterator->next) {
		my $URI = $row->{ 'o' }->value;
		$self->ConceptScheme->addImportsToScheme($URI);
	}

}


sub _getConceptsFromScheme {
	my ($self, $model) = @_;
	
	my $query = RDF::Query->new( 'SELECT ?s WHERE {?s a <'.(SKOS.'Concept').'>}' );
	my $iterator = $query->execute( $model );
	my $profile;
	while (my $row = $iterator->next) {
		my $URI = $row->{ 's' }->value;
		my $concept;
		my $query2 = RDF::Query->new( "SELECT ?inscheme ?label WHERE {
					     OPTIONAL {<$URI> <".(SKOS.'inScheme')."> ?inscheme} .\n
					     OPTIONAL {<$URI> <".(RDFS.'label')."> ?label} .\n
					     }");
		my $iterator2 = $query2->execute( $model );
		while (my $row2 = $iterator2->next) {
			$concept = Ontology::Views::SKOS::Concept->new(
				label => $row2->{label}->value, 
				ontologyTermURI => $URI,
				inSchemeURI => $row2->{inscheme}->value,
			);
		
		} 
		my $query3 = RDF::Query->new( "SELECT ?broader ?narrower  WHERE {
						OPTIONAL {<$URI> <".(SKOS.'broader')."> ?broader} .\n
						OPTIONAL {<$URI> <".(SKOS.'narrower')."> ?narrower} .\n
					     }");
		my $iterator3 = $query3->execute( $model );
		while (my $row3 = $iterator3->next) {
			$concept->addBroader($row3->{'broader'}->value) if $row3->{'broader'};
			$concept->addNarrower($row3->{'narrower'}->value) if $row3->{'narrower'};
		}
		$self->ConceptScheme->addConceptToScheme($concept);			     
	}

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
