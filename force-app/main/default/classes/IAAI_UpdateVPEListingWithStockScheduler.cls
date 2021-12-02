global class IAAI_UpdateVPEListingWithStockScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        Id batchId = Database.executebatch(new IAAI_UpdateVPEListingWithStockBatch(), 200);
    }
}