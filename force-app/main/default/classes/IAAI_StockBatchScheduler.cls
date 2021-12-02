global class IAAI_StockBatchScheduler implements Schedulable {
    global void execute(SchedulableContext ctx) {
        Database.executeBatch(new IAAI_ASAP_Stock_Batch(),1); 
    }
}