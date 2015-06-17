package FAIR::Profile::Parser;


# ABSTRACT: Parser that reads FAIR Profile RDF and creates a FAIR::Profile object

use Moose;

use strict;
use Carp;
use RDF::Trine::Parser;
use RDF::Trine::Model;
use RDF::Query; 
use LWP::Simple;
use FAIR::NAMESPACES;
use FAIR::Profile; 

#use vars qw /$VERSION/;
#$VERSION = sprintf "%d.%02d", q$Revision: 1.5 $ =~ /: (\d+)\.(\d+)/;

=head1 NAME

FAIR::Profile::Parser - a module for reading FAIR Profile RDF files

=head1 SYNOPSIS

 use FAIR::Profile::Parser;

 my $parser = FAIR::Profile::Parser->new(filename => "./ProfileSchema.rdf");
 my $DatasetSchema = $parser->parse;

 my $schema =  $DatasetSchema->serialize;
 open(OUT, ">ProfileSchema2.rdf")
 print OUT $schema;
 close OUT;

 
=cut

=head1 DESCRIPTION

FAIR Profiles describe the metadata elements, and constrained values, that should be
associated with a given information entity.  They ARE NOT containers for this metadata,
they only describe what that metadata should look like (meta-meta-data :-) )

This module will parse an RDF file containing a FAIR Profile into
objects that can be used to construct a metadata capture interface.
The objects will tell you what fields are required/optional, and what possible
values they are allowed to contain.

=cut

=head1 AUTHORS

Mark Wilkinson (markw at illuminae dot com)

=cut

=head1 METHODS


=head2 new

 Title : new
 Usage : my $ProfileParser = FAIR::Profile::Parser->new();
 Function: Builds a new FAIR::Profile::Parser
 Returns : FAIR::Profile::Parser
 Args : filename => $filename
        model => $model (an existing RDF::Trine::Model -
	        if you don't supply this it will be created for you)


=cut

=head2 parse

 Title : parse
 Usage : my $ProfileObject = $ProfileParser->parse();
 Function: parse the file associated with the Parser
 Returns : FAIR::Profile
 Args : none

=cut

=head2 filename

 Title : filename
 Usage : $ProfileParser->filename($filename);
 Function: associate a file with the parser
 Returns : null
 Args : full or relative path to the file to be parsed

=cut


=head2 data

 Title : data
 Usage : $ProfileParser->data($rdfdata);
 Function: associate a data string with the parser
 Returns : null
 Args : string of RDF in the format specified in $Parser->data_format

=cut


=head2 data_format

 Title : data_format
 Usage : $ProfileParser->data_format($format);
 Function: the format of the RDF data in ->data (if any)
 Returns : null
 Args : rdfxml | turtle | ntriples | nquads (or any type acceptable to RDF::Trine)

=cut


=head2 model

 Title : model
 Usage : $ProfileParser->model($RDFTrineModel);
 Function: associate an RDF::Trine::Model with the parser
 Returns : null
 Args : RDF::Trine::Model (this will be created for you, if not supplied)

=cut


=head2 profile

 Title : profile
 Usage : $Profile = $ProfileParser->profile;
 Function: retrieve the profile after a parse.  Must parse first!
 Returns : FAIR::Profile
 Args : none

=cut




has filename => (
	is => 'rw',
	isa => "Str",
	required => 0,
	);

has data => (
	is => 'rw',
	isa => "Str",
	required => 0,
	);

has data_format => (
	is => 'rw',
	isa => "Str",
	required => 0,
);

has model => (
	is => 'rw',
	isa => 'RDF::Trine::Model',
	default => sub { my $store = RDF::Trine::Store::Memory->new();
			my $model = RDF::Trine::Model->new($store); return $model;},
	);

has profile => (
	is => 'rw',
	isa => 'FAIR::Profile',
	
	);

sub parse {
	
	my ($self) = @_;
	my $filename = $self->filename;
	my $model = $self->model;
	my $data = $self->data;
	if ($filename) {
		if ($filename =~ m'^http://') {
			my $result = get($filename);
			die "Nothing could be retrieved from $filename\n" unless $result;		
			RDF::Trine::Parser->parse_url_into_model($filename, $model );
			
		} else {
				
			die "file $filename does not exist" unless (-e $filename);
		#	open(IN, "$filename") || die "can't open input file $!\n";
			RDF::Trine::Parser->parse_file_into_model( "", $filename, $model );
		
		}
	} elsif ($data){
		die "you can't pass data without telling me the ->data_format" unless ($self->data_format);
		my $parser = RDF::Trine::Parser->new($self->data_format);
		$parser->parse_into_model("", $data, $model );
	}
	
	
	# $self->model($model);  # this appears to be redundant...
	
	my $profile = $self->getProfile();
	return $profile;
}

sub getProfile {
	my ($self) = @_;
	my $model = $self->model;

	my $query = RDF::Query->new( "SELECT ?s WHERE {?s a <".FAIR."FAIRProfile>}" );
	my $iterator = $query->execute( $model );
	my $profile;
	while (my $row = $iterator->next) {
		my $URI = $row->{ 's' };
		$profile = $self->_fillProfile($URI);
	}
	$self->profile($profile);
	return $profile;

}



sub _fillProfile {
	my ($self, $URITrine) = @_;
	#has URI => (
	#has type => (
	#has hasClass => (
	#has label => (
	#has title => (
	#has description => (
	#has license => (
	#has organization => (
	#has identifier => (
	#has schemardfs_URL => (

	my %ns = %FAIR::Base::predicate_namespaces;
	my $prefixes = _generatePrefixHeader();
	my $query = "SELECT ?label ?title ?description ?modified ?license ?issued ?organization ?identifier ?schemardfs_URL ?type
	WHERE { ";
	my $whereclause = "";
	my $URI = $URITrine->value;
	foreach my $element(qw(label title description modified license issued organization identifier schemardfs_URL type)){
		$whereclause .= "OPTIONAL {<$URI> $ns{$element}:$element ?$element} .\n";
	}
	$query = $prefixes . $query . $whereclause . "}";
	#print STDERR $query;
	my $Q = RDF::Query->new( $query );
	my $iterator = $Q->execute( $self->model );
	my $row = $iterator->next;  # should only be one!
	
	my $label = $row->{label}->value if $row->{label};
	my $title = $row->{title}->value if $row->{title};
	my $description = $row->{description}->value if $row->{description};
	my $modified = $row->{modified}->value if $row->{modified};
	my $license = $row->{license}->value if $row->{license};
	my $issued = $row->{issued}->value if $row->{issued};
	my $organization = $row->{organization}->value if $row->{organization};
	my $identifier = $row->{identifier}->value if $row->{identifier};
	my $schemardfs_URL = $row->{schemardfs_URL}->value if $row->{schemardfs_URL};
	my $type = $row->{type}->value if $row->{type};
	my $ProfileObject = FAIR::Profile->new(
		URI => $URI,
		label => $label,
		title => $title,
		description => $description,
		modified => $modified,
		license => $license,
		issued => $issued,
		organization => $organization,
		identifier => $identifier,
#		schemardfs_URL => $schemardfs_URL,
	);
	
	$self->profile($ProfileObject);
	
	$self->_fillClasses();
	
	return $self->profile();
	
	
}

sub _fillClasses {
	my ($self) = @_;
	my $ProfileObject = $self->profile;
	my $model = $self->model;
	my %ns = %FAIR::Base::predicate_namespaces;
	
	my $ProfileURI = $ProfileObject->URI;

	my $prefixes = _generatePrefixHeader();
	
	my $query = RDF::Query->new( "$prefixes
				    SELECT ?c WHERE {?c $ns{provenance}:provenance <$ProfileURI>}" );
	my $iterator = $query->execute( $model );
	my $profile;
	while (my $row = $iterator->next) {
		next unless $row->{'c'};
		my $ClassURI = $row->{ 'c' }->value;
		my $class = $self->_fillClass($ClassURI);
		$ProfileObject->add_Class($class);
		
		$self->_fillProperties($class);
	}
	
	
}

sub _fillClass {

	my ($self, $ClassURI) = @_;

		#label => ['Descriptor Profile Schema Class', 'read'],
		#class_type => [undef, 'read/write'],  # this is a URI to an OWL class or RDFS class

	my $model = $self->model;
	my %ns = %FAIR::Base::predicate_namespaces;
	
	my $prefixes = _generatePrefixHeader();
	my $query = "SELECT ?label ?onClassType 
	WHERE { ";
	my $whereclause = "";
	foreach my $element(qw(label onClassType)){
		$whereclause .= "OPTIONAL {<$ClassURI> $ns{$element}:$element ?$element} .\n";
	}
	#print STDERR $whereclause;
	$query = $prefixes . $query . $whereclause . "}";
	my $Q = RDF::Query->new( $query );
	my $iterator = $Q->execute( $self->model );
	my $row = $iterator->next;  # should only be one!
	
	my $label = $row->{label}->value if $row->{label};
	my $class_type = $row->{onClassType}->value if $row->{onClassType};
	my $ClassObject = FAIR::Profile::Class->new(
		URI => $ClassURI,
		label => $label,
		onClassType => $class_type,
	);
	
	return $ClassObject;

	
}

sub _fillProperties {
	my ($self, $ClassObject) = @_;
	my $model = $self->model;
	my %ns = %FAIR::Base::predicate_namespaces;

	my $ClassURI = $ClassObject->URI;
	
	my $prefixes = _generatePrefixHeader();
	my $query = RDF::Query->new( "$prefixes
				    SELECT ?p WHERE {<$ClassURI> $ns{hasProperty}:hasProperty  ?p}" );
	my $iterator = $query->execute( $model );
	my $profile;
	while (my $row = $iterator->next) {
		next unless $row->{'p'};
		my $PropertyURI = $row->{ 'p' }->value;
		my $property = $self->_fillProperty($PropertyURI);
		$ClassObject->add_Property($property);
	}

}

sub _fillProperty {
	
	my ($self, $PropertyURI) = @_;

		#property_type => [ undef, 'read/write' ],  # a URI referring to an ontological predicate
		#_allowed_values => [undef, 'read/write' ],   # this is a list of URL references to either other Profiles, or to SKOS view on an ontology (Jupp et al, 2013)
		#label => ['Descriptor Profile Schema Property', 'read'],
		#allow_multiple => ['true', 'read/write'],   # can this property appear multiple times?


	my $model = $self->model;
	
	my %ns = %FAIR::Base::predicate_namespaces;
	my $prefixes = _generatePrefixHeader();
	my $query = "SELECT ?label ?onPropertyType ?maxCount ?minCount 
	WHERE { ";
	my $whereclause = "";
	foreach my $element(qw(label onPropertyType maxCount minCount)){
		$whereclause .= "OPTIONAL {<$PropertyURI> $ns{$element}:$element ?$element} .\n";
	}
	#print STDERR $whereclause;
	$query = $prefixes . $query . $whereclause . "}";
	my $Q = RDF::Query->new( $query );
	my $iterator = $Q->execute( $self->model );
	my $row = $iterator->next;  # should only be one!
	
	my $label = $row->{label}->value if $row->{label};
	my $property_type = $row->{onPropertyType}->value if $row->{onPropertyType};
	my $maxCount = $row->{maxCount}->value if $row->{maxCount};
	my $minCount = $row->{minCount}->value if $row->{minCount};
	my $PropertyObject = FAIR::Profile::Property->new(
		URI => $PropertyURI,
		label => $label,
		onPropertyType => $property_type,
	);
	if (defined $maxCount) {
		$PropertyObject->maxCount($maxCount);
	}
	if (defined $minCount) {
		$PropertyObject->minCount($minCount);
	}

	my $query2 = "SELECT ?allowedValues
	WHERE { ";
	my $whereclause2 = "";
	foreach my $element(qw(allowedValues)){
		$whereclause2 .= "OPTIONAL {<$PropertyURI> $ns{$element}:$element ?$element} .\n";
	}
	#print STDERR $whereclause2;
	$query2 = $prefixes . $query2 . $whereclause2 . "}";
	my $Q2 = RDF::Query->new( $query2 );
	my $iterator2 = $Q2->execute( $self->model );
	while (my $row = $iterator2->next){
		my $restrictionURI = $row->{allowedValues}->value if $row->{allowedValues};
		next unless $restrictionURI;
		$PropertyObject->add_AllowedValue($restrictionURI);
	}
	
	
	return $PropertyObject;

	
}

sub _generatePrefixHeader {
	no strict "refs";
	my $header = "";
	foreach my $namespace (qw(DCAT
        DC
        DCTYPE
        FOAF
        RDF
        RDFS
        SKOS
        VCARD
        XSD
	FAIR)) {
		$header = $header . "PREFIX $namespace: <".&$namespace.">\n";
	}
	return $header
}

1;
