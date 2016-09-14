global class OwnerReassignment implements Database.Batchable<sObject>{
   global String query;
   global String email;
   global Id toId;
   global Id fromId;

global database.querylocator start(Database.BatchableContext BC){
            return Database.getQueryLocator(query);}

global void execute(Database.BatchableContext BC, List<sObject> scope){
    List<Account> accns = new List<Account>();

   for(sObject s : scope){Account a = (Account)s;
        if(a.Id==fromId){
            a.Rating = 'Warm';
            accns.add(a);
            }
        }

update accns;
    
}
global void finish(Database.BatchableContext BC){
Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

mail.setToAddresses(new String[] {email});
mail.setReplyTo('briandowx@yahoo.com');
mail.setSenderDisplayName('Batch Processing');
mail.setSubject('Batch Process Completed');
mail.setPlainTextBody('Batch Process has completed');

Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
}
}