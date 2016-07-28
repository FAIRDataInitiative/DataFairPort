package dcat.fairport.org;

public class DCATDistribution {

	private DCTTitle title = null;
	private DCTDescription description = null;
	private DCTIssued issued = null;
	private DCTModified modified = null;
	private DCTLicense license = null;
	private DCTRights rights = null;
	private DCATAccessURL accessURL = null;
	private DCATDownloadURL downloadURL = null;
	private DCATMediaType mediaType = null;
	private DCTFormat format = null;
	private DCATByteSize byteSize = null;
	
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
	
	public DCATAccessURL getAccessURL() {
		return accessURL;
	}
	
	public void setAccessURL(DCATAccessURL accessURL) {
		this.accessURL = accessURL;
	}
	
	public DCATDownloadURL getDownloadURL() {
		return downloadURL;
	}
	
	public void setDownloadURL(DCATDownloadURL downloadURL) {
		this.downloadURL = downloadURL;
	}
	
	public DCATMediaType getMediaType() {
		return mediaType;
	}
	
	public void setMediaType(DCATMediaType mediaType) {
		this.mediaType = mediaType;
	}
	
	public DCTFormat getFormat() {
		return format;
	}
	
	public void setFormat(DCTFormat format) {
		this.format = format;
	}
	
	public DCATByteSize getByteSize() {
		return byteSize;
	}
	
	public void setByteSize(DCATByteSize byteSize) {
		this.byteSize = byteSize;
	}
	
	
}
