public class RPM_APIControllerHelper {

    public static String currentStockNumber;

    public static Map<String, Object> mainNode  {get;set;}
    public static Map<String, Object> mapRLSE_ASN  {get;set;}
    public static Map<String, Object> mapSTORAGE_DTL  {get;set;}
    public static Map<String, Object> mapProvider  {get;set;}
    public static Map<String, Object> mapSalvor  {get;set;}
    public static Map<String, Object> mapVehicle  {get;set;}
    public static Map<String, Object> mapProcStatus  {get;set;}
    public static Map<String, Object> mapRelease  {get;set;}
    public static Map<String, Object> mapVehicleLocation  {get;set;}
    public static Map<String, Object> claimRep  {get;set;}
    public static Map<String, Object> branchContact  {get;set;}
   
    //Record Types 
    public static String contactRecordTypeId;
    public static String notesOnTaskRecordTypeId;
    public static String releaseProblemOnTaskRecordType;
    public static String storageLocationAccountRecordType;
    public static String providerAccountRecordType;
    
    public static String RPM_PraseXML(String strXML,String checksumValue,String callFrom) {
         
        String response = IAAI_LCU_XMLParser.xmlToJson(strXML);
        // String currentStockNumber; 
        Map<String, Object> parsedResponse = (Map<String, Object>) JSON.deserializeUntyped(response);
        //Main Node
        mainNode = (Map<String, Object>) parsedResponse.get('IAAI_ASSIGNMENT_INFO');
        mapRLSE_ASN = (Map<String, Object>) mainNode.get('RLSE_ASN');
        

        Case currentReleaseAssignment = new Case();
        Account storageLocation = new Account(); 
        Account objSalvageProviderAccount = new Account();
        Branch__c objBranch = new Branch__c();
        Contact crcAdjusterContact = new Contact();
        Contact crcVehicleOwnerContact = new Contact();
        Contact crcBranchManagerContact = new Contact();
        List<Contact> listContactsToUpsert = new List<Contact>();
        map<String,Task>  mapReleseProblem = new Map<String,Task>();
        map<String,Task>  mapNotes = new Map<String,Task>();
        List<Task> listReleaseProblem = new List<Task>();
        List<Task> listNotesToCreate = new List<Task>();
        List<Variable_Storage_Charge__c> listofVariableStorage = new List<Variable_Storage_Charge__c>();
        List<Release_Charge__c> listofReleaseCharges = new List<Release_Charge__c>();

        //Init Record Type Ids
        notesOnTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CRC_Note').getRecordTypeId();
        releaseProblemOnTaskRecordType = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CRC_Release_Problem').getRecordTypeId();
        contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('ASAP RPM Contact').getRecordTypeId();
        storageLocationAccountRecordType =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Storage Location').getRecordTypeId();
        providerAccountRecordType =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Provider Account').getRecordTypeId();

        String checkSum;
        
        //Get checksum from xml to check if we have any new changes. 
        if(String.valueOf(mapRLSE_ASN.get('CHECKSUM')) != null){
            checkSum = String.valueOF(mapRLSE_ASN.get('CHECKSUM'));
        }
        
        if(mainNode.get('IAAI_STOCK_NUMBER') != null){
            currentStockNumber = String.valueOF(mainNode.get('IAAI_STOCK_NUMBER'));
            if(currentStockNumber != null){
                Stock__c[] objStock = [Select id from Stock__c where Name =: currentStockNumber];
                List<Case> listofCases = [Select Id,Stock__c,Stock__r.Name,AccountId,CRC_Storage_Location__c,CRC_Adjuster__c,Branch__c,CRC_Branch_Manager__c,ContactId,
                                        (Select id,Name from Release_Charges__r),(Select id  from Variable_Storage_Charges__r) From Case where Stock__r.Name =: currentStockNumber];
                if(listofCases.size() > 0 ){
                    currentReleaseAssignment = listofCases[0];
                }
                if(objStock.size() > 0){
                    currentReleaseAssignment.CRC_Stock_Number__c = String.valueOf(mainNode.get('IAAI_STOCK_NUMBER'));
                    currentReleaseAssignment.Stock__c = objStock[0].Id;
                }
            }
            if(currentReleaseAssignment != null && currentReleaseAssignment.AccountId != null){
                objSalvageProviderAccount.Id = currentReleaseAssignment.AccountId;
            }
            if(currentReleaseAssignment != null && currentReleaseAssignment.CRC_Storage_Location__c != null){
                storageLocation.id = currentReleaseAssignment.CRC_Storage_Location__c;
            }

            if(currentReleaseAssignment != null && currentReleaseAssignment.CRC_Adjuster__c != null){
                crcAdjusterContact.id = currentReleaseAssignment.CRC_Adjuster__c;
            }
            if(currentReleaseAssignment != null && currentReleaseAssignment.CRC_Branch_Manager__c != null){
                crcBranchManagerContact.id = currentReleaseAssignment.CRC_Branch_Manager__c;
            }
            if(currentReleaseAssignment != null && currentReleaseAssignment.Branch__c != null){
                objBranch.Id = currentReleaseAssignment.Branch__c;
            }
            if(currentReleaseAssignment != null && currentReleaseAssignment.Id != null){
                for(Task objTask : [Select id,Release_Problem_Code__c,CRC_Comment_DateTime_Text__c,CRC_Comment_Author__c,CRC_Comment_ID__c,RP_Follow_Up_Date_Time__c,Description,RecordTypeId,Status,Subject,Type,WhatId,WhoId from Task 
                                    where whatid =: currentReleaseAssignment.Id and (RecordTypeId =:releaseProblemOnTaskRecordType OR  RecordTypeId =:notesOnTaskRecordTypeId)]){
                    if(objTask.recordTypeId == releaseProblemOnTaskRecordType){
                        mapReleseProblem.put(String.valueOf(objTask.CRC_Comment_DateTime_Text__c), objTask);
                    }else if(objTask.recordTypeId == notesOnTaskRecordTypeId){
                        mapNotes.put(String.valueof(objTask.CRC_Comment_DateTime_Text__c),objTask);
                     
                    }
                }

            }
        }
        
        if(callFrom == 'RPM'){
            RPM_API_RestResource.apiError = null;
            RPM_API_RestResource.apiStockNumber = String.valueOf(mainNode.get('IAAI_STOCK_NUMBER'));
            RPM_API_RestResource.apiTRANS_ID = String.valueOf(mainNode.get('TRAN_ID'));
            RPM_API_RestResource.apitransactionType = String.valueOf(mainNode.get('TRANSACTION_TYPE'));
         }
       
        /*if(checkSum == checksumValue){ 
            throw new CRC_Exception('No New updates on the records');
        }else*/
            if(currentStockNumber != null  && currentReleaseAssignment.Stock__c == null && mainNode.get('IAAI_STOCK_NUMBER') != null){
                
                Stock__c objStock = new  Stock__c();
                objStock.Stock__c = String.valueOf(mainNode.get('IAAI_STOCK_NUMBER'));
                objStock.Name = String.valueOf(mainNode.get('IAAI_STOCK_NUMBER'));
                insert objStock;
                currentReleaseAssignment.Stock__c = objStock.id;
                currentReleaseAssignment.CRC_Stock_Number__c = String.valueOf(mainNode.get('IAAI_STOCK_NUMBER'));
            }
            //Level 2 nodes
            mapSTORAGE_DTL = (Map<String, Object>) mainNode.get('STORAGE_DTL');
            //Level 3 nodes under RLSE_ASN
            mapProvider = (Map<String, Object>) mapRLSE_ASN.get('PROVIDER');
            mapSalvor = (Map<String, Object>) mapRLSE_ASN.get('SALVOR');
            mapVehicle = (Map<String, Object>) mapRLSE_ASN.get('VEHICLE');
            mapProcStatus = (Map<String, Object>) mapRLSE_ASN.get('PROC_STATUS');
            mapRelease = (Map<String, Object>) mapRLSE_ASN.get('RELEASE');
            system.debug('---mapRelease--'+mapRelease);
            //level 3 nodes under STORAGE_DTL
            mapVehicleLocation = (Map<String, Object>) mapSTORAGE_DTL.get('VEHICLE_LOCATION');
            claimRep = (Map<String, Object>) mapProvider.get('CLAIM_REP');
            branchContact = (Map<String, Object>) mapSalvor.get('BRANCH');
           
           //Salvage Provider - Standard Account
            objSalvageProviderAccount = RPM_PraseSalvageProvider(mainNode,objSalvageProviderAccount);
            //if(mainNode.containsKey('CRC_Provider_SLA__c')) {
            //    currentReleaseAssignment.CRC_Provider_SLA__c = String.valueOf(mainNode.get('CRC_Provider_SLA__c'));
            //}
            upsert objSalvageProviderAccount;

            //Branch
            objBranch = RPM_PraseBranch(objBranch);
            upsert objBranch;

            
            if(claimRep!= null){
                 crcAdjusterContact = RPM_PraseSalvageProviderContact(crcAdjusterContact,objSalvageProviderAccount);
                 listContactsToUpsert.add(crcAdjusterContact);
            }
            

            //CRC Branch manager
            if(branchContact != null){
                crcBranchManagerContact = RPM_BranchManagerContact(crcBranchManagerContact,objBranch);
                listContactsToUpsert.add(crcBranchManagerContact);
            }
            
            upsert listContactsToUpsert;
            
            //Storage Location field updates
            if(mapVehicleLocation.get('PICKUP_LOCATION_TYPE') != null && mapVehicleLocation.get('PICKUP_LOCATION_TYPE') == 'BUSINESS'){
                storageLocation = RPM_PraseStorageLocation(storageLocation);
                if(storageLocation.Name == null || storageLocation.Name == ''){
                    storageLocation.Name = 'TBD';
                }
                upsert storageLocation;
            }

            listReleaseProblem = RPM_PraseReleaseProblems(mapReleseProblem,currentReleaseAssignment);
            List<Task> combinedReleaseProblems = new List<Task>();
            combinedReleaseProblems.addAll(listReleaseProblem);
            combinedReleaseProblems.addAll(mapReleseProblem.values());
            if(combinedReleaseProblems.size()>0){
                DateTime latestfollowupdatetime;
                for(Task objTask : combinedReleaseProblems){
                    system.debug(latestfollowupdatetime);
                        if(objTask.RP_Follow_Up_Date_Time__c > System.now()  &&  objTask.Status == 'In Progress'){
                            if(latestfollowupdatetime != null && objTask.RP_Follow_Up_Date_Time__c  < latestfollowupdatetime){
                                latestfollowupdatetime = objTask.RP_Follow_Up_Date_Time__c ;
                            }else if(latestfollowupdatetime == null ){
                                latestfollowupdatetime = objTask.RP_Follow_Up_Date_Time__c;
                            }
                    } 
                }
                
                if(latestfollowupdatetime != null){
                    currentReleaseAssignment.CRC_Release_Problem_Follow_Up_Datetime__c = latestfollowupdatetime;
                }

            }
            
            //Case - Release Assignments fields update
            currentReleaseAssignment = RPM_PraseCurrentReleaseAssignment(currentReleaseAssignment);
            
            if(currentReleaseAssignment.AccountId == null && objSalvageProviderAccount != null && objSalvageProviderAccount.id != null ){
                currentReleaseAssignment.AccountId = objSalvageProviderAccount.id;
            }

            if(currentReleaseAssignment.CRC_Storage_Location__c == null && storageLocation!=null && storageLocation.id != null ){
                currentReleaseAssignment.CRC_Storage_Location__c = storageLocation.id;
            }

            Map<String, String> relatedContacts = getRelatedContacts();
            if(crcAdjusterContact != null ){
                currentReleaseAssignment.CRC_Adjuster__c = relatedContacts.get(CRC_Constants.STORAGE_LOCATION_CONTACT_ADJUSTER_TYPE+'---'+crcAdjusterContact.CRC_Storage_Location_Id__c);
            }

            if(crcBranchManagerContact != null){
                currentReleaseAssignment.CRC_Branch_Manager__c = relatedContacts.get(CRC_Constants.STORAGE_LOCATION_CONTACT_BRANCH_MANAGER_TYPE+'---'+crcBranchManagerContact.CRC_Storage_Location_Id__c);
            }

            if(currentReleaseAssignment.Branch__c == null && objBranch != null ){
                currentReleaseAssignment.Branch__c = objBranch.id;
            }

            if(CRC_Constants.REFRESH_AND_CHECKOUT == true){
                currentReleaseAssignment.ownerid = UserInfo.getUserId();
            }
            if(currentReleaseAssignment.Status != 'Release Problem'){
                currentReleaseAssignment.CRC_Release_Problem_Follow_Up_Datetime__c = null;
            }
            
            Upsert currentReleaseAssignment;
            
            //Check if storage rate type = VAR mapRelease.get('VARIABLE_STORAGE_RATE_INFO')
            if(currentReleaseAssignment.Variable_Storage_Charges__r.size()>0){
                list<Variable_Storage_Charge__c> listVarC = currentReleaseAssignment.Variable_Storage_Charges__r;
                delete listVarC;
            }
            
            if(mapRelease.get('VR_STORAGE_RATE_TYPE_CODE') != null && String.valueOf(mapRelease.get('VR_STORAGE_RATE_TYPE_CODE')) == 'VAR'){
               listofVariableStorage = RPM_PraseVariableStorageCharges(currentReleaseAssignment);
            }
            if(currentReleaseAssignment.Release_Charges__r.size()>0){
                list<Release_Charge__c> listrelC = currentReleaseAssignment.Release_Charges__r;
                delete listrelC;
            }
            if(mapRelease.get('VR_EXPENSES') != null ){
                listofReleaseCharges = RPM_PraseReleaseCharges(currentReleaseAssignment);
            }
            
           
            if(listofVariableStorage.size()>0){
                Database.insert(listofVariableStorage);
            } 
            if(listofReleaseCharges.size()>0){
                Database.insert(listofReleaseCharges);
            } 
           


            //Tasks - Notes
            listNotesToCreate = RPM_PraseNotes(mapNotes,currentReleaseAssignment); 
            
            if(listNotesToCreate.size()>0){
                Database.insert(listNotesToCreate);
            }

            //Release problems
            //listReleaseProblem = RPM_PraseReleaseProblems(mapReleseProblem,currentReleaseAssignment);
            if(listReleaseProblem.size()>0){
                for(Task oT : listReleaseProblem){
                    oT.WhatId = currentReleaseAssignment.id;
                }
            }

            if(listReleaseProblem.size()>0){
                Database.upsert(listReleaseProblem);
            } 
            
          
            return 'Callout successful and records updated';
        
    }//Method

    public static Contact RPM_PraseContact(Map<String, Object> parseContact) {
        //Contact Lookup CRC_Adjuster__c 
        //Contact Lookup CRC_Branch_Manager__c 
        //Contact Lookup ContactId 
        Contact objContact = new Contact();
        if(parseContact.get('COMPANY_NAME') != null){
            //objContact.companyName = String.valueOf(parseContact.get('COMPANY_NAME'));
        }
        if(parseContact.get('FIRST_NAME') != null){
            objContact.FirstName = String.valueOf(parseContact.get('FIRST_NAME'));
        }
        if(parseContact.get('LAST_NAME') != null){
            objContact.LastName = String.valueOf(parseContact.get('LAST_NAME'));
        }
        if(parseContact.get('ADDRESS_LINE1') != null){
            objContact.mailingstreet = String.valueOf(parseContact.get('ADDRESS_LINE1'));
        }
        if(parseContact.get('ADDRESS_LINE2') != null){
            objContact.mailingstreet += System.Label.CRC_Street_Address_Separator + String.valueOf(parseContact.get('ADDRESS_LINE2'));
        }
        if(parseContact.get('CITY') != null){
            objContact.mailingcity = String.valueOf(parseContact.get('CITY'));
        }
        if(parseContact.get('STATE') != null){
            //objContact.State__c = String.valueOf(parseContact.get('STATE'));
        }
        if(parseContact.get('ZIP') != null){
            objContact.mailingpostalcode = String.valueOf(parseContact.get('ZIP'));
        }
        if(parseContact.get('COUNTRY_CODE') != null){
            objContact.mailingCountry = String.valueOf(parseContact.get('COUNTRY_CODE'));
        }
        if(parseContact.get('PHONE_NUMBER1') != null){
            objContact.Phone = String.valueOf(parseContact.get('PHONE_NUMBER1'));
        }
        if(parseContact.get('PHONE_NUMBER1_EXT') != null){
            objContact.Phone_1_Ext__c = String.valueOf(parseContact.get('PHONE_NUMBER1_EXT'));
        }
        if(parseContact.get('PHONE_TYPE1') != null){
            objContact.Phone_Type_1__c = String.valueOf(parseContact.get('PHONE_TYPE1'));
        }
        if(parseContact.get('PHONE_NUMBER2') != null){
            objContact.OtherPhone = String.valueOf(parseContact.get('PHONE_NUMBER2'));
        }
        if(parseContact.get('PHONE_NUMBER2_EXT') != null){
            objContact.Phone_2_Ext__c = String.valueOf(parseContact.get('PHONE_NUMBER2_EXT'));
        }
        if(parseContact.get('PHONE_TYPE2') != null){
            objContact.Phone_Type_2__c = String.valueOf(parseContact.get('PHONE_TYPE2'));
        }
        if(parseContact.get('FAX_NUMBER') != null){
            objContact.Fax = String.valueOf(parseContact.get('FAX_NUMBER'));
        }
        if(parseContact.get('EMAIL') != null){
            objContact.Email = String.valueOf(parseContact.get('EMAIL'));
        }
        
        return objContact;

    }//RPM_PraseContact

    public static Branch__c RPM_PraseBranch( Branch__c oBranch) {
        Branch__c objBranch = new Branch__c();
        String branchCode;
        if(mapSalvor.get('BRANCH_CODE') != null){
            objBranch.Branch_Number__c = String.valueOf(mapSalvor.get('BRANCH_CODE'));
            branchCode = String.valueOf(mapSalvor.get('BRANCH_CODE'));
        }
        //Check if any existing branch has the same Branch Code 
        if(branchCode != null){
           Branch__c[] branchObject =  [Select id,Branch_Number__c from Branch__c where Branch_Number__c =: branchCode];
           if(branchObject.size()>0 && branchObject[0].Branch_Number__c != null){
            objBranch.Id =  branchObject[0].Id;
           }
        }
        if(mapSalvor.get('BRANCH_NAME') != null){
            objBranch.Name = String.valueOf(mapSalvor.get('BRANCH_NAME'));
        }
        if(mapSalvor.get('PHONE_NUMBER1') != null){
            objBranch.Phone__c = String.valueOf(mapSalvor.get('PHONE_NUMBER1'));
        }
        if( objBranch.Phone__c == null){
            objBranch.Phone__c = '987654321';
        }

        
        return objBranch;

    }//RPM_PraseBranch

    public static Case RPM_PraseCurrentReleaseAssignment(Case currentReleaseAssignment) {

        Map<String, Object> mapCatInfo = (Map<String, Object>) mapSalvor.get('CAT_INFO');
        Map<String, Object> mapVehicleOwner = (Map<String, Object>) mapProvider.get('OWNER');
        Map<String, Object> mapVehicleOwnerContact = (Map<String, Object>) mapVehicleOwner.get('CONTACT');
        Map<String, Object> mapVehicleOwnerContactRES = (Map<String, Object>) mapVehicleLocation.get('CONTACT');
        
        //Create Release Assignment
        Id storageLocationRT = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CRC Storage Location').getRecordTypeId();
        Id residentialRT = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CRC Residential').getRecordTypeId();
       

        if(mapVehicleLocation.get('PICKUP_LOCATION_TYPE') != null && mapVehicleLocation.get('PICKUP_LOCATION_TYPE') == 'RESIDENTIAL'){
            currentReleaseAssignment.RecordTypeId = residentialRT;
            if(mapVehicleLocation.get('SL_STATUS') != null ){
                currentReleaseAssignment.VO_Status__c = String.valueOf(mapVehicleLocation.get('SL_STATUS'));
            }

             //Vehicle Owner Contact
             if(mapVehicleOwnerContactRES != null && mapVehicleOwnerContactRES.get('FIRST_NAME') != null ){
                currentReleaseAssignment.CRC_VO_First_Name__c = String.valueOf(mapVehicleOwnerContactRES.get('FIRST_NAME'));
            }
            if(mapVehicleOwnerContactRES != null && mapVehicleOwnerContactRES.get('LAST_NAME') != null ){
                currentReleaseAssignment.CRC_VO_Last_Name__c = String.valueOf(mapVehicleOwnerContactRES.get('LAST_NAME'));
            }
            if(mapVehicleOwnerContactRES != null && mapVehicleOwnerContactRES.get('PHONE_NUMBER1') != null ){
                currentReleaseAssignment.CRC_VO_Primary_Phone_Number__c = String.valueOf(mapVehicleOwnerContactRES.get('PHONE_NUMBER1'));
            }
            if(mapVehicleOwnerContactRES != null && mapVehicleOwnerContactRES.get('PHONE_NUMBER1_EXT') != null ){
                currentReleaseAssignment.CRC_VO_Primary_Extension__c = String.valueOf(mapVehicleOwnerContactRES.get('PHONE_NUMBER1_EXT'));
            }
            if(mapVehicleOwnerContactRES != null && mapVehicleOwnerContactRES.get('PHONE_TYPE1') != null ){
                currentReleaseAssignment.CRC_VO_Primary_Phone_Type__c = String.valueOf(mapVehicleOwnerContactRES.get('PHONE_TYPE1'));
            }
            if(mapVehicleOwnerContactRES != null && mapVehicleOwnerContactRES.get('PHONE_NUMBER2') != null ){
                currentReleaseAssignment.CRC_VO_Secondary_Phone_Number__c = String.valueOf(mapVehicleOwnerContactRES.get('PHONE_NUMBER2'));
            }
            if(mapVehicleOwnerContactRES != null && mapVehicleOwnerContactRES.get('PHONE_NUMBER2_EXT') != null ){
                currentReleaseAssignment.CRC_Secondary_Extension__c = String.valueOf(mapVehicleOwnerContactRES.get('PHONE_NUMBER2_EXT'));
            }
            if(mapVehicleOwnerContactRES != null && mapVehicleOwnerContactRES.get('PHONE_TYPE2') != null ){
                currentReleaseAssignment.CRC_VO_Secondary_Phone_Type__c = String.valueOf(mapVehicleOwnerContactRES.get('PHONE_TYPE2'));
            }
            if(mapVehicleOwnerContactRES != null && mapVehicleOwnerContactRES.get('EMAIL') != null ){
                currentReleaseAssignment.CRC_VO_Email__c = String.valueOf(mapVehicleOwnerContactRES.get('EMAIL'));
            }
            if(mapVehicleOwnerContactRES != null && mapVehicleOwnerContactRES.get('COMPANY_NAME') != null ){
                currentReleaseAssignment.CRC_Company_Name__c = String.valueOf(mapVehicleOwnerContactRES.get('COMPANY_NAME'));
            }
            if(mapVehicleOwnerContactRES != null && mapVehicleOwnerContactRES.get('ADDRESS_LINE1') != null ){
                currentReleaseAssignment.CRC_VO_Address_Line_1__c = String.valueOf(mapVehicleOwnerContactRES.get('ADDRESS_LINE1'));
            }
            
            if(mapVehicleOwnerContactRES != null && mapVehicleOwnerContactRES.get('ZIP') != null ){
                currentReleaseAssignment.CRC_VO_Zip__c = String.valueOf(mapVehicleOwnerContactRES.get('ZIP'));
            }
            if(mapVehicleOwnerContactRES != null && mapVehicleOwnerContactRES.get('COUNTRY_CODE') != null ){
                currentReleaseAssignment.CRC_VO_Country__c = String.valueOf(mapVehicleOwnerContactRES.get('COUNTRY_CODE'));
            }
            if(mapVehicleOwnerContactRES != null && mapVehicleOwnerContactRES.get('CITY') != null ){
                currentReleaseAssignment.CRC_VO_City__c = String.valueOf(mapVehicleOwnerContactRES.get('CITY'));
            }
            if(mapVehicleOwnerContactRES != null && mapVehicleOwnerContactRES.get('STATE') != null ){
                currentReleaseAssignment.CRC_VO_StatePicklist__c = String.valueOf(mapVehicleOwnerContactRES.get('STATE'));
            }
            if(mapSTORAGE_DTL != null && mapSTORAGE_DTL.get('CHECKSUM') != null ){
                currentReleaseAssignment.CRC_Res_Checksum__c = String.valueOf(mapSTORAGE_DTL.get('CHECKSUM'));
            }
            if(mapVehicleLocation != null && mapVehicleLocation.get('STORAGE_LOCATION_ID') != null ){
                currentReleaseAssignment.CRC_Res_Location_Id__c = String.valueOf(mapVehicleLocation.get('STORAGE_LOCATION_ID'));
            }


        }else if(mapVehicleLocation.get('PICKUP_LOCATION_TYPE') != null && mapVehicleLocation.get('PICKUP_LOCATION_TYPE') == 'BUSINESS'){
            currentReleaseAssignment.RecordTypeId = storageLocationRT;
             //Vehicle Owner Contact
             if(mapVehicleOwnerContact != null && mapVehicleOwnerContact.get('FIRST_NAME') != null ){
                currentReleaseAssignment.CRC_VO_First_Name__c = String.valueOf(mapVehicleOwnerContact.get('FIRST_NAME'));
            }
            if(mapVehicleOwnerContact != null && mapVehicleOwnerContact.get('LAST_NAME') != null ){
                currentReleaseAssignment.CRC_VO_Last_Name__c = String.valueOf(mapVehicleOwnerContact.get('LAST_NAME'));
            }
            if(mapVehicleOwnerContact != null && mapVehicleOwnerContact.get('PHONE_NUMBER1') != null ){
                currentReleaseAssignment.CRC_VO_Primary_Phone_Number__c = String.valueOf(mapVehicleOwnerContact.get('PHONE_NUMBER1'));
            }
            if(mapVehicleOwnerContact != null && mapVehicleOwnerContact.get('PHONE_NUMBER1_EXT') != null ){
                currentReleaseAssignment.CRC_VO_Primary_Extension__c = String.valueOf(mapVehicleOwnerContact.get('PHONE_NUMBER1_EXT'));
            }
            if(mapVehicleOwnerContact != null && mapVehicleOwnerContact.get('PHONE_TYPE1') != null ){
                currentReleaseAssignment.CRC_VO_Primary_Phone_Type__c = String.valueOf(mapVehicleOwnerContact.get('PHONE_TYPE1'));
            }
            if(mapVehicleOwnerContact != null && mapVehicleOwnerContact.get('PHONE_NUMBER2') != null ){
                currentReleaseAssignment.CRC_VO_Secondary_Phone_Number__c = String.valueOf(mapVehicleOwnerContact.get('PHONE_NUMBER2'));
            }
            if(mapVehicleOwnerContact != null && mapVehicleOwnerContact.get('PHONE_NUMBER2_EXT') != null ){
                currentReleaseAssignment.CRC_Secondary_Extension__c = String.valueOf(mapVehicleOwnerContact.get('PHONE_NUMBER2_EXT'));
            }
            if(mapVehicleOwnerContact != null && mapVehicleOwnerContact.get('PHONE_TYPE2') != null ){
                currentReleaseAssignment.CRC_VO_Secondary_Phone_Type__c = String.valueOf(mapVehicleOwnerContact.get('PHONE_TYPE2'));
            }
            if(mapVehicleOwnerContact != null && mapVehicleOwnerContact.get('EMAIL') != null ){
                currentReleaseAssignment.CRC_VO_Email__c = String.valueOf(mapVehicleOwnerContact.get('EMAIL'));
            }


        }
        if(mapVehicleLocation.get('PICKUP_LOCATION_TYPE') != null){
            currentReleaseAssignment.CRC_Pickup_Location_Type__c = String.valueOf(mapVehicleLocation.get('PICKUP_LOCATION_TYPE'));
        }
        if(mainNode.get('SALVAGE_ID') != null){
            currentReleaseAssignment.CRC_Salvage_Id__c = String.valueOf(mainNode.get('SALVAGE_ID'));
        }
        system.debug('--Checksum1--'+String.valueof(mapRLSE_ASN.get('CHECKSUM')));
        if(String.valueof(mapRLSE_ASN.get('CHECKSUM')) != null){
            currentReleaseAssignment.CRC_Checksum__c = String.valueOf(mapRLSE_ASN.get('CHECKSUM')) ;
        }
        if(mapProvider.get('VEHICLE_TYPE') != null ){
            currentReleaseAssignment.CRC_Vehicle_Type__c = String.valueOf(mapVehicle.get('VEHICLE_TYPE'));
        } 
        if(mapProvider.get('THREE_WAY_CALL_REQUESTED') != null && mapProvider.get('THREE_WAY_CALL_REQUESTED') == 'Y' ){
            currentReleaseAssignment.Three_Way_Call_Requested__c = true;
        }else{
            currentReleaseAssignment.Three_Way_Call_Requested__c = false;
        } 
        if(mapProvider.get('THREE_WAY_CALL_OCCURED') != null ){
            currentReleaseAssignment.Three_Way_Call_Occured__c = String.valueOf(mapVehicle.get('THREE_WAY_CALL_OCCURED'));
        }  
        if(mapProvider.get('CONTACT_ADJUSTER') != null ){
            currentReleaseAssignment.CRC_Contact_Adjuster__c = String.valueOf(mapVehicle.get('CONTACT_ADJUSTER'));
        } 
        if(mapProvider.get('QUICK_RELEASE') != null && mapProvider.get('QUICK_RELEASE') == 'Y' ){
            currentReleaseAssignment.CRC_Quick_Release__c = true;
        }else{
            currentReleaseAssignment.CRC_Quick_Release__c = false;
        } 

        if(mapProvider.get('VEHICLE_TYPE') != null ){
            currentReleaseAssignment.CRC_Vehicle_Type__c = String.valueOf(mapVehicle.get('VEHICLE_TYPE'));
        }  
        if(mapVehicle.get('VIN') != null ){
            currentReleaseAssignment.CRC_VIN__c = String.valueOf(mapVehicle.get('VIN'));
        }  
        if(mapVehicle.get('YEAR') != null ){
            currentReleaseAssignment.CRC_Year__c = String.valueOf(mapVehicle.get('YEAR'));
        }  
        if(mapVehicle.get('MAKE') != null ){
            currentReleaseAssignment.CRC_Make__c = String.valueOf(mapVehicle.get('MAKE'));
        }
        if(mapVehicle.get('MODEL') != null ){
            currentReleaseAssignment.Model__c = String.valueOf(mapVehicle.get('MODEL'));
        }
        if(mapVehicle.get('BODY_STYLE') != null ){
            currentReleaseAssignment.CRC_Body_Style__c = String.valueOf(mapVehicle.get('BODY_STYLE'));
        }
        if(mapVehicle.get('COLOR') != null ){
            currentReleaseAssignment.CRC_Exterior_Color__c = String.valueOf(mapVehicle.get('COLOR'));
        }
        if(mapVehicle.get('ENGINE') != null ){
            currentReleaseAssignment.CRC_Engine__c = String.valueOf(mapVehicle.get('ENGINE'));
        }
        if(mapVehicle.get('DRIVE') != null ){
            currentReleaseAssignment.CRC_Drive__c = String.valueOf(mapVehicle.get('DRIVE'));
        }
        if(mapVehicle.get('TRANSMISSION') != null ){
            currentReleaseAssignment.CRC_Transmission__c = String.valueOf(mapVehicle.get('TRANSMISSION'));
        }
        if(mapVehicle.get('FUEL_TYPE') != null ){
            currentReleaseAssignment.CRC_Fuel_Type__c = String.valueOf(mapVehicle.get('FUEL_TYPE'));
        }
        if(mapVehicle.get('CYLINDERS') != null ){
            currentReleaseAssignment.CRC_Cylinders__c = String.valueOf(mapVehicle.get('CYLINDERS'));
        }
        if(mapVehicle.get('EMPTY_WEIGHT') != null ){
            currentReleaseAssignment.CRC_Empty_Weight__c = String.valueOf(mapVehicle.get('EMPTY_WEIGHT'));
        }
        if(mapVehicle.get('KEYS_INDICATOR') != null ){
            currentReleaseAssignment.CRC_Keys_with_Vehicle__c = String.valueOf(mapVehicle.get('KEYS_INDICATOR'));
        }
        if(mapVehicle.get('LICENSE_PLATE_NUMBER') != null ){
            currentReleaseAssignment.CRC_License_Plate__c = String.valueOf(mapVehicle.get('LICENSE_PLATE_NUMBER'));
        }
        
        if(mapVehicle.get('ODOMETER_READING') != null ){
            currentReleaseAssignment.CRC_Odometer_Reading__c = Integer.valueOf(mapVehicle.get('ODOMETER_READING'));
        }
        if(mapVehicle.get('RUNNABLE_AND_DRIVEABLE_INDICATOR') != null && mapVehicle.get('RUNNABLE_AND_DRIVEABLE_INDICATOR') == 'Y' ){
            currentReleaseAssignment.CRC_Runnable_and_Driveble_Indicator__c = true;
        }else{
            currentReleaseAssignment.CRC_Runnable_and_Driveble_Indicator__c = false;
        }
        if(mapVehicle.get('PRIMARY_DAMAGE_CODE') != null ){
            currentReleaseAssignment.CRC_Primary_Damage_Code__c = String.valueOf(mapVehicle.get('PRIMARY_DAMAGE_CODE'));
        }
       
        if(mapVehicle.get('SECONDARY_DAMAGE_CODE') != null ){
            currentReleaseAssignment.CRC_Secondary_Damage_Code__c = String.valueOf(mapVehicle.get('SECONDARY_DAMAGE_CODE'));
        }
        if(mapProcStatus.get('ASSIGNMENT_DATETIME') != null ){
            currentReleaseAssignment.CRC_Assignment_Date_Time__c = convertStringToDateTime(String.valueOf(mapProcStatus.get('ASSIGNMENT_DATETIME')).replace('T',' '));
        }
        if(mapProcStatus.get('SP_PREPAID_CAPTURE_ALLOWED') != null && mapProcStatus.get('SP_PREPAID_CAPTURE_ALLOWED') == null){
            currentReleaseAssignment.CRC_Prepaid_Capture_Allowed__c = true;
        }else{
            currentReleaseAssignment.CRC_Prepaid_Capture_Allowed__c = false;
        }
        if(mapProcStatus.get('SP_PREPAID_ADVANCE_CHARGES_THROUGH_DATE') != null ){
            currentReleaseAssignment.CRC_Prepaid_Adv_Charges_Through_Date__c = Date.valueOf(String.valueOf(mapProcStatus.get('SP_PREPAID_ADVANCE_CHARGES_THROUGH_DATE')).replace('T',' '));
        }
        if(mapProcStatus.get('SP_PREPAID_TOTAL_AMT') != null ){
            currentReleaseAssignment.CRC_Prepaid_Total_Amount__c = Double.valueOf(mapProcStatus.get('SP_PREPAID_TOTAL_AMT'));
        }
        if(mapProcStatus.get('IAA_REQUESTED_TO_PAY_ADVANCE_CHARGES') != null && mapProcStatus.get('IAA_REQUESTED_TO_PAY_ADVANCE_CHARGES') == 'Y'){
            currentReleaseAssignment.IAA_Requested_to_Pay_Advance_Charges__c = true;
        }else{
            currentReleaseAssignment.IAA_Requested_to_Pay_Advance_Charges__c = false;
            currentReleaseAssignment.Updated_Advance_Chg_Max_Authorized_Amt__c = null;
            currentReleaseAssignment.Updated_Advance_Chg_Auth_By_First_Name__c = null;
            currentReleaseAssignment.Updated_Advance_Chg_Auth_By_last_Name__c = null;
            currentReleaseAssignment.Updated_Advance_Chg_Auth_DateTime__c = null;
        }
     
        if(mapProcStatus.get('PROVIDER_DEFINED_MAX_AUTHORIZED_AMOUNT_MINIMUM') != null ){
            currentReleaseAssignment.Provider_Defined_Max_Auth_Amount__c = Double.valueOf(mapProcStatus.get('PROVIDER_DEFINED_MAX_AUTHORIZED_AMOUNT_MINIMUM'));
          }
          if(mapProcStatus.get('UPDATED_ADVANCE_CHG_MAX_AUTHORIZED_AMOUNT') != null ){
              currentReleaseAssignment.Updated_Advance_Chg_Max_Authorized_Amt__c = Double.valueOf(mapProcStatus.get('UPDATED_ADVANCE_CHG_MAX_AUTHORIZED_AMOUNT'));
          }
          if(mapProcStatus.get('ADVANCE_CHG_MAX_AUTHORIZED_AMOUNT') != null ){
              currentReleaseAssignment.Adv_Charges_Max_Authorized_Amount__c = Double.valueOf(mapProcStatus.get('ADVANCE_CHG_MAX_AUTHORIZED_AMOUNT'));
          }
          if(mapProcStatus.get('UPDATED_ADVANCE_CHG_MAX_AUTHORIZED_BY_FIRST_NAME') != null ){
              currentReleaseAssignment.Updated_Advance_Chg_Auth_By_First_Name__c = String.valueOf(mapProcStatus.get('UPDATED_ADVANCE_CHG_MAX_AUTHORIZED_BY_FIRST_NAME'));
          }
          if(mapProcStatus.get('UPDATED_ADVANCE_CHG_MAX_AUTHORIZED_BY_LAST_NAME') != null ){
              currentReleaseAssignment.Updated_Advance_Chg_Auth_By_last_Name__c = String.valueOf(mapProcStatus.get('UPDATED_ADVANCE_CHG_MAX_AUTHORIZED_BY_LAST_NAME'));
          }
          if(mapProcStatus.get('UPDATED_ADVANCE_CHG_MAX_AUTHORIZED_DATETIME') != null ){
              currentReleaseAssignment.Updated_Advance_Chg_Auth_DateTime__c = convertStringToDateTime(String.valueOf(mapProcStatus.get('UPDATED_ADVANCE_CHG_MAX_AUTHORIZED_DATETIME')).replace('T',' '));
          }
        if(mapProcStatus.get('ACTUAL_RELEASE_DATETIME') != null ){
            currentReleaseAssignment.Actual_Release_Date_Time__c = convertStringToDateTime(String.valueOf(mapProcStatus.get('ACTUAL_RELEASE_DATETIME')).replace('T',' '));
        }
        if(mapProcStatus.get('DRY_RUN_OCCURRED_DATETIME') != null ){
            currentReleaseAssignment.CRC_Dry_Run_Date_Time__c = convertStringToDateTime(String.valueOf(mapProcStatus.get('CRC_Dry_Run_Date_Time__c')).replace('T',' '));
        }
        if(mapProcStatus.get('PICKUP_DATETIME') != null ){
            currentReleaseAssignment.CRC_Pickup_Date_Time__c = convertStringToDateTime(String.valueOf(mapProcStatus.get('PICKUP_DATETIME')).replace('T',' '));
        }
        if(mapProcStatus.get('SALVAGE_DROP_OFF_DATETIME') != null ){
            currentReleaseAssignment.CRC_Salvage_Drop_Off_Date_Time__c = convertStringToDateTime(String.valueOf(mapProcStatus.get('SALVAGE_DROP_OFF_DATETIME')).replace('T',' '));
        }

        if(mapRelease.get('VR_RELEASED_BY_CONTACT_USER_ID') != null ){
            currentReleaseAssignment.CRC_Release_Person_User_Id__c = Integer.valueOf(mapRelease.get('VR_RELEASED_BY_CONTACT_USER_ID'));
        }
        if(mapRelease.get('VR_RELEASED_BY_FIRST_NAME') != null ){
            currentReleaseAssignment.CRC_Release_Person_First_Name__c = String.valueOf(mapRelease.get('VR_RELEASED_BY_FIRST_NAME'));
        }
        if(mapRelease.get('VR_RELEASED_BY_LAST_NAME') != null ){
            currentReleaseAssignment.CRC_Release_Person_Last_Name__c = String.valueOf(mapRelease.get('VR_RELEASED_BY_LAST_NAME'));
        }
        if(mapRelease.get('VR_IS_VEHICLE_AT_LOCATION') == 'Y'){
            currentReleaseAssignment.CRC_Is_Vehicle_There__c = true;  
        }else if(mapRelease.get('VR_IS_VEHICLE_AT_LOCATION') == 'N'){
            currentReleaseAssignment.CRC_Is_Vehicle_There__c = false;   
        } 
        if(mapRelease.get('VR_VEHICLE_RELEASED') == 'Y'){
            currentReleaseAssignment.CRC_Vehicle_Released__c = true;  
        }else if(mapRelease.get('VR_VEHICLE_RELEASED') == 'N'){
            currentReleaseAssignment.CRC_Vehicle_Released__c = false;   
        }
       
        if(mapRelease.get('VR_ANTICIPATED_PICKUP_DATETIME') != null ){
            currentReleaseAssignment.CRC_Anticipated_Release_Date_Time__c = convertStringToDateTime(String.valueOf(mapRelease.get('VR_ANTICIPATED_PICKUP_DATETIME')).replace('T',' '));
        }
        if(mapRelease.get('VR_EARLIEST_AVAILABLE_PICKUP_START_DATETIME') != null ){
            currentReleaseAssignment.CRC_Earliest_Available_Pickup__c = convertStringToDateTime(String.valueOf(mapRelease.get('VR_EARLIEST_AVAILABLE_PICKUP_START_DATETIME')).replace('T',' '));
        }
        if(mapRelease.get('VR_ASSIGNMENT_QUOTED_PICKUP_DATETIME') != null ){
            currentReleaseAssignment.CRC_Quoted_Release_Date_Time__c = convertStringToDateTime(String.valueOf(mapRelease.get('VR_ASSIGNMENT_QUOTED_PICKUP_DATETIME')).replace('T',' '));
        }
        if(mapRelease.get('VR_CALL_BEFORE_COMING') == 'Y'){
            currentReleaseAssignment.CRC_Call_Before_Coming__c = true;  
        }else if(mapRelease.get('VR_CALL_BEFORE_COMING') == 'N'){
            currentReleaseAssignment.CRC_Call_Before_Coming__c = false;   
        }
        if(mapRelease.get('VR_VEHICLE_BLOCKED_IN') == 'Y'){
            currentReleaseAssignment.CRC_Vehicle_Blocked_In__c = true;  
        }else if(mapRelease.get('VR_VEHICLE_BLOCKED_IN') == 'N'){
            currentReleaseAssignment.CRC_Vehicle_Blocked_In__c = false;   
        }
        if(mapRelease.get('VR_VEHICLE_TOWABLE') == 'Y'){
            currentReleaseAssignment.CRC_Vehicle_Towable__c = true;  
        }else if(mapRelease.get('VR_VEHICLE_TOWABLE') == 'N'){
            currentReleaseAssignment.CRC_Vehicle_Towable__c = false;   
        }
        if(mapRelease.get('VR_RESIDENCE_AT_HOME_REQUIREMENT') == 'Y'){
            currentReleaseAssignment.CRC_At_Home_Requirement__c = true;  
        }else if(mapRelease.get('VR_RESIDENCE_AT_HOME_REQUIREMENT') == 'N'){
            currentReleaseAssignment.CRC_At_Home_Requirement__c = false;   
        }
        if(mapRelease.get('VR_RESIDENCE_AT_HOME_REQUIREMENT') == 'Y'){
            currentReleaseAssignment.CRC_At_Home_Requirement__c = true;  
        }else if(mapRelease.get('VR_RESIDENCE_AT_HOME_REQUIREMENT') == 'N'){
            currentReleaseAssignment.CRC_At_Home_Requirement__c = false;   
        }
        if(mapRelease.get('VR_VEHICLE_LOCATION_CODE') != null ){
            currentReleaseAssignment.CRC_Vehicle_Location__c = String.valueOf(mapRelease.get('VR_VEHICLE_LOCATION_CODE'));
        }
        //if(mapRelease.get('VR_VEHICLE_LOCATION_DESC') != null ){
            //currentReleaseAssignment.CRC_Vehicle_Location_Description__c = String.valueOf(mapRelease.get('VR_VEHICLE_LOCATION_DESC'));
        //}
        if(mapRelease.get('VR_STORAGE_RATE') != null ){
            currentReleaseAssignment.CRC_Storage_Rate__c = Decimal.valueOf(String.valueOf(mapRelease.get('VR_STORAGE_RATE')));
        }
        if(mapRelease.get('VR_STORAGE_RATE_TYPE_CODE') != null ){
            currentReleaseAssignment.CRC_Rate_Type__c = String.valueOf(mapRelease.get('VR_STORAGE_RATE_TYPE_CODE'));
        }
        //if(mapRelease.get('VR_STORAGE_RATE_TYPE') != null ){
           // currentReleaseAssignment.CRC_Rate_Type_Description__c = String.valueOf(mapRelease.get('VR_STORAGE_RATE_TYPE'));
        //}
        
        if(mapRelease.get('VR_TOTAL_CHECK_AMOUNT') != null ){
            currentReleaseAssignment.CRC_Total_Check_Amount__c = Decimal.valueOf(String.valueOf(mapRelease.get('VR_TOTAL_CHECK_AMOUNT')));
        }

        
        if(mapRelease.get('VR_CHARGES_CLEARED') == 'Y' ){
            currentReleaseAssignment.CRC_Charges_Cleared__c = true;
        }else if(mapRelease.get('VR_CHARGES_CLEARED') == 'N' ){
            currentReleaseAssignment.CRC_Charges_Cleared__c = false;
        }
        if(mapRelease.get('VR_TOW_ZONE') != null ){
            currentReleaseAssignment.CRC_Tow_Zone__c = String.valueOf(mapRelease.get('VR_TOW_ZONE'));
        }
        if(mapRelease.get('VR_MILEAGE') != null ){
            currentReleaseAssignment.CRC_Mileage__c = Integer.valueOf(mapRelease.get('VR_MILEAGE'));
        }
        if(mapRelease.get('SLA_CALCULATED_PICKUP_DATETIME') != null ){
            currentReleaseAssignment.CRC_SLA_Calculated_Pickup_DateTime__c = convertStringToDateTime(String.valueOf(mapRelease.get('SLA_CALCULATED_PICKUP_DATETIME')).replace('T',' '));
        }
        if(mapRelease.get('VR_RELEASE_PROBLEM_EMAIL') != null ){
            currentReleaseAssignment.CRC_Release_Problem_Email__c = String.valueOf(mapRelease.get('VR_RELEASE_PROBLEM_EMAIL'));
        }
        if(mapRelease.get('TEXAS_VSF_FORM') != null ){
            currentReleaseAssignment.CRC_Texas_VSF_Form__c = String.valueOf(mapRelease.get('TEXAS_VSF_FORM'));
        }
        if(mapProvider.get('PROVIDER_TRANSACTION_IDENTIFIER') != null ){
            currentReleaseAssignment.CRC_Transaction_Identifier__c = String.valueOf(mapProvider.get('PROVIDER_TRANSACTION_IDENTIFIER'));
        }
        if(mapProvider.get('PROVIDER_VEHICLE_IDENTIFIER') != null ){
            currentReleaseAssignment.CRC_Vehicle_Identifier__c = String.valueOf(mapProvider.get('PROVIDER_VEHICLE_IDENTIFIER'));
        }
        if(mapProvider.get('CLAIM_NUMBER') != null){
            currentReleaseAssignment.CRC_Claim__c = String.valueOf(mapProvider.get('CLAIM_NUMBER'));
        }
        if(mapProvider.get('CLAIM_SUFFIX_NUMBER') != null ){
            currentReleaseAssignment.CRC_Calim_Suffix__c = String.valueOf(mapProvider.get('CLAIM_SUFFIX_NUMBER'));
        }
        if(mapProvider.get('INSURED_POLICY_NUMBER') != null ){
            currentReleaseAssignment.CRC_Policy__c = String.valueOf(mapProvider.get('INSURED_POLICY_NUMBER'));
        }
        if(mapProvider.get('LOSS_DATETIME') != null){
            currentReleaseAssignment.CRC_Date_of_Loss__c = Date.valueOf(String.valueOf(mapProvider.get('LOSS_DATETIME')).replace('T',' '));
        }
        if(mapProvider.get('TYPE_OF_LOSS_CODE') != null ){
            currentReleaseAssignment.CRC_Loss_Type__c = String.valueOf(mapProvider.get('TYPE_OF_LOSS_CODE'));
        }
        if(mapProvider.get('MINIMUM_BID_AMOUNT') != null ){
            currentReleaseAssignment.CRC_Min_Bid_Amount__c = Integer.valueOf(mapProvider.get('MINIMUM_BID_AMOUNT'));
        }
        if(mapProvider.get('BID_APPROVAL_REQ') != 'Y' ){
            currentReleaseAssignment.CRC_Bid_Approval_Request__c = true;
        }else if(mapProvider.get('BID_APPROVAL_REQ') != 'N' ){
            currentReleaseAssignment.CRC_Bid_Approval_Request__c = false;
        }
        // if(mapProvider.get('PROVIDER_GROUP_CODE') != null ){
        //     currentReleaseAssignment.CRC_Provider_Group_Code__c = Integer.valueOf(mapProvider.get('PROVIDER_GROUP_CODE'));
        // }
        // if(mapProvider.get('PROVIDER_GROUP_DESCRIPTION') != null ){
        //     currentReleaseAssignment.CRC_Provider_Group_Description__c = String.valueOf(mapProvider.get('PROVIDER_GROUP_DESCRIPTION'));
        // }
        if(mapProvider.get('MANAGED_BY_CODE') != null ){
            currentReleaseAssignment.CRC_Managed_By_Code__c = Integer.valueOf(mapProvider.get('MANAGED_BY_CODE'));
        }
        if(mapProvider.get('MANAGED_BY_DESCRIPTION') != null ){
            currentReleaseAssignment.CRC_Managed_By_Description__c = String.valueOf(mapProvider.get('MANAGED_BY_DESCRIPTION'));
        }


            //Residential case  - pick VEHICLE_LOCATION and use that 
            


           


        if(mapProcStatus != null && mapProcStatus.get('STORAGE_START_DATE') != null ){
            currentReleaseAssignment.CRC_Start_Date__c = Date.valueOf(String.valueOf(mapProcStatus.get('STORAGE_START_DATE')).replace('T',' '));
        }
        if(mapProcStatus != null && mapProcStatus.get('STORAGE_STOP_DATE') != null ){
            currentReleaseAssignment.CRC_End_Date__c = Date.valueOf(String.valueOf(mapProcStatus.get('STORAGE_STOP_DATE')).replace('T',' '));
        }
        

        if(mapProcStatus != null && mapProcStatus.get('CHECKIN_DATETIME') != null ){
            currentReleaseAssignment.CRC_Check_in_Date_Time__c = convertStringToDateTime(String.valueOf(mapProcStatus.get('CHECKIN_DATETIME')).replace('T',' '));
        }

        if(mapProcStatus != null && mapProcStatus.get('VEHICLE_ON_HOLD') != null && mapProcStatus.get('VEHICLE_ON_HOLD') == 'Y'){
            currentReleaseAssignment.CRC_Vehicle_On_Hold__c = true;
        }else{
            currentReleaseAssignment.CRC_Vehicle_On_Hold__c = false;
        }

        if(mapProcStatus != null && mapProcStatus.get('CANCEL_REASON') != null ){
            currentReleaseAssignment.CRC_Cancel_Reason__c = String.valueOf(mapProcStatus.get('CANCEL_REASON'));
        }

        if(mapProcStatus != null && mapProcStatus.get('CANCELLATION_DATETIME') != null ){
            currentReleaseAssignment.CRC_Cancellation_Date_Time__c = convertStringToDateTime(String.valueOf(mapProcStatus.get('CANCELLATION_DATETIME')).replace('T',' ')); 
        }
        if(mapProcStatus != null && mapProcStatus.get('CLOSE_DATETIME') != null ){
            currentReleaseAssignment.CRC_Close_Date_Time__c =  convertStringToDateTime(String.valueOf(mapProcStatus.get('CLOSE_DATETIME')).replace('T',' ')); 
        }
        if(mapProcStatus != null && mapRelease.get('VR_TITLE_IND') != null ){
            currentReleaseAssignment.Title_Indicator__c =  String.valueOf(mapRelease.get('VR_TITLE_IND')); 
        }

         if(mapProcStatus != null && mapProcStatus.get('PROCESS_STATUS_DESC') != null ){
            currentReleaseAssignment.Status = String.valueOf(mapProcStatus.get('PROCESS_STATUS_DESC'));
         }
        //Assignment type fields are getting merged
        String releaseAssignmentTypes;
        if(mapSalvor.get('TITLE_WORK_ONLY_ASSIGNMENT') == 'Y'){
            if(releaseAssignmentTypes == null){
                releaseAssignmentTypes = 'Title Work Only;';
            }else{
                releaseAssignmentTypes =releaseAssignmentTypes + 'Title Work Only;';
            }
        }
        if(mapSalvor.get('TOW_ONLY_ASSIGNMENT') == 'Y'){
            if(releaseAssignmentTypes == null){
                releaseAssignmentTypes = 'Tow Only;';
            }else{
                releaseAssignmentTypes =releaseAssignmentTypes + 'Tow Only;';
            }
            
        }
        if(mapSalvor.get('VIC_ASSIGNMENT') == 'Y'){
            if(releaseAssignmentTypes == null){
                releaseAssignmentTypes = 'VIC;';
            }else{
                releaseAssignmentTypes =releaseAssignmentTypes + 'VIC;';
            }
            
        }
        if(mapSalvor.get('PRIORITY_TOW') == 'Y'){
            if(releaseAssignmentTypes == null){
                releaseAssignmentTypes = 'Priority Tow;';
            }else{
                releaseAssignmentTypes =releaseAssignmentTypes + 'Priority Tow;';
            }
            
        }
       
        if(mapCatInfo != null && mapCatInfo.get('CAT_IND') == 'Y'){
            if(releaseAssignmentTypes == null){
                releaseAssignmentTypes = 'CAT;';
            }else{
                releaseAssignmentTypes =releaseAssignmentTypes + 'CAT;';
            }
           
        }

        if(mapCatInfo != null && mapCatInfo.get('CAT_NAME') != null){
            currentReleaseAssignment.CRC_CAT_Name__c = String.valueOf(mapCatInfo.get('CAT_NAME'));
        }
        if(releaseAssignmentTypes != null){
            currentReleaseAssignment.CRC_Assignment_Type__c = releaseAssignmentTypes;
        }

    
        return currentReleaseAssignment;

    }//RPM_PraseCurrentReleaseAssignment

    public static Account RPM_PraseStorageLocation(Account storageLocation) {

        List<Contact> listContactsToInsert = new List<Contact>();
        Map<String, Object> mapBillingContact = (Map<String, Object>) mapVehicleLocation.get('CONTACT');
        Map<String, Object> mapMailingAddress = (Map<String, Object>) mapVehicleLocation.get('MAILING_ADDRESS');
        String storageLocationID = String.valueof(mapVehicleLocation.get('STORAGE_LOCATION_ID'));
        Integer storageLocationIdInt = Integer.valueOf(mapVehicleLocation.get('STORAGE_LOCATION_ID'));
        Map<String, Object> mapMailingContact;
        if(mapMailingAddress != null){
            mapMailingContact = (Map<String, Object>) mapMailingAddress.get('CONTACT');
        }
        
        //Check if account already exist
        if(mapVehicleLocation.get('STORAGE_LOCATION_ID') != null ){
            storageLocation.Location_Id__c = storageLocationIdInt;
        }
        Account[] objA = [Select id from Account where Location_Id__c =: storageLocationIdInt];
        if(objA.size()> 0 && objA[0].Id != null){
            storageLocation.id = objA[0].Id;
        }
        storageLocation.recordtypeId =  storageLocationAccountRecordType;
        Map<String, Object> mapProvider = (Map<String, Object>) mapRLSE_ASN.get('PROVIDER');
        //Storage Location fields 
        if(mapSTORAGE_DTL.get('CHECKSUM') != null ){
            storageLocation.CRC_CHECKSUM__c = String.valueOf(mapSTORAGE_DTL.get('CHECKSUM'));
        }
        if(mapVehicleLocation.get('STORAGE_LOCATION_ID') != null ){
            storageLocation.Location_Id__c = Integer.valueOf(mapVehicleLocation.get('STORAGE_LOCATION_ID'));
        }
        if(mapVehicleLocation.get('SL_VALIDATION_STATUS') != null && mapVehicleLocation.get('SL_VALIDATION_STATUS') == 'Y'){
            storageLocation.Validated__c  = true;
        }else{
            storageLocation.Validated__c  = false;
        }
        if(mapVehicleLocation.get('SL_STATUS') != null ){
            storageLocation.Storage_Location_Status__c = String.valueOf(mapVehicleLocation.get('SL_STATUS'));
        }
        if(mapVehicleLocation.get('THREE_WAY_CALL_REQUESTED') != null ){
            //storageLocation.three = Integer.valueOf(mapVehicleLocation.get('THREE_WAY_CALL_REQUESTED'));
        }
        if(mapVehicleLocation.get('SL_ADDRESS_ID') != null ){
            storageLocation.Address_ID__c = Integer.valueOf(mapVehicleLocation.get('SL_ADDRESS_ID'));
        }
        if(mapVehicleLocation.get('SL_STATUS') != null ){
            //storageLocation.statu = Integer.valueOf(mapVehicleLocation.get('SL_STATUS'));
        }
        if(mapVehicleLocation.get('SL_CONTACT_ID') != null ){
            //storageLocation.statu = Integer.valueOf(mapVehicleLocation.get('SL_CONTACT_ID'));
        }
        if(mapVehicleLocation.get('SL_CASH_ONLY') != null && mapVehicleLocation.get('SL_CASH_ONLY') == 'Y'){
            storageLocation.Cash_Only_Payments__c  = true;
        }else{
            storageLocation.Cash_Only_Payments__c  = false;
        }
        // if(mapVehicleLocation.get('SL_TOWER_CHECK') != null && mapVehicleLocation.get('SL_TOWER_CHECK') == 'Y'){
        //     storageLocation.Tower_Checks_Accepted__c  = true;
        // }else{
        //     storageLocation.Tower_Checks_Accepted__c  = false;
        // }
        // if(mapVehicleLocation.get('SL_IAA_CHECK') != null && mapVehicleLocation.get('SL_IAA_CHECK') == 'Y'){
        //     storageLocation.IAA_Checks_Accepted__c  = true;
        // }else{
        //     storageLocation.IAA_Checks_Accepted__c  = false;
        // }
        if(mapVehicleLocation.get('SL_TOWER_CHECK') != null && mapVehicleLocation.get('SL_TOWER_CHECK') == 'Y'){
            storageLocation.Tower_Check__c  = true;
        }else{
            storageLocation.Tower_Check__c  = false;
        }
        if(mapVehicleLocation.get('SL_IAA_CHECK') != null && mapVehicleLocation.get('SL_IAA_CHECK') == 'Y'){
            storageLocation.IAA_Check__c  = true;
        }else{
            storageLocation.IAA_Check__c  = false;
        }
        if(mapVehicleLocation.get('SL_CALL_BEFORE_PICKUP') != null && mapVehicleLocation.get('SL_CALL_BEFORE_PICKUP') == 'Y'){
            storageLocation.Call_Before_Pickup__c  = true;
        }else{
            storageLocation.Call_Before_Pickup__c  = false;
        }
        if(mapBillingContact.get('COMPANY_NAME') != null ){
            storageLocation.Name = String.valueOf(mapBillingContact.get('COMPANY_NAME'));
        }
        if(mapBillingContact.get('ADDRESS_LINE1') != null ){
            storageLocation.BillingStreet = String.valueOf(mapBillingContact.get('ADDRESS_LINE1'));
        }
        if(mapBillingContact.get('ADDRESS_LINE2') != null ){   
        //storageLocation.BillingStreet = storageLocation.BillingStreet + ' ; ' + String.valueOf(mapBillingContact.get('ADDRESS_LINE2'));
         storageLocation.BillingStreet = storageLocation.BillingStreet + System.Label.CRC_Street_Address_Separator + String.valueOf(mapVehicleLocation.get('SL_ADDRESS_LINE2'));
        }
        if(mapBillingContact.get('CITY') != null ){
            storageLocation.BillingCity = String.valueOf(mapBillingContact.get('CITY'));
        }
        if(mapBillingContact.get('STATE') != null ){
            storageLocation.BillingState = String.valueOf(mapBillingContact.get('STATE'));
        }
        if(mapBillingContact.get('ZIP') != null ){
            storageLocation.BillingPostalCode = String.valueOf(mapBillingContact.get('ZIP'));
        }
        if(mapBillingContact.get('COUNTRY_CODE') != null ){
            storageLocation.BillingCountry = String.valueOf(mapBillingContact.get('COUNTRY_CODE'));
        }
        //Create contact if the Phone number is available in Contact node
        if(mapBillingContact.get('PHONE_NUMBER1') != null ){
            Contact objBContact = new Contact();
            objBContact.Stock_Number__c = currentStockNumber;
            Contact[] objC = [Select id from Contact where Stock_Number__c =:currentStockNumber AND CRC_Storage_Location_ID__c =: storageLocationID and Type__c = 'Storage Location'];
                if(objC.size()> 0 && objC[0].Id != null){
                    objBContact.id = objC[0].Id;
                }
                if(mapVehicleLocation.get('STORAGE_LOCATION_ID') != null){
                    objBContact.CRC_Storage_Location_ID__c = String.valueOf(mapVehicleLocation.get('STORAGE_LOCATION_ID'));
                }
                
            objBContact.RecordTypeId = contactRecordTypeId;
            objBContact.Phone = String.valueOf(mapBillingContact.get('PHONE_NUMBER1'));
            if(mapBillingContact.get('FIRST_NAME') != null){
                objBContact.FirstName = String.valueOf(mapBillingContact.get('FIRST_NAME'));
            }
            if(mapBillingContact.get('LAST_NAME') != null){
                objBContact.LastName = String.valueOf(mapBillingContact.get('LAST_NAME'));
            }else{
                objBContact.LastName = 'Test';
            }
            if(mapBillingContact.get('ADDRESS_LINE1') != null){
                objBContact.mailingstreet = String.valueOf(mapBillingContact.get('ADDRESS_LINE1'));
            }
            if(mapBillingContact.get('ADDRESS_LINE2') != null){
                objBContact.mailingstreet  +=  System.Label.CRC_Street_Address_Separator + String.valueOf(mapBillingContact.get('ADDRESS_LINE2'));
            }
            if(mapBillingContact.get('CITY') != null){
                objBContact.mailingCity = String.valueOf(mapBillingContact.get('CITY'));
            }
            if(mapBillingContact.get('ZIP') != null){
                objBContact.mailingpostalcode = String.valueOf(mapBillingContact.get('ZIP'));
            }
            if(mapBillingContact.get('COUNTRY_CODE') != null){
                objBContact.mailingCountry = String.valueOf(mapBillingContact.get('COUNTRY_CODE'));
            }
            if(mapBillingContact.get('PHONE_NUMBER1_EXT') != null){
                objBContact.Phone_1_Ext__c = String.valueOf(mapBillingContact.get('PHONE_NUMBER1_EXT'));
            }
            if(mapBillingContact.get('PHONE_TYPE1') != null){
                objBContact.Phone_Type_1__c = String.valueOf(mapBillingContact.get('PHONE_TYPE1'));
            }
            if(mapBillingContact.get('PHONE_NUMBER2') != null){
                objBContact.OtherPhone = String.valueOf(mapBillingContact.get('PHONE_NUMBER2'));
            }
            if(mapBillingContact.get('PHONE_NUMBER2_EXT') != null){
                objBContact.Phone_2_Ext__c = String.valueOf(mapBillingContact.get('PHONE_NUMBER2_EXT'));
            }
            if(mapBillingContact.get('PHONE_TYPE2') != null){
                objBContact.Phone_Type_2__c = String.valueOf(mapBillingContact.get('PHONE_TYPE2'));
            }
            if(mapBillingContact.get('FAX_NUMBER') != null){
                objBContact.Fax = String.valueOf(mapBillingContact.get('FAX_NUMBER'));
            }
            if(mapBillingContact.get('EMAIL') != null){
                objBContact.Email = String.valueOf(mapBillingContact.get('EMAIL'));
            }
            objBContact.AccountId = storageLocation.id;
            objBContact.Type__c = 'Storage Location';
            listContactsToInsert.add(objBContact);
        }

        if(mapMailingContact != null && mapMailingContact.get('COMPANY_NAME') != null ){
            storageLocation.Name = String.valueOf(mapMailingContact.get('COMPANY_NAME'));
        }
        if(mapMailingContact != null && mapMailingContact.get('ADDRESS_LINE1') != null ){
            storageLocation.ShippingStreet = String.valueOf(mapMailingContact.get('ADDRESS_LINE1'));
        }
        if(mapMailingContact != null && mapMailingContact.get('ADDRESS_LINE2') != null ){ 
            storageLocation.ShippingStreet = storageLocation.ShippingStreet + System.Label.CRC_Street_Address_Separator + String.valueOf(mapMailingContact.get('ADDRESS_LINE2'));
        }
        if(mapMailingContact != null && mapMailingContact.get('CITY') != null ){
            storageLocation.ShippingCity = String.valueOf(mapMailingContact.get('CITY'));
        }
        if(mapMailingContact != null && mapMailingContact.get('STATE') != null ){
            storageLocation.ShippingState = String.valueOf(mapMailingContact.get('STATE'));
        }
        if(mapMailingContact != null &&  mapMailingContact.get('ZIP') != null ){
            storageLocation.ShippingPostalCode = String.valueOf(mapMailingContact.get('ZIP'));
        }
        if(mapVehicleLocation.get('LATITUDE') != null ){
            storageLocation.BillingLatitude = Double.valueOf(mapVehicleLocation.get('LATITUDE'));
        }
        if(mapVehicleLocation.get('LONGITUDE') != null ){
            storageLocation.BillingLongitude = Double.valueOf(mapVehicleLocation.get('LONGITUDE'));
        }
        if(mapVehicleLocation.get('ADDRESS_ACCURACY') != null ){
            //storageLocation.BillingGeocodeAccuracy = String.valueOf(mapVehicleLocation.get('ADDRESS_ACCURACY'));
        }
        
        if(mapVehicleLocation.get('SL_FEDERAL_EIN') != null ){
            storageLocation.Federal_Tax_ID__c = String.valueOf(mapVehicleLocation.get('SL_FEDERAL_EIN'));
        }
        if(mapVehicleLocation.get('SL_IAA_CREDIT_CARD') != null && mapVehicleLocation.get('SL_IAA_CREDIT_CARD') == 'Y'){
            storageLocation.Credit_Card_Accepted__c = true;
        }else{
            storageLocation.Credit_Card_Accepted__c = false;
        }
        if(mapVehicleLocation.get('SL_CHECK_PAYABLE_TO') != null ){
            storageLocation.Check_Payable_To__c = String.valueOf(mapVehicleLocation.get('SL_CHECK_PAYABLE_TO'));
        }
        String StorageRequirements;
        if(mapVehicleLocation.containsKey('SL_RELEASE_REQUIREMENTS')) {
            String rrqq = JSON.serialize(mapVehicleLocation.get('SL_RELEASE_REQUIREMENTS'));
           system.debug('----RRQ---'+rrqq);
            String finalString1;
            
            if(String.isNotBlank(rrqq)) {
                if(rrqq.startsWith('{')) {
                    finalString1 = '[{'+rrqq.substring(27,rrqq.length()-1)+']';
                }else{
                    finalString1 = rrqq;
                }
            }
            system.debug('----RRQ1---'+finalString1);
            List<Object> rrQ = new List<Object>();
            if(String.isNotBlank(finalString1)) {
                rrQ = (List<Object>) JSON.deserializeUntyped(finalString1);
            } else {
                rrQ = (List<Object>) mapVehicleLocation.get('SL_RELEASE_REQUIREMENTS');   
            }
            mapVehicleLocation.put('SL_RELEASE_REQUIREMENTS', rrQ);
            if(!rrQ.isEmpty()) {
                
                for(Object rq : rrQ) {
                    Map<String, Object> vc1 = (Map<String, Object>) rq;
                    
                    if(vc1 != null && vc1.get('SL_RELEASE_REQUIREMENT_CODE') != null){
                        if(StorageRequirements == null){
                            StorageRequirements = vc1.get('SL_RELEASE_REQUIREMENT_CODE')+';';
                        }else{
                        StorageRequirements = StorageRequirements + vc1.get('SL_RELEASE_REQUIREMENT_CODE')+';';
                        }
                    }
                }
            }
        }
        system.debug('-----STORAGE----'+StorageRequirements);
        if(StorageRequirements != null){
            storageLocation.Storage_Requirements__c = StorageRequirements;
        }
        

        
        if(mapMailingContact!= null && mapMailingContact.get('COUNTRY_CODE') != null ){
            storageLocation.ShippingCountry = String.valueOf(mapMailingContact.get('COUNTRY_CODE'));
        }
        //Create contact if the Phone number is available in Contact node and if the phone is different than billing contact
        if(mapMailingContact!= null && mapMailingContact.get('PHONE_NUMBER1') != null && mapBillingContact.get('PHONE_NUMBER1')!= null && (mapMailingContact.get('PHONE_NUMBER1') != mapBillingContact.get('PHONE_NUMBER1'))){
            Contact objMContact = new Contact();
            Contact[] objC = [Select id from Contact where CRC_Storage_Location_ID__c =: storageLocationID and Type__c = 'Location Mailing Contact'];
            if(objC.size()> 0 && objC[0].Id != null){
                objMContact.id = objC[0].Id;
            }
            if(mapVehicleLocation.get('STORAGE_LOCATION_ID') != null){
                objMContact.CRC_Storage_Location_ID__c = String.valueOf(mapVehicleLocation.get('STORAGE_LOCATION_ID'));
            }
          
           
            //TODO:
            objMContact.RecordTypeId = contactRecordTypeId;
            objMContact.Phone = String.valueOf(mapMailingContact.get('PHONE_NUMBER1'));
            if(mapMailingContact.get('FIRST_NAME') != null){
                objMContact.FirstName = String.valueOf(mapMailingContact.get('FIRST_NAME'));
            }
            if(mapMailingContact.get('LAST_NAME') != null){
                objMContact.LastName = String.valueOf(mapMailingContact.get('LAST_NAME'));
            }else{
                objMContact.LastName = 'Test';
            }
            if(mapMailingContact.get('ADDRESS_LINE1') != null){
                objMContact.mailingstreet = String.valueOf(mapMailingContact.get('ADDRESS_LINE1'));
            }
            if(mapMailingContact.get('ADDRESS_LINE2') != null){
                objMContact.mailingstreet += System.Label.CRC_Street_Address_Separator + String.valueOf(mapMailingContact.get('ADDRESS_LINE2'));
            }
            if(mapMailingContact.get('CITY') != null){
                objMContact.mailingcity = String.valueOf(mapMailingContact.get('CITY'));
            }
            if(mapMailingContact.get('ZIP') != null){
                objMContact.mailingpostalcode = String.valueOf(mapMailingContact.get('ZIP'));
            }
            if(mapMailingContact.get('COUNTRY_CODE') != null){
                objMContact.mailingcountry = String.valueOf(mapMailingContact.get('COUNTRY_CODE'));
            }
            if(mapMailingContact.get('PHONE_NUMBER1_EXT') != null){
                objMContact.Phone_1_Ext__c = String.valueOf(mapMailingContact.get('PHONE_NUMBER1_EXT'));
            }
            if(mapMailingContact.get('PHONE_TYPE1') != null){
                objMContact.Phone_Type_1__c = String.valueOf(mapMailingContact.get('PHONE_TYPE1'));
            }
            if(mapMailingContact.get('PHONE_NUMBER2') != null){
                objMContact.OtherPhone = String.valueOf(mapMailingContact.get('PHONE_NUMBER2'));
            }
            if(mapMailingContact.get('PHONE_NUMBER2_EXT') != null){
                objMContact.Phone_2_Ext__c = String.valueOf(mapMailingContact.get('PHONE_NUMBER2_EXT'));
            }
            if(mapMailingContact.get('PHONE_TYPE2') != null){
                objMContact.Phone_Type_2__c = String.valueOf(mapMailingContact.get('PHONE_TYPE2'));
            }
            if(mapMailingContact.get('FAX_NUMBER') != null){
                objMContact.Fax = String.valueOf(mapMailingContact.get('FAX_NUMBER'));
            }
            if(mapMailingContact.get('EMAIL') != null){
                objMContact.Email = String.valueOf(mapMailingContact.get('EMAIL'));
            }
            objMContact.AccountId = storageLocation.id; 
            objMContact.Type__c  =   'Location Mailing Contact';
            listContactsToInsert.add(objMContact);
        }
        //duplicate handling for 
        Upsert listContactsToInsert;
   
        if(mapVehicleLocation.containsKey('SL_HOURS_OF_OPERATION')) {
                String rHourOfOp = JSON.serialize(mapVehicleLocation.get('SL_HOURS_OF_OPERATION'));
                String finalString1;
                if(String.isNotBlank(rHourOfOp)) {
                    if(rHourOfOp.startsWith('{')) {
                        finalString1 = '['+rHourOfOp+']';
                    }
                }
                List<Object> operationHours = new List<Object>();
                if(String.isNotBlank(finalString1)) {
                    operationHours = (List<Object>) JSON.deserializeUntyped(finalString1);
                } else {
                    operationHours = (List<Object>) mapVehicleLocation.get('SL_HOURS_OF_OPERATION');   
                }
                mapVehicleLocation.put('SL_HOURS_OF_OPERATION', operationHours);
                if(!operationHours.isEmpty()) {
                    for(Object objOperationHours : operationHours) {
                        Map<String, Object> vc1 = (Map<String, Object>) objOperationHours;

                        if(vc1 != null && vc1.get('HOO_DAY_OF_WEEK') != null){
                            
                            if(vc1.get('HOO_DAY_OF_WEEK') != null && String.valueOf(vc1.get('HOO_DAY_OF_WEEK')) == '1'){
                                if(vc1.get('HOO_OPEN_FROM') != null){  
                                    if(vc1.get('HOO_OPEN_FROM') == '2000-01-01T00:00:00'){
                                        storageLocation.Sunday_Open_From__c =  null;
                                    }else{
                                        List<String> tempList = String.valueOf(vc1.get('HOO_OPEN_FROM')).split('T')[1].split(':');
                                        storageLocation.Sunday_Open_From__c =  Time.newInstance(Integer.valueOf(tempList[0]), Integer.valueOf(tempList[1]), Integer.valueOf(tempList[2]), 0);
                                    }
                                }
                                if(vc1.get('HOO_CLOSED_AT') != null){ 
                                    if(vc1.get('HOO_CLOSED_AT') == '2000-01-01T00:00:00'){
                                        storageLocation.Sunday_Closed_At__c =  null;
                                    }else{
                                        List<String> tempList = String.valueOf(vc1.get('HOO_CLOSED_AT')).split('T')[1].split(':');
                                        storageLocation.Sunday_Closed_At__c =  Time.newInstance(Integer.valueOf(tempList[0]), Integer.valueOf(tempList[1]), Integer.valueOf(tempList[2]), 0);
                                    }
                                }
                                if(vc1.get('HOO_UNAVAILABLE_FROM') != null){   
                                    if(vc1.get('HOO_UNAVAILABLE_FROM') == '2000-01-01T00:00:00'){
                                        storageLocation.Sunday_Unavailable_From__c =  null;
                                    }else{
                                        List<String> tempList = String.valueOf(vc1.get('HOO_UNAVAILABLE_FROM')).split('T')[1].split(':');
                                        storageLocation.Sunday_Unavailable_From__c =  Time.newInstance(Integer.valueOf(tempList[0]), Integer.valueOf(tempList[1]), Integer.valueOf(tempList[2]), 0);
                                    }
                                }
                                if(vc1.get('HOO_UNAVAILABLE_TO') != null){ 
                                    if(vc1.get('HOO_UNAVAILABLE_TO') == '2000-01-01T00:00:00'){
                                        storageLocation.Sunday_Unavailable_To__c =  null;
                                    }else{
                                        List<String> tempList = String.valueOf(vc1.get('HOO_UNAVAILABLE_TO')).split('T')[1].split(':');
                                        storageLocation.Sunday_Unavailable_To__c =  Time.newInstance(Integer.valueOf(tempList[0]), Integer.valueOf(tempList[1]), Integer.valueOf(tempList[2]), 0);
                                    } 
                                }
                            }
                            if(vc1.get('HOO_DAY_OF_WEEK') != null && String.valueOf(vc1.get('HOO_DAY_OF_WEEK')) == '2'){
                                if(vc1.get('HOO_OPEN_FROM') != null){  
                                    if(vc1.get('HOO_OPEN_FROM') == '2000-01-01T00:00:00'){
                                        storageLocation.Monday_Open_From__c =  null;
                                    }else{
                                        List<String> tempList = String.valueOf(vc1.get('HOO_OPEN_FROM')).split('T')[1].split(':');
                                        storageLocation.Monday_Open_From__c =  Time.newInstance(Integer.valueOf(tempList[0]), Integer.valueOf(tempList[1]), Integer.valueOf(tempList[2]), 0);
                                    }
                                }
                                if(vc1.get('HOO_CLOSED_AT') != null){ 
                                    if(vc1.get('HOO_CLOSED_AT') == '2000-01-01T00:00:00'){
                                        storageLocation.Monday_Closed_At__c =  null;
                                    }else{
                                        List<String> tempList = String.valueOf(vc1.get('HOO_CLOSED_AT')).split('T')[1].split(':');
                                        storageLocation.Monday_Closed_At__c =  Time.newInstance(Integer.valueOf(tempList[0]), Integer.valueOf(tempList[1]), Integer.valueOf(tempList[2]), 0);
                                    }
                                }
                                if(vc1.get('HOO_UNAVAILABLE_FROM') != null){   
                                    if(vc1.get('HOO_UNAVAILABLE_FROM') == '2000-01-01T00:00:00'){
                                        storageLocation.Monday_Unavailable_From__c =  null;
                                    }else{
                                        List<String> tempList = String.valueOf(vc1.get('HOO_UNAVAILABLE_FROM')).split('T')[1].split(':');
                                        storageLocation.Monday_Unavailable_From__c =  Time.newInstance(Integer.valueOf(tempList[0]), Integer.valueOf(tempList[1]), Integer.valueOf(tempList[2]), 0);
                                    }
                                }
                                if(vc1.get('HOO_UNAVAILABLE_TO') != null){ 
                                    if(vc1.get('HOO_UNAVAILABLE_TO') == '2000-01-01T00:00:00'){
                                        storageLocation.Monday_Unavailable_To__c =  null;
                                    }else{
                                        List<String> tempList = String.valueOf(vc1.get('HOO_UNAVAILABLE_TO')).split('T')[1].split(':');
                                        storageLocation.Monday_Unavailable_To__c =  Time.newInstance(Integer.valueOf(tempList[0]), Integer.valueOf(tempList[1]), Integer.valueOf(tempList[2]), 0);
                                    } 
                                }
                                
                            }
                            if(vc1.get('HOO_DAY_OF_WEEK') != null && String.valueOf(vc1.get('HOO_DAY_OF_WEEK')) == '3'){
                                if(vc1.get('HOO_OPEN_FROM') != null){  
                                    if(vc1.get('HOO_OPEN_FROM') == '2000-01-01T00:00:00'){
                                        storageLocation.Tuesday_Open_From__c =  null;
                                    }else{
                                        List<String> tempList = String.valueOf(vc1.get('HOO_OPEN_FROM')).split('T')[1].split(':');
                                        storageLocation.Tuesday_Open_From__c =  Time.newInstance(Integer.valueOf(tempList[0]), Integer.valueOf(tempList[1]), Integer.valueOf(tempList[2]), 0);
                                    }
                                }
                                if(vc1.get('HOO_CLOSED_AT') != null){ 
                                    if(vc1.get('HOO_CLOSED_AT') == '2000-01-01T00:00:00'){
                                        storageLocation.Tuesday_Closed_At__c =  null;
                                    }else{
                                        List<String> tempList = String.valueOf(vc1.get('HOO_CLOSED_AT')).split('T')[1].split(':');
                                        storageLocation.Tuesday_Closed_At__c =  Time.newInstance(Integer.valueOf(tempList[0]), Integer.valueOf(tempList[1]), Integer.valueOf(tempList[2]), 0);
                                    }
                                }
                                if(vc1.get('HOO_UNAVAILABLE_FROM') != null){   
                                    if(vc1.get('HOO_UNAVAILABLE_FROM') == '2000-01-01T00:00:00'){
                                        storageLocation.Tuesday_Unavailable_From__c =  null;
                                    }else{
                                        List<String> tempList = String.valueOf(vc1.get('HOO_UNAVAILABLE_FROM')).split('T')[1].split(':');
                                        storageLocation.Tuesday_Unavailable_From__c =  Time.newInstance(Integer.valueOf(tempList[0]), Integer.valueOf(tempList[1]), Integer.valueOf(tempList[2]), 0);
                                    }
                                }
                                if(vc1.get('HOO_UNAVAILABLE_TO') != null){ 
                                    if(vc1.get('HOO_UNAVAILABLE_TO') == '2000-01-01T00:00:00'){
                                        storageLocation.Tuesday_Unavailable_To__c =  null;
                                    }else{
                                        List<String> tempList = String.valueOf(vc1.get('HOO_UNAVAILABLE_TO')).split('T')[1].split(':');
                                        storageLocation.Tuesday_Unavailable_To__c =  Time.newInstance(Integer.valueOf(tempList[0]), Integer.valueOf(tempList[1]), Integer.valueOf(tempList[2]), 0);
                                    } 
                                }
                            }
                            if(vc1.get('HOO_DAY_OF_WEEK') != null && String.valueOf(vc1.get('HOO_DAY_OF_WEEK')) == '4'){
                                if(vc1.get('HOO_OPEN_FROM') != null){  
                                    if(vc1.get('HOO_OPEN_FROM') == '2000-01-01T00:00:00'){
                                        storageLocation.Wednesday_Open_From__c =  null;
                                    }else{
                                        List<String> tempList = String.valueOf(vc1.get('HOO_OPEN_FROM')).split('T')[1].split(':');
                                        storageLocation.Wednesday_Open_From__c =  Time.newInstance(Integer.valueOf(tempList[0]), Integer.valueOf(tempList[1]), Integer.valueOf(tempList[2]), 0);
                                    }
                                }
                                if(vc1.get('HOO_CLOSED_AT') != null){ 
                                    if(vc1.get('HOO_CLOSED_AT') == '2000-01-01T00:00:00'){
                                        storageLocation.Wednesday_Closed_At__c =  null;
                                    }else{
                                        List<String> tempList = String.valueOf(vc1.get('HOO_CLOSED_AT')).split('T')[1].split(':');
                                        storageLocation.Wednesday_Closed_At__c =  Time.newInstance(Integer.valueOf(tempList[0]), Integer.valueOf(tempList[1]), Integer.valueOf(tempList[2]), 0);
                                    }
                                }
                                if(vc1.get('HOO_UNAVAILABLE_FROM') != null){   
                                    if(vc1.get('HOO_UNAVAILABLE_FROM') == '2000-01-01T00:00:00'){
                                        storageLocation.Wednesday_Unavailable_From__c =  null;
                                    }else{
                                        List<String> tempList = String.valueOf(vc1.get('HOO_UNAVAILABLE_FROM')).split('T')[1].split(':');
                                        storageLocation.Wednesday_Unavailable_From__c =  Time.newInstance(Integer.valueOf(tempList[0]), Integer.valueOf(tempList[1]), Integer.valueOf(tempList[2]), 0);
                                    }
                                }
                                if(vc1.get('HOO_UNAVAILABLE_TO') != null){ 
                                    if(vc1.get('HOO_UNAVAILABLE_TO') == '2000-01-01T00:00:00'){
                                        storageLocation.Wednesday_Unavailable_To__c =  null;
                                    }else{
                                        List<String> tempList = String.valueOf(vc1.get('HOO_UNAVAILABLE_TO')).split('T')[1].split(':');
                                        storageLocation.Wednesday_Unavailable_To__c =  Time.newInstance(Integer.valueOf(tempList[0]), Integer.valueOf(tempList[1]), Integer.valueOf(tempList[2]), 0);
                                    } 
                                }
                            }
                            if(vc1.get('HOO_DAY_OF_WEEK') != null && String.valueOf(vc1.get('HOO_DAY_OF_WEEK')) == '5'){
                                if(vc1.get('HOO_OPEN_FROM') != null){  
                                    if(vc1.get('HOO_OPEN_FROM') == '2000-01-01T00:00:00'){
                                        storageLocation.Thursday_Open_From__c =  null;
                                    }else{
                                        List<String> tempList = String.valueOf(vc1.get('HOO_OPEN_FROM')).split('T')[1].split(':');
                                        storageLocation.Thursday_Open_From__c =  Time.newInstance(Integer.valueOf(tempList[0]), Integer.valueOf(tempList[1]), Integer.valueOf(tempList[2]), 0);
                                    }
                                }
                                if(vc1.get('HOO_CLOSED_AT') != null){ 
                                    if(vc1.get('HOO_CLOSED_AT') == '2000-01-01T00:00:00'){
                                        storageLocation.Thursday_Closed_At__c =  null;
                                    }else{
                                        List<String> tempList = String.valueOf(vc1.get('HOO_CLOSED_AT')).split('T')[1].split(':');
                                        storageLocation.Thursday_Closed_At__c =  Time.newInstance(Integer.valueOf(tempList[0]), Integer.valueOf(tempList[1]), Integer.valueOf(tempList[2]), 0);
                                    }
                                }
                                if(vc1.get('HOO_UNAVAILABLE_FROM') != null){   
                                    if(vc1.get('HOO_UNAVAILABLE_FROM') == '2000-01-01T00:00:00'){
                                        storageLocation.Thursday_Unavailable_From__c =  null;
                                    }else{
                                        List<String> tempList = String.valueOf(vc1.get('HOO_UNAVAILABLE_FROM')).split('T')[1].split(':');
                                        storageLocation.Thursday_Unavailable_From__c =  Time.newInstance(Integer.valueOf(tempList[0]), Integer.valueOf(tempList[1]), Integer.valueOf(tempList[2]), 0);
                                    }
                                }
                                if(vc1.get('HOO_UNAVAILABLE_TO') != null){ 
                                    if(vc1.get('HOO_UNAVAILABLE_TO') == '2000-01-01T00:00:00'){
                                        storageLocation.Thursday_Unavailable_To__c =  null;
                                    }else{
                                        List<String> tempList = String.valueOf(vc1.get('HOO_UNAVAILABLE_TO')).split('T')[1].split(':');
                                        storageLocation.Thursday_Unavailable_To__c =  Time.newInstance(Integer.valueOf(tempList[0]), Integer.valueOf(tempList[1]), Integer.valueOf(tempList[2]), 0);
                                    } 
                                }
                            }
                            if(vc1.get('HOO_DAY_OF_WEEK') != null && String.valueOf(vc1.get('HOO_DAY_OF_WEEK')) == '6'){
                                
                                if(vc1.get('HOO_OPEN_FROM') != null){  
                                    if(vc1.get('HOO_OPEN_FROM') == '2000-01-01T00:00:00'){
                                        storageLocation.Friday_Open_From__c =  null;
                                    }else{
                                        List<String> tempList = String.valueOf(vc1.get('HOO_OPEN_FROM')).split('T')[1].split(':');
                                        storageLocation.Friday_Open_From__c =  Time.newInstance(Integer.valueOf(tempList[0]), Integer.valueOf(tempList[1]), Integer.valueOf(tempList[2]), 0);
                                    }
                                }
                                if(vc1.get('HOO_CLOSED_AT') != null){ 
                                    if(vc1.get('HOO_CLOSED_AT') == '2000-01-01T00:00:00'){
                                        storageLocation.Friday_Closed_At__c =  null;
                                    }else{
                                        List<String> tempList = String.valueOf(vc1.get('HOO_CLOSED_AT')).split('T')[1].split(':');
                                        storageLocation.Friday_Closed_At__c =  Time.newInstance(Integer.valueOf(tempList[0]), Integer.valueOf(tempList[1]), Integer.valueOf(tempList[2]), 0);
                                    }
                                }
                                if(vc1.get('HOO_UNAVAILABLE_FROM') != null){   
                                    if(vc1.get('HOO_UNAVAILABLE_FROM') == '2000-01-01T00:00:00'){
                                        storageLocation.Friday_Unavailable_From__c =  null;
                                    }else{
                                        List<String> tempList = String.valueOf(vc1.get('HOO_UNAVAILABLE_FROM')).split('T')[1].split(':');
                                        storageLocation.Friday_Unavailable_From__c =  Time.newInstance(Integer.valueOf(tempList[0]), Integer.valueOf(tempList[1]), Integer.valueOf(tempList[2]), 0);
                                    }
                                }
                                if(vc1.get('HOO_UNAVAILABLE_TO') != null){ 
                                    if(vc1.get('HOO_UNAVAILABLE_TO') == '2000-01-01T00:00:00'){
                                        storageLocation.Friday_Unavailable_To__c =  null;
                                    }else{
                                        List<String> tempList = String.valueOf(vc1.get('HOO_UNAVAILABLE_TO')).split('T')[1].split(':');
                                        storageLocation.Friday_Unavailable_To__c =  Time.newInstance(Integer.valueOf(tempList[0]), Integer.valueOf(tempList[1]), Integer.valueOf(tempList[2]), 0);
                                    } 
                                }
                            }
                            if(vc1.get('HOO_DAY_OF_WEEK') != null && String.valueOf(vc1.get('HOO_DAY_OF_WEEK')) == '7'){
                                if(vc1.get('HOO_OPEN_FROM') != null){  
                                    if(vc1.get('HOO_OPEN_FROM') == '2000-01-01T00:00:00'){
                                        storageLocation.Saturday_Open_From__c =  null;
                                    }else{
                                        List<String> tempList = String.valueOf(vc1.get('HOO_OPEN_FROM')).split('T')[1].split(':');
                                        storageLocation.Saturday_Open_From__c =  Time.newInstance(Integer.valueOf(tempList[0]), Integer.valueOf(tempList[1]), Integer.valueOf(tempList[2]), 0);
                                    }
                                }
                                if(vc1.get('HOO_CLOSED_AT') != null){ 
                                    if(vc1.get('HOO_CLOSED_AT') == '2000-01-01T00:00:00'){
                                        storageLocation.Saturday_Closed_At__c =  null;
                                    }else{
                                        List<String> tempList = String.valueOf(vc1.get('HOO_CLOSED_AT')).split('T')[1].split(':');
                                        storageLocation.Saturday_Closed_At__c =  Time.newInstance(Integer.valueOf(tempList[0]), Integer.valueOf(tempList[1]), Integer.valueOf(tempList[2]), 0);
                                    }
                                }
                                if(vc1.get('HOO_UNAVAILABLE_FROM') != null){   
                                    if(vc1.get('HOO_UNAVAILABLE_FROM') == '2000-01-01T00:00:00'){
                                        storageLocation.Saturday_Unavailable_From__c =  null;
                                    }else{
                                        List<String> tempList = String.valueOf(vc1.get('HOO_UNAVAILABLE_FROM')).split('T')[1].split(':');
                                        storageLocation.Saturday_Unavailable_From__c =  Time.newInstance(Integer.valueOf(tempList[0]), Integer.valueOf(tempList[1]), Integer.valueOf(tempList[2]), 0);
                                    }
                                }
                                if(vc1.get('HOO_UNAVAILABLE_TO') != null){ 
                                    if(vc1.get('HOO_UNAVAILABLE_TO') == '2000-01-01T00:00:00'){
                                        storageLocation.Saturday_Unavailable_To__c =  null;
                                    }else{
                                        List<String> tempList = String.valueOf(vc1.get('HOO_UNAVAILABLE_TO')).split('T')[1].split(':');
                                        storageLocation.Saturday_Unavailable_To__c =  Time.newInstance(Integer.valueOf(tempList[0]), Integer.valueOf(tempList[1]), Integer.valueOf(tempList[2]), 0);
                                    } 
                                }
                            }
                        }
                    }
                }
         }
    
         return storageLocation;

    }//RPM_PraseStorageLocation

    public static List<Variable_Storage_Charge__c> RPM_PraseVariableStorageCharges(Case currentReleaseAssignment) {
        List<Variable_Storage_Charge__c>  variableStorageCharges = new List<Variable_Storage_Charge__c> ();
	
        //Map<String, Object> mapStorageRate = (Map<String, Object>) mapRelease.get('VARIABLE_STORAGE_RATE_INFO');
       
        if(mapRelease.containsKey('VARIABLE_STORAGE_RATE_INFO')) {
            String rStorageToString = JSON.serialize(mapRelease.get('VARIABLE_STORAGE_RATE_INFO'));
            String finalString1;
            
            if(String.isNotBlank(rStorageToString)) {
                if(rStorageToString.startsWith('{"VARIABLE_STORAGE_RATE_INFO":')){
                    finalString1 = '[{'+rStorageToString.substring(31,rStorageToString.length()-1)+']';
                   
                }else if(rStorageToString.startsWith('{')) {
                    finalString1 = '['+rStorageToString+']';
                }else{
                    finalString1 = rStorageToString;
                }
            }
            List<Object> rStorages = new List<Object>();
            if(String.isNotBlank(finalString1)) {
                rStorages = (List<Object>) JSON.deserializeUntyped(finalString1);
            } else {
                rStorages = (List<Object>) mapRelease.get('VARIABLE_STORAGE_RATE_INFO');   
            }
            mapRelease.put('VARIABLE_STORAGE_RATE_INFO', rStorages);
            if(!rStorages.isEmpty()) {
                
                for(Object vrExpense : rStorages) {
                    Map<String, Object> vc1 = (Map<String, Object>) vrExpense;
                    
                    if(vc1 != null && vc1.get('VRS_SEQUENCE_NBR') != null){
                        
                        Variable_Storage_Charge__c vs = new Variable_Storage_Charge__c();
                        if(currentReleaseAssignment.Id != null){
                            vs.Case__c = currentReleaseAssignment.Id ;
                        }
                        if(vc1.get('VRS_SEQUENCE_NBR') != null){
                            vs.Name =  String.valueOf(vc1.get('VRS_SEQUENCE_NBR')); 
                        }
                        if(vc1.get('VRS_FEE_AMOUNT') != null){
                            vs.Fee_Amount__c =  Decimal.valueOf(String.valueOf(vc1.get('VRS_FEE_AMOUNT'))); 
                        }
                        if(vc1.get('VRS_RESPONSIBLE_PARTY') != null){
                            vs.Responsible_Party__c =  String.valueOf(vc1.get('VRS_RESPONSIBLE_PARTY')); 
                        }
                        if(vc1.get('VRS_RESPONSIBLE_PARTY') != null){
                            vs.Variable_Days__c =  Integer.valueOf(vc1.get('VRS_VARIABLE_DAYS')); 
                        }
                        variableStorageCharges.add(vs); 
                        
                    }
                  
                }
            }
        }
        return variableStorageCharges;

    }//RPM_PraseVariableStorageCharges
    
    public static List<Release_Charge__c> RPM_PraseReleaseCharges(Case currentReleaseAssignment) {
        List<Release_Charge__c>  releaseCharges = new List<Release_Charge__c> ();
        
        if(mapRelease.containsKey('VR_EXPENSES')) {
            String rStorageToString = JSON.serialize(mapRelease.get('VR_EXPENSES'));
            System.debug('----RP01---'+rStorageToString);
            String finalString1;
            
            if(String.isNotBlank(rStorageToString)) {
                if(rStorageToString.startsWith('{"VR_EXPENSE":')){
                    finalString1 = '[{'+rStorageToString.substring(15,rStorageToString.length()-1)+']';
                   
                }else if(rStorageToString.startsWith('{')) {
                    finalString1 = '['+rStorageToString+']';
                }else{
                    finalString1 = rStorageToString;
                }
            }
            System.debug('----RP011---'+finalString1);
            List<Object> rStorages = new List<Object>();
            if(String.isNotBlank(finalString1)) {
                rStorages = (List<Object>) JSON.deserializeUntyped(finalString1);
            } else {
                rStorages = (List<Object>) mapRelease.get('VR_EXPENSES');   
            }
            mapRelease.put('VR_EXPENSES', rStorages);
            if(!rStorages.isEmpty()) {
                
                for(Object vrExpense : rStorages) {
                    Map<String, Object> vc1 = (Map<String, Object>) vrExpense;
                    
                    if(vc1 != null && vc1.get('VRE_CHARGE_TYPE_ID') != null){
                        
                        Release_Charge__c vs = new Release_Charge__c();
                        if(currentReleaseAssignment.Id != null){
                            vs.Case__c = currentReleaseAssignment.Id ;
                        }
                        
                        if(vc1.get('VRE_CHARGE_TYPE_ID') != null){
                            vs.Name =  String.valueOf(vc1.get('VRE_CHARGE_TYPE_ID')); 
                            vs.charge_type__c =  String.valueOf(vc1.get('VRE_CHARGE_TYPE_ID')); 
                        }
                        if(vc1.get('VRE_EVENT_CATEGORY_CODE') != null){
                            vs.Event_Category__c =  String.valueOf(vc1.get('VRE_EVENT_CATEGORY_CODE')); 
                        }
                        if(vc1.get('VRE_AMOUNT') != null){
                            vs.Amount__c =  Double.valueOf(vc1.get('VRE_AMOUNT')); 
                        }
                        if(vc1.get('VRE_TAX_AMOUNT') != null){
                            vs.Tax_Amount__c =  Double.valueOf(vc1.get('VRE_TAX_AMOUNT')); 
                        }else{
                            vs.Tax_Amount__c = 0.0;
                        }
                        if(vc1.get('VRE_RESPONSIBLE_PARTY_CODE') != null){
                            vs.Responsible_Party__c =  String.valueOf(vc1.get('VRE_RESPONSIBLE_PARTY_CODE')); 
                        }
                        releaseCharges.add(vs);    
                    }
                }
            }
        }
        return releaseCharges;

    }//RPM_PraseReleaseCharges
 
    public static List<Task> RPM_PraseNotes(map<String,Task>  mapNotes, Case currentReleaseAssignment) {
        List<Task> listTask = new List<Task>();
        if(mapProcStatus.containsKey('VEHICLE_COMMENTS')) {
            String commentsToString = JSON.serialize(mapProcStatus.get('VEHICLE_COMMENTS'));
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
                vehicleComments = (List<Object>) mapProcStatus.get('VEHICLE_COMMENTS');   
            }
            System.debug(JSON.serialize(vehicleComments));
            if(vehicleComments!= null && !vehicleComments.isEmpty()) {
                Set<String> setValidCommentCategory = new Set<String>{'ASN','DSP','RLS','RLP'};
                
                for(Object vehicleComment : vehicleComments) {
                    Map<String, Object> vc = (Map<String, Object>) vehicleComment;
                    Task objTask = new Task();
                    objTask.Status = 'Completed';
                   
                    if(vc.get('COMMENT_DATETIME')!= null && vc.get('COMMENT_CATEGORY') != null && mapNotes.get(String.valueOf(vc.get('COMMENT_DATETIME')).replace('T',' ').SubStringBefore('.')) == null && setValidCommentCategory.contains(String.valueOf(vc.get('COMMENT_CATEGORY')))){
                            if(vc.get('COMMENT_DATETIME') != null){ 
                                objTask.CRC_Comment_DateTime_Text__c = String.valueOf(vc.get('COMMENT_DATETIME'));
                            }
                            if(String.valueOf(vc.get('COMMENT_TEXT')).length() > 70){
                                objTask.Subject = String.valueOf(vc.get('COMMENT_CATEGORY')) +' : '+ String.valueOf(vc.get('COMMENT_TEXT')).substring(0,70); 
                            }else{
                                objTask.Subject = String.valueOf(vc.get('COMMENT_CATEGORY')) +' : '+ String.valueOf(vc.get('COMMENT_TEXT')); 
                            }
                            
                            objTask.CRC_Comment_ID__c = String.valueOf(vc.get('COMMENT_ID'));
                            objTask.CRC_Comment_Author__c = String.valueOf(vc.get('COMMENT_AUTHOR'));
                            objTask.Description = String.valueOf(vc.get('COMMENT_TEXT'));
                            objTask.CRC_Note_Category__c = String.valueOf(vc.get('COMMENT_CATEGORY'));
                            objTask.RecordTypeId  = notesOnTaskRecordTypeId;

                            objTask.WhatId = currentReleaseAssignment.id;
                            listTask.add(objTask);
                     }
                }
          }
      }

      return listTask;

    }//RPM_PraseNotes

    //Switch method from release problem to case is pending
    public static List<Task> RPM_PraseReleaseProblems(map<String,Task>  mapReleseProblem, Case currentReleaseAssignment) {

        List<Task> listRProb = new List<Task>();
        if(mapProcStatus.containsKey('RELEASE_PROBLEMS')) {
          
            String rProblemToString = JSON.serialize(mapProcStatus.get('RELEASE_PROBLEMS'));
            String finalString1;
            if(String.isNotBlank(rProblemToString)) {
                 if(rProblemToString.startsWith('{"RELEASE_PROBLEM":')){
                    finalString1 = '[{'+rProblemToString.substring(20,rProblemToString.length()-1)+']';
                   
                }else if(rProblemToString.startsWith('{')) {
                    finalString1 = '['+rProblemToString+']';
                }else{
                    finalString1 = rProblemToString;
                }
            }

            List<Object> releaseProblems = new List<Object>();
            if(String.isNotBlank(finalString1)) {
                releaseProblems = (List<Object>) JSON.deserializeUntyped(finalString1);
              
            } else {
                releaseProblems = (List<Object>) mapProcStatus.get('RELEASE_PROBLEMS');   
            }
            
            mapProcStatus.put('RELEASE_PROBLEMS', releaseProblems);

            if(!releaseProblems.isEmpty()) {
                for(Object objReleaseProb : releaseProblems) {

                    Map<String, Object> vc1 = (Map<String, Object>) objReleaseProb;
                    if(vc1 != null && vc1.get('RELEASE_PROBLEM_CODE') != null){
                        Task rp = new Task();
                        rp.IsVisibleInSelfService = true;
                        rp.RecordTypeId = releaseProblemOnTaskRecordType;
                        rp.WhatId = currentReleaseAssignment.id;
                        if(vc1.get('RELEASE_PROBLEM_CODE') != null){
                            rp.Release_Problem_Code__c =  String.valueOf(vc1.get('RELEASE_PROBLEM_CODE')); 
                        }
                        system.debug('------192--'+vc1.get('RELEASE_PROBLEM_OPEN_DATETIME'));
                        system.debug('------193--'+String.valueOf(vc1.get('RELEASE_PROBLEM_OPEN_DATETIME')).replace('T',' '));
                        if(vc1.get('RELEASE_PROBLEM_DESCRIPTION') != null){
                            rp.subject =  String.valueOf(vc1.get('RELEASE_PROBLEM_DESCRIPTION')); 
                        }
                        if(vc1.get('RELEASE_PROBLEM_OPEN_DATETIME') != null){ 
                            //rp.CRC_Comment_DateTime__c = Datetime.valueOfGMT(String.valueOf(vc1.get('RELEASE_PROBLEM_OPEN_DATETIME')).replace('T',' '));
                            rp.CRC_Comment_Datetime_Text__c = String.valueOf(vc1.get('RELEASE_PROBLEM_OPEN_DATETIME'));
                        }
                        if(vc1.get('RELEASE_PROBLEM_LAST_WORKED_DATETIME') != null){ 
                            rp.RP_Last_Worked_DateTime__c = convertStringToDateTime(String.valueOf(vc1.get('RELEASE_PROBLEM_LAST_WORKED_DATETIME')).replace('T',' '));
                        }
                        if(vc1.get('RELEASE_PROBLEM_FOLLOW_UP_DATETIME') != null){ 
                            rp.RP_Follow_Up_Date_Time__c = convertStringToDateTime(String.valueOf(vc1.get('RELEASE_PROBLEM_FOLLOW_UP_DATETIME')).replace('T',' '));
                        }
                        if(vc1.get('RELEASE_PROBLEM_RESOLVED_DATETIME') != null){ 
                            rp.RP_Resolved_Date_Time__c = convertStringToDateTime(String.valueOf(vc1.get('RELEASE_PROBLEM_RESOLVED_DATETIME')).replace('T',' '));
                        }
                        if(vc1.get('RELEASE_PROBLEM_RESOLVED') == 'Y'){
                            rp.Status = 'Completed';
                        }else{
                            rp.Status = 'In Progress';
                        }
                        if(mapReleseProblem.get(String.valueOf(rp.CRC_Comment_DateTime_Text__c)) != null ){
                            rp.id =  mapReleseProblem.get(String.valueOf(rp.CRC_Comment_DateTime_Text__c)).id;
                        }
                        listRProb.add(rp);
                        
                    }
                }
            }
        }
        return listRProb;
    
    }//RPM_PraseReleaseProblems

    public static Account RPM_PraseSalvageProvider(Map<String, Object> mainNode, Account objSalvageProviderAccount) {
  
        //Provider fields
        
        if(mapProvider.get('PROVIDER_OFFICE_IDENTIFIER') != null ){
            //Get Account with matching 
            String providerIdentifier = '%'+mapProvider.get('PROVIDER_OFFICE_IDENTIFIER')+'%';
            Account[] objA = [Select id from Account where BI_ID__c like :providerIdentifier];
            if(objA.size()> 0 && objA[0].Id != null){
                objSalvageProviderAccount.id = objA[0].Id;
            }
            objSalvageProviderAccount.BI_ID__c = String.valueOf(mapProvider.get('PROVIDER_OFFICE_IDENTIFIER'));
            objSalvageProviderAccount.RecordTypeId = providerAccountRecordType;

            if(mapProvider.get('PROVIDER_NAME') != null ){
                objSalvageProviderAccount.Name = String.valueOf(mapProvider.get('PROVIDER_NAME'));
            }
            if(mapProvider.get('PROVIDER_GROUP_CODE') != null ){
                objSalvageProviderAccount.CRC_Provider_Group_Code__c = Integer.valueOf(mapProvider.get('PROVIDER_GROUP_CODE'));
            }
            if(mapProvider.get('PROVIDER_GROUP_DESCRIPTION') != null ){
                objSalvageProviderAccount.CRC_Provider_Group_Description__c = String.valueOf(mapProvider.get('PROVIDER_GROUP_DESCRIPTION'));
            }
            // added by balram till line # 1731
            String providerGroupDescription = String.valueOf(mapProvider.get('PROVIDER_GROUP_DESCRIPTION'));
            
            //mainNode.put('CRC_Provider_SLA__c', '2 Hours');
            //mainNode.put('CRC_Same_Day_Release__c', false);
            if(String.isNotBlank(providerGroupDescription)) {
                List<CRC_SLA_Calculation__mdt> slaCalculations = CRC_SLA_Calculation__mdt.getAll().values();

                if(!slaCalculations.isEmpty()) {
                    for (CRC_SLA_Calculation__mdt sla : slaCalculations) {
                        if(sla.Label.contains(providerGroupDescription)) {
                            objSalvageProviderAccount.CRC_Provider_SLA__c = sla.SLA__c;
                            objSalvageProviderAccount.CRC_Same_Day__c = sla.Same_Day__c;
                            //mainNode.put('CRC_Provider_SLA__c', sla.SLA__c);
                            //mainNode.put('CRC_Same_Day_Release__c', sla.Same_Day__c);
                            break;
                        }else{
                            objSalvageProviderAccount.CRC_Provider_SLA__c = '2 Hours';
                            objSalvageProviderAccount.CRC_Same_Day__c = false;
                            //mainNode.put('CRC_Provider_SLA__c', '2 Hours');
                            // mainNode.put('CRC_Provider_SLA__c', '2 Hours');
                            // mainNode.put('CRC_Same_Day_Release__c', false);
                        }
                    }
                }

                // List<CRC_Same_Day_Provider__mdt> sameDayMapping = CRC_Same_Day_Provider__mdt.getAll().values();
                // if(!slaCalculations.isEmpty()) {
                //     for (CRC_Same_Day_Provider__mdt sla : sameDayMapping) {
                //         if(sla.Label.contains(providerGroupDescription)) {
                //             mainNode.put('CRC_Provider_SLA__c', 'Same Day');
                //             mainNode.put('CRC_Same_Day_Release__c', true);
                //             break;
                //         }
                //     }
                // }
            }
        }
 
        return objSalvageProviderAccount;

    }//RPM_PraseSalvageProvider

    public static Contact RPM_PraseSalvageProviderContact(Contact crcAdjusterContact,Account objSalvageProviderAccount) {
  
        crcAdjusterContact = RPM_PraseContact((Map<String, Object>) claimRep.get('CONTACT'));  
        crcAdjusterContact.RecordTypeId = contactRecordTypeId;
        crcAdjusterContact.Stock_Number__c = currentStockNumber;

        String providerIdentifier = String.valueof(mapProvider.get('PROVIDER_OFFICE_IDENTIFIER'));

        if(objSalvageProviderAccount.Id != null){
            crcAdjusterContact.AccountId = objSalvageProviderAccount.id;
        }
        crcAdjusterContact.Type__c = 'Adjuster';
        if(mapProvider.get('PROVIDER_OFFICE_IDENTIFIER') != null){
            crcAdjusterContact.CRC_Storage_Location_ID__c = providerIdentifier;
        }

        upsertContact(crcAdjusterContact, providerIdentifier);

        // if(providerIdentifier != null && crcAdjusterContact.Id == null){
        //     Contact[] objC = [Select id from Contact where CRC_Storage_Location_ID__c =: providerIdentifier];
        //     if(objC.size()> 0 && objC[0].Id != null){
        //         crcAdjusterContact.id = objC[0].Id;
        //     }else{
        //         crcAdjusterContact.CRC_Storage_Location_ID__c = providerIdentifier;
        //     }
        // }
        
        return crcAdjusterContact;

    }

    public static Contact RPM_BranchManagerContact(Contact crcBMContact,Branch__c objBranch){
        crcBMContact = RPM_PraseContact((Map<String, Object>) branchContact.get('CONTACT'));
        crcBMContact.RecordTypeId = contactRecordTypeId;
        crcBMContact.Stock_Number__c = currentStockNumber;
            if(objBranch.id != null){
                crcBMContact.Branch__c = objBranch.id;
            }
            crcBMContact.Type__c = 'Branch Manager';


            //TODO: change storage location field to contact id
            String branchCode = String.valueOf(mapSalvor.get('BRANCH_CODE'));
            if(String.isNotBlank(branchCode)) {
                upsertContact(crcBMContact, branchCode);
            }
            // if(branchCode != null && crcBMContact.Id == null){
            //     Contact[] objC = [Select id from Contact where CRC_Storage_Location_ID__c =: branchCode];
            //     if(objC.size()> 0 && objC[0].Id != null){
            //         crcBMContact.id = objC[0].Id;
            //     }else{
            //         crcBMContact.CRC_Storage_Location_ID__c = branchCode;
            //     }
            // }
            return crcBMContact;
    }//RPM_BranchManagerContact

    private static void upsertContact(Contact con, String uniqueIdentifier) {
        List<Contact> contacts = [SELECT Id FROM Contact WHERE Stock_Number__c =:currentStockNumber AND CRC_Storage_Location_Id__c =:uniqueIdentifier];
        if(!contacts.isEmpty()) {
            con.Stock_Number__c = currentStockNumber;
            con.CRC_Storage_Location_Id__c = uniqueIdentifier;
            con.Id = contacts[0].Id;
        } else {
            con.Stock_Number__c = currentStockNumber;
            con.CRC_Storage_Location_Id__c = uniqueIdentifier;
            con.Id = null;
        }
    }

    private static Map<String, String> getRelatedContacts() {
        List<Contact> contacts = [SELECT Id, Type__c, CRC_Storage_Location_Id__c FROM Contact 
                                    WHERE  Stock_Number__c =:currentStockNumber];

        Map<String, String> typeVsContactId = new Map<String, String>();
        if(!contacts.isEmpty()) {
            for(Contact c : contacts) {
                typeVsContactId.put(c.Type__c+'---'+c.CRC_Storage_Location_Id__c, c.Id);
            }
        }
        return typeVsContactId;
    }

    private static datetime convertStringToDateTime(String inputDateString){


        DateTime inputDateTime  = Datetime.valueOfGMT(inputDateString);  
        System.debug('inputDateTime = ' + inputDateTime);

            TimeZone tz = TimeZone.getTimeZone(System.Label.CRC_RPM_Timezone);
            String tzName = tz.getDisplayName();
            String parsedHours = tzName.substringBetween('(GMT',') ');
            String parsedHoursTime = parsedHours.substring(1);
            Boolean ifContainsMinus = parsedHours.contains('-') ? true : false;
            String[] timeArray = parsedHoursTime.split(':');
            if( ifContainsMinus ){ 
                inputDateTime =  inputDateTime.addHours(integer.valueOf(timeArray[0]));
                inputDateTime =  inputDateTime.addMinutes(Integer.valueOf(timeArray[1]));
            }else{// When daylight is of
                inputDateTime =  inputDateTime.addHours(-Integer.valueOf(timeArray[0]));
                inputDateTime =  inputDateTime.addMinutes(-Integer.valueOf(timeArray[1]));
            }
        
        return inputDateTime;
    }

}