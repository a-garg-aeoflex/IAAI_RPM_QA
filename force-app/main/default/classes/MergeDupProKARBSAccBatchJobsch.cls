global class MergeDupProKARBSAccBatchJobsch implements Schedulable 
{
    global void execute(SchedulableContext sc) 
    {
        MergeDuplicateProspectKARBSAccount objMerDupProKARBSAAcc = new MergeDuplicateProspectKARBSAccount(); 
        Database.executebatch(objMerDupProKARBSAAcc,1);
    }
}