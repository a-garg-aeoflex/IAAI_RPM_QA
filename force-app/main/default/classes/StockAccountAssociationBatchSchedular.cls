global class StockAccountAssociationBatchSchedular implements Schedulable{

    global void execute(SchedulableContext sc){

        StockAccountAssociationBatch b = new StockAccountAssociationBatch ();
        database.executebatch(b);
    }
}