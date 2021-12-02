/******************************************************************************************************
 * @Class Name:- StockBidContactAssociationBatch
 * @Description :- This class is used on Stock Bid object to update record in Btach
******************************************************************************************************/


global class StockBidContactAssociationBatch implements Database.Batchable<sObject> {
  
    global Database.QueryLocator start(Database.BatchableContext BC) {
       /**   Query is written in Custom Label ***/
       String query = Label.StockBidContactAssociationBatch;
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext BC, List<Stock_Bid__c> stockList) {     
        List<Stock_Bid__c> lstStockbid = new List<Stock_Bid__c>();
        List<String> lstIdStock = new List<String>();
        Set<String> setStockbid = new Set<String>();
        Map<String, Contact> mapContactIdCon = new Map<String, Contact>();
        Map<String, Stock_bid__c> mapStockNameStockBidStockNm = new Map<String, Stock_bid__c>();
        
		for(Stock_Bid__c objStkbd : stockList){
			mapStockNameStockBidStockNm.put(objStkbd.Stock__c,objStkbd);
			lstIdStock.add(objStkbd.stock__c);
            if(!String.isBlank(objStkbd.Buyer_Employee_Id__c) && String.isBlank(objStkbd.Bidder_Contact__c)){             
                setStockbid.add(objStkbd.Buyer_Employee_Id__c);               
                lstStockbid.add(objStkbd);
            }
            
        }
        for(Contact objCon : [SELECT Id, Name, Buyer_Employee_ID__c
                              FROM Contact
                              WHERE Buyer_Employee_ID__c IN: setStockbid]){
                              
                mapContactIdCon.put(objCon.Buyer_Employee_ID__c, objCon);
        }
        for(Stock_Bid__c objStockBid :lstStockbid){
           /* system.debug('objStockBid.Buyer_Employee_Id__c '+objStockBid.Buyer_Employee_Id__c);
            system.debug('mapContactIdCon.get(objStockBid.Buyer_Employee_Id__c) '+mapContactIdCon.get(objStockBid.Buyer_Employee_Id__c));*/
            if(mapContactIdCon.get(objStockBid.Buyer_Employee_Id__c) <> null){
                objStockBid.Bidder_Contact__c = mapContactIdCon.get(objStockBid.Buyer_Employee_Id__c).Id;
            }
        }
        List<Stock__c> lstStock = new List<Stock__c>();
		system.debug('Stock bid Stock '+lstIdStock.size());
        for(Stock__c objStockRec : [SELECT Id, Name,Stock_Bid__c FROM Stock__c WHERE Name IN: lstIdStock AND Stock_Bid__c = NULL]){
            if( mapStockNameStockBidStockNm.get(objStockRec.Name) <> null){
                objStockRec.Stock_Bid__c = mapStockNameStockBidStockNm.get(objStockRec.Name).Id;
            	lstStock.add(objStockRec);
            }
            
        
        }
        try {
            if(!lstStockbid.isEmpty()){
               /* for(Stock_Bid__c objStockBid :lstStockbid){
                    system.debug('objStockBid.Buyer_Employee_Id__c '+objStockBid.Buyer_Employee_Id__c);
                }*/
                update lstStockbid;
            }
            system.debug('Size of Stock list '+lstStock.size());
            if(!lstStock.isEmpty()){
              for(Stock__c objStock :lstStock){
                    system.debug('Stock Id '+objStock.Id +'Stock name '+objStock.Name+'Stock Bid Id '+objStock.stock_bid__c);
                }
                update lstStock;
            }
            
         
        } catch(Exception e) {
            System.debug(e);
        }
         
    }   
     
    global void finish(Database.BatchableContext BC) {       
  }
}