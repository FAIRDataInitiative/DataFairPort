package FAIR::Accessor;




# ABSTRACT: all this does is assign the HTTP call to the correct routine



use base 'FAIR::AccessorBase';

#  for testing at the command-line...
unless ($ENV{REQUEST_METHOD}){  # if running from command line

    if ($ARGV[0]) {  # if there are any user-supplied arguments
        $ENV{REQUEST_METHOD} = $ARGV[0];
        $ENV{'SERVER_NAME'} = $ARGV[1] ;
        $ENV{'REQUEST_URI'} = $ARGV[2];
        $ENV{'SCRIPT_NAME'} = $ARGV[2];
        $ENV{'PATH_INFO'} = $ARGV[3] ;
    } else {
        $ENV{REQUEST_METHOD} = "GET";
        $ENV{'SERVER_NAME'} =  "example.net";
        $ENV{'REQUEST_URI'} = "/SemanticPHIBase/Metadata";
        $ENV{'SCRIPT_NAME'} = "/SemanticPHIBase/Metadata";
        $ENV{'PATH_INFO'} = "/INT_00000";
    }
}


sub handle_requests {

    my $self = shift;
    my $base = $self->Configuration->basePATH();  # $base is a regular expression that separates the "path" from the "id" portion of the PATH_INFO environment variable
    $base ||= "";
    # THIS ROUTINE WILL BE SHARED BY ALL SERVERS
    if ($ENV{REQUEST_METHOD} eq "HEAD") {
        $self->manageHEAD();
        exit;
    } elsif ($ENV{REQUEST_METHOD} eq "OPTIONS"){
        $self->manageHEAD();
        exit;
    }  elsif ($ENV{REQUEST_METHOD} eq "GET") {
        unless ($ENV{'REQUEST_URI'} =~ /$base/){
            print "Status: 500\n"; 
            print "Content-type: text/plain\n\nThe configured basePATH argument $base does not match the request URI  $ENV{'REQUEST_URI'}\n\n";
            exit 0;
        }
        my $id = $ENV{'PATH_INFO'};
        $id =~ s/^\///;  # get rid of leading /
        
        if ($id) {  #$ENV{'PATH_INFO'} this is a request like  /Allele/dip21  where the user is asking for a specific individual
                $self->printResourceHeader();
                $self->manageResourceGET('ID' => $id);
        } else {  # this is a request like /Allele  or /Allele/  where the user is asking for the container
                $self->printContainerHeader();
                $self->manageContainerGET();
        }
    } else {
        print "Status: 405 Method Not Allowed\n"; 
        print "Content-type: text/plain\n\nYou can only request HEAD, OPTIONS or GET from this LD Platform Server\n\n";
        exit 0;
    }

}



=head1 NAME

    FAIR::Accessor - Module for creating Linked Data Platform Accessors for the FAIR Data project

=head1 SYNOPSIS

The following code is a complete implementation of a 'Hello, World!' FAIR Accessor


 C<##!/usr/local/bin/perl -w

 package Metadata;

 use strict;
 use warnings;
 use JSON;
 use FAIR::Accessor;

 #-----------------------------------------------------------------
 # Configuration and Daemon
 #-----------------------------------------------------------------

 use base 'FAIR::Accessor';

 my $config = {
   title => 'Semantic PHI Base Metadata Server',
   ETAG_Base => "TopLevelMetadata_Accessor_For_SemanticPHIBase", # this is a unique identificaiton string for the service (required by the LDP specification)
   localNamespaces => {
	ontology => 'http://example.org/ontologies/MyOntology#', 
	},  # add a few new namespaces to the list of known namespaces....
   localMetadataElements => [qw(hw:Greeting hw2:grusse) ],  # things that we use in addition to common metadata elements
   basePATH => 'Nameof/ThisScript', # REQUIRED regexp to match the RESTful PATH part of the URL, before the ID number

 };

 my $service = Metadata->new(%$config);

 # start daemon
 $service->handle_requests;


 #-----------------------------------------------------------------
 # Accessor Implementation
 #-----------------------------------------------------------------

 
 =head2 MetaContainer
  Function: REQUIRED SUBROUTINE - returns the first-stage LD Platform list of contained URIs and the dataset metadata.
  Args    : $starting_at_record : this will be passed-in to tell you what record to start with (for paginated responses)
  $path : the webserver's PATH_INFO environment value (used to modify the behaviour of REST services)
  Returns : JSON encoded listref of 'meta URIs' representing individual records
  Note    :  meta URIs are generally URIs that point back to this same server; calling GET on a meta URI will
            return an RDF description of the set of DCAT distributions for that record.
            The format of the JSON response is as follows:
            
            {"metadata:element1" : "some value",
             "external:metadatatype":  "some other value",
             "void:entities" : "3",
             "ldp:contains" : ["http://myserver.org/ThisScript/record/479-467-29",
                               "http://myserver.org/ThisScript/record/479-467-32",
                               "http://myserver.org/ThisScript/record/479-467-434"
                               ]
            }
            
            Recommended metadata elements include dc:title, dcat:description,dcat:identifier,
            dcat:keyword,dcat:landingPage,dcat:publisher,dcat:theme
            
            note #1:  Using dcat:theme requires you to create a SKOS concept scheme of the various ontology
            terms that describe the data in your repository... this isn't hard, but it's not entirely trivial either...
            
            note #2:  if you return URLs in the ldp:contains, then you must also return the count of those URLs in void:entities
 =cut
 
 
 sub MetaContainer {

   my ($self, %ARGS) = @_;

   # this is how you would manage "RESTful" references to different subsets of your data repository
   #if ($ENV{'REQUEST_URI'} =~ /DataSliceX/) {
   #    # some behavior for Data Slice X
   #} elsif ($ENV{'REQUEST_URI'} =~ /DataSliceY/) {
   #    # some behavior for Data Slice Y
   #}
 
   my $metadata =  $self->getRepositoryMetadata();

  # you may chose to return no record IDs at all, if you only want to serve repository-level metadata
   
   my $BASE_URL = "http://" . $ENV{'SERVER_NAME'} . $ENV{'REQUEST_URI'};

   my @known_records = ('http://example.org/Nameof/ThisScript/123');  # generate a list of HTTP records
   # note that the record URLs point to this script!
   
   # these two pieces of metadata are required by the LDP specification
   $metadata->{'void:entities'} = scalar(@known_records);  #  THE TOTAL *NUMBER* OF RECORDS THAT CAN BE SERVED
   $metadata->{'ldp:contains'} = \@known_records; # the listref of record ids

   return encode_json($metadata);

 }

 


 =head2 Distributions

  Function: REQUIRED IF get_all_meta_URIs list of URIs point back to this script.
           returns the second-stage LD Platform metadata describing the DCAT distributions, formats, and URLs
           for a particular record
  Args    : $ID : the desired ID number, as determined by the Accessor.pm module
           $PATH_INFO : the webserver's PATH_INFO environment value (in case the $ID best-guess is wrong... then you're on your own!)
  Returns : JSON encoded hashref of 'meta URIs' representing individual DCAT distributions and their mime-type (mime-type is key)
            The format for this response is (you are always allowed to use lists as values if you wish):
            
            {"metadata":
                {"rdf:type": ["edam:data_0006","sio:SIO_000088"]
                 "my:metadatathingy":  "some value",
                 "external:metadatatype":  "some other value"
                },
            "distributions":
                {"application/rdf+xml" : "http://myserver.org/ThisScript/record/479-467-29X.rdf",
                 "text/html" : "http://myserver.org/ThisScript/record/479-467-29X.html"
                }
            }

 =cut


 sub Distributions {
   my ($self, %ARGS) = @_;

   my $ID = $ARGS{'ID'};
   # ID is the piece of the URL that comes after http://example.org/Nameof/ThisScript/___here____
   # you created these URLs in the MetaContainer routine above
   my %response;
   my %formats;
   my %metadata;

   # using the $ID, create the links to the actual records, in whatever format...
   my $accnumber = $ID;  # maybe transform ID to get the accession
   
   # make the links to teh text and RDF versions of this record
   $formats{'text/html'} = "http://example.org/query.php?acc=$accnumber";
   $formats{'application/rdf+xml'} = "http://example.org/Resource/$ID";

   # set the ontological type for the record  (optional)
   $metadata{'rdf:type'} = ['ontology:PHIBO_00022'];  # note the qNAME!  If you have defined 'ontology' in the $config hashref at the beginning, you can use a qname here

   # and whatever other metadata you wish (also optional)
   my $metadata	= $self->getDistributionMetadata($accnumber);

   $response{distributions} = \%formats;
   $response{metadata} = $metadata if (keys %$metadata);  # only set it if you can provided something

   my $response  = encode_json(\%response);

   return $response;

 }

 sub getRepositoryMetadata {
   my %metadata = (
   'dc:title' => "Semantic PHI Base Accessor",
   'dcat:description' => "FAIR Accessor server for the Semantic PHI Base.  This server exposes the plant portion of the Pathogen Host Interaction database as Linked Data, following the FAIR Data Principles. This interface (the one you are reading) follows the W3C Linked Data Platform behaviors.   The data provided here is an RDF transformation of data kindly provided by the researchers at PHI Base (doi:10.1093/nar/gku1165)",
   'dcat:identifier' => "http://linkeddata.systems/SemanticPHI/Metadata",
   'dcat:keyword' => ["pathogenesis", "plant/pathogen interactions", "PHI Base", "semantic web", "linked data", "FAIR Data", "genetic database", "phytopathology"],
   'dcat:landingPage' => 'http://www.phi-base.org/',
   'foaf:page' => ['http://linkeddata.systems:8890/sparql','http://www.phi-base.org/'],
   'dcat:language' => 'http://id.loc.gov/vocabulary/iso639-1/en',
   'dc:language' => 'http://lexvo.org/id/iso639-3/eng', 
   'dcat:publisher' => ['http://wilkinsonlab.info',"Rothamsted Research", ' http://www.rothamsted.ac.uk', 'http://www.phi-base.org'],
   'dcat:theme'  => 'http://linkeddata.systems/ConceptSchemes/semanticphi_concept_scheme.rdf',  # this is the URI to a SKOS Concept Scheme
  'daml:has-Technical-Lead' => ["Dr. Alejandro Rodriguez Gonzalez","Alejandro Rodriguez Iglesias"],
  'daml:has-Principle-Investigator' => ["Dr. Mark Wilkinson","Dr. Kim Hammond-Kosack"],
  'dc:creator' => 'http://www.phi-base.org/',
  'pav:authoredBy' => ['http://orcid.org/0000-0002-9699-485X','http://orcid.org/0000-0002-6019-7306'],
  'dcat:contactPoint' => 'http://biordf.org/DataFairPort/MiscRDF/Wilkinson.rdf',
  'dcat:license' => 'http://purl.org/NET/rdflicense/cc-by-nd4.0',
  'dc:license' => 'http://purl.org/NET/rdflicense/cc-by-nd4.0',
  'dc:issued' => "2015-11-17", 
  'rdf:type' => ['prov:Collection', 'dctypes:Dataset'],
   );
   return \%metadata;
   
 } 

 sub getDistributionMetadata {
  my ($self, $ID) = @_;
  my %metadata = (
        'dcat:description' => "RDF representation of PHI Base Interaction Record PHI:$ID",
        'dc:title' => "PHI-Base Interaction PHI:$ID",
        'dcat:modified' => "2015-11-17", 
        'dc:issued' => "2015-11-17", 
        'dcat:identifier' => "http://linkeddata.systems/SemanticPHI/Metadata",
        'dcat:keyword' => ["pathogenesis", "host/pathogen interaction", "PHI Base"],
        'dcat:landingPage' => ['http://www.phi-base.org/'],
   	'foaf:page' => 'http://linkeddata.systems:8890/sparql',
   	'foaf:page' => 'http://www.phi-base.org/',
        'dcat:language' => 'http://id.loc.gov/vocabulary/iso639-1/en',
   	'dcat:publisher' => ['http://wilkinsonlab.info',"Rothamsted Research", 'http://www.rothamsted.ac.uk', 'http://www.phi-base.org'],
        'daml:has-Technical-Lead' => ["Dr. Alejandro Rodriguez Gonzalez", "Alejandro Rodriguez Iglesias"],
        'daml:has-Principle-Investigator' => ["Dr. Mark Wilkinson","Dr. Kim Hammond-Kosack"],
        'dcat:contactPoint' => 'http://biordf.org/DataFairPort/MiscRDF/Wilkinson.rdf',
        'void:inDataset' => 'http://linkeddata.systems/SemanticPHIBase/Metadata',
	'dcat:license' => 'http://purl.org/NET/rdflicense/cc-by-nd4.0',
  	'dc:license' => 'http://purl.org/NET/rdflicense/cc-by-nd4.0',
	'dc:creator' => 'http://www.phi-base.org/',
  	'pav:authoredBy' => ['http://orcid.org/0000-0002-9699-485X', 'http://orcid.org/0000-0002-6019-7306'],
	);
  return \%metadata;
 }



>

=head1 DESCRIPTION

FAIR Accessors are an implementation of the W3Cs Linked Data Platform.

FAIR Accessors follow a two-stage interaction, where the first stage
retrieves metadata about the repository, and (optionally) a series of URLs representing
'meta-records' for every record in that repository (or whatever slice of the repository
is being served). This is accomplished by the B<MetaContainer> subroutine.  These URLs
will generally point back at this same Accessor script (e.g. with the
record number appended to the URL:  I<http://this.host/thisscript/12345>).

The second stage involves retrieving metadata about individual recoreds.
The metadata is up to you, but optimally it would include the available
DCAT distributions and their file formats.  The second stage can be accomplished
by this same Accessor script, using the Distributions subroutine.

The two subroutine names - B<MetaContainer>  and  B<Distributions> - are not flexible, as they are
called by-name, by the Accessor libraries.

You B<MUST> create the B<MetaContainer> subroutine, at a minimum, and it should return some metadata.
It does not have to return a list of known records (in which case it simply acts as a metadata
descriptor of the repository in general, nothing more... which is fine!... and there will be no
second stage interaction.  In this case, you do not need to provide a B<Distributions> subroutine.)


=cut


=head1 Command-line testing

If you wish to test your Accessor server at the command line, you can run it with the following commandline arguments (in order):

 Method (always GET, at the moment)
 Domain
 Request URI (i.e. the path to this script, including the script name)
 PATH_INFO  (anything that should appear in the PATH_INFO variable of the webserver)

  perl  myAccessorScript  GET  example.net  /this/myAccessorScript /1234567

=cut



1;
