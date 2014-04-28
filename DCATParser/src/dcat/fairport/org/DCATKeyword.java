package dcat.fairport.org;

import java.util.ArrayList;
import java.util.List;

public class DCATKeyword {
	
	private List<String> keyword = null; /* note, could be multiple keywords */

	public DCATKeyword(){
		keyword = new ArrayList<String>();
	}
	
	public List<String> getKeyword() {
		return keyword;
	}

	public void setKeyword(List<String> keyword) {
		if ( keyword == null ){
			this.keyword.clear();
		}
		else{
			this.keyword = keyword;
		}
	}

	public void addKeyword(String keyword) {
		this.keyword.add(keyword);
	}
	
}
