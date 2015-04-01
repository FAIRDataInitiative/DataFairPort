use lib "../lib/";
use FAIR::Profile::Parser;

my $parser = FAIR::Profile::Parser->new(filename => "./DemoMicroarrayProfileScheme.rdf");
my $DatasetSchema = $parser->parse;


my $schema =  $DatasetSchema->serialize;
open(OUT, ">DemoMicroarrayProfileScheme_duplicate.rdf") or die "Can't open the output file to write the profile schema$!\n";
print OUT $schema;
close OUT;

