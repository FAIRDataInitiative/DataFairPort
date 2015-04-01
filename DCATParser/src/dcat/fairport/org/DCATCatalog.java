package dcat.fairport.org;

import java.util.Iterator;
import java.util.List;

import com.hp.hpl.jena.ontology.Individual;
import com.hp.hpl.jena.ontology.OntClass;
import com.hp.hpl.jena.ontology.OntModel;
import com.hp.hpl.jena.ontology.OntModelSpec;
import com.hp.hpl.jena.rdf.model.ModelFactory;
import com.hp.hpl.jena.rdf.model.Resource;

public class DCATCatalog {

		private DCTTitle title = null;
		private DCTDescription description = null;
		private DCTIssued issued = null;
		private DCTModified modified = null;
		private DCTLanguage language = null;
		private DCTLicense license = null;
		private DCTRights rights = null;
		private DCTSpatial spatial = null;
		private DCTHomepage homepage = null;
		private FOAFAgent publisher = null;
		private SKOSConceptScheme themeTaxonomy = null;
		private DCATCatalogRecord record = null;
		private List<DCATDataset> dataset = null;
		
		public DCATCatalog() {
		}

		public DCTTitle getTitle() {
			return title;
		}
		
		public void setTitle(DCTTitle title) {
			this.title = title;
		}
		
		public DCTDescription getDescription() {
			return description;
		}
		
		public void setDescription(DCTDescription description) {
			this.description = description;
		}
		
		public DCTIssued getIssued() {
			return issued;
		}
		
		public void setIssued(DCTIssued issued) {
			this.issued = issued;
		}
		
		public DCTModified getModified() {
			return modified;
		}
		
		public void setModified(DCTModified modified) {
			this.modified = modified;
		}
		
		public DCTLanguage getLanguage() {
			return language;
		}
		
		public void setLanguage(DCTLanguage language) {
			this.language = language;
		}
		
		public DCTLicense getLicense() {
			return license;
		}
		
		public void setLicense(DCTLicense license) {
			this.license = license;
		}
		
		public DCTRights getRights() {
			return rights;
		}
		
		public void setRights(DCTRights rights) {
			this.rights = rights;
		}
		
		public DCTSpatial getSpatial() {
			return spatial;
		}
		
		public void setSpatial(DCTSpatial spatial) {
			this.spatial = spatial;
		}
		
		public DCTHomepage getHomepage() {
			return homepage;
		}
		
		public void setHomepage(DCTHomepage homepage) {
			this.homepage = homepage;
		}
		
		public FOAFAgent getPublisher() {
			return publisher;
		}
		
		public void setPublisher(FOAFAgent publisher) {
			this.publisher = publisher;
		}

		public SKOSConceptScheme getThemeTaxonomy() {
			return themeTaxonomy;
		}

		public void setThemeTaxonomy(SKOSConceptScheme themeTaxonomy) {
			this.themeTaxonomy = themeTaxonomy;
		}

		public DCATCatalogRecord getRecord() {
			return record;
		}

		public void setRecord(DCATCatalogRecord record) {
			this.record = record;
		}

		public List<DCATDataset> getDataset() {
			return dataset;
		}

		public void setDataset(List<DCATDataset> dataset) {
			this.dataset = dataset;
		}

		public void addDataset(DCATDataset dataset) {
			this.dataset.add(dataset);
		}
		
		public void removeDataset(DCATDataset dataset){
			int index = this.dataset.indexOf(dataset);
			if ( index >= 0 ){
				this.dataset.remove(index);
			}
		}

		public void addThemeTaxonomy(SKOSConceptScheme conceptScheme) {
			this.themeTaxonomy = conceptScheme;
		}
		
		public void removeThemeTaxonomy(SKOSConceptScheme conceptScheme) {
			this.themeTaxonomy = null;
		}

		public void addRecord(DCATCatalogRecord catalogRecord) {
			this.record = catalogRecord;
		}
		
		public void removeRecord(DCATCatalogRecord catalogRecord) {
			this.record = null;
		}

		public void addPublisher(FOAFAgent publisher) {
			this.publisher = publisher;
		}
		
		public void removePublisher(FOAFAgent publisher){
			this.publisher = null;
		}

		public void store() {
			// create the base model
			String SOURCE = "http://www.eswc2006.org/technologies/ontology";
			String NS = SOURCE + "#";
			OntModel base = ModelFactory.createOntologyModel( OntModelSpec.OWL_MEM );
			base.read( SOURCE, "RDF/XML" );

			// create the reasoning model using the base
			OntModel inf = ModelFactory.createOntologyModel( OntModelSpec.OWL_MEM_MICRO_RULE_INF, base );

			// create a dummy paper for this example
			OntClass paper = base.getOntClass( NS + "Paper" );
			Individual p1 = base.createIndividual( NS + "paper1", paper );

			// list the asserted types
			for (Iterator<Resource> i = p1.listRDFTypes(true); i.hasNext(); ) {
			    System.out.println( p1.getURI() + " is asserted in class " + i.next() );
			}

			// list the inferred types
			p1 = inf.getIndividual( NS + "paper1" );
			for (Iterator<Resource> i = p1.listRDFTypes(true); i.hasNext(); ) {
			    System.out.println( p1.getURI() + " is inferred to be in class " + i.next() );
			}		
		}
}
