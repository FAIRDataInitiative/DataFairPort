#!/usr/bin/perl -w

use RDF::Trine;
use RDF::Trine::Statement;
use RDF::Trine::Node::Resource;
use RDF::Trine::Node::Literal;
use RDF::NS;
use RDF::Trine::Serializer;

my $ns = RDF::NS->new('20131205');   # check at runtime
die "can't set namespace $!\n" unless ($ns->SET(fair => 'https://raw.githubusercontent.com/FAIRDataInitiative/DataFairPort/master/Schema/FAIR-schema.owl#'));
die "can't set namespace $!\n" unless ($ns->SET(proj => "http://biordf.org/DataFairPort/DragonDB_Allele_Projectors.rdf#"));

my $model = createFreshTrineModel();

my $stm = statement($ns->proj('Projector1'), $ns->rdf('type'), $ns->fair('dataProjectorDescriptor'));
$model->add_statement($stm);
$stm = statement($ns->proj('Projector2'), $ns->rdf('type'), $ns->fair('dataProjectorDescriptor'));
$model->add_statement($stm);
$stm = statement($ns->proj('Projector3'), $ns->rdf('type'), $ns->fair('dataProjectorDescriptor'));
$model->add_statement($stm);


$stm = statement($ns->proj('Projector1'), $ns->fair('projectsSource'), "http://antirrhinum.net");
$model->add_statement($stm);
$stm = statement($ns->proj('Projector1'), $ns->fair('projectsFAIRProfile'), "http://biordf.org/DataFairPort/ProfileSchemas/DragonDB_Allele_ProfileAlleleDescriptions.rdf");
$model->add_statement($stm);
$stm = statement($ns->proj('Projector1'), $ns->fair('usesAccessor'), "http://biordf.org/DataFairPort/DragonDB_Allele_Accessor.rdf");
$model->add_statement($stm);


$stm = statement($ns->proj('Projector2'), $ns->fair('projectsSource'), "http://antirrhinum.net");
$model->add_statement($stm);
$stm = statement($ns->proj('Projector2'), $ns->fair('projectsFAIRProfile'), "http://biordf.org/DataFairPort/ProfileSchemas/DragonDB_Allele_ProfileImagesEDAM.rdf");
$model->add_statement($stm);
$stm = statement($ns->proj('Projector2'), $ns->fair('usesAccessor'), "http://biordf.org/DataFairPort/DragonDB_Allele_Accessor.rdf");
$model->add_statement($stm);


$stm = statement($ns->proj('Projector3'), $ns->fair('projectsSource'), "http://antirrhinum.net");
$model->add_statement($stm);
$stm = statement($ns->proj('Projector3'), $ns->fair('projectsFAIRProfile'), "http://biordf.org/DataFairPort/ProfileSchemas/DragonDB_Allele_ProfileAlleleImagesSIO.rdf");
$model->add_statement($stm);
$stm = statement($ns->proj('Projector3'), $ns->fair('usesAccessor'), "http://biordf.org/DataFairPort/DragonDB_Allele_Accessor.rdf");
$model->add_statement($stm);


open(OUT, ">DragonDB_FAIRDataProjector.rdf") || die "canm't open output file $!\n";
print OUT serializeThis($model);
close OUT;

exit 1;


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

		if ($o =~ /^http\:\/\//){
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

sub serializeThis{
    my $model = shift;
    my $serializer = RDF::Trine::Serializer->new('turtle');
    return $serializer->serialize_model_to_string($model);
}

sub createFreshTrineModel {
    my $store = RDF::Trine::Store::Memory->new();
    my $model = RDF::Trine::Model->new($store);
    return $model;
}