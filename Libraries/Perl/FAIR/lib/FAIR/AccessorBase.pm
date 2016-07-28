package FAIR::AccessorBase;
use lib "../";



# ABSTRACT: The core Accessor functions


use Moose;
use URI::Escape;
use JSON;
use FAIR::AccessorConfig;
use RDF::Trine::Parser 0.135;
use RDF::Trine::Model 0.135;
use RDF::Trine::Statement 0.135;
use RDF::Trine::Node::Resource;
use RDF::Trine::Node::Literal;
use Scalar::Util 'blessed';
use Log::Log4perl;


with 'FAIR::CoreFunctions';

has 'Configuration' => (
    isa => 'FAIR::AccessorConfig',
    is => 'rw',
);


around BUILDARGS => sub {
      my %return;
      $return{'Configuration'} = FAIR::AccessorConfig->new(@_);
      return \%return;
  };





# ============================================
#  All Daemons must implement this method

sub get_all_meta_URIs {
	my ( @args ) = @_;

	# user-specific implementation will override this method
}

# ============================================
#  Some Daemons may implement this method

sub get_distribution_URIs {
	my ( @args ) = @_;

	# user-specific implementation will override this method
}

# =============================================



# ===============  STAGE 1 Subroutines

sub manageContainerGET {
    my ($self, %args) = @_;  # %args  are PATH => '/some/path'
    
    unless ($ENV{'SCRIPT_NAME'}) {print STDERR "your servers implementation of CGI does not capture the SCRIPT_NAME; defaulting to REQUEST_URI!";}
    my $SCRIPT_NAME = $ENV{'SCRIPT_NAME'}?$ENV{'SCRIPT_NAME'}:$ENV{REQUEST_URI};  # best guess!  
    $SCRIPT_NAME =~ s/^\///;   # if it is there, get rid of the leading /
    
    my $BASE_URL = "http://" . $ENV{'SERVER_NAME'} . "/$SCRIPT_NAME";
    $BASE_URL .= $ENV{'PATH_INFO'}  if $ENV{'PATH_INFO'} ;
    my $store = RDF::Trine::Store::Memory->new();
    my $model = RDF::Trine::Model->new($store);
    my $ns = $self->Configuration->Namespaces;
        
    $self->callMetadataAccessor($BASE_URL, $model);  

    my $statement = statement($BASE_URL, $ns->rdf("type"), $ns->ldp("BasicContainer")); 
    $model->add_statement($statement);
    
    unless ($model->count_statements(RDF::Trine::Node::Resource->new($BASE_URL), RDF::Trine::Node::Resource->new($ns->dc("title")))){
      $statement = statement($BASE_URL, $ns->dc("title"), $self->Configuration->{'title'}); 
      $model->add_statement($statement); 
    }
    $self->serializeThis($model);

}

sub makeSensibleStatement {
      my ($self, $subject, $predicate, $obj) = @_;
      my $NS = $self->Configuration->Namespaces();
      my ($ns, $pred) = split /:/, $predicate;
      my $statement;
      if (($obj =~ /^http:/) || ($obj =~ /^https:/)) {  # if its a URL
            $statement = statement($subject,  $NS->$ns($pred), $obj); 
      } elsif ((!($obj =~ /\s/)) && ($obj =~ /\S+:\S+/)){  # if it looks like a qname tag
            my ($vns,$vobj) = split /:/, $obj;
            if ($NS->$vns($vobj)) {
                  $statement = statement($subject,  $NS->$ns($pred), $NS->$vns($vobj));                   
            } else {
                  $statement = statement($subject,  $NS->$ns($pred), $obj); 
            }                             
      } else {
            $statement = statement($subject,  $NS->$ns($pred), $obj); 
      }
      return $statement;
      
}


sub callMetadataAccessor {
      my ($self, $subject, $model) = @_;
      
      my ($result, $more) = $self->MetaContainer(); # this subroutine is provided by the end-user in the Accessor script on the web
      
      if (blessed($result) && $result->isa("RDF::Trine::Model")) {  # if they are doing this, they know what they are doing!  (we assume)
            my $iterator = $result->statements;
            while (my $stm = $iterator->next()) {
                 $model->add_statement($stm);
            }
            
      }
      else {
      
            $result = decode_json($result);
            
            $model->begin_bulk_ops();
            
            foreach my $CDE(keys %$result){
        
              next unless $result->{$CDE}; 
              my $statement;
              my $values = $result->{$CDE};
              $values = [$values] unless (ref($values) =~ /ARRAY/);
              my $temprdf;  # doing this to make the import more efficient... I hope!
              foreach my $value(@$values){
                    $statement = $self->makeSensibleStatement($subject, $CDE, $value);
                    my $str = $statement->as_string;  # almost n3 format... need to fix it a bit...
                    $str =~ s/^\(triple\s//;
                    $str =~ s/\)$/./;
                    $temprdf .= "$str\n";  # this is RDF in n3 format
              }
              my $parser     = RDF::Trine::Parser->new( 'ntriples' );
              $parser->parse_into_model( "http://example.org/", $temprdf, $model );
         
            }
            $model->end_bulk_ops();
            
            # this code allows you to constrain the metadata... I don't like this idea anymore...
            #foreach my $CDE(@{$self->Configuration->MetadataElements}){  # common metadata, plus locally specified metadata elements
            #    next unless $result->{$CDE};  # this will reject any metadata that you didn't specify in the configuration
            #    my ($namespace, $term) = split /:/, $CDE;
            #    
            #    if (ref($result->{$CDE}) =~ /ARRAY/) {
            #        foreach (@{$result->{$CDE}}){
            #            my $statement = statement($subject, $ns->$namespace($term), $_); 
            #            $model->add_statement($statement);
            #        }
            #    } else {                    
            #        my $statement = statement($subject,$ns->$namespace($term), $result->{$CDE}); 
            #        $model->add_statement($statement);
            #    }
          #}
      }
      if ($more && blessed($more) && $more->isa("RDF::Trine::Model")) {  # if they are doing this, they know what they are doing!  (we assume)
            my $iterator = $more->statements;
            while (my $stm = $iterator->next()) {
                 $model->add_statement($stm);
           }
      }            

}
# ====================== END OF STAGE1 SUBROUTINES




# ==================  Stage 2 subroutines =============

sub manageResourceGET {  # $self->manageResourceGET('PATH' => $path, 'ID' => $id);
    my ($self, %ARGS) = @_;
    my $ID = $ARGS{'ID'};
    
    my $store = RDF::Trine::Store::Memory->new();
    my $model = RDF::Trine::Model->new($store);
          
    $self->callDataAccessor($model, $ID);

    $self->serializeThis($model);

}


sub callDataAccessor {
    my ($self, $model, $ID) = @_;

      # call out to user-provided subroutine
    my ($result, $projections) = $self->Distributions('ID' => $ID);
    $result = decode_json($result);

    my $URL = "http://" . $ENV{'SERVER_NAME'} . $ENV{'REQUEST_URI'};
    my $NS = $self->Configuration->Namespaces();

    my $distributions = $result->{'distributions'};
      foreach my $format(keys %$distributions){
            next unless ($format =~ /\S/);
            my $location = $distributions->{$format};
            $location = [$location] unless (ref($location) =~ /ARRAY/);  # force it to be always be an arrayref just for code clarity
            
            foreach my $loc(@$location){
                  next unless ($loc =~ /\S/);
                  my $statement = statement($URL, $NS->dcat('distribution'), $loc);
                  $model->add_statement($statement);
                  
                  $statement = statement($loc, $NS->rdf('type'), $NS->dcat('Distribution'));
                  $model->add_statement($statement);
                  
                  $statement = statement($loc, $NS->rdf('type'), $NS->dctypes('Dataset'));
                  $model->add_statement($statement);

                  $statement = statement($loc, $NS->dc('format'), $format);
                  $model->add_statement($statement);

                  if (($format =~ /turtle/) || ($format =~ /rdf/) || ($format =~ /quads/)) {
                        $statement = statement($loc, $NS->rdf('type'), $NS->void('Dataset'));
                        $model->add_statement($statement);
                  }
                  
            
                  $statement = statement($loc, $NS->dcat('downloadURL'), $loc);
                  $model->add_statement($statement);
            }
      }
                   
        
      my $metadata = $result->{'metadata'};
      if ($metadata && keys %$metadata) {
      
            foreach my $predicate(keys %$metadata){
                  my $values = $metadata->{$predicate};
                  $values = [$values] unless (ref($values) =~ /ARRAY/);
                                    
                  foreach my $value(@$values) {
                        my $statement = $self->makeSensibleStatement($URL, $predicate, $value);
                        $model->add_statement($statement);                               
                  }
            }
      }
      if ($projections && blessed($projections) && $projections->isa("RDF::Trine::Model")) {  # if they are doing this, they know what they are doing!  (we assume)
            $model->add_iterator($projections->as_stream);
      }


      # okay, $model is now full!
}



sub printResourceHeader {
	my ($self) = @_;
        my $ETAG = $self->Configuration->ETAG_Base();
	my $entity = $ENV{'PATH_INFO'};
	$entity =~ s/^\///;
#	print "Content-Type: text/turtle\n";
	print "Content-Type: application/rdf+xml\n";
	print "ETag: \"$ETAG"."_"."$entity\"\n";
	print "Allow: GET,OPTIONS,HEAD\n";
	print 'Link: <http://www.w3.org/ns/ldp#Resource>; rel="type"'."\n\n";

}

sub printContainerHeader {
	my ($self) = @_;
        my $ETAG = $self->Configuration->ETAG_Base();
#	print "Content-Type: text/turtle\n";
	print "Content-Type: application/rdf+xml\n";
	print "ETag: \"$ETAG\"\n";
	print "Allow: GET,OPTIONS,HEAD\n";
	print 'Link: <http://www.w3.org/ns/ldp#BasicContainer>; rel="type",'."\n";
	print '      <http://www.w3.org/ns/ldp#Resource>; rel="type"'."\n\n";
	#    print "Transfer-Encoding: chunked\n\n";

}

sub manageHEAD {
	my ($self) = @_;
        my $ETAG = $self->Configuration->ETAG_Base();
	
	print "Content-Type: text/turtle\n";
	print "ETag: \"$ETAG\"\n";
	print "Allow: GET,OPTIONS,HEAD\n\n";
	print 'Link: <http://www.w3.org/ns/ldp#BasicContainer>; rel="type",'."\n";
	print '      <http://www.w3.org/ns/ldp#Resource>; rel="type"'."\n\n";
    
}

sub serializeThis{
    my ($self, $model) = @_;
#    my $serializer = RDF::Trine::Serializer->new('turtle');  # the turtle serializer is simply too slow to use...
    my $serializer = RDF::Trine::Serializer->new('rdfxml');  # TODO - this should work with content negotiation
    print $serializer->serialize_model_to_string($model);
}



#
## returns the request content type
## defaults to application/rdf+xml
#sub get_request_content_type {
#	my ($self) = @_;
#    my $CONTENT_TYPE = 'application/rdf+xml';
#    if (defined $ENV{CONTENT_TYPE}) {
#        $CONTENT_TYPE = 'text/rdf+n3' if $ENV{CONTENT_TYPE} =~ m|text/rdf\+n3|gi;
#        $CONTENT_TYPE = 'text/rdf+n3' if $ENV{CONTENT_TYPE} =~ m|text/n3|gi;
#        $CONTENT_TYPE = 'application/n-quads' if $ENV{CONTENT_TYPE} =~ m|application/n\-quads|gi;
#        
#    }
#    return $CONTENT_TYPE;
#}
#
## returns the response requested content type
## defaults to application/rdf+xml
#sub get_response_content_type {
#    my ($self) = @_;
#    my $CONTENT_TYPE = 'application/rdf+xml';
#    if (defined $ENV{HTTP_ACCEPT}) {
#        $CONTENT_TYPE = 'text/rdf+n3' if $ENV{HTTP_ACCEPT} =~ m|text/rdf\+n3|gi;
#        $CONTENT_TYPE = 'text/rdf+n3' if $ENV{HTTP_ACCEPT} =~ m|text/n3|gi;
#        $CONTENT_TYPE = 'application/n-quads' if $ENV{HTTP_ACCEPT} =~ m|application/n\-quads|gi;
#        
#    }
#    return $CONTENT_TYPE;
#}


1;
