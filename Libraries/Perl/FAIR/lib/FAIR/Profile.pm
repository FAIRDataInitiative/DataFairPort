package FAIR::Profile;


# ABSTRACT: the base class representing a FAIR Profile.  Everything else is attached to this

use Moose;
use strict;
use Carp;
use base 'FAIR::Base';
use FAIR::NAMESPACES;
use FAIR::Profile::Class;
use FAIR::Profile::Property;
use RDF::Trine::Store::Memory;



=head1 NAME


FAIR::Profile - a module representing a DCAT Profile.


=head1 SYNOPSIS

 use FAIR;
 use FAIR::Profile::Parser;
 use FAIR::Profile;
 
 my $parser = FAIR::Profile::Parser->new(filename => "./ProfileSchema.rdf");
 my $Profile = $parser->parse;  # A DCAT::Profile from a file

 my $Profile2 = FAIR::Profile->new(
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
 
 my $ProfileClass = FAIR::Profile::Class->new(
    class_type => FAIR."dataset",  # DCAT is an exported constant
    URI => "http://datafairport.org/examples/ProfileSchemas/DCATDatasetExample.rdf",
   );

 my $TitleProperty = FAIR::Profile::Property->new(
    property_type => DCT.'title', # DCT is an exported constant
    allow_multiple => "false",
 );
 $TitleProperty->set_RequirementStatus('required');
 $TitleProperty->add_ValueRange(XSD."string");
 $ProfileClass->add_Property($TitleProperty);


 my $DescrProperty = FAIR::Profile::Property->new(
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

DCAT Profiles are not part of the official DCAT specification, but the idea was raised
by the DCAT working group as something that might be useful... it
certainly is!
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


has URI => (
	is => 'rw',
	isa => "Str",
	builder => '_generate_URI',
	);

has type => (
	is => 'rw',
	isa => 'ArrayRef[Str]',
	traits => [qw/Serializable/],  # it is, but it is handled differently than most serializable traits
	default => sub {[FAIR.'FAIRProfile', DC.'ProvenanceStatement']},
	);

has hasClass => (
	is => 'rw',
	isa => 'FAIR::Profile::Class',
	traits => [qw/Serializable/],   # THIS attribute is mirror-image, so if you try to serialize it you get an infinite loop
	writer => '_add_Class',
	);

has label => (
	is => 'rw',
	isa => "Str",
	default => 'FAIR Profile Descriptor',
	traits => [qw/Serializable/],
	);

has title => (
	is => 'rw',
	isa => "Str",
	traits => [qw/Serializable/],
	);

has description => (
	is => 'rw',
	isa => "Str",
	traits => [qw/Serializable/],
	);

has license => (
	is => 'rw',
	isa => "Str",
	traits => [qw/Serializable/],
	);

has organization => (
	is => 'rw',
	isa => "Str",
	traits => [qw/Serializable/],
	);

has identifier => (
	is => 'rw',
	isa => "Str",
	traits => [qw/Serializable/],
	);

has schemardfs_URL => (
	is => 'rw',
	isa => "Str",
	traits => [qw/Serializable/],
	default => FAIR,
	);

sub _generate_URI {
	my ($self, $newval) = @_;
	return $newval if $newval;
	
	my $ug = UUID::Generator::PurePerl->new();  
	my $ug1 = $ug->generate_v4()->as_string;
	return "http://datafairport.org/sampledata/profileschemaprofile/$ug1";
}


sub add_Class {   
	my ($self, $class) = @_;
	die "not a FAIR Profile Schema Class *$class->type*" unless (FAIR.'FAIRClass' ~~ $class->type);
	$class->provenance($self);
	#my $classes = $self->hasClass;
	#push @$classes, $class;
	$self->_add_Class($class);
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


1;
