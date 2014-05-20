package DCAT::Profile::Schema::Parser;
use strict;
use Carp;
use lib "../../../";
use DCAT::Base;
use DCAT::NAMESPACES;
use DCAT;
use RDF::Trine::Parser;
use RDF::Trine::Model;
use RDF::Query;


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
		filename => [ undef, 'read/write' ], 
		model => [undef, 'read/write'],
		profile => [undef, 'read/write'],
		

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
	unless ($self->model){
            my $store = RDF::Trine::Store::Memory->new();
            my $model = RDF::Trine::Model->new($store);
		$self->model($model);
	}
	return $self;
}

sub parse {
	
	my ($self) = @_;
	my $filename = $self->filename;
	die "file $filename does not exist" unless (-e $filename);
#	open(IN, "$filename") || die "can't open input file $!\n";
	my $model = $self->model;
	RDF::Trine::Parser->parse_file_into_model( "", $filename, $model );
	$self->model($model);  # I think this is unnecessary... its a reference anyway... but just in case!
	
	my $profile = $self->getProfile();
	return $profile;
}

sub getProfile {
	my ($self) = @_;
	my $model = $self->model;

	my $query = RDF::Query->new( 'SELECT ?s WHERE {?s a <http://dcat.profile.schema/Schema>}' );
	my $iterator = $query->execute( $model );
	my $profile;
	while (my $row = $iterator->next) {
		my $URI = $row->{ 's' };
		$profile = $self->_fillProfile($URI);
	}
	return $profile;

}



sub _fillProfile {
	my ($self, $URITrine) = @_;
#		label => ['Descriptor Profile Schema', 'read'],
#		title => [ undef, 'read/write' ],
#		description => [ undef, 'read/write' ],
#		modified => [ undef, 'read/write' ],
#                license => [ undef, 'read/write' ],
#                issued => [ undef, 'read/write' ],
#    		organization => [ undef, 'read/write' ],
#		identifier => [ undef, 'read/write' ],
#		schemardfs_URL => ["http://raw.githubusercontent.com/markwilkinson/DataFairPort/master/Schema/DCATProfile.rdfs", 'read/write'],
#		_has_class => [undef, 'read/write'],
#		type => [['http://dcat.profile.schema/Schema'], 'read'],
#		
#		_URI => [undef, 'read/write'],
	my %ns = %DCAT::Base::predicate_namespaces;
	my $prefixes = _generatePrefixHeader();
	my $query = "SELECT ?label ?title ?description ?modified ?license ?issued ?organization ?identifier ?schemardfs_URL ?type
	WHERE { ";
	my $whereclause = "";
	my $URI = $URITrine->value;
	foreach my $element(qw(label title description modified license issued organization identifier schemardfs_URL type)){
		$whereclause .= "OPTIONAL {<$URI> $ns{$element}:$element ?$element} .\n";
	}
	#print STDERR $whereclause;
	$query = $prefixes . $query . $whereclause . "}";
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
	my $ProfileObject = DCAT::Profile::Schema->new(
		_URI => $URI,
		label => $label,
		title => $title,
		description => $description,
		modified => $modified,
		license => $license,
		issued => $issued,
		organization => $organization,
		identifier => $identifier,
		schemardfs_URL => $schemardfs_URL,
	);
	
	$self->profile($ProfileObject);
	
	$self->_fillClasses();
	
	return $self->profile();
	
	
}

sub _fillClasses {
	my ($self) = @_;
	my $ProfileObject = $self->profile;
	my $model = $self->model;
	
	my $ProfileURI = $ProfileObject->_URI;

	my $has_class = $DCAT::Base::predicate_namespaces{has_class};	
	no strict "refs";
	$has_class = &$has_class."has_class";
	use strict "refs";
	
	my $query = RDF::Query->new( "SELECT ?c WHERE {<$ProfileURI>  <$has_class> ?c}" );
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
	
	my %ns = %DCAT::Base::predicate_namespaces;
	my $prefixes = _generatePrefixHeader();
	my $query = "SELECT ?label ?class_type 
	WHERE { ";
	my $whereclause = "";
	foreach my $element(qw(label class_type)){
		$whereclause .= "OPTIONAL {<$ClassURI> $ns{$element}:$element ?$element} .\n";
	}
	#print STDERR $whereclause;
	$query = $prefixes . $query . $whereclause . "}";
	my $Q = RDF::Query->new( $query );
	my $iterator = $Q->execute( $self->model );
	my $row = $iterator->next;  # should only be one!
	
	my $label = $row->{label}->value if $row->{label};
	my $class_type = $row->{class_type}->value if $row->{class_type};
	my $ClassObject = DCAT::Profile::Schema::Class->new(
		_URI => $ClassURI,
		label => $label,
		class_type => $class_type,
	);
	
	return $ClassObject;

	
}

sub _fillProperties {
	my ($self, $ClassObject) = @_;
	my $model = $self->model;
	my $ClassURI = $ClassObject->_URI;
	
	my $has_property = $DCAT::Base::predicate_namespaces{has_property};	
	no strict "refs";
	$has_property = &$has_property."has_property";
	use strict "refs";

	my $query = RDF::Query->new( "SELECT ?p WHERE {<$ClassURI>  <$has_property> ?p}" );
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
	
	my %ns = %DCAT::Base::predicate_namespaces;
	my $prefixes = _generatePrefixHeader();
	my $query = "SELECT ?label ?property_type ?requirement_status ?allow_multiple 
	WHERE { ";
	my $whereclause = "";
	foreach my $element(qw(label property_type requirement_status allow_multiple)){
		$whereclause .= "OPTIONAL {<$PropertyURI> $ns{$element}:$element ?$element} .\n";
	}
	#print STDERR $whereclause;
	$query = $prefixes . $query . $whereclause . "}";
	my $Q = RDF::Query->new( $query );
	my $iterator = $Q->execute( $self->model );
	my $row = $iterator->next;  # should only be one!
	
	my $label = $row->{label}->value if $row->{label};
	my $property_type = $row->{property_type}->value if $row->{property_type};
	my $allow_multiple = $row->{allow_multiple}->value if $row->{allow_multiple};
	my $required = $row->{requirement_status}->value if $row->{requirement_status};
	my $PropertyObject = DCAT::Profile::Schema::Property->new(
		_URI => $PropertyURI,
		label => $label,
		property_type => $property_type,
		allow_multiple => $allow_multiple,
	);
	$PropertyObject->set_RequirementStatus($required?$required:'optional');

	my $query2 = "SELECT ?allowed_values
	WHERE { ";
	my $whereclause2 = "";
	foreach my $element(qw(allowed_values)){
		$whereclause2 .= "OPTIONAL {<$PropertyURI> $ns{$element}:$element ?$element} .\n";
	}
	#print STDERR $whereclause2;
	$query2 = $prefixes . $query2 . $whereclause2 . "}";
	my $Q2 = RDF::Query->new( $query2 );
	my $iterator2 = $Q2->execute( $self->model );
	while (my $row = $iterator2->next){
		my $restrictionURI = $row->{allowed_values}->value if $row->{allowed_values};
		next unless $restrictionURI;
		$PropertyObject->add_ValueRange($restrictionURI);
	}
	
	
	return $PropertyObject;

	
}

sub _generatePrefixHeader {
	no strict "refs";
	my $header;
	foreach my $namespace (qw(DCAT
        DCT
        DCTYPE
        FOAF
        RDF
        RDFS
        SKOS
        VCARD
        XSD
	DCTS)) {
		$header = $header . "PREFIX $namespace: <".&$namespace.">\n";
	}
	return $header
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
