global class scheduledOwnerReassignment implements Schedulable{
    global void execute(SchedulableContext SC) {
        id u = '0017000000MHEYd';
        OwnerReassignment reassign = new OwnerReassignment();        
        ID batchprocessid = Database.executeBatch(reassign); 
    }
}