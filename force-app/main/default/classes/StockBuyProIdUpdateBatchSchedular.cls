global class StockBuyProIdUpdateBatchSchedular implements Schedulable{

    global void execute(SchedulableContext sc){

        StockBuyProIdUpdateBatch b = new StockBuyProIdUpdateBatch ();
        database.executebatch(b);
    }
}