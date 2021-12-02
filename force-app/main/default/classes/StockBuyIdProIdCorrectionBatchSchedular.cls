global class StockBuyIdProIdCorrectionBatchSchedular implements Schedulable{

    global void execute(SchedulableContext sc){

        StockBuyerIdProviderIdCorrectionBatch b = new StockBuyerIdProviderIdCorrectionBatch ();
        database.executebatch(b);
    }
}