package DCAT::Profile;
use strict;
use Carp;
use lib "../";
use DCAT::Base;
use DCAT::NAMESPACES;
use RDF::Trine::Store::Memory;
use vars qw($AUTOLOAD @ISA);

use base 'DCAT::Base';

use vars qw /$VERSION/;
$VERSION = sprintf "%d.%02d", q$Revision: 1.5 $ =~ /: (\d+)\.(\d+)/;


=head1 NAME

DCAT::Profile - a module representing a DCAT Profile

=head1 SYNOPSIS

 use DCAT;
 use DCAT::Profile::Parser;
 use DCAT::Profile;
 
 my $parser = DCAT::Profile::Parser->new(filename => "./ProfileSchema.rdf");
 my $Profile = $parser->parse;  # A DCAT::Profile from a file

 my $Profile2 = DCAT::Profile->new(
		label => 'UBC Thesis Submission Profile',
		title => 'UBC Thesis Submission Profile'
		description => 'the metadata that must be associated with thesis deposition',
		modified => 'May 21, 2014',
                license => 'CC',
                issued => 'May 21, 2014,
    		organization => 'University of British Columbia',
		identifier => 'doi:123.123.123',
		URI => 'http://ubc.ca/library/thesis/metadataprofile.rdf'
 )
 
 my $ProfileClass = DCAT::Profile::Class->new(
    class_type => DCAT."dataset",  # DCAT is an exported constant
    URI => "http://datafairport.org/examples/ProfileSchemas/DCATDatasetExample.rdf",
   );

 my $TitleProperty = DCAT::Profile::Property->new(
    property_type => DCT.'title', # DCT is an exported constant
    allow_multiple => "false",
 );
 $TitleProperty->set_RequirementStatus('required');
 $TitleProperty->add_ValueRange(XSD."string");
 $ProfileClass->add_Property($TitleProperty);


 my $DescrProperty = DCAT::Profile::Property->new(
    property_type => DCT.'description',
    allow_multiple => "false",
 );
 $DescrProperty->set_RequirementStatus('required');
 $DescrProperty->add_ValueRange(XSD."string"); # XSD is an exported constant
 $ProfileClass->add_Property($DescrProperty);

 $Profile2->add_Class($DCATDatasetClass);

 my $profileRDF =  $Profile2->serialize;
 open(OUT, ">ProfileSchema.rdf") or die "$!\n";
 print OUT $schema;
 close OUT;

 
=cut

=head1 DESCRIPTION

DCAT Profiles describe the metadata elements, and constrained values, that should be
associated with a given information entity.  They ARE NOT containers for this metadata,
they only describe what that metadata should look like (meta-meta-data :-) )

This module represents a DCAT Profile, and can be serialized into RDF.
The objects it contains (classes and properties) will tell you what metadata fields
are required/optional, and what possible values they are allowed to contain.

=cut

=head1 AUTHORS

Mark Wilkinson (markw at illuminae dot com)

=cut

=head1 METHODS


=head2 new

 Title : new
 Usage : my $ProfileParser = DCAT::Profile->new();
 Function: Builds a new DCAT::Profile
 Returns : DCAT::Profile
 Args : label => $string
	title => $string
	description => $string
	modified => $date
        license => $string
        issued => $date
    	organization => $string
	identifier => $string
	URI => $URI (optional - a unique URI will be auto-generated)


=cut

=head2 label

 Title : label
 Usage : $label = $Profile->label($label);
 Function: get/set the RDF label for this object when serialized
 Returns : string
 Args : string

=cut

=head2 title

 Title : title
 Usage : $title = $Profile->title($title);
 Function: get/set the title of this Profile
 Returns : string
 Args : string

=cut

=head2 description

 Title : description
 Usage : $desc = $Profile->description($desc);
 Function: get/set the description of this Profile
 Returns : string
 Args : string

=cut


=head2 modified

 Title : modified
 Usage : $date = $Profile->modified($date);
 Function: get/set the modified date of this Profile
 Returns : string  (one day this will be more rigorous!)
 Args : string (one day this will be more rigorous!)

=cut


=head2 issued

 Title : issued
 Usage : $date = $Profile->issued($date);
 Function: get/set the created/issued date of this Profile
 Returns : string  (one day this will be more rigorous!)
 Args : string (one day this will be more rigorous!)

=cut



=head2 organization

 Title : organization
 Usage : $name = $Profile->organization($name);
 Function: get/set the organization who created this Profile
 Returns : string  (should probably be a URI... one day)
 Args : string  (should probably be a URI... one day)

=cut


=head2 identifier

 Title : identifier
 Usage : $id = $Profile->identifier($id);
 Function: get/set the unique identifier for this Profile
 Returns : string  (should be a URI or a DOI if available)
 Args : string   (should be a URI or a DOI if available)

=cut


=head2 URI

 Title : URI
 Usage : $uri = $Profile->URI($uri);
 Function: get/set the URI for this Profile - the root URI in the RDF
 Returns : string  (should be a URI)
 Args : string   (should be a URI)
 notes:  if this is not supplied, a unique URI will be automatically generated

=cut


=head2 add_Class

 Title : add_Class
 Usage : $Profile->add_Class($Class);
 Function: add a new DCAT::Profile::Class to the Profile
 Returns : boolean (1 for success)
 Args : DCAT::Profile::Class

=cut


=head2 has_class

 Title : has_class
 Usage : $Profile->has_class();
 Function: retrieve all Classes for the profile
 Returns : listref of DCAT::Profile::Class objects
 Args : none
 Note:  the capitalization of the method name
        matches the capitalization of the RDF predicate...

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
		
		URI => [undef, 'read/write'],
		
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
	$self->{URI} = ("http://datafairport.org/sampledata/profileschema/$ug1")  unless $self->{URI};

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
