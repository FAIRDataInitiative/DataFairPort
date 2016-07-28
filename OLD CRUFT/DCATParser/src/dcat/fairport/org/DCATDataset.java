package dcat.fairport.org;

public class DCATDataset {

		private DCTTitle title = null;
		private DCTDescription description = null;
		private DCTIssued issued = null;
		private DCTModified modified = null;
		private DCTIdentifier identifier = null;
		private DCATKeyword keyword = null; 
		private DCTLanguage Language = null;
		private DCATContactPoint contactPoint = null;
		private DCTTemporal temporal = null;
		private DCTSpatial spatial = null;
		private DCTAccrualPeriodicity accrualPeriodicity = null;
		private DCATLandingPage landingPage = null;
		private FOAFAgent publisher = null;
		private SKOSConcept theme = null;
		private DCATDistribution distribution = null;
		
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
		
		public DCTIdentifier getIdentifier() {
			return identifier;
		}
		
		public void setIdentifier(DCTIdentifier identifier) {
			this.identifier = identifier;
		}
		
		public DCATKeyword getKeyword() {
			return keyword;
		}
		
		public void setKeyword(DCATKeyword keyword) {
			this.keyword = keyword;
		}
		
		public DCTLanguage getLanguage() {
			return Language;
		}
		
		public void setLanguage(DCTLanguage language) {
			Language = language;
		}
		
		public DCATContactPoint getContactPoint() {
			return contactPoint;
		}
		
		public void setContactPoint(DCATContactPoint contactPoint) {
			this.contactPoint = contactPoint;
		}
		
		public DCTTemporal getTemporal() {
			return temporal;
		}
		
		public void setTemporal(DCTTemporal temporal) {
			this.temporal = temporal;
		}
		
		public DCTSpatial getSpatial() {
			return spatial;
		}
		
		public void setSpatial(DCTSpatial spatial) {
			this.spatial = spatial;
		}
		
		public DCTAccrualPeriodicity getAccrualPeriodicity() {
			return accrualPeriodicity;
		}
		
		public void setAccrualPeriodicity(DCTAccrualPeriodicity accrualPeriodicity) {
			this.accrualPeriodicity = accrualPeriodicity;
		}
		
		public DCATLandingPage getLandingPage() {
			return landingPage;
		}
		
		public void setLandingPage(DCATLandingPage landingPage) {
			this.landingPage = landingPage;
		}

		public FOAFAgent getPublisher() {
			return publisher;
		}

		public void setPublisher(FOAFAgent publisher) {
			this.publisher = publisher;
		}

		public SKOSConcept getTheme() {
			return theme;
		}

		public void setTheme(SKOSConcept theme) {
			this.theme = theme;
		}

		public DCATDistribution getDistribution() {
			return distribution;
		}

		public void setDistribution(DCATDistribution distribution) {
			this.distribution = distribution;
		}

		public void removeDistribution(DCATDistribution distribution) {
			this.distribution = null;
		}
		
		public void addDistribution(DCATDistribution distribution) {
			this.distribution = distribution;
		}

		public void addKeyword(String keyword) {
			this.keyword.addKeyword( keyword );
		}
		
		
}
