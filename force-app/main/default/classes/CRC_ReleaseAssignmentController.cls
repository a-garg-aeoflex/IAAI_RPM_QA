public without sharing class CRC_ReleaseAssignmentController {
 
  
    @AuraEnabled
    public static void checkInCheckOutMethod(String recId, String operation){
        
        if(operation == 'checkOut')
        {
            CRC_Constants.REFRESH_AND_CHECKOUT = true;
            try{
                RPM_APIController.refreshFromRPM(recId); 
                Database.executeBatch(new CRC_Priority_Update()); 
            }catch(Exception e){
                throw new AuraHandledException(e.getMessage());
            }
            
        }else if(operation == 'checkIn')
        {
            String queueid = CRC_Constants.CRC_PRIORITY_ASSIGNMENTS;
            Case c = new case();
            c.id = recId;
            c.ownerid = queueid;
            try{
                Database.update(c);
                EventBus.publish(new Console_Tab__e(Refresh_Successful__c=true)); //Added by Anuj on 25th Nov, 21 as part of testing
                Database.executeBatch(new CRC_Priority_Update());
            }catch(Exception e){ 
                throw new AuraHandledException(e.getMessage());
            }
           
        }
    }

    @AuraEnabled
    public static string releaseVehicleCheck(String recId){
        
       Case objCase = [Select Id,Status from Case where id =: recId];

       if(objCase.status == 'Release Problem'){
            throw new AuraHandledException('You cannot release the vehicle as there are open release problems associated with it'); 
       }
       if(objCase.status == 'Wait Dispatch'){
            throw new AuraHandledException('This vehicle has already been released. You cannot re-release the vehicle');
       }

        return 'Success';
    }

    @AuraEnabled
    public static Map<String,Object> releaseVehicle(String recId,Map<String,object> request){
  
          Case objCase = [Select Id,Stock__r.Name,CRC_Salvage_Id__c,CRC_Charges_Cleared__c,CRC_Checksum__c from Case where id =: recId];
                if(objCase != null){
                    request.put('IAAI_STOCK_NUMBER',objCase.Stock__r.Name);
                    request.put('SALVAGE_ID',objCase.CRC_Salvage_Id__c);
                    request.put('CHECKSUM',objCase.CRC_Checksum__c);
                    request.put('VR_CHARGES_CLEARED',objCase.CRC_Charges_Cleared__c);
                    request.put('Id',recId);
                }
                if(request.get('VR_NOTE_DESCRIPTION') != null){
                    request.put('CRC_Note_Category__c','DSP');
                    request.put('Description',request.get('VR_NOTE_DESCRIPTION'));
                }


            try {
                Map<String, Object> response = new Map<String, Object>();
                RPM_ReleaseAssignmentController.BasicHttpBinding_IAssignment obj = new RPM_ReleaseAssignmentController.BasicHttpBinding_IAssignment();
                Blob headerValue = Blob.valueOf(CRC_Constants.RPM_CREDENTIALS.DeveloperName + ':' + CRC_Constants.RPM_CREDENTIALS.Password__c);
                String authorizationHeader = 'BASIC '+ EncodingUtil.base64Encode(headerValue);
                Map<String,String> inputHeaderMap = new  Map<String,String>();
                inputHeaderMap.put('Authorization', authorizationHeader);
                obj.inputHttpHeaders_x = inputHeaderMap;
                obj.timeout_x = Integer.valueOf(CRC_Constants.RPM_CREDENTIALS.Callout_Time_Limit__c);
                String soapResponse = obj.IAAI_ASSIGNMENT_INFO(CRC_RPM_RequestHelper.releaseVehiclePost(request), CRC_Constants.RPM_CREDENTIALS.DeveloperName);
                System.debug(soapResponse);
                //response = response.put('response', soapResponse);
                response = CRC_RPM_RequestHelper.parseRPMResponse(soapResponse);
                    if(response.get('STATUS_CODE') == 'ACCEPT'){
                        Map<String, Object> result = RPM_APIController.RPM_AddUserNotes(request);
                    }
                RPM_APIController.createLog('Saleforce', 'RPM', 'manageReleaseProblem',  'request', soapResponse, 'http://uat.eai.iaai.com/IAAI.Services/Assignment.svc', 'Success');
                
                return response;

            } catch (Exception e) {
                System.debug(e.getMessage()+'---'+e.getStackTraceString());
                throw new AuraHandledException(e.getMessage());
            }
        

    }
    
   

    @AuraEnabled
    public static Map<String, Object> getCaseContactData(String rAId){
        try { 
            Case cs = [Select Id,CRC_Claim__c,CRC_Policy__c,CRC_Date_of_Loss__c,CRC_Provider_SLA__c,
                        Branch__c,Branch__r.Name,CRC_Branch_Manager__r.Name,OwnerId, Owner.Name,Owner.Email, CRC_VO_First_Name__c, CRC_VO_Last_Name__c,
                        CRC_VO_Email__c, CRC_VO_Primary_Phone_Number__c, CRC_VO_Primary_Phone_Type__c, CRC_VO_Secondary_Phone_Number__c, 
                        CRC_VO_Secondary_Phone_Type__c, CRC_VO_Address_Line_1__c, CRC_VO_Fax__c, 
                        CRC_VO_Zip__c, CRC_VO_City__c, CRC_VO_Primary_Extension__c, CRC_Salvage_Id__c, CRC_Checksum__c,
                        Stock__r.Stock__c, Account.Name , CRC_Branch_Manager__r.FirstName, CRC_Branch_Manager__r.LastName, 
                        CRC_Branch_Manager__r.RecordType.Name, CRC_Branch_Manager__r.Email, CRC_Branch_Manager__r.Fax, CRC_Branch_Manager__r.Type__c, 
                        CRC_Branch_Manager__r.Phone, CRC_Release_Problem_Email__c, CRC_Branch_Manager__r.OtherPhone, 
                        CRC_Branch_Manager__r.MailingStreet, CRC_Branch_Manager__r.MailingCity, CRC_Branch_Manager__r.MailingState, 
                        CRC_Branch_Manager__r.MailingPostalCode, CRC_Branch_Manager__r.MailingCountry, CRC_Pickup_Location_Type__c, 
                        CRC_Adjuster__c, CRC_Adjuster__r.Name, CRC_Adjuster__r.FirstName, CRC_Adjuster__r.LastName, CRC_Adjuster__r.Email, 
                        CRC_Adjuster__r.Fax, CRC_Adjuster__r.Phone, CRC_Adjuster__r.OtherPhone, CRC_Adjuster__r.MailingStreet, CRC_Stock_Number__c,
                        CRC_Adjuster__r.MailingCity, CRC_Adjuster__r.MailingState, CRC_Adjuster__r.MailingPostalCode, CRC_Adjuster__r.MailingCountry    
                        FROM Case 
                        WHERE Id =: RAId Limit 1];
            return new Map<String, Object> {
                'case'          =>  cs,
                'branchManager' =>  (String.isNotBlank(cs.CRC_Branch_Manager__c) ? cs.CRC_Branch_Manager__r : null),
                'adjuster'  =>  cs.CRC_Adjuster__r
            };
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


 
}