global class scheduled_ETO_AuditInactiveUser implements Schedulable{
    global void execute(SchedulableContext SC) {
           
       ETO_AuditInactiveUser auditUser = new ETO_AuditInactiveUser();
       auditUser.query='SELECT Id, Name, isActive, LastLoginDate, profileId FROM User WHERE LastLoginDate < LAST_N_DAYS:3 AND isActive = true';
       auditUser.notifyEmail = 'briandowx@yahoo.com';
       ID batchprocessid = Database.executeBatch(auditUser);
    }
}