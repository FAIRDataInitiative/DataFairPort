use DCAT::Profile::Parser;

my $parser = DCAT::Profile::Parser->new(filename => "./ProfileSchema.rdf");
my $DatasetSchema = $parser->parse;


my $schema =  $DatasetSchema->serialize;
open(OUT, ">ProfileSchema2.rdf") or die "Can't open the output file to write the profile schema$!\n";
print OUT $schema;
close OUT;

