package dcat.fairport.org;

public class DCATCatalogRecord {

	private DCTTitle title = null;
	private DCTDescription description = null;
	private DCTIssued issued = null;
	private DCTModified modified = null;
	private DCATDataset primareTopic = null;
	
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

	public DCATDataset getPrimareTopic() {
		return primareTopic;
	}

	public void setPrimareTopic(DCATDataset primareTopic) {
		this.primareTopic = primareTopic;
	}

	
}
