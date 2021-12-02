global class StockBranchNameUpdate implements Database.batchable<sobject>, Database.Stateful{ 
    
    global Database.QueryLocator  start(Database.BatchableContext bc) {
        
        /*SELECT Branch_Name__c,payment_Branch_number__c , Branch_number__c, Id FROM Stock__c 
			WHERE (payment_Branch_number__c != null AND payment_Branch__c = Null) 
					OR (Branch_number__c != NULL AND Branch_Name__c = NULL)*/
        String query = System.Label.StockBranchUpdateQuery;    
        system.debug(' query '+query);             
        
        return Database.getQueryLocator(query);    
    }
    
    
    global void execute(Database.BatchableContext bc, List<Stock__c> lstStock){
        List<Stock__c> lstStockUpdate = new List<Stock__c>();
        List<String> BranchNumbers = new List<String>();
        Map<String,String> mapOfBranchNumAndBranchId = new Map<String,String>();
        for(Stock__c objStock : lstStock){
            if(objStock.Branch_number__c != NULL && objStock.Branch_Name__c == NULL){
                BranchNumbers.add(objStock.Branch_number__c);            
        	}
            if(objStock.payment_Branch_number__c != NULL && objStock.payment_Branch__c == NULL){
                BranchNumbers.add(objStock.payment_Branch_number__c);
            }
        }
        
        for(Branch__c objBranch : [SELECT Id, Name, Branch_Number__c From Branch__c WHERE Branch_Number__c IN: BranchNumbers]){
            mapOfBranchNumAndBranchId.put(objBranch.Branch_Number__c,objBranch.id);
        }
        for(Stock__c objStock :lstStock){
            if(mapOfBranchNumAndBranchId.containsKey(objStock.Branch_Number__c) && mapOfBranchNumAndBranchId.containsKey(objStock.payment_Branch_number__c)){
                objStock.Branch_Name__c = mapOfBranchNumAndBranchId.get(objStock.Branch_Number__c);
                objStock.Payment_Branch__c = mapOfBranchNumAndBranchId.get(objStock.Payment_Branch_number__c);
                lstStockUpdate .add(objStock);
            }else if(mapOfBranchNumAndBranchId.containsKey(objStock.payment_Branch_number__c)){
                 objStock.Payment_Branch__c = mapOfBranchNumAndBranchId.get(objStock.Payment_Branch_number__c);
                 lstStockUpdate .add(objStock);
            }else if(mapOfBranchNumAndBranchId.containsKey(objStock.Branch_Number__c)){
                objStock.Branch_Name__c = mapOfBranchNumAndBranchId.get(objStock.Branch_Number__c);
                lstStockUpdate .add(objStock);
            }
        }
        if(!lstStockUpdate.isEmpty()){
            update lstStockUpdate ;
        }
    }
    
    global void finish(Database.BatchableContext bc){
    }
    
    
}