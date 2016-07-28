package processor.fairport.org;

import java.util.Date;
import java.util.List;

import dcat.fairport.org.*;

public class DCATProcessor {
	
	public DCATCatalog createCatalog(  String title, String description, Date issued, Date modified, 
									   String language, String license, String rights, String spatial, 
									   String homepage ){
		DCATCatalog catalog = new DCATCatalog();

		DCTTitle dctTitle = new DCTTitle();
		dctTitle.setTitle(title);
		catalog.setTitle(  dctTitle );
		
		DCTDescription dctDescription = new DCTDescription();
		dctDescription.setDescription(description);
		catalog.setDescription(dctDescription);
		
		DCTIssued dctIssued = new DCTIssued();
		dctIssued.setIssued(issued);
		catalog.setIssued(dctIssued);
		
		DCTModified dctModified = new DCTModified();
		dctModified.setModified(modified);
		catalog.setModified(dctModified);
		
		DCTLanguage dctLanguage = new DCTLanguage();
		dctLanguage.setLanguage(language);
		catalog.setLanguage(dctLanguage);
		
		DCTLicense dctLicense = new DCTLicense();
		dctLicense.setLicense(license);
		catalog.setLicense(dctLicense);
		
		DCTRights dctRights = new DCTRights();
		dctRights.setRights(rights);
		catalog.setRights(dctRights);
		
		DCTSpatial dctSpatial = new DCTSpatial();
		dctSpatial.setSpatial(spatial);
		catalog.setSpatial(dctSpatial);
		
		DCTHomepage dctHomepage = new DCTHomepage();
		dctHomepage.setHomepage(homepage);
		catalog.setHomepage(dctHomepage);
		
		return catalog;
	}
	
	public void addDatasetToCatalog( DCATCatalog catalog, DCATDataset dataset ){
		catalog.addDataset(dataset);
	}
	
	public void removeDatasetFromCatalog( DCATCatalog catalog, DCATDataset dataset ){
		catalog.removeDataset(dataset);
	}

	public void addThemeTaxonomyToCatalog( DCATCatalog catalog, SKOSConceptScheme conceptScheme ){
		catalog.addThemeTaxonomy(conceptScheme);
	}

	public void removeThemeTaxonomyFromCatalog( DCATCatalog catalog, SKOSConceptScheme conceptScheme ){
		catalog.removeThemeTaxonomy(conceptScheme);
	}

	public void addCatalogRecordToCatalog( DCATCatalog catalog, DCATCatalogRecord catalogRecord ){
		catalog.addRecord(catalogRecord);
	}

	public void removeCatalogRecordFromCatalog( DCATCatalog catalog, DCATCatalogRecord catalogRecord ){
		catalog.removeRecord(catalogRecord);
	}

	public void addPublisherToCatalog( DCATCatalog catalog, FOAFAgent publisher ){
		catalog.addPublisher(publisher);
	}

	public void removePublisherToCatalog( DCATCatalog catalog, FOAFAgent publisher ){
		catalog.removePublisher(publisher);
	}

	public void dropCatalog( DCATCatalog catalog ){
		catalog = null;
	}
	
	public DCATDataset createDataSet( String title, String description, Date issued, Date modified, String identifier,
						  			  List<String> keyword, String language, String contactPoint, String temporal,
						  			  String spatial, String accrualPeriodicity, String landingPage ){
		DCATDataset dataset = new DCATDataset();

		DCTTitle dctTitle = new DCTTitle();
		dctTitle.setTitle(title);
		dataset.setTitle(  dctTitle );
		
		DCTDescription dctDescription = new DCTDescription();
		dctDescription.setDescription(description);
		dataset.setDescription(dctDescription);
		
		DCTIssued dctIssued = new DCTIssued();
		dctIssued.setIssued(issued);
		dataset.setIssued(dctIssued);
		
		DCTModified dctModified = new DCTModified();
		dctModified.setModified(modified);
		dataset.setModified(dctModified);
		
		DCATKeyword dcatKeyword = new DCATKeyword();
		dcatKeyword.setKeyword(keyword);
		dataset.setKeyword(dcatKeyword);
		
		DCTLanguage dctLanguage = new DCTLanguage();
		dctLanguage.setLanguage(language);
		dataset.setLanguage(dctLanguage);
		
		DCATContactPoint dcatContactPoint = new DCATContactPoint();
		dcatContactPoint.setContactPoint(contactPoint);
		dataset.setContactPoint(dcatContactPoint);
		
		DCTTemporal dctTemporal = new DCTTemporal();
		dctTemporal.setTemporal(temporal);
		dataset.setTemporal(dctTemporal);
		
		DCTSpatial dctSpatial = new DCTSpatial();
		dctSpatial.setSpatial(spatial);
		dataset.setSpatial(dctSpatial);
		
		DCTAccrualPeriodicity dctAccrualPerdiodicity = new DCTAccrualPeriodicity();
		dctAccrualPerdiodicity.setAccrualPeriodicity(accrualPeriodicity);
		dataset.setAccrualPeriodicity(dctAccrualPerdiodicity);
		
		DCATLandingPage dcatLandingPage = new DCATLandingPage();
		dcatLandingPage.setLandingPage(landingPage);
		dataset.setLandingPage(dcatLandingPage);
		
		return dataset;
	}
	
	public void dropDataset( DCATDataset dataset ){
		dataset = null;
	}
	
	public void addDistributionToDataset( DCATDataset dataset, DCATDistribution distribution ){
		dataset.addDistribution(distribution);
	}
	
	public void removeDistributionToDataset( DCATDataset dataset, DCATDistribution distribution ){
		dataset.removeDistribution(distribution);
	}

	public DCATDistribution createDistribution( String title, String description, Date issued, Date modified, 
			   									String license, String rights, String accessURL, 
			   									String downloadURL, String mediaType, String format, 
			   									Integer byteSize ){
		DCATDistribution distribution = new DCATDistribution();

		DCTTitle dctTitle = new DCTTitle();
		dctTitle.setTitle(title);
		distribution.setTitle(  dctTitle );
		
		DCTDescription dctDescription = new DCTDescription();
		dctDescription.setDescription(description);
		distribution.setDescription(dctDescription);
		
		DCTIssued dctIssued = new DCTIssued();
		dctIssued.setIssued(issued);
		distribution.setIssued(dctIssued);
		
		DCTModified dctModified = new DCTModified();
		dctModified.setModified(modified);
		distribution.setModified(dctModified);
		
		DCTLicense dctLicense = new DCTLicense();
		dctLicense.setLicense(license);
		distribution.setLicense(dctLicense);
		
		DCTRights dctRights = new DCTRights();
		dctRights.setRights(rights);
		distribution.setRights(dctRights);
		
		DCATAccessURL dcatAccessURL = new DCATAccessURL();
		dcatAccessURL.setAccessURL(accessURL);
		distribution.setAccessURL(dcatAccessURL);
		
		DCATDownloadURL dcatDownloadURL = new DCATDownloadURL();
		dcatDownloadURL.setDownloadURL(downloadURL);
		distribution.setDownloadURL(dcatDownloadURL);
		
		DCATMediaType dcatMediaType = new DCATMediaType();
		dcatMediaType.setMediaType(mediaType);
		distribution.setMediaType(dcatMediaType);
		
		DCTFormat dctFormat = new DCTFormat();
		dctFormat.setFormat(format);
		distribution.setFormat(dctFormat);
		
		DCATByteSize dcatByteSize = new DCATByteSize();
		dcatByteSize.setByteSize(byteSize);
		distribution.setByteSize(dcatByteSize);

		return distribution;
	}
	
	public void dropDistribution( DCATDistribution distribution ){
		distribution = null;
	}
	
	public DCATCatalogRecord createCatalogRecord( String title, String description, Date issued, Date modified ){
		DCATCatalogRecord catalogRecord = new DCATCatalogRecord();

		DCTTitle dctTitle = new DCTTitle();
		dctTitle.setTitle(title);
		catalogRecord.setTitle(  dctTitle );
		
		DCTDescription dctDescription = new DCTDescription();
		dctDescription.setDescription(description);
		catalogRecord.setDescription(dctDescription);
		
		DCTIssued dctIssued = new DCTIssued();
		dctIssued.setIssued(issued);
		catalogRecord.setIssued(dctIssued);
		
		DCTModified dctModified = new DCTModified();
		dctModified.setModified(modified);
		catalogRecord.setModified(dctModified);
		
		return catalogRecord;

	}

	public void addKeywordToDataset(DCATDataset dataset, String keyword) {
		dataset.addKeyword(keyword);
	}

	public void addPublisherToDataset(DCATDataset dataset, FOAFAgent publisher) {
		dataset.setPublisher(publisher);
	}
}
