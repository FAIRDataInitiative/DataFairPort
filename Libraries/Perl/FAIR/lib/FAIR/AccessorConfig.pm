package FAIR::AccessorConfig;



# ABSTRACT: The key/value of the current configuration of the Accessor


use strict;
use warnings;
use Moose;
use RDF::NS '20131205';              # check at compile time

# define common metadata elements here, and their namespaces


my @CDE = qw(
    dcat:contactPoint
    dcat:description
    dcat:distribution
    dcat:frequency
    dcat:identifier
    dcat:keyword
    dcat:landingPage
    dcat:language
    dcat:publisher
    dcat:releaseDate
    dcat:spatial
    dcat:temporal
    dcat:theme
    dcat:license
    dc:title
    dcat:updateDate
    void:entities
    daml:has-Technical-Lead
    daml:has-Administrative-Contact
    daml:has-Program-Manager
    daml:has-Principle-Investigator
    
    ldp:contains

);

has 'title' => (
    isa => 'Str',
    is  => 'rw',
    required => "yes",
);

has 'serviceTextualDescription' => (
    isa => 'Str',
    is => 'rw'
);

has 'textualAccessibilityInfo' => (
    isa => 'Str',
    is => 'rw',
);

has 'mechanizedAccessibilityInfo' => (
    isa => 'Str',
    is => 'rw',
);

has 'textualLicenseInfo' => (
    isa => 'Str',
    is => 'rw',
);

has 'mechanizedLicenseInfo' => (
    isa => 'Str',
    is => 'rw',
);

has 'basePATH' => (
    isa => 'Str',  # string representing a regular expression to be applied against $ENV{PATH_INFO}
    is => 'rw',
);

has 'localNamespaces' => (
    isa => 'HashRef',
    is => 'rw',
);

has 'localMetadataElements' => (
    isa => 'ArrayRef[Str]',
    is => 'rw',
);

has 'Namespaces' => (
    isa => "RDF::NS",
    is => "rw",
    default => sub {return RDF::NS->new('20131205')}
);

has 'ETAG_Base' => (
    isa => "Str",
    is => "rw",
);

has 'MetadataElements' => (
    isa => 'ArrayRef[Str]',
    is => 'rw',
);



	

sub BUILD {
    my ($self) = @_;
    my $NS = $self->Namespaces; 
    die "can't set namespace $!\n" unless ($NS->SET(ldp => 'http://www.w3.org/ns/ldp#'));
    die "can't set namespace $!\n" unless ($NS->SET(daml => "http://www.ksl.stanford.edu/projects/DAML/ksl-daml-desc.daml#"));
    die "can't set namespace $!\n" unless ($NS->SET(edam => "http://edamontology.org/"));
    die "can't set namespace $!\n" unless ($NS->SET(sio => "http://semanticscience.org/resource/"));
    die "can't set namespace $!\n" unless ($NS->SET(example => 'http://example.org/ns#'));

    foreach my $abbreviation(keys %{$self->localNamespaces()}){
	my $namespace = $self->localNamespaces()->{$abbreviation};
        unless ($NS->SET($abbreviation => $namespace)){
	    print STDERR  "Failed to set namespace $abbreviation  ==  $namespace   Make sure your abbreviation has no capital letters (Perl library quirk!)";
	}
    }
    my @MetaDataElements = (@CDE, @{$self->localMetadataElements()});
    $self->MetadataElements(\@MetaDataElements);  # concatinate local with common metadata elements
    
}

1;
