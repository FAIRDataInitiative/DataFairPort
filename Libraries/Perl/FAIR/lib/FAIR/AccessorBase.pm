package FAIR::AccessorBase;



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
use Log::Log4perl;



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
    my $PATH = $args{'PATH'};
    
    my $BASE_URL = "http://" . $ENV{'SERVER_NAME'} . $ENV{'REQUEST_URI'};
    $BASE_URL .= $ENV{'PATH_INFO'}  if $ENV{'PATH_INFO'} ;

    my $store = RDF::Trine::Store::Memory->new();
    my $model = RDF::Trine::Model->new($store);
    my $ns = $self->Configuration->Namespaces;
        
    my $statement = statement($BASE_URL, $ns->rdf("type"), $ns->ldp("BasicContainer")); 
    $model->add_statement($statement); 
    $statement = statement($BASE_URL, $ns->dc("title"), $self->Configuration->{'title'}); 
    $model->add_statement($statement); 
    
    $self->callMetadataAccessor($BASE_URL, $PATH, $model);  
    
    $self->serializeThis($model);

}


sub callMetadataAccessor {
    my ($self, $subject, $PATH, $model) = @_;

    
    my $result = $self->MetaContainer('PATH' => $PATH); # this subroutine is provided by the end-user in the Accessor script on the web
    $result = decode_json($result);
    
    
    my $ns = $self->Configuration->Namespaces();
    
    foreach my $CDE(@{$self->Configuration->MetadataElements}){  # common metadata, plus locally specified metadata elements
        next unless $result->{$CDE};  # this will reject any metadata that you didn't specify in the configuration
        my ($namespace, $term) = split /:/, $CDE;
        
        if (ref($result->{$CDE}) =~ /ARRAY/) {
            foreach (@{$result->{$CDE}}){
                my $statement = statement($subject, $ns->$namespace($term), $_); 
                $model->add_statement($statement);
            }
        } else {                    
            my $statement = statement($subject,$ns->$namespace($term), $result->{$CDE}); 
            $model->add_statement($statement);
        }
    }
}

# ====================== END OF STAGE1 SUBROUTINES




# ==================  Stage 2 subroutines =============

sub manageResourceGET {  # $self->manageResourceGET('PATH' => $path, 'ID' => $id);
    my ($self, %ARGS) = @_;
    my $PATH = $ARGS{'PATH'};
    my $ID = $ARGS{'ID'};
    
    my $store = RDF::Trine::Store::Memory->new();
    my $model = RDF::Trine::Model->new($store);
          
    $self->callDataAccessor($model, $PATH, $ID);

    $self->serializeThis($model);

}


sub callDataAccessor {
    my ($self, $model, $PATH, $ID) = @_;

      # call out to user-provided subroutine
    my $result = $self->Distributions('PATH' => $PATH, 'ID' => $ID);
    $result = decode_json($result);


    my $BASE_URL = "http://" . $ENV{'SERVER_NAME'} . $ENV{'REQUEST_URI'};
    my $URL = "http://" . $ENV{'SERVER_NAME'} . $ENV{'REQUEST_URI'} . $ENV{'PATH_INFO'};
    my $NS = $self->Configuration->Namespaces();

    my $distributions = $result->{'distributions'};
      foreach my $format(keys %$distributions){
            my $location = $distributions->{$format};
            $location = [$location] unless (ref($location) =~ /ARRAY/);  # force it to be always be an arrayref just for code clarity
            
            foreach my $loc(@$location){
                  my $statement = statement($URL, $NS->dcat('distribution'), $loc);
                  $model->add_statement($statement);
                  
                  $statement = statement($loc, $NS->rdf('type'), $NS->dcat('Distribution'));
                  $model->add_statement($statement);
                  
                  $statement = statement($loc, $NS->dc('format'), $format);
                  $model->add_statement($statement);
            
                  $statement = statement($loc, $NS->dcat('downloadURL'), $loc);
                  $model->add_statement($statement);
            }
      }
                   
        
      my $metadata = $result->{'metadata'};
      if ($metadata && keys %$metadata) {
      
            foreach my $predicate(keys %$metadata){
                  my $values = $metadata->{$predicate};
                  $values = [$values] unless (ref($values) =~ /ARRAY/);

                  my ($ns,$pred) = split /:/, $predicate;
                                    
                  foreach my $value(@$values) {
                        if ($value =~ /^http:/) {  # if its a URL
                              my $statement = statement($URL,  $NS->$ns($pred), $value); 
                              $model->add_statement($statement); 
                        } elsif ($value =~ /\S+:\S+/){  # if it looks like a qname tag
                              my ($vns,$vobj) = split /:/, $value;
                              my $statement = statement($URL,  $NS->$ns($pred), $NS->$vns($vobj)); 
                              $model->add_statement($statement); 
                        } else {
                              my $statement = statement($URL,  $NS->$ns($pred), $value); 
                              $model->add_statement($statement);                               
                        }
                  }
            }
      }
      
      # okay, $model is now full!
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

		if ($o =~ /^http\:\/\// || $o =~ /^https\:\/\//){
			$o = RDF::Trine::Node::Resource->new($o);
		} elsif ($o =~ /^<http\:\/\//){
			$o =~ s/[\<\>]//g;
			$o = RDF::Trine::Node::Resource->new($o);
		} elsif ($o =~ /"(.*?)"\^\^\<http\:/) {
			$o = RDF::Trine::Node::Literal->new($1);
		} else {
			$o = RDF::Trine::Node::Literal->new($o);				
		}
	}
	my $statement = RDF::Trine::Statement->new($s, $p, $o);
	return $statement;
}


sub printResourceHeader {
	my ($self) = @_;
        my $ETAG = $self->Configuration->ETAG_Base();
	my $entity = $ENV{'PATH_INFO'};
	$entity =~ s/^\///;
	print "Content-Type: text/turtle\n";
	print "ETag: \"$ETAG"."_"."$entity\"\n";
	print "Allow: GET,OPTIONS,HEAD\n";
	print 'Link: <http://www.w3.org/ns/ldp#Resource>; rel="type"'."\n\n";

}

sub printContainerHeader {
	my ($self) = @_;
        my $ETAG = $self->Configuration->ETAG_Base();
	print "Content-Type: text/turtle\n";
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
    my $serializer = RDF::Trine::Serializer->new('turtle');  # TODO - this should work with content negotiation
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
