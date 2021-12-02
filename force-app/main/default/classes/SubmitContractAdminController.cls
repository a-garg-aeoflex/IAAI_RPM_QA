public without sharing class SubmitContractAdminController {
    
    public class checkMedatoryFieldAccount{
        @AuraEnabled public Boolean allMandatoryFilled;
        @AuraEnabled public String mandatoryFields;
         public checkMedatoryFieldAccount(){}
         
    }
    @AuraEnabled(cacheable=true)
	public static checkMedatoryFieldAccount getCurrentAccount(Id accountId) {
        checkMedatoryFieldAccount objCFA = new checkMedatoryFieldAccount();
        objCFA.allMandatoryFilled = true;
        objCFA.mandatoryFields = '';
        system.debug('Current Account Id  '+accountId);
        Boolean allMandatoryFilled =  True;
		Account objCurrentAcc = [SELECT Id, Name, Branch__c, VRD_Level__c, Phone, FEIN__c, IBuyFast_Manual_Auto__c,
                                 		ShippingStreet, ShippingCity, ShippingState, ShippingCountry, 
                                 		ShippingPostalCode
                                 FROM Account
                                 WHERE Id =: accountId Limit 1];
       
       system.debug('objCurrentAcc '+ objCurrentAcc);
        if(objCurrentAcc.Branch__c == Null ){
            allMandatoryFilled = False;   
             system.debug('objCurrentAcc 1');
            objCFA.allMandatoryFilled = False;
            if(objCFA.mandatoryFields == ''){
                 objCFA.mandatoryFields ='Branch';
            }else{
                objCFA.mandatoryFields =  objCFA.mandatoryFields+', <BR />'+ 'Branch';
            }
        	
        }
       /* if(objCurrentAcc.IBuyFast_Manual_Auto__c == Null ){
             allMandatoryFilled = False;
            system.debug('objCurrentAcc 2');
            objCFA.allMandatoryFilled = False;
            if(objCFA.mandatoryFields == ''){
                 objCFA.mandatoryFields ='IBuyFast Manual/Auto';
            }else{
                objCFA.mandatoryFields =  objCFA.mandatoryFields+', <BR />'+ 'IBuyFast Manual/Auto';
            }
        	
        }*/
        /*if(objCurrentAcc.Name == Null || objCurrentAcc.Name == ''){
             allMandatoryFilled = False;
            system.debug('objCurrentAcc 3');
            objCFA.allMandatoryFilled = False;
            if(objCFA.mandatoryFields == ''){
                 objCFA.mandatoryFields ='Name';
            }else{
                objCFA.mandatoryFields =  objCFA.mandatoryFields+', <BR />'+ 'Name';
            }
        }*/
        	
        if(objCurrentAcc.FEIN__c == Null || objCurrentAcc.FEIN__c == '' ){
             allMandatoryFilled = False;
            system.debug('objCurrentAcc 4');
            objCFA.allMandatoryFilled = False;
            if(objCFA.mandatoryFields == ''){
                 objCFA.mandatoryFields ='FEIN';
            }else{
                objCFA.mandatoryFields =  objCFA.mandatoryFields+', <BR />'+ 'FEIN';
            }        	
        }
        if(objCurrentAcc.VRD_Level__c == Null || objCurrentAcc.VRD_Level__c == ''){
            allMandatoryFilled = False;
            system.debug('objCurrentAcc 5');
            objCFA.allMandatoryFilled = False;
            if(objCFA.mandatoryFields == ''){
                 objCFA.mandatoryFields ='VRD Level';
            }else{
                objCFA.mandatoryFields =  objCFA.mandatoryFields+', <BR />'+ 'VRD Level';
            }    	
        }
        if(objCurrentAcc.Phone == Null || objCurrentAcc.Phone == ''){
            allMandatoryFilled = False;
            system.debug('objCurrentAcc 6');
            objCFA.allMandatoryFilled = False;
            if(objCFA.mandatoryFields == ''){
                 objCFA.mandatoryFields ='Phone';
            }else{
                objCFA.mandatoryFields =  objCFA.mandatoryFields+', <BR />'+ 'Phone';
            }         	
        }       
        if(objCurrentAcc.ShippingStreet == Null || objCurrentAcc.ShippingStreet == ''){
            allMandatoryFilled = False;
            system.debug('objCurrentAcc 7');
            objCFA.allMandatoryFilled = False;
             if(objCFA.mandatoryFields == ''){
                 objCFA.mandatoryFields ='Shipping Street';
            }else{
                objCFA.mandatoryFields =  objCFA.mandatoryFields+', <BR />'+ 'Shipping Street';
            }   
        	//objCFA.mandatoryFields =  objCFA.mandatoryFields+', <BR />'+ 'Shipping Street';
        } 
        if(objCurrentAcc.ShippingCity == Null || objCurrentAcc.ShippingCity == ''){
            allMandatoryFilled = False;
            system.debug('objCurrentAcc 8');
             objCFA.allMandatoryFilled = False;
            if(objCFA.mandatoryFields == ''){
                 objCFA.mandatoryFields ='Shipping City';
            }else{
                objCFA.mandatoryFields =  objCFA.mandatoryFields+', <BR />'+ 'Shipping City';
            }   
        	//objCFA.mandatoryFields =  objCFA.mandatoryFields+', <BR />'+ 'ShippingCity';
        } 
        if(objCurrentAcc.ShippingState == Null || objCurrentAcc.ShippingState == ''){
            allMandatoryFilled = False;
            system.debug('objCurrentAcc 10');
            objCFA.allMandatoryFilled = False;
            if(objCFA.mandatoryFields == ''){
                 objCFA.mandatoryFields ='Shipping State';
            }else{
                objCFA.mandatoryFields =  objCFA.mandatoryFields+', <BR />'+ 'Shipping State';
            }   
        	//objCFA.mandatoryFields =  objCFA.mandatoryFields+', <BR />'+ 'ShippingState';
        } 
        if(objCurrentAcc.ShippingCountry == Null || objCurrentAcc.ShippingCountry == ''){
            allMandatoryFilled = False;
            system.debug('objCurrentAcc 9');
             objCFA.allMandatoryFilled = False;
            if(objCFA.mandatoryFields == ''){
                 objCFA.mandatoryFields ='Shipping Country';
            }else{
                objCFA.mandatoryFields =  objCFA.mandatoryFields+', <BR />'+ 'Shipping Country';
            }   
        	//objCFA.mandatoryFields =  objCFA.mandatoryFields+', <BR />'+ 'ShippingCountry';
        } 
        
        if(objCurrentAcc.ShippingPostalCode == Null || objCurrentAcc.ShippingPostalCode == ''){
            allMandatoryFilled = False;
            system.debug('objCurrentAcc 11');
             objCFA.allMandatoryFilled = False;
            if(objCFA.mandatoryFields == ''){
                 objCFA.mandatoryFields ='Shipping PostalCode';
            }else{
                objCFA.mandatoryFields =  objCFA.mandatoryFields+', <BR />'+ 'Shipping PostalCode';
            }  
        	//objCFA.mandatoryFields =  objCFA.mandatoryFields+', <BR />'+ 'ShippingPostalCode';
        } 
        
        List<ContentDocumentLink> listCDL = [SELECT ContentDocumentId, Id, IsDeleted, LinkedEntityId, ShareType,
                                  		 	SystemModstamp, Visibility 
                                  	FROM ContentDocumentLink 
                                  	WHERE LinkedEntityId =:objCurrentAcc.Id];
      List<Id> lstContentDocumentlist = new List<Id>();
      for(ContentDocumentLink objCDL : listCDL){
          lstContentDocumentlist.add(objCDL.ContentDocumentId);
      }
       system.debug('lstContentDocumentlist '+lstContentDocumentlist);
      list<ContentVersion> listCV = new list<ContentVersion>();
       ContentDocument objCD = new ContentDocument();
      if(!listCDL.isEmpty()){
         	listCV = [SELECT Checksum, ContentBodyId, ContentDocumentId, ContentLocation, ContentModifiedById,
                   		  ContentModifiedDate, ContentSize, ContentUrl, CreatedById, CreatedDate, Description, Document_Type__c,
                   		  ExternalDataSourceId, ExternalDocumentInfo1, ExternalDocumentInfo2, FeaturedContentBoost,
                   		  FeaturedContentDate, FileExtension, FileType, FirstPublishLocationId, Id, IsAssetEnabled,
                   		  IsDeleted, IsLatest, IsMajorVersion, LastModifiedById, LastModifiedDate, NegativeRatingCount,
                   		  Origin, OwnerId, PathOnClient, PositiveRatingCount, PublishStatus, RatingCount, ReasonForChange,
                   		  SharingOption,SharingPrivacy,SystemModstamp,TagCsv,TextPreview,Title,VersionData, VersionNumber 
                   FROM ContentVersion
                   WHERE Document_Type__c = 'W-9'AND ContentDocumentId IN : lstContentDocumentlist Order By LastModifiedDate DESC  Limit 1];
     }
      system.debug('listCV '+listCV);  
      if(listCV.isEmpty() ){
        	allMandatoryFilled = False;
            system.debug('objCurrentAcc 13');
            objCFA.allMandatoryFilled = False;
          if(objCFA.mandatoryFields == ''){
                 objCFA.mandatoryFields ='please upload W9 Document through W9 Attachment button';
            }else{
                objCFA.mandatoryFields =  objCFA.mandatoryFields+', <BR />'+ 'please upload W9 Document through W9 Attachment button';
            }  
        	//objCFA.mandatoryFields =  objCFA.mandatoryFields+', <BR />'+ 'please Upload W9 Document';
      }
     
       system.debug('objCFA '+ objCFA);
       //return allMandatoryFilled;
       return objCFA;
		
	}
    @AuraEnabled(cacheable=False)
    public static void submitApprovalProcess(String currentRecordId){
        String accountId = currentRecordId;
        Account upAcc = [Select Id, Account_Owner_Approver__c,Account_Owner_Requester__c,Approval_Status__c From Account WHERE Id =:accountId ];
        
        String userId = userInfo.getUserId();
            User logedInUser =[SELECT ManagerId FROM User where Id =: userId Limit 1];
        upAcc.Account_Owner_Approver__c = logedInUser.ManagerId;
        upAcc.Account_Owner_Requester__c = logedInUser.Id;
        upAcc.Approval_Status__c = 'Initiated from contact admin';
        update upAcc;
            Approval.ProcessSubmitRequest appReq = new Approval.ProcessSubmitRequest();
        	appReq.setComments('Submitting request for approval.');
        	appReq.setObjectId(accountId);
            appReq.setSubmitterId(upAcc.Account_Owner_Requester__c); 
            appReq.setProcessDefinitionNameOrId('SubmitContractAdminApproval');
        	appReq.setSkipEntryCriteria(true);            
            appReq.setNextApproverIds(new Id[] {upAcc.Account_Owner_Approver__c});
            Approval.ProcessResult result = Approval.process(appReq); 
    }
    @AuraEnabled(cacheable=false)
	public static void updateContentVersion(Id accountId, string documentId) {
       ContentVersion objConVer = [SELECT ContentBodyId,ContentDocumentId,ContentUrl,Document_Type__c,VersionData,VersionNumber 
        							FROM ContentVersion 
        							WHERE ContentDocumentId =: documentId];
        objConVer.Document_Type__c = 'W-9';
        system.debug(' objConVer '+objConVer);
        update objConVer;
    }
}