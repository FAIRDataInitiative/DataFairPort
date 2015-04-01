package FAIR::Base;

use RDF::NS '20131205';
use strict;
use lib "../";

use FAIR::NAMESPACES; 

our %predicate_namespaces = qw{
    type RDF
    title DC
    description DC
    issued DC
    modified DC
    identifier DC
    keyword DC
    language DC
    contactPoint DC
    temporal DC
    spatial DC
    accrualPeriodicity DC
    landingPage DCAT
    license DC
    rights DC
    accessURL DCAT
    downloadURL DCAT
    mediaType DCAT
    format DC
    byteSize DCAT
    homepage FOAF
    publisher DC
    theme DCAT
    inScheme SKOS
    themeTaxonomy DCAT
    dataset DCAT
    record DCAT
    distribution DCAT
    primaryTopic FOAF
    
    label RDFS
    organization DC
    hasClass FAIR
    hasProperty FAIR
    onClassType FAIR
    onPropertyType FAIR
    allowedValues FAIR
    maxCount FAIR
    minCount FAIR
    FAIRClass FAIR
    FAIRProperty FAIR
    FAIRProfile FAIR
    
    schemardfs_URL FAIR
    
};


sub _toTriples {
	my ($self, $model) = @_;
        unless ($model){  # this is a recursive sub, so sometimes the preexisting model is passed in to be filled
            my $store = RDF::Trine::Store::Memory->new();
            $model = RDF::Trine::Model->new($store);
        }
        my %namespaces;
	my $dct = RDF::Trine::Namespace->new( DC);  # from shared exported constants in NAMESPACES.pm
        $namespaces{DC} = $dct;
        
	my $dcat = RDF::Trine::Namespace->new( DCAT);
        $namespaces{DCAT} = $dcat;
        
	my $skos = RDF::Trine::Namespace->new( SKOS);
        $namespaces{SKOS} = $skos;

	my $foaf = RDF::Trine::Namespace->new( FOAF);
        $namespaces{FOAF} = $foaf;

	my $rdfs = RDF::Trine::Namespace->new( RDFS);
        $namespaces{RDFS} = $rdfs;

	my $rdf = RDF::Trine::Namespace->new( RDF);
        $namespaces{RDF} = $rdf;

	my $fair = RDF::Trine::Namespace->new( FAIR);
        $namespaces{FAIR} = $fair;

	my $sub = $self->URI;

        foreach my $key($self->_standard_keys){   # GOOD LORD!  This subroutine just keeps getting uglier and uglier!

            next if $key =~ /^_/;   # not a method representing a predicate
            next if $key eq "URI";
            
            if ($key =~ /^\-(\S+)/) {  # a method representing a predicate that can have multiple values, so it is modeled as a subroutine
                my $method = $1;
                my $objects = $self->$method;  # call the subroutine.  All return a list-ref; sometimes its a list of DCAT objects, sometimes a listref of strings
                my @subjects = ();
                foreach my $object(@$objects){
                    #print STDERR $object, "\n";
		    next unless ($object);  # might be undef
                    if (ref($object) && $object->can('_toTriples')) {  # is it a DCAT object?  if so, unpack it  
                        $object->_toTriples($model);  # recursive call... unpack that DCAT object to triples
                        my $toConnect = $object->URI;
                        my $namespace = $namespaces{$predicate_namespaces{$method}};
                        my $stm = statement($sub, $namespace.$method, $toConnect);
                        $model->add_statement($stm);                                        
                    } else {  # if it isn't a DCAT object, then it's just a listref of strings
                        my $namespace = $namespaces{$predicate_namespaces{$method}};
                        my $stm = statement($sub, $namespace.$method, $object);
                        $model->add_statement($stm);                    
                    }
                }
                next;
            } elsif ($key =~ /^type/) {   # rdf:type
                my $types = $self->type;  # call the subroutine.  All return a list-ref
                foreach my $type(@$types){
                    my $stm = statement($sub, RDF."type", $type);
                    $model->add_statement($stm);                    
                }
                next;
            } else {
                # print STDERR $key, "\n";
                my $namespace = $namespaces{$predicate_namespaces{$key}};
                my $value = $self->$key;
                next unless defined $value;
                my $stm = statement($sub, $namespace.$key, $value);
                $model->add_statement($stm);
            }
        }
	return $model;
}

sub toTriples {
    my ($self) = @_;
    my $model = $self->_toTriples;
    my $iter = $model->get_statements();
    my @statements;
    while (my $st = $iter->next) {
            push @statements, $st;    
    }
    return @statements;
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
		if (($o =~ m'^http://') || ($o =~ m'^https://')){
			$o =~ s/[\<\>]//g;
			$o = RDF::Trine::Node::Resource->new($o);
		} elsif ($o =~ /\D/) {
			$o = RDF::Trine::Node::Literal->new($o);
		} else {
			$o = RDF::Trine::Node::Literal->new($o);				
		}
	}
	my $statement = RDF::Trine::Statement->new($s, $p, $o);
	return $statement;
}











1;

