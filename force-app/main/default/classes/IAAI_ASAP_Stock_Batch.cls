global class IAAI_ASAP_Stock_Batch implements Database.Batchable<sobject>,  Database.AllowsCallouts {

    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String statustype = 'Won';
        return Database.getQueryLocator( //and   vin__c = \'1GMDV03L95D294244\'
            //'SELECT ID,VIN__c,Wholesale_ACV__c,Make__c,Model__c,Bid_Offer_Amount_Paid__c,Model_Year__c,Original_Bid_Offer_Amount__c,Pickup_Zip__c,ASAP_Updated__c,Status_of_Listing__c,Provider_First_Name__c,Provider_Last_Name__c,Provider_Phone_Number__c,Pickup_Address__c,Pickup_street__c,Pickup_City__c,Pickup_State__c,Pickup_Phone_Number__c,Has_Keys__c,Adjuster_First_Name__c,Adjuster_Last_Name__c,Adjuster_Number__c,Handler_First_Name__c,Handler_Last_Name__c,Handler_Number__c,   Claim__c,Notes__c,Tower_Notes__c,Adj_Notes__c FROM VPE_Listings__c where ASAP_Updated__c = false and Status_of_Listing__c =:statustype Limit 50000'
            'SELECT ID,VIN__c,Wholesale_ACV__c,Make__c,Model__c,Bid_Offer_Amount_Paid__c,Model_Year__c,Original_Bid_Offer_Amount__c,Pickup_Zip__c,ASAP_Updated__c,Status_of_Listing__c,Provider_First_Name__c,Provider_Last_Name__c,Provider_Phone_Number__c,Pickup_Address__c,Pickup_street__c,Pickup_City__c,Pickup_State__c,Pickup_Phone_Number__c,Has_Keys__c, Claim__c, VPE_Listing_Partner__r.Name FROM VPE_Listings__c where ASAP_Updated__c = false and Status_of_Listing__c =:statustype Limit 50000'
        );
    }
    global void execute(Database.BatchableContext bc, List<VPE_Listings__c> records){
        list<VPE_Listings__c> listVPE = new list<VPE_Listings__c>();
        list<Stock__c> listStock = new list<Stock__c>();
        for(VPE_Listings__c v:records){
            system.debug('-----ASAP---'+v);
            IAAI_ASAP_Get_Stock imvs = new IAAI_ASAP_Get_Stock();
            if(v.VIN__c!='' && v.Pickup_Zip__c!=''){
                 system.debug('-----ASAP1---'+v);
                Stock__c ab = imvs.basicAuthCallout(v);
                ab.ACV__c = v.Wholesale_ACV__c;
                ab.Make__c = v.Make__c;
                ab.Model__c = v.Model__c;
                ab.Sale_Amount__c = v.Bid_Offer_Amount_Paid__c;
                ab.VIN__c = v.VIN__c;
                ab.Year__c = v.Model_Year__c;
                listStock.add(ab);
                v.ASAP_Updated__c = true;
                v.Stock_ID__c = ab.Stock__c;
                v.ASAP_Error__c = ab.ASAP_Error__c;
                listVPE.add(v);
            }
        } 
        if(listVPE.size()>0){
            update listVPE;
        }
        if(listStock.size()>0){
            insert listStock;
            system.debug('Inserted stock'+listStock);
        }
    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }    
}