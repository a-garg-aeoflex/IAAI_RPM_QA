global class StockBidContactAssociationSchedule  implements Schedulable { 
    global void execute(SchedulableContext SC) { 
        StockBidContactAssociationBatch objSCA = new StockBidContactAssociationBatch();         
        Database.executeBatch(objSCA); 
    }
}