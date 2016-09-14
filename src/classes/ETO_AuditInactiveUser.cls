global class ETO_AuditInactiveUser implements Database.Batchable<sObject>{
   // to be passed in from scheduled job or annonymous apex
   global String query;   
   global String notifyEmail;
   
   //local variable
   global String Name;
   global Integer count;
   global Date today = Date.today();
   

global database.querylocator start(Database.BatchableContext BC){
            return Database.getQueryLocator(query);}

global void execute(Database.BatchableContext BC, List<sObject> scope){
    List<User> users = new List<User>();

   count = 0;
   for(sObject s : scope){
        User u = (User)s;
        try {
            if(u.profileId != '00e70000000tYMN'){
                Name = u.Name;            
                u.isActive = false;  
                        
                users.add(u);
                count++;
            }
        } catch(NullPointerException e) {
            System.debug(e.getMessage());
        } catch(NoDataFoundException e) {
            System.debug(e.getMessage());
        } catch(ListException e) {
            System.debug(e.getMessage());
        }
    } //for
            
    try {
        update users;
    } catch (DmlException e) {
        for (Integer i = 0; i < e.getNumDml(); i++)
            System.debug(e.getDmlMessage(i));
    }        
    
}
global void finish(Database.BatchableContext BC){
    try { 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        mail.setToAddresses(new String[] {notifyEmail});
        mail.setReplyTo('briandowx@yahoo.com');
        mail.setSenderDisplayName('ETO Batch Processing');
        mail.setSubject('User Audit Batch Process Completed');
        mail.setPlainTextBody('Batch Process has completed');
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    } catch(EmailException e) {
        System.debug(e.getMessage());
    }        
}
}