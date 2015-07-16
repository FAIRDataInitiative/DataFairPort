package FAIR::Accessor;
$FAIR::Accessor::VERSION = '0.216';



# ABSTRACT: all this does is assign the HTTP call to the correct routine



#use lib "../";
use base 'FAIR::AccessorBase';
#
#unless ($ENV{REQUEST_METHOD}){  # if running from command line
#        $ENV{REQUEST_METHOD} = "GET";
#        $ENV{'REQUEST_URI'} = "/this/thing";
#        $ENV{'SERVER_NAME'} = "example.net";
#	$ENV{'PATH_INFO'} = "/479-467-29X";
#}

sub handle_requests {

    my $self = shift;
    
    # THIS ROUTINE WILL BE SHARED BY ALL SERVERS
    if ($ENV{REQUEST_METHOD} eq "HEAD") {
        $self->manageHEAD();
        exit;
    } elsif ($ENV{REQUEST_METHOD} eq "OPTIONS"){
        $self->manageHEAD();
        exit;
    }  elsif ($ENV{REQUEST_METHOD} eq "GET") {
            if ($ENV{'PATH_INFO'}) {  # this will never happen with the minimal server
                    $self->printResourceHeader();
                    $self->manageResourceGET();
            } else {
                    $self->printContainerHeader();
                    $self->manageContainerGET();
            }
    } else {
        print "Status: 405 Method Not Allowed\n"; 
        print "Content-type: text/plain\n\nYou can only request HEAD, OPTIONS or GET from this LD Platform Server\n\n";
        exit 0;
    }

}








1;

__END__

=pod

=encoding UTF-8

=head1 NAME

FAIR::Accessor - all this does is assign the HTTP call to the correct routine

=head1 VERSION

version 0.216

=head1 SYNOPSIS

The following code is a complete implementation of a 'Hello, World!' FAIR Accessor

 #!/usr/bin/perl -w

 package HelloWorld_Accessor;  # this should be the same as your filename!

 use strict;
 use warnings;
 use JSON;


 #-----------------------------------------------------------------
 # Configuration and Daemon
 #-----------------------------------------------------------------

 use base 'FAIR::Accessor';

 my $config = {
    title => 'Hello World Data Accessor',
    serviceTextualDescription => 'Server for some Helloworld Data',
    textualAccessibilityInfo => "The information from this server requries no authentication",  # this could also be a $URI describing the accessibiltiy
    mechanizedAccessibilityInfo => "",  # this must be a URI to an RDF document
    textualLicenseInfo => "CC-BY",  # this could also be a URI to the license info
    mechanizedLicenseInfo =>  "", # this must be a URI to an RDF document
    baseURI => "", # I don't know what this is used for yet, but I have a feeling I will need it!
    ETAG_Base => "HelloWorld_Accessor_For_Greetings", # this is a unique identificaiton string for the service (required by the LDP specification)
    localNamespaces => {hw => 'http://hello.world.org/some/items/',
                        hw2 => 'http://another.hello.world.org/some/predicates/'},  # add a few new namespaces to the list of known namespaces....
    localMetadataElements => [qw(hw:Greeting hw2:grusse) ],  # things that we use in addition to common metadata elements

 };

 my $service = HelloWorld_Accessor->new(%$config);

 # start daemon
 $service->handle_requests;


 #-----------------------------------------------------------------
 # Accessor Implementation
 #-----------------------------------------------------------------



 =head2 get_all_meta_URIs

  Function: REQUIRED SUBROUTINE - returns the first-stage LD Platform list of contained URIs and the dataset metadata.
  Args    : $starting_at_record : this will be passed-in to tell you what record to start with (for paginated responses)
  $path : the webserver's PATH_INFO environment value (used to modify the behaviour of REST services)
  Returns : JSON encoded listref of 'meta URIs' representing individual records
  Note    :  meta URIs are generally URIs that point back to this same server; calling GET on a meta URI will
            return an RDF description of the set of DCAT distributions for that record.\
            this can be handled by the

 =cut

 sub get_all_meta_URIs {

    my ($starting_at_record, $path_info) = @_;
    $path_info ||="";
    
    my %result =  (  # NOTE THAT ALL OF THESE ARE OPTIONAL!  (and there are more fields.... see DCAT...)
                    'dc:title' => "Hello World Accessor Server",
                   'dcat:description' => "the prototype Accessor server for Hello World",
                    'dcat:identifier' => "handle:HelloWorld1234567",
                    'dcat:keyword' => ["greetings", "friendly", "welcome", "Hi"],
                    'dcat:landingPage' => 'http://hello.world.net/homepage.html',
                    'dcat:language' => 'en',
                    'dcat:publisher' => 'http://hello.world.net',
                    'dcat:temporal' => 'http://reference.data.gov.uk/id/quarter/2006-Q1',  # look at this!!  It doesn't have to be this complex, but it can be!
                    'dcat:theme'  => 'http://example.org/ConceptSchemes/HelloWorld.rdf',  # this is the URI to a SKOS Concept Scheme
                    );
    my $BASE_URL = "http://" . $ENV{'SERVER_NAME'} . $ENV{'REQUEST_URI'} . $path_info;

   # you may chose to return no record IDs at all, if you only want to serve repository-level metadata     
    my @known_records = ($BASE_URL . "/hello",
                         $BASE_URL . "/world",
                         # ...  you need to generate this list of record URIs here... somehow
                        );
    $result{'void:entities'} = scalar(@known_records);  #  THE TOTAL *NUMBER* OF RECORDS THAT CAN BE SERVED
    $result{'ldp:contains'} = \@known_records; # the listref of record ids
    
    return encode_json(\%result);

 }


 =head2 get_distribution_URIs

  Function: REQUIRED IF get_all_meta_URIs list of URIs point back to this script.
           returns the second-stage LD Platform metadata describing the DCAT distributions, formats, and URLs
           for a particular record
  Args    : $ID : the desired ID number, as determined by the Accessor.pm module
           $PATH_INFO : the webserver's PATH_INFO environment value (in case the $ID best-guess is wrong... then you're on your own!)
  Returns : JSON encoded hashref of 'meta URIs' representing individual DCAT distributions and their formats (format is key)
            The format for this response is:
            
            {"metadata":
                {"rdf:type": ["edam:data_0006","sio:SIO_000088"]
                },
            "distributions":
                {"application/rdf+xml":"http://myserver.org/ThisScript/record/479-467-29X.rdf",
                 "text/html":"http://myserver.org/ThisScript/record/479-467-29X.html"
                }
            }

 =cut


 sub get_distribution_URIs {
    my ($self, $ID, $PATH_INFO) = @_;

    my %response;

    my %formats;
    my %metadata;
    
    $formats{'text/html'} = 'http://myserver.org/ThisScript/helloworld.html';
    $formats{'application/rdf+xml'} = 'http://myserver.org/ThisScript/helloworld.rdf';

    # set the ontological type for the record  (optional)
    $metadata{'rdf:type'} = ['edam:data_0006', 'sio:SIO_000088'];
    
    # and whatever other metadata you wish (also optional)
    # extractMetaDataFromSpreadsheet(\%metadata, $ID);    

    $response{distributions} = \%formats;
    $response{metadata} = \%metadata if (keys %metadata);  # only set it if you can provided something

    my $response  = encode_json(\%response);
    
    return $response;

 }

=head1 DESCRIPTION

FAIR Accessors are an implementation of the W3Cs Linked Data Platform.  FAIR Accessors follow a two-stage interaction model, where the first stage
retrieves a series of URLs representing meta-records for every record in that repository (or whatever slice of the repository is being served).
This is accomplished by the get_all_meta_URIs subroutine.  These URLs will generally point back at this same Accessor script (e.g. with the
record number appended to the URL:  http://this.host/thisscript/12345).

This script then expresses metadata about that record, including the available DCAT distributions and their file formats.  This is
accomplished by the get_distribution_URIs subroutine.

The two subroutine names - get_all_meta_URIs  and  get_distribution_URIs - are not flexible, as they are called by the underlying libraries.

=head1 NAME

    FAIR::Accessor - Module for creating Linked Data Platform Accessors for the FAIR Data project

=head1 AUTHOR

Mark Denis Wilkinson (markw [at] illuminae [dot] com)

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2015 by Mark Denis Wilkinson.

This is free software, licensed under:

  The Apache License, Version 2.0, January 2004

=cut
