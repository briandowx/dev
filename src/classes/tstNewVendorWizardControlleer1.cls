public with sharing class tstNewVendorWizardControlleer1 {
	Parent__c parent;
	
	public Parent__c getParent() {
		if (parent == null)
			parent = new Parent__c();
			
		return parent;			
	} //
	
	public PageReference step1() {
		return Page.ptNewVendorStep1;
	} //
		
	public PageReference save() {
		try {
			insert parent;
		} catch (Exception e) {
			PageReference p = Page.ptVendorThankYou;
			p.getParameters().put('error', 'noInsert');
			
		}
		PageReference p = Page.ptVendorThankYou;
		
		p.setRedirect(true);
		
		return p;		
	} //	 

} //class