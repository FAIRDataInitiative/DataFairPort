package FAIR::Accessor::Distribution;
use strict;
use Moose;
use Data::UUID;
use RDF::Trine::Store::Memory;
use RDF::Trine::Model;

with 'FAIR::CoreFunctions';

has 'NS' => (
    is => 'rw',
);

has 'downloadURL'=> (
      is => 'rw',
      isa => 'Str',
);

has 'source'=> (
      is => 'rw',
      isa => 'Str',
);

has 'subjecttemplate'=> (
      is => 'rw',
      isa => 'Str',
);

has 'subjecttype'=> (
      is => 'rw',
      isa => 'Str',
);

has 'predicate'=> (
      is => 'rw',
      isa => 'Str',
);

has 'objecttemplate'=> (
      is => 'rw',
      isa => 'Str',
);

has 'objecttype'=> (
      is => 'rw',
      isa => 'Str',
);

has 'availableformats'=> (
      is => 'rw',
      isa => 'Str',
);

has 'distributionType' => (
      is => 'rw',
      isa => 'ArrayRef',
      default => sub {["dcat:Distribution", "dc:Dataset"]},
);

has 'baseURI' => (
      is => 'rw',
      isa => 'Str',
      default => "http://datafairport.org/local/Source",
);


has 'UUID' => (
      is => 'rw',
      isa => 'Str',
      default => sub { my $ug =Data::UUID->new; my $uuid = $ug->create(); return $ug->to_string( $uuid ) }
);

#has 'model' => (
#      is => 'rw',
#      isa => 'RDF::Trine::Model',
#      default => sub {my $store = RDF::Trine::Store::Memory->new(); return RDF::Trine::Model->new($store)}
#);

has 'Projectionmodel' => (
    isa => "RDF::Trine::Model",
    is => "rw",
    default => sub {my $store = RDF::Trine::Store::Memory->new(); return RDF::Trine::Model->new($store)}
);


sub types {
      my ($self) = @_;
      my $format = $self->availableformats;
      my @types = @{$self->distributionType};
      if (($format =~/turtle/) || ($format =~ /rdf/) || ($format =~ /quads/)) {
            push @types, "void:Dataset";
      }
      
      if ($self->source) {  # if it has this, then it is TPF
            push @types, "fair:Projector";
      }
      return @types;
}

sub ProjectionModel {
    my ($self) = @_;
    my $uuid = $self->UUID();
    my $NS = $self->NS();

    my $model = $self->Projectionmodel;
    
    my $SRC = "http://datafairport.org/local/Source$uuid";
    my $MAP = "http://datafairport.org/local/Mappings$uuid";
    my $SMAP = "http://datafairport.org/local/SubjectMap$uuid";
    my $POMAP = "http://datafairport.org/local/POMap$uuid";
    my $OMAP =  "http://datafairport.org/local/ObjectMap$uuid";
    my $SMAP2 = "http://datafairport.org/local/SubjectMap2$uuid";
    
    
    my $statement;
        
    $statement = $self->makeSensibleStatement($SRC, $self->NS->rml('source'), $self->source);
    $model->add_statement($statement);
        
       
    $statement = $self->makeSensibleStatement($MAP, $self->NS->rml('logicalSource'), $SRC);
    $model->add_statement($statement);

    
    $statement = $self->makeSensibleStatement($SRC, $self->NS->rml('hasMapping'), $MAP);
    $model->add_statement($statement);
        #  <SRC>  rml:referenceFormulation  ql:CSV
    $statement = $self->makeSensibleStatement($SRC, $self->NS->rml('referenceFormulation'), $self->NS->ql('TriplePatternFragments'));
    $model->add_statement($statement);


        
        # <MAP> rr:subjectMap <SMAP>
    $statement = $self->makeSensibleStatement($MAP, $self->NS->rr('subjectMap'), $SMAP);
    $model->add_statement($statement);
        # <SMAP> rr:template "http://something/{ID}"


   my $templateurl = RDF::Trine::Node::Literal->new($self->subjecttemplate);
    $statement = $self->makeSensibleStatement($SMAP, $self->NS->rr('template'), $templateurl);
    $model->add_statement($statement);

    $statement = $self->makeSensibleStatement($SMAP, $self->NS->rr('class'), $self->subjecttype);
    $model->add_statement($statement);

    
    
        # <MAP>  rr:predicateObjectMap <POMAP>
    $statement = $self->makeSensibleStatement($MAP, $self->NS->rr('predicateObjectMap'), $POMAP);
    $model->add_statement($statement);
        #
        # <POMAP>  rr:predicate {$predicate}
    $statement = $self->makeSensibleStatement($POMAP, $self->NS->rr('predicate'), $self->predicate);
    $model->add_statement($statement);
        # <POMAP>  rr:objectMap <OMAP>
    $statement = $self->makeSensibleStatement($POMAP, $self->NS->rr('objectMap'), $OMAP);
    $model->add_statement($statement);
    
    
    
        #
        # <OMAP> rr:parentTriplesMap <OBJMAP>
    $statement = $self->makeSensibleStatement($OMAP, $self->NS->rr('parentTriplesMap'), $SMAP2);
    $model->add_statement($statement);
        # <OMAP> rr:subjecctMap <SMAP2>
        # <SMAP2>  rr:template "http://somethingelse/{out}
    if ($self->objecttype =~ /\#string/){
        $templateurl = RDF::Trine::Node::Literal->new("{value}");
    } else {
        $templateurl = RDF::Trine::Node::Literal->new($self->objecttemplate);
    }
    $statement = $self->makeSensibleStatement($SMAP2, $self->NS->rr('template'), $templateurl);
    $model->add_statement($statement);

    $statement = $self->makeSensibleStatement($SMAP2, $self->NS->rr('class'), $self->objecttype);
    $model->add_statement($statement);

    return $model;

}

sub makeSensibleStatement {
      my ($self, $subject, $predicate, $obj) = @_;
      my $NS = $self->NS;
      
      if (($subject =~ /^http:/) || ($subject =~ /^https:/)) {
      } else {
             my ($ns, $sub) = split /:/, $subject;
             $subject = $NS->$ns($sub);   # add the namespace   
      }
      
      if (($predicate =~ /^http:/) || ($predicate =~ /^https:/)) {
      } else {
             my ($ns, $pred) = split /:/, $predicate;
             $predicate = $NS->$ns($pred);   # add the namespace   
      }
         
      if (($obj =~ /^http:/) || ($obj =~ /^https:/)) {  # if its a URL
            # do nothing
      } elsif ((!($obj =~ /\s/)) && ($obj =~ /\S+:\S+/)){  # if it looks like a qname tag
            my ($ns,$obj) = split /:/, $obj;
            if ($NS->$ns($obj)) {
                  $obj =  $NS->$ns($obj);   # add the namespace               
            }
      }
         
      my $statement = statement($subject,  $predicate, $obj); 
      
      return $statement;
      
}


#
#sub ProjectionMap{
#    my ($self, $URL, $SOURCE, $subtemplate, $type, $predicate, $objecttemplate, $otype) = @_;
#    my $uuid = UUID::Generator::PurePerl->new();
#    $uuid = $uuid->generate_v1();
#    my $NS = $self->NS();
#
#    my $model = $self->Projectionmodel;
#    
#    my $SRC = "http://datafairport.org/local/Source$uuid";
#    my $MAP = "http://datafairport.org/local/Mappings$uuid";
#    my $SMAP = "http://datafairport.org/local/SubjectMap$uuid";
#    my $POMAP = "http://datafairport.org/local/POMap$uuid";
#    my $OMAP =  "http://datafairport.org/local/ObjectMap$uuid";
#    my $SMAP2 = "http://datafairport.org/local/SubjectMap2$uuid";
#    
#    
#    my $statement;
#        # Mapping
#        #  <CSV>  rml:isSourceOf  <SRC>
#        #  <SRC>  rml:source    <CSV>
#    $statement = statement($URL, $NS->rml('source'), $SOURCE);
#    $model->add_statement($statement);
#        
#        #  <MAP>  rml:logicalSource <SRC>
#    $statement = statement($MAP, $NS->rml('logicalSource'), $URL);
#    $model->add_statement($statement);
#
#    
#        #  <SRC>  rml:hasMapping   <MAP>
#    $statement = statement($URL, $NS->rml('hasMapping'), $MAP);
#    $model->add_statement($statement);
#        #  <SRC>  rml:referenceFormulation  ql:CSV
#    $statement = statement($URL, $NS->rml('referenceFormulation'), $NS->ql('TriplePatternFragments'));
#    $model->add_statement($statement);
#
#
#        
#        # <MAP> rr:subjectMap <SMAP>
#    $statement = statement($MAP, $NS->rr('subjectMap'), $SMAP);
#    $model->add_statement($statement);
#        # <SMAP> rr:template "http://something/{ID}"
#
#
#   my $templateurl = RDF::Trine::Node::Literal->new($subtemplate);
#    $statement = statement($SMAP, $NS->rr('template'), $templateurl);
#    $model->add_statement($statement);
#
#    $statement = statement($SMAP, $NS->rr('class'), $type);
#    $model->add_statement($statement);
#
#    
#    
#        # <MAP>  rr:predicateObjectMap <POMAP>
#    $statement = statement($MAP, $NS->rr('predicateObjectMap'), $POMAP);
#    $model->add_statement($statement);
#        #
#        # <POMAP>  rr:predicate {$predicate}
#    $statement = statement($POMAP, $NS->rr('predicate'), $predicate);
#    $model->add_statement($statement);
#        # <POMAP>  rr:objectMap <OMAP>
#    $statement = statement($POMAP, $NS->rr('objectMap'), $OMAP);
#    $model->add_statement($statement);
#    
#    
#    
#        #
#        # <OMAP> rr:parentTriplesMap <OBJMAP>
#    $statement = statement($OMAP, $NS->rr('parentTriplesMap'), $SMAP2);
#    $model->add_statement($statement);
#        # <OMAP> rr:subjecctMap <SMAP2>
#        # <SMAP2>  rr:template "http://somethingelse/{out}
#    if ($otype =~ /\#string/){
#        $templateurl = RDF::Trine::Node::Literal->new("{value}");
#    } else {
#        $templateurl = RDF::Trine::Node::Literal->new($objecttemplate);
#    }
#    $statement = statement($SMAP2, $NS->rr('template'), $templateurl);
#    $model->add_statement($statement);
#
#    $statement = statement($SMAP2, $NS->rr('class'), $otype);
#    $model->add_statement($statement);
#
#        
#}


1;
