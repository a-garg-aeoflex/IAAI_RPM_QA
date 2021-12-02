global class MergeDuplicateAccountBatchJobscheduled implements Schedulable 
{
    global void execute(SchedulableContext sc) 
    {
        MergeDuplicateAccount objMergeDuplicateAccount = new MergeDuplicateAccount(); 
        Database.executebatch(objMergeDuplicateAccount,1);
    }
}