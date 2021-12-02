/*
    Restresource class which has httpPost method to send xml in salesforce from carvio to update Stock record
    @author - AEOFlex
*/
@RestResource(urlMapping='/iaai/*')
///services/apexrest/iaai
global with sharing class  IAAI_LCU_RestResource {
    
    /* Post webservice for Carvio to send Stock update  
     * @param xml : XML String 
     * return     : Error per updated Email ID
    */
    @HttpPost
    webService static String doPost() {
        RestRequest req = RestContext.request;
        
        Dom.Document doc = new Dom.Document();   
        String s = IAAI_LCU_XMLParser.xmlToJson(req.requestbody.tostring());
        Map<String, Object> parsedResponse = (Map<String, Object>) JSON.deserializeUntyped(s);
        Map<String, Object> mainNode = (Map<String, Object>) parsedResponse.get('IAAI_LCU');
        Map<String, Object> procStatus = (Map<String, Object>) mainNode.get('PROC_STATUS');
        Map<String, Object> vehicleNode = (Map<String, Object>) mainNode.get('VEHICLE');
        List<ContentNote> listContentNoteUpdated = new List<ContentNote>();
       
        if(procStatus.containsKey('VEHICLE_COMMENTS')) {
            String commentsToString = JSON.serialize(procStatus.get('VEHICLE_COMMENTS'));
            String finalString;
            if(String.isNotBlank(commentsToString)) {
                if(commentsToString.startsWith('{')) {
                    finalString = '['+commentsToString+']';
                }
            }
            List<Object> vehicleComments = new List<Object>();
            if(String.isNotBlank(finalString)) {
                vehicleComments = (List<Object>) JSON.deserializeUntyped(finalString);
            } else {
             	vehicleComments = (List<Object>) procStatus.get('VEHICLE_COMMENTS');   
            }
            
            System.debug(JSON.serialize(vehicleComments));
            if(vehicleComments!= null && !vehicleComments.isEmpty()) {
                for(Object vehicleComment : vehicleComments) {
                    Map<String, Object> vc = (Map<String, Object>) vehicleComment;
                    ContentNote cn = new ContentNote();
                    String str  = '\n Comment Date :'+ String.valueOf(vc.get('COMMENT_DATETIME')) +'\n'+'Comment Author: '+ String.valueOf(vc.get('COMMENT_AUTHOR'))+'\n'+'Comment: '+ String.valueOf(vc.get('COMMENT_TEXT'));
                    String returnStr = '<p>' + str.replaceAll('\n','</p><p>') + '</p>';
                   
                    cn.Content = Blob.valueOf(returnStr);
                    cn.Title = 'Vehicle Comments';
                    listContentNoteUpdated.add(cn);
                }
            }
        }
        
        if(procStatus.containsKey('RELEASE_PROBLEMS')) {
            String rProblemToString = JSON.serialize(procStatus.get('RELEASE_PROBLEMS'));
            String finalString1;
            if(String.isNotBlank(rProblemToString)) {
                if(rProblemToString.startsWith('{')) {
                    finalString1 = '['+rProblemToString+']';
                }
            }
            List<Object> releaseProblems = new List<Object>();
            if(String.isNotBlank(finalString1)) {
                releaseProblems = (List<Object>) JSON.deserializeUntyped(finalString1);
            } else {
             	releaseProblems = (List<Object>) procStatus.get('RELEASE_PROBLEMS');   
            }
            procStatus.put('RELEASE_PROBLEMS', releaseProblems);
            if(!releaseProblems.isEmpty()) {
                for(Object objReleaseProb : releaseProblems) {
                    //System.debug('objReleaseProb==='+objReleaseProb);
                    Map<String, Object> objReleaseProblemTemp = (Map<String, Object>) objReleaseProb;
                    Map<String, Object> vc1 = (Map<String, Object>) objReleaseProblemTemp.get('RELEASE_PROBLEM');
                    //System.debug('vc1---'+vc1.keySet()+'=='+ String.valueOf(vc1.get('RELEASE_PROBLEM_CODE')));
                    if(vc1 != null && vc1.get('RELEASE_PROBLEM_CODE') != null){
                    ContentNote cn1 = new ContentNote();
                    String str  = '\n RELEASE PROBLEM_CODE :'+ String.valueOf(vc1.get('RELEASE_PROBLEM_CODE')) +'\n'+'RELEASE PROBLEM DESCRIPTION: '+ String.valueOf(vc1.get('RELEASE_PROBLEM_DESCRIPTION'))+'\n'+'RELEASE PROBLEM OPEN DATETIME: '+ String.valueOf(vc1.get('RELEASE_PROBLEM_OPEN_DATETIME'))+'\n'+'RELEASE PROBLEM RESOLVED DATETIME: '+ String.valueOf(vc1.get('RELEASE_PROBLEM_RESOLVED_DATETIME'));
                    String returnStr1 = '<p>' + str.replaceAll('\n','</p><p>') + '</p>';
                    
                    cn1.Content = Blob.valueOf(returnStr1);
                    cn1.Title = 'Release Problems';
                    listContentNoteUpdated.add(cn1);
                    }
                }
            }
        }
        if(listContentNoteUpdated.size()>0){
            Database.insert(listContentNoteUpdated, false);
        }
        
        List<ContentNote> listContentNote = new List<ContentNote>();
        Stock__c  objStock = new Stock__c();
        String stockId; 
        String returnErrorMessage;
        if(mainNode.get('IAAI_STOCK_NUMBER') != null){
            for(Stock__c objS : [Select id from Stock__c where Stock__c =: String.valueof(mainNode.get('IAAI_STOCK_NUMBER'))]){
                stockId = objS.Id;
            }
            if(stockId == null){
                for(Stock__c objS : [Select id from Stock__c where Name =: String.valueof(mainNode.get('IAAI_STOCK_NUMBER'))]){
                stockId = objS.Id;
            }
            }
        }
        
        if(stockId != null){
            
            objStock.id = stockId;
            
            if(mainNode.get('TRAN_ID') != null ){
               objStock.TRAN_ID__c = String.valueof(mainNode.get('TRAN_ID')); 
            }
            if(mainNode.get('SENT_FROM') != null ){
               objStock.SENT_FROM__c = String.valueof(mainNode.get('SENT_FROM')); 
            }
            if(mainNode.get('CREATE_DATETIME') != null ){
               objStock.CREATE_DATETIME__c = Datetime.valueOf(String.valueOf(mainNode.get('CREATE_DATETIME')).replace('T',' ')); 
            }
           
                        
            if(vehicleNode.get('KEYS_INDICATOR')  == 'Y'){
				 objStock.KEYS_INDICATOR__c = true;  
			}else if(vehicleNode.get('KEYS_INDICATOR') == 'N'){
                objStock.KEYS_INDICATOR__c = false;   
            }
            
            if(vehicleNode.get('KEY_FOB') != null){
                 objStock.KEY_FOB__c = String.valueOf(vehicleNode.get('KEY_FOB'));
            }
            
            if(vehicleNode.get('ENGINE') != null){
                 objStock.ENGINE__c = String.valueOf(vehicleNode.get('ENGINE'));
            }
            if(vehicleNode.get('PRIMARY_DAMAGE_CODE') != null){
                 objStock.PRIMARY_DAMAGE_CODE__c = String.valueOf(vehicleNode.get('PRIMARY_DAMAGE_CODE'));
            }
            
            if(vehicleNode.get('PRIMARY_DAMAGE')  != null){
                objStock.PRIMARY_DAMAGE__c = String.valueOf(vehicleNode.get('PRIMARY_DAMAGE'));
            }
            if(vehicleNode.get('VEHICLE_TYPE')  != null){
            	objStock.VEHICLE_TYPE__c = String.valueOf(vehicleNode.get('VEHICLE_TYPE'));   
            }
            
            if(procStatus.get('PROCESS_STATUS_DESC') != null){
                objStock.PROCESS_STATUS_DESC__c = String.valueOf(procStatus.get('PROCESS_STATUS_DESC'));
            }
            
			if(procStatus.get('ASSIGNMENT_DATETIME')  != null){       
               objStock.ASSIGNMENT_DATETIME__c = Datetime.valueOf(String.valueOf(procStatus.get('ASSIGNMENT_DATETIME')).replace('T',' '));
            }
            if(procStatus.get('IAA_REQUESTED_TO_PAY_ADVANCE_CHARGES') == 'Y'){
                objStock.IAA_REQUESTED_TO_PAY_ADVANCE_CHARGES__c = true;  
            }else if(procStatus.get('IAA_REQUESTED_TO_PAY_ADVANCE_CHARGES') == 'N'){
                objStock.IAA_REQUESTED_TO_PAY_ADVANCE_CHARGES__c = false;   
            }           
           
            if(procStatus.get('SP_PREPAID_TOTAL_AMT')  != null){       
                objStock.SP_PREPAID_TOTAL_AMT__c = decimal.valueOf(String.valueOf(procStatus.get('SP_PREPAID_TOTAL_AMT')));
            }            
            if(procStatus.get('ORIGINAL_ADVANCE_CHG_MAX_AUTHORIZED_AMOUNT')  != null){       
                objStock.ORIGINAL_ADVANCE_CHG_MAX_AUTHORIZED_AMOU__c = decimal.valueOf(String.valueOf(procStatus.get('ORIGINAL_ADVANCE_CHG_MAX_AUTHORIZED_AMOUNT')));
            }
            if(procStatus.get('UPDATED_ADVANCE_CHG_MAX_AUTHORIZED_AMOUNT')  != null){ 
                objStock.UPDATED_ADVANCE_CHG_MAX_AUTHORIZED_AMOUN__c = decimal.valueOf(String.valueOf(procStatus.get('UPDATED_ADVANCE_CHG_MAX_AUTHORIZED_AMOUNT')));
            }
            if(procStatus.get('UPDATED_ADVANCE_CHG_MAX_AUTHORIZED_BY')  != null){
                objStock.UPDATED_ADVANCE_CHG_MAX_AUTHORIZED_BY__c = String.valueOf(procStatus.get('UPDATED_ADVANCE_CHG_MAX_AUTHORIZED_BY'));
            }
            if(procStatus.get('UPDATED_ADVANCE_CHG_MAX_AUTHORIZED_DATETIME')  != null){
                objStock.UPDATED_ADVANCE_CHG_MAX_AUTHORIZED_DATE__c = Datetime.valueOf(String.valueOf(procStatus.get('UPDATED_ADVANCE_CHG_MAX_AUTHORIZED_DATETIME')).replace('T',' '));
            }
            if(procStatus.get('BRANCH_DEFAULT_ADVANCE_CHG_MAX_AUTHORIZED_AMOUNT')  != null){
                objStock.BRANCH_DEFAULT_ADVANCE_CHG_MAX_AUTHORIZE__c = decimal.valueOf(String.valueOf(procStatus.get('BRANCH_DEFAULT_ADVANCE_CHG_MAX_AUTHORIZED_AMOUNT')));
            }
            if(procStatus.get('ACTUAL_RELEASE_DATETIME')  != null){
                objStock.ACTUAL_RELEASE_DATETIME__c = Datetime.valueOf(String.valueOf(procStatus.get('ACTUAL_RELEASE_DATETIME')).replace('T',' '));
            }
            if(procStatus.get('PICKUP_DATETIME')  != null){
                objStock.PICKUP_DATETIME__c = Datetime.valueOf(String.valueOf(procStatus.get('PICKUP_DATETIME')).replace('T',' '));
            }
            if(procStatus.get('DISPATCH_DATETIME')  != null){
                objStock.DISPATCH_DATETIME__c = Datetime.valueOf(String.valueOf(procStatus.get('DISPATCH_DATETIME')).replace('T',' '));
            }
            if(procStatus.get('SALVAGE_DROP_OFF_DATETIME')  != null){
                objStock.SALVAGE_DROP_OFF_DATETIME__c = Datetime.valueOf(String.valueOf(procStatus.get('SALVAGE_DROP_OFF_DATETIME')).replace('T',' '));
            }
            if(procStatus.get('STORAGE_START_DATE')  != null){
                objStock.STORAGE_START_DATE__c = Datetime.valueOf(String.valueOf(procStatus.get('STORAGE_START_DATE')).replace('T',' '));
            }
            if(procStatus.get('STORAGE_STOP_DATE')  != null){
                objStock.STORAGE_STOP_DATE__c = Datetime.valueOf(String.valueOf(procStatus.get('STORAGE_STOP_DATE')).replace('T',' '));
            }
            if(procStatus.get('CHECKIN_DATETIME')  != null){
                objStock.CHECKIN_DATETIME__c = Datetime.valueOf(String.valueOf(procStatus.get('CHECKIN_DATETIME')).replace('T',' '));
            }
            if(procStatus.get('TOTAL_ADVANCE_CHARGES')  != null){
                objStock.TOTAL_ADVANCE_CHARGES__c = decimal.valueOf(String.valueOf(procStatus.get('TOTAL_ADVANCE_CHARGES')));
            }
            if(procStatus.get('VEHICLE_INSPECTION_SERVICE') == 'Y'){
                objStock.VEHICLE_INSPECTION_SERVICE__c = true;  
            }else if(procStatus.get('VEHICLE_INSPECTION_SERVICE') == 'N'){
                objStock.VEHICLE_INSPECTION_SERVICE__c = false;   
            } 
            if(procStatus.get('VEHICLE_INSPECTION_SERVICE_DESC')  != null){
                objStock.VEHICLE_INSPECTION_SERVICE_DESC__c = String.valueOf(procStatus.get('VEHICLE_INSPECTION_SERVICE_DESC'));
            }
            if(procStatus.get('VEHICLE_IMAGES_AVAILABLE_DATETIME')  != null){ 
                objStock.VEHICLE_IMAGES_AVAILABLE_DATETIME__c = Datetime.valueOf(String.valueOf(procStatus.get('VEHICLE_IMAGES_AVAILABLE_DATETIME')).replace('T',' '));
            }
            if(procStatus.get('TOWER_IMAGES_AVAILABLE_DATETIME')  != null){ 
                objStock.TOWER_IMAGES_AVAILABLE_DATETIME__c = Datetime.valueOf(String.valueOf(procStatus.get('TOWER_IMAGES_AVAILABLE_DATETIME')).replace('T',' '));
            }
            if(procStatus.get('TITLE_REC_FROM_SALVAGE_PROVIDER_DATETIME')  != null){
                objStock.TITLE_REC_FROM_SALVAGE_PROVIDER_DATETIME__c = Datetime.valueOf(String.valueOf(procStatus.get('TITLE_REC_FROM_SALVAGE_PROVIDER_DATETIME')).replace('T',' '));
            }
            if(procStatus.get('ORIGINAL_TITLE_STATE')  != null){
                objStock.ORIGINAL_TITLE_STATE__c = String.valueOf(procStatus.get('ORIGINAL_TITLE_STATE'));
            }
            if(procStatus.get('TITLE_SENT_TO_DMV_DATETIME')  != null){
                objStock.TITLE_SENT_TO_DMV_DATETIME__c = Datetime.valueOf(String.valueOf(procStatus.get('TITLE_SENT_TO_DMV_DATETIME')).replace('T',' '));
            }
            if(procStatus.get('TITLE_TYPE')  != null){
                objStock.TITLE_TYPE__c = String.valueOf(procStatus.get('TITLE_TYPE'));
            }
            if(procStatus.get('TITLE_STATE')  != null){ 
                objStock.TITLE_STATE__c = String.valueOf(procStatus.get('TITLE_STATE'));
            }
            if(procStatus.get('TITLE_CERTIFICATE_NUMBER')  != null){
                objStock.TITLE_CERTIFICATE_NUMBER__c = String.valueOf(procStatus.get('TITLE_CERTIFICATE_NUMBER'));
            }
            if(procStatus.get('TITLE_REC_FROM_DMV_DATETIME')  != null){
                objStock.TITLE_REC_FROM_DMV_DATETIME__c = Datetime.valueOf(String.valueOf(procStatus.get('TITLE_REC_FROM_DMV_DATETIME')).replace('T',' '));
            }
            if(procStatus.get('READY_FOR_SALE_DATETIME')  != null){
                objStock.READY_FOR_SALE_DATETIME__c = Datetime.valueOf(String.valueOf(procStatus.get('READY_FOR_SALE_DATETIME')).replace('T',' '));
            }
            if(procStatus.get('AUCTION_DATETIME')  != null){
                objStock.AUCTION_DATETIME__c = Datetime.valueOf(String.valueOf(procStatus.get('AUCTION_DATETIME')).replace('T',' '));
            }
            if(procStatus.get('SOLD_DATETIME')  != null){
                objStock.SOLD_DATETIME__c = Datetime.valueOf(String.valueOf(procStatus.get('SOLD_DATETIME')).replace('T',' '));
            }
            if(procStatus.get('BUYER_PAID_DATETIME')  != null){
                objStock.BUYER_PAID_DATETIME__c = Datetime.valueOf(String.valueOf(procStatus.get('BUYER_PAID_DATETIME')).replace('T',' '));
            }
            if(procStatus.get('NICB_REPORTED_DATETIME')  != null){
                objStock.NICB_REPORTED_DATETIME__c = Datetime.valueOf(String.valueOf(procStatus.get('NICB_REPORTED_DATETIME')).replace('T',' '));
            }
            if(procStatus.get('NMVTIS_REPORTED_DATETIME')  != null){
                objStock.NMVTIS_REPORTED_DATETIME__c = Datetime.valueOf(String.valueOf(procStatus.get('NMVTIS_REPORTED_DATETIME')).replace('T',' '));
            }
            if(procStatus.get('CANCEL_REASON')  != null){
                objStock.CANCEL_REASON__c = String.valueOf(procStatus.get('CANCEL_REASON'));
            }
            if(procStatus.get('CANCELLATION_DATETIME')  != null){
                objStock.CANCELLATION_DATETIME__c = Datetime.valueOf(String.valueOf(procStatus.get('CANCELLATION_DATETIME')).replace('T',' '));
            }
            if(procStatus.get('CLOSE_DATETIME')  != null){
                objStock.CLOSE_DATETIME__c = Datetime.valueOf(String.valueOf(procStatus.get('CLOSE_DATETIME')).replace('T',' '));
            }
            
            if(procStatus.get('QUOTED_RELEASE_DATE')  != null){
            objStock.QUOTED_RELEASE_DATE__c = Datetime.valueOf(String.valueOf(procStatus.get('QUOTED_RELEASE_DATE')).replace('T',' '));
            }
            if(procStatus.get('NUMBER_OF_DAYS_OF_STORAGE')  != null){
                objStock.NUMBER_OF_DAYS_OF_STORAGE__c = decimal.valueOf(String.valueOf(procStatus.get('NUMBER_OF_DAYS_OF_STORAGE')).replace('T',' '));
            }
            
            if(procStatus.get('VEHICLE_ENHANCED') == 'Y'){
                objStock.VEHICLE_ENHANCED__c = true;  
            }else if(procStatus.get('VEHICLE_ENHANCED') == 'N'){
                objStock.VEHICLE_ENHANCED__c = false;   
            }
            
            if(procStatus.get('VEHICLE_ON_HOLD') == 'Y'){ 
                objStock.VEHICLE_ON_HOLD__c = true;  
            }else if(procStatus.get('VEHICLE_ON_HOLD') == 'N'){
                objStock.VEHICLE_ON_HOLD__c = false;   
            }
            
            update objStock;
            
            VPE_Listings__c objListingRecord =new VPE_Listings__c();
            VPE_Listings__c[] objListingRecordList = [Select id,Stock_Lookup__c,Listing_Id__c from VPE_Listings__c where Stock_Lookup__c =: objStock.Id];
            if(objListingRecordList.size()>0){
                objListingRecord = objListingRecordList[0];
            }
            
            String proStatus;
            if(procStatus.get('PROCESS_STATUS_DESC') != null){
             proStatus = String.valueOf(procStatus.get('PROCESS_STATUS_DESC'));    
            }
            
            Set<String> setStatuses = new Set<String>();
            setStatuses.addAll(System.Label.CARVIO_LCU_Statuses.Split(','));
             system.debug('------------ListingID0-----');
            if(objListingRecord != null && objListingRecord.Listing_Id__c != null && proStatus != null && setStatuses.contains(proStatus)){
               system.debug('------------ListingID-----');
            	System.enqueueJob(new IAAI_LCU_UpdateQueueable(objListingRecord.Listing_Id__c,objStock.id,procStatus));
            }
            System.debug(JSON.serialize(listContentNoteUpdated));
            if( listContentNoteUpdated.size()> 0){
                Database.Insert(listContentNoteUpdated,false);
                List<ContentDocumentLink> listCDL = new List<ContentDocumentLink>();
                for(ContentNote cnn : listContentNoteUpdated){
                    ContentDocumentLink clnk = new ContentDocumentLink();
                	clnk.LinkedEntityId = objStock.Id;
                	clnk.ContentDocumentId = cnn.Id;
                	clnk.ShareType = 'I';
                    listCDL.add(clnk);
                }
                Database.Insert(listCDL,false);
                
            }
        }else{
            returnErrorMessage = 'Stock Id in payload does not exist in salesforce!';
        }
        
        
        if(returnErrorMessage!= null){
            return returnErrorMessage;
        }else{
            return 'Salesforce Stock Records is updated successfully: '+objStock.id; 
        }

    }
  
}