package DCAT::Base;
use lib "..";
use DCAT::NAMESPACES;
use vars qw /$VERSION/;
$VERSION = sprintf "%d.%02d", q$Revision: 0.1 $ =~ /: (\d+)\.(\d+)/;

our %predicate_namespaces = qw{
    type RDF
    title DCT
    description DCT
    issued DCT
    modified DCT
    identifier DCT
    keyword DCT
    language DCT
    contactPoint DCT
    temporal DCT
    spatial DCT
    accrualPeriodicity DCT
    landingPage DCAT
    license DCT
    rights DCT
    accessURL DCAT
    downloadURL DCAT
    mediaType DCAT
    format DCT
    byteSize DCAT
    homepage FOAF
    publisher DCT
    theme DCAT
    inScheme SKOS
    themeTaxonomy DCAT
    dataset DCAT
    record DCAT
    distribution DCAT
    primaryTopic FOAF
};

sub URI {
    my ($self) = @_;
    return $self->_URI;
}


sub toTriples {
	my ($self) = @_;
	my $store = RDF::Trine::Store::Memory->new();
	my $model = RDF::Trine::Model->new($store);
        my %namespaces;
	my $dct = RDF::Trine::Namespace->new( DCT);  # from shared exported constants in NAMESPACES.pm
        $namespaces{DCT} = $dct;
        
	my $dcat = RDF::Trine::Namespace->new( DCAT);
        $namespaces{DCAT} = $dcat;
        
	my $skos = RDF::Trine::Namespace->new( SKOS);
        $namespaces{SKOS} = $skos;

	my $foaf = RDF::Trine::Namespace->new( FOAF);
        $namespaces{FOAF} = $foaf;

	my $rdf = RDF::Trine::Namespace->new( RDF);
        $namespaces{RDF} = $rdf;

	my $sub = $self->_URI;

        foreach my $key($self->_standard_keys){

            next if $key =~ /^_/;   # not a method representing a predicate
            
            if ($key =~ /^\-(\S+)/) {  # a method representing a predicate that can have multiple values
                my $method = $1;
                my $objects = $self->$method;  # call the subroutine.  All return a list-ref
                foreach my $object(@$objects){
                    my @statements = $object->toTriples;
                    foreach my $stm(@statements) {
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
                my $namespace = $namespaces{$predicate_namespaces{$key}};
                my $value = $self->$key;
                my $stm = statement($sub, $namespace.$key, $value);
                $model->add_statement($stm);
            }
        }
	
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
		if ($o =~ /http\:\/\//){
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

