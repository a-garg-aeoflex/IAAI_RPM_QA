global class StockBranchNameUpdateSch implements Schedulable 
{
     global void execute(SchedulableContext sc) 
    {
        StockBranchNameUpdate objStockBranchNameUpdate = new StockBranchNameUpdate(); 
        Database.executebatch(objStockBranchNameUpdate);
    }
   
}