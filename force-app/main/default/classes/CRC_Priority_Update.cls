public class CRC_Priority_Update implements Database.batchable<sObject>,Schedulable{ 
    // cron expression for half n hour    crn1 = '0 0 * 30 * ? n' and crn1 = '0 0 * 0 * ? n';
    public Iterable<sObject> start(Database.BatchableContext BC){
        return CRC_RA_Shufflemaster.getOrderedRA();
    }
       
   public void execute(Database.BatchableContext info, List<sObject> scope){
        Database.update((List<Case>)scope,false); 
   } 

   public void finish(Database.BatchableContext info){     
   } 

   public void execute(SchedulableContext sc) {
    CRC_Priority_Update crcObj = new CRC_Priority_Update();
    database.executebatch(crcObj,200);
   }
}


//System.schedule('Process shufflemaster at Half Hours','0 0 * * * ?',new CRC_Priority_Update());
//System.schedule('Process shufflemaster at one Hours','0 30 * * * ?',new CRC_Priority_Update());