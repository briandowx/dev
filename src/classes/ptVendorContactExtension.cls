public class ptVendorContactExtension {
    private final ptContact__c vendorContact;
    
    public ptVendorContactExtension(ApexPages.StandardController stdController) {
        vendorContact = (ptContact__c)stdController.getRecord();
    }
    
    public PageReference saveVendorContact() {
        try {
            insert(vendorContact);
        } catch(System.DMLException e) {
            ApexPages.addMessages(e);           
            return null;
        }
        
        PageReference p = Page.ptVendorThankYou;
                
        p.setRedirect(true);
        return p;
    }

} //