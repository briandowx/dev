public with sharing class ptNewVendorWizardController {
    Vendor__c ptVendor;
    ptContact__c ptContact;
    
    public Vendor__c getptVendor() {
        if (ptVendor == null)
            ptVendor = new Vendor__c();
            
        return ptVendor;
    }
    
    public ptContact__c getptContact() {
        if(ptContact == null)
            ptContact = new ptContact__c();
            
        return ptContact;           
    }
    
    public PageReference step1() {
        return Page.ptNewVendorStep1;
        
    }
    
    public PageReference step2() {
        return Page.ptNewVendorStep2;
    }
    
    public PageReference step3() {
        return Page.ptNewVendorStep3;
    }
    
    public PageReference save() {
    	try {
        	insert ptVendor;
    	} catch (Exception e) {
    		PageReference p = Page.ptVendorThankYou;
    		p.getParameters().put('error', 'noInsert');
    	}
        ptContact.Vendor__c = ptVendor.id;
        
        try {
        	insert ptContact;
        } catch (Exception e) {
        	PageReference p = Page.ptVendorThankYou;
        	p.getParameters().put('error', 'noInsert');   
        	     
        }
        
        PageReference p = Page.ptVendorThankYou;
                
        p.setRedirect(true);
        return p;
    }
    
    
}