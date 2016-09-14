public with sharing class tstNewVendorWizardController {
	Vendor__c ptVendor;
	ptContact__c ptContact;
	
	public Vendor__c getVendor() {
		if (ptVendor == null)
			ptVendor = new Vendor__c();
			
		return ptVendor;			
	} //
	
	public ptContact__c getContact() {
		if (ptContact == null) 
			ptContact = new ptContact__c();
			
		return ptContact;
	} //
	
	public PageReference step1() {
		return Page.ptNewVendorStep1;
	} //		
	
	public PageReference save() {
		try {
			insert ptVendor;
		} catch (Exception e) {
			PageReference p = Page.ptVendorThankYou;
			p.getParameters().put('error', 'noInsert');
		}
		
		ptContact.Vendor__c = ptVendor.Id;
		try {
			insert ptContact;
		} catch(Exception e) {
			PageReference p = Page.ptVendorThankYou;
			p.getParameters().put('error', 'noInsert');
		}
		
		PageReference p = Page.ptVendorThankYou;
		
		p.setRedirect(true);
		
		return p;		
	} //
			
}	//class