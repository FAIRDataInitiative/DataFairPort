package test.dcat.fairport.org;

import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

import dcat.fairport.org.DCATCatalog;
import dcat.fairport.org.DCATCatalogRecord;
import dcat.fairport.org.DCATDataset;
import dcat.fairport.org.DCATDistribution;
import dcat.fairport.org.FOAFAgent;
import processor.fairport.org.DCATProcessor;

public class Test {

	/**
	 * @param args
	 * @throws ParseException 
	 */
	public static void main(String[] args) throws ParseException {
		
		DCATProcessor processor = new DCATProcessor();
		
		DCATCatalog catalog = processor.createCatalog( "Imaginary Catalog", 
													   null, 
													   null, /*issued*/
													   null, /*modified*/ 
													   "http://id.loc.gov/vocabulary/iso639-1/en", 
													   null, /*license*/
													   null, /*rights*/
													   null, /*spatial*/ 
													   "http://example.org/catalog" );
		
		FOAFAgent publisher = new FOAFAgent();
		publisher.setPublisher("Transparency Office");
		processor.addPublisherToCatalog(catalog, publisher);
		
		DateFormat df = new SimpleDateFormat("yyyy-MM-dd");
		Date issued = df.parse("2011-12-11");  
		Date modified = df.parse("2011-12-11");
		
		DCATDistribution distribution = processor.createDistribution( 	
				"CSV distribution of imaginary dataset 001", 
				null, /*description*/
				issued, 
				modified, 
				null, /*license*/ 
				null, /*rights*/ 
				"http://www.example.org/files/001.csv", 
				"http://www.example.org/files/001.csv", 
				"text/csv", 
				null, /*format*/ 
				5120 );

		DCATDataset dataset = processor.createDataSet(
				"Imaginary dataset", 
				null, 
				issued, 
				modified, 
				null, /* identifier */
				null, 
				"http://id.loc.gov/vocabulary/iso639-1/en", 
				"http://example.org/transparency-office/contact", 
				"http://reference.data.gov.uk/id/quarter/2006-Q1",
				"http://www.geonames.org/6695072", 
				"http://purl.org/linked-data/sdmx/2009/code#freq-W", 
				null );
		processor.addKeywordToDataset( dataset, "accountability" );
		processor.addKeywordToDataset( dataset, "transparency" );
		processor.addKeywordToDataset( dataset, "payments" );
		processor.addPublisherToDataset( dataset, publisher );
		processor.addDistributionToDataset(dataset, distribution);
		
       
		DCATCatalogRecord catalogRecord = processor.createCatalogRecord( 
				"Imaginary CatalogRecord",
				null, /*description*/
				issued, /*issued*/
				modified /*modified*/ 
				);
		catalogRecord.setPrimareTopic(dataset);
		processor.addCatalogRecordToCatalog(catalog, catalogRecord);
		
		catalog.store();
	}

}
