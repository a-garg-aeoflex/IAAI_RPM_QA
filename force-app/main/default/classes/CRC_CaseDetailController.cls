public class CRC_CaseDetailController {
    @AuraEnabled
    public static Map<String, Object> getCaseDetail(String caseId){
        try {
            if(String.isBlank(caseId)) {
                throw new CRC_Exception('Invalid Case Id');
            }
            String ReleaseProblemId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('CRC Release Problem').getRecordTypeId();
            Case cs = [SELECT Id, CRC_Storage_Location__c, CRC_Release_Requirements__c, OwnerId, CRC_Checksum__c, Stock__r.Stock__c, CRC_Salvage_Id__c, 
                        Account.Name, CRC_Storage_Rate__c,  Adv_Charges_Max_Authorized_Amount__c, Provider_Defined_Max_Auth_Amount__c, 
                        Updated_Advance_Chg_Auth_By_First_Name__c, Updated_Advance_Chg_Auth_By_Last_Name__c, Updated_Advance_Chg_Auth_DateTime__c,
                        Updated_Advance_Chg_Max_Authorized_Amt__c, CRC_VO_Address_Line_1__c, CRC_VO_City__c,
                        CRC_VO_Email__c, CRC_VO_Fax__c, CRC_VO_First_Name__c, CRC_VO_Last_Name__c, CRC_VO_Primary_Extension__c, CRC_VO_Primary_Phone_Number__c,
                        CRC_VO_Primary_Phone_Type__c, CRC_VO_Secondary_Phone_Number__c, CRC_VO_Secondary_Phone_Type__c, CRC_VO_Zip__c, 
                        VO_Validated__c, VO_Status__c, CRC_Company_Name__c, CRC_Res_Location_Id__c, CRC_Res_Checksum__c, CRC_VO_StatePicklist__c, 
                        CRC_VO_Country__c, Title_Indicator__c, CRC_Stock_Number__c,
                
                        CRC_Storage_Location__r.Name, CRC_Storage_Location__r.Location_Id__c, toLabel(CRC_Storage_Location__r.Storage_Location_Status__c),
                        CRC_Storage_Location__r.Phone, CRC_Storage_Location__r.Fax, CRC_Storage_Location__r.Email__c, CRC_Storage_Location__r.BillingStreet, 
                        CRC_Storage_Location__r.BillingCity, CRC_Storage_Location__r.BillingState, CRC_Storage_Location__r.BillingPostalCode, 
                        CRC_Storage_Location__r.ShippingStreet, CRC_Storage_Location__r.ShippingCity, CRC_Storage_Location__r.ShippingState, 
                        CRC_Storage_Location__r.ShippingCountry, CRC_Storage_Location__r.BillingCountry,
                        CRC_Storage_Location__r.ShippingPostalCode, CRC_Storage_Location__r.Federal_Tax_ID__c, toLabel(CRC_Storage_Location__r.Storage_Requirements__c), 
                        CRC_Storage_Location__r.Sunday_Open_From__c, CRC_Storage_Location__r.Sunday_Closed_At__c, CRC_Storage_Location__r.Sunday_Unavailable_From__c,
                        CRC_Storage_Location__r.Sunday_Unavailable_To__c, CRC_Storage_Location__r.CRC_checksum__c, 
                        CRC_Storage_Location__r.Monday_Open_From__c, CRC_Storage_Location__r.Monday_Closed_At__c, CRC_Storage_Location__r.Monday_Unavailable_From__c,
                        CRC_Storage_Location__r.Monday_Unavailable_To__c, CRC_Storage_Location__r.Validated__c, 
                        CRC_Storage_Location__r.Tuesday_Open_From__c, CRC_Storage_Location__r.Tuesday_Closed_At__c, CRC_Storage_Location__r.Tuesday_Unavailable_From__c,
                        CRC_Storage_Location__r.Tuesday_Unavailable_To__c, 
                        CRC_Storage_Location__r.Wednesday_Open_From__c, CRC_Storage_Location__r.Wednesday_Closed_At__c, CRC_Storage_Location__r.Wednesday_Unavailable_From__c,
                        CRC_Storage_Location__r.Wednesday_Unavailable_To__c, 
                        CRC_Storage_Location__r.Thursday_Open_From__c, CRC_Storage_Location__r.Thursday_Closed_At__c, CRC_Storage_Location__r.Thursday_Unavailable_From__c,
                        CRC_Storage_Location__r.Thursday_Unavailable_To__c, 
                        CRC_Storage_Location__r.Friday_Open_From__c, CRC_Storage_Location__r.Friday_Closed_At__c, CRC_Storage_Location__r.Friday_Unavailable_From__c,
                        CRC_Storage_Location__r.Friday_Unavailable_To__c, 
                        CRC_Storage_Location__r.Saturday_Open_From__c, CRC_Storage_Location__r.Saturday_Closed_At__c, CRC_Storage_Location__r.Saturday_Unavailable_From__c,
                        CRC_Storage_Location__r.Saturday_Unavailable_To__c, CRC_Storage_Location__r.Cash_Only_Payments__c, CRC_Storage_Location__r.Credit_Card_Accepted__c,
                        CRC_Storage_Location__r.Call_Before_Pickup__c, CRC_Storage_Location__r.Check_Payable_To__c,

                        CRC_Pickup_Location_Type__c, 
            
                        CRC_VIN__c, CRC_Year__c, Model__c, CRC_Make__c, CRC_License_Plate__c, CRC_Release_Person_First_Name__c, CRC_Release_Person_Last_Name__c, 
                        CRC_Assignment_Type__c, CRC_Vehicle_Location__c, 
                        CRC_Exterior_Color__c, CRC_Is_Vehicle_There__c, CRC_Vehicle_Released__c, 
                        CRC_Earliest_Available_Pickup__c,CRC_Anticipated_Release_Date_Time__c,
                        CRC_SLA_Calculated_Pickup_DateTime__c,CRC_Quoted_Release_Date_Time__c, CRC_Vehicle_Blocked_In__c, CRC_Keys_with_Vehicle__c, CRC_Call_Before_Coming__c, CRC_Vehicle_Towable__c, 
                        CRC_Tow_Zone__c, CRC_Mileage__c, CRC_Primary_Damage_Code__c, CRC_Drive__c, CRC_Fuel_Type__c, 
                        CRC_Loss_Type__c, CRC_Secondary_Damage_Code__c,

                        CRC_Start_Date__c, CRC_End_Date__c,CRC_Total_Check_Amount__c,IAA_Requested_to_Pay_Advance_Charges__c,CRC_Charges_Cleared__c, CRC_Maximum_Authorized_Amount__c, CRC_Rate_Type__c,

                        (SELECT Id, Name, Responsible_Party__c, Variable_Days__c, Fee_Amount__c FROM Variable_Storage_Charges__r),

                        (SELECT Id, Subject, Status, Release_Problem_Code__c, CRC_Comment_DateTime__c, RP_Last_Worked_DateTime__c,RP_Follow_Up_Date_Time__c, 
                        RP_Resolved_Date_Time__c,RP_Resolved__c,CRC_Comment_Datetime_Text__c 
                        FROM Tasks 
                        where recordtypeid =: ReleaseProblemId)

                        FROM Case
                        WHERE Id =:caseId];

            return new Map<String, Object>{
                'case' => cs, 
                'storage' => cs.CRC_Storage_Location__r, 
                'releaseProblems' => cs.Tasks,
                'releaseCharges' => [SELECT Id, Name, Charge_Type__c, Event_Category__c, Amount__c, Tax_Amount__c, Responsible_Party__c, Case__c 
                                    FROM Release_Charge__c WHERE Case__c =: caseId],
                'actionsNeeded' => (String.isNotBlank(cs.OwnerId) && (String.valueOf(cs.OwnerId).startsWith('005')) ? true : false),
                'storageLocationContacts' => [SELECT Id, FirstName, LastName, RecordType.Name, Email, Fax, Type__c, Phone FROM Contact 
                                            WHERE 
                                            Stock_Number__c =:cs.CRC_Stock_Number__c AND AccountId =:cs.CRC_Storage_Location__c AND 
                                            RecordType.DeveloperName =:CRC_Constants.STORAGE_LOCATION_CONTACT_RECORD_TYPE_NAME 
                                            AND (Type__c =:CRC_Constants.STORAGE_LOCATION_CONTACT_TYPE OR Type__c =:CRC_Constants.STORAGE_LOCATION_MAILING_CONTACT_TYPE) LIMIT 2]
            };
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, Object> saveCaseDetail(Map<String, Object> inputData){
        try {
            Case cs = (Case) JSON.deserializeStrict(JSON.serialize(inputData.get('assignment')), Case.class);
            // update cs;
            return new Map<String, Object>{'success' => true, 'case' => cs};
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, Object> saveStorageInformation(Map<String, Object> inputData){
        try {
            Account acc = (Account) JSON.deserializeStrict(JSON.serialize(inputData.get('storage')), Account.class);
            update acc;
            return new Map<String, Object>{'success' => true, 'storage' => acc};
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, Object> updateAssignmentInRPM(Map<String, Object> inputData){
        try {
            Map<String, Object> response = new Map<String, Object>();
            RPM_ReleaseAssignmentController.BasicHttpBinding_IAssignment obj = new RPM_ReleaseAssignmentController.BasicHttpBinding_IAssignment();
            Blob headerValue = Blob.valueOf(CRC_Constants.RPM_CREDENTIALS.DeveloperName + ':' + CRC_Constants.RPM_CREDENTIALS.Password__c);
            String authorizationHeader = 'BASIC '+ EncodingUtil.base64Encode(headerValue);
            Map<String,String> inputHeaderMap = new  Map<String,String>();
            inputHeaderMap.put('Authorization', authorizationHeader);
            obj.inputHttpHeaders_x = inputHeaderMap;
            //obj.endpoint_x  = imdt.Endpoint__c;
            obj.timeout_x = Integer.valueOf(CRC_Constants.RPM_CREDENTIALS.Callout_Time_Limit__c);
            String soapResponse = obj.IAAI_ASSIGNMENT_INFO(CRC_RPM_RequestHelper.assignmentUpdateRequest(inputData), CRC_Constants.RPM_CREDENTIALS.DeveloperName);
            System.debug(soapResponse);
            response.put('response', soapResponse);
            return response;
        } catch (Exception e) {
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, Object> searchLocation(Map<String, Object> inputData){
        try {
            Map<String, Object> result = new Map<String, Object>();
            String fieldName = String.valueOf(inputData.get('fieldName'));
            String fieldValue = String.escapeSingleQuotes(String.valueOf(inputData.get('value')));
            if(String.isBlank(fieldValue)) {
                throw new CRC_Exception('No Storage Location Found');
            }
            String query = 'SELECT Id, Location__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, Phone FROM Account WHERE RecordTypeId = \'0121U000000araJQAQ\'';
            if (fieldName == 'Location_Id__c') {
                Integer fieldValueInt = Integer.valueOf(fieldValue);
                query += ' AND Location_Id__c =: fieldValueInt';
            } else if (fieldName == 'Location__c') {
                query += ' AND Location__c =: fieldValue';
            } else if (fieldName == 'BillingCity') {
                query += ' AND BillingCity =: fieldValue';
            } else if (fieldName == 'BillingPostalCode') {
                query += ' AND BillingPostalCode =: fieldValue';
            } else if (fieldName == 'Branch__r.Name') {
                query += ' AND Branch__r.Name =: fieldValue';
            }

            List<Account> accounts = Database.query(query);
            if(accounts.size() == 0) {
                throw new CRC_Exception('No Storage Location Found');
            }
            return new Map<String, Object>{'result' => accounts};
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, Object> searchStorageLocation(Map<String, String> inputData){
        try {
            System.debug(JSON.serialize('inputData-->'+inputData));
            Map<String, Object> response = new Map<String, Object>();
            String emptyValue = '';
            String companyName = (inputData.get('LocationName') != null) ? inputData.get('LocationName') : '';
            String country = (inputData.get('Country') != null) ? inputData.get('Country') : '';
            String state = (inputData.get('State') != null) ? inputData.get('State') : '';

            String address = (inputData.get('fieldName') == 'Address') ? inputData.get('value') : '';
            String city = (inputData.get('fieldName') == 'City') ? inputData.get('value') : '';
            String zip = (inputData.get('fieldName') == 'Zip') ? inputData.get('value') : '';
            
            // '<COMPANY_NAME>'+(fieldName.equals('Company') == true ? value : emptyValue)+'</COMPANY_NAME>'+
            String xmlSt = '<IAAI_STORAGE_LOCATION_LOOKUP xmlns="http://eai.iaa.com/AssignmentRelease/iaai_storage_location_lookup/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'+
                                '<TRAN_ID>36bf689a-c1a4-4c34-aacc-414c1614a5aa</TRAN_ID>'+
                                '<CREATE_DATETIME>2019-04-22T16:21:16.564Z</CREATE_DATETIME>'+
                                '<SENT_FROM>CRCC</SENT_FROM>'+
                                '<VERSION>CC V1.9</VERSION>'+
                                '<TRANSACTION_TYPE>STOR LOC LOOKUP</TRANSACTION_TYPE>';

            if(inputData.get('fieldName') == 'Phone') {
                xmlSt += '<PHONE_NUMBER_SEARCH_CRITERIA>'+
                            '<PHONE_NUMBER>'+inputData.get('value')+'</PHONE_NUMBER>'+
                        '</PHONE_NUMBER_SEARCH_CRITERIA>';
            } else {
                xmlSt += '<LOCATION_SEARCH_CRITERIA>'+
                                    '<COMPANY_NAME>'+companyName+'</COMPANY_NAME>'+
                                    '<ADDRESS_LINE1>'+address+'</ADDRESS_LINE1>'+
                                    '<CITY>'+city+'</CITY>'+
                                    '<STATE>'+state+'</STATE>'+
                                    '<COUNTRY>'+country+'</COUNTRY>'+
                                    '<ZIP>'+zip+'</ZIP>'+
                                '</LOCATION_SEARCH_CRITERIA>';
            }
            xmlSt += '</IAAI_STORAGE_LOCATION_LOOKUP>';
            
            System.debug('xmlSt-->'+xmlSt);

            String soapResponse;
            RPM_StorageLocationController.BasicHttpBinding_IStorageLocation obj = new RPM_StorageLocationController.BasicHttpBinding_IStorageLocation();
            Blob headerValue = Blob.valueOf(CRC_Constants.RPM_CREDENTIALS.DeveloperName + ':' + CRC_Constants.RPM_CREDENTIALS.Password__c);
            String authorizationHeader = 'BASIC '+ EncodingUtil.base64Encode(headerValue);
            Map<String,String> inputHeaderMap = new  Map<String,String>();
            inputHeaderMap.put('Authorization', authorizationHeader);
            obj.inputHttpHeaders_x = inputHeaderMap;
            //obj.endpoint_x  = imdt.Endpoint__c;
            obj.timeout_x = Integer.valueOf(CRC_Constants.RPM_CREDENTIALS.Callout_Time_Limit__c);
            soapResponse = obj.IAAI_STORAGE_LOCATION_LOOKUP(xmlSt, CRC_Constants.RPM_CREDENTIALS.DeveloperName);
            System.debug(soapResponse);
            response.put('response', soapResponse);
            return response;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, Object> getStorageLocationDetail(String locationId, Boolean isTemp){
        try {
            Map<String, Object> response = new Map<String, Object>();
            RPM_StorageLocationController.BasicHttpBinding_IStorageLocation obj = new RPM_StorageLocationController.BasicHttpBinding_IStorageLocation();
            Blob headerValue = Blob.valueOf(CRC_Constants.RPM_CREDENTIALS.DeveloperName + ':' + CRC_Constants.RPM_CREDENTIALS.Password__c);
            String authorizationHeader = 'BASIC '+ EncodingUtil.base64Encode(headerValue);
            Map<String,String> inputHeaderMap = new  Map<String,String>();
            inputHeaderMap.put('Authorization', authorizationHeader);
            obj.inputHttpHeaders_x = inputHeaderMap;
            //obj.endpoint_x  = imdt.Endpoint__c;
            obj.timeout_x = Integer.valueOf(CRC_Constants.RPM_CREDENTIALS.Callout_Time_Limit__c);
            String soapResponse = obj.IAAI_STOR_LOC_DETAIL(CRC_RPM_RequestHelper.getStorageLocationDetail(locationId, false), CRC_Constants.RPM_CREDENTIALS.DeveloperName);
            System.debug(soapResponse);
            response.put('response', soapResponse);
            return response;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, Object> addStorageLocation(Map<String, Object> request){
        try {
            System.debug(JSON.serialize(request));
            Map<String, Object> response = new Map<String, Object>();
            RPM_StorageLocationController.BasicHttpBinding_IStorageLocation obj = new RPM_StorageLocationController.BasicHttpBinding_IStorageLocation();
            Blob headerValue = Blob.valueOf(CRC_Constants.RPM_CREDENTIALS.DeveloperName + ':' + CRC_Constants.RPM_CREDENTIALS.Password__c);
            String authorizationHeader = 'BASIC '+ EncodingUtil.base64Encode(headerValue);
            Map<String,String> inputHeaderMap = new  Map<String,String>();
            inputHeaderMap.put('Authorization', authorizationHeader);
            obj.inputHttpHeaders_x = inputHeaderMap;
            obj.timeout_x = Integer.valueOf(CRC_Constants.RPM_CREDENTIALS.Callout_Time_Limit__c);
            String soapResponse = obj.IAAI_STORAGE_LOCATION_MAINTENANCE(CRC_RPM_RequestHelper.createStorageLocationRequest(request), CRC_Constants.RPM_CREDENTIALS.DeveloperName);
            System.debug('ADD_STORAGE_LOCATION-->'+soapResponse);
            Map<String, String> createStorageResponse = CRC_RPM_RequestHelper.parseRPMResponse(soapResponse);

            if(createStorageResponse.get(CRC_Constants.RPM_STATUS_CODE) == CRC_Constants.RPM_ACCEPT_STATUS_CODE) {
                String soapResponse1 = obj.IAAI_STOR_LOC_DETAIL(CRC_RPM_RequestHelper.getStorageLocationDetail(createStorageResponse.get('VEHICLE_LOCATION.TEMP_STORAGE_LOCATION_ID'), true), CRC_Constants.RPM_CREDENTIALS.DeveloperName);
                System.debug('Detail--Storage-LOCATION-->'+soapResponse1);
                Map<String, String> storageDetailResponse = CRC_RPM_RequestHelper.parseRPMResponse(soapResponse1);
            
                if(storageDetailResponse.get(CRC_Constants.RPM_STATUS_CODE) == CRC_Constants.RPM_ACCEPT_STATUS_CODE) {
                    RPM_ReleaseAssignmentController.BasicHttpBinding_IAssignment assignmentUpdateRequest = new RPM_ReleaseAssignmentController.BasicHttpBinding_IAssignment();
                    Blob headerValue1 = Blob.valueOf(CRC_Constants.RPM_CREDENTIALS.DeveloperName + ':' + CRC_Constants.RPM_CREDENTIALS.Password__c);
                    String authorizationHeader1 = 'BASIC '+ EncodingUtil.base64Encode(headerValue);
                    Map<String,String> inputHeaderMap1 = new  Map<String,String>();
                    inputHeaderMap1.put('Authorization', authorizationHeader);
                    assignmentUpdateRequest.inputHttpHeaders_x = inputHeaderMap;
                    assignmentUpdateRequest.timeout_x = Integer.valueOf(CRC_Constants.RPM_CREDENTIALS.Callout_Time_Limit__c);
                    request.put('STORAGE_LOCATION_ID', storageDetailResponse.get('VEHICLE_LOCATION.STORAGE_LOCATION_ID'));
                    String soapResponse2 = assignmentUpdateRequest.IAAI_ASSIGNMENT_INFO(CRC_RPM_RequestHelper.changeStorageLocationOnAssignment(request), CRC_Constants.RPM_CREDENTIALS.DeveloperName);
                    System.debug('assignmentUpdateResponse-->'+soapResponse2);
                    Map<String, String> updateAssignmentResponse = CRC_RPM_RequestHelper.parseRPMResponse(soapResponse2);
            
                    if(updateAssignmentResponse.get(CRC_Constants.RPM_STATUS_CODE) == CRC_Constants.RPM_ACCEPT_STATUS_CODE) {
                        
                    } else {
                        throw new CRC_Exception(updateAssignmentResponse.get('REJECT_REASON_DESCRIPTION'));    
                    }
                } else {
                    throw new CRC_Exception(storageDetailResponse.get('REJECT_REASON_DESCRIPTION'));
                }
            } else {
                throw new CRC_Exception(createStorageResponse.get('REJECT_REASON_DESCRIPTION'));
            }

            response.put('response', soapResponse);
            return response;
        } catch (Exception e) {
            System.debug(e.getMessage()+'-->'+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, Object> processStorageLocation(Map<String, Object> request){
        try {
            Map<String, Object> response = new Map<String, Object>();
            RPM_StorageLocationController.BasicHttpBinding_IStorageLocation obj = new RPM_StorageLocationController.BasicHttpBinding_IStorageLocation();
            CRC_RPM_Credential__mdt imdt =  [SELECT DeveloperName, Call_Center_ID__c, Callout_Time_Limit__c,Endpoint__c, Password__c FROM CRC_RPM_Credential__mdt LIMIT 1];
            //IAAI_VPE_Listing_Partner__mdt imdt =  [SELECT DeveloperName,Endpoint__c,Id,Password__c,UserName__c FROM IAAI_VPE_Listing_Partner__mdt where DeveloperName = 'RPM'];
            Blob headerValue = Blob.valueOf(CRC_Constants.RPM_CREDENTIALS.DeveloperName + ':' + imdt.Password__c);
            String authorizationHeader = 'BASIC '+ EncodingUtil.base64Encode(headerValue);
            Map<String,String> inputHeaderMap = new  Map<String,String>();
            inputHeaderMap.put('Authorization', authorizationHeader);
            obj.inputHttpHeaders_x = inputHeaderMap;
            //obj.endpoint_x  = imdt.Endpoint__c;
            obj.timeout_x = Integer.valueOf(imdt.Callout_Time_Limit__c);
            String soapResponse = obj.IAAI_STORAGE_LOCATION_MAINTENANCE(CRC_RPM_RequestHelper.updateStorageLocationRequest(request), CRC_Constants.RPM_CREDENTIALS.DeveloperName);
            System.debug(soapResponse);
            response.put('response', soapResponse);
            return response;
        } catch (Exception e) {
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, Object> saveReleaseProblem(Map<String, Object> request,Boolean isUpdate){
        try {
            Map<String, Object> response = new Map<String, Object>();
            RPM_ReleaseAssignmentController.BasicHttpBinding_IAssignment obj = new RPM_ReleaseAssignmentController.BasicHttpBinding_IAssignment();
            Blob headerValue = Blob.valueOf(CRC_Constants.RPM_CREDENTIALS.DeveloperName + ':' + CRC_Constants.RPM_CREDENTIALS.Password__c);
            String authorizationHeader = 'BASIC '+ EncodingUtil.base64Encode(headerValue);
            Map<String,String> inputHeaderMap = new  Map<String,String>();
            inputHeaderMap.put('Authorization', authorizationHeader);
            obj.inputHttpHeaders_x = inputHeaderMap;
            obj.timeout_x = Integer.valueOf(CRC_Constants.RPM_CREDENTIALS.Callout_Time_Limit__c);
            String soapResponse = obj.IAAI_ASSIGNMENT_INFO(CRC_RPM_RequestHelper.saveReleaseProblemRequest(request, isUpdate), CRC_Constants.RPM_CREDENTIALS.DeveloperName);
            System.debug(soapResponse);
            response.put('response', soapResponse);
            RPM_APIController.createLog('Saleforce', 'RPM', 'Create Release Problem',  'request', soapResponse, 'http://uat.eai.iaai.com/IAAI.Services/Assignment.svc', 'Success');
           
            return response;

        } catch (Exception e) {
            System.debug(e.getMessage()+'---'+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, Object> saveVehicleInformation(Map<String, Object> request) {
        try {
            Map<String, Object> response = new Map<String, Object>();
            RPM_ReleaseAssignmentController.BasicHttpBinding_IAssignment obj = new RPM_ReleaseAssignmentController.BasicHttpBinding_IAssignment();
            Blob headerValue = Blob.valueOf(CRC_Constants.RPM_CREDENTIALS.DeveloperName + ':' + CRC_Constants.RPM_CREDENTIALS.Password__c);
            String authorizationHeader = 'BASIC '+ EncodingUtil.base64Encode(headerValue);
            Map<String,String> inputHeaderMap = new  Map<String,String>();
            inputHeaderMap.put('Authorization', authorizationHeader);
            obj.inputHttpHeaders_x = inputHeaderMap;
            obj.timeout_x = Integer.valueOf(CRC_Constants.RPM_CREDENTIALS.Callout_Time_Limit__c);
            String soapResponse = obj.IAAI_ASSIGNMENT_INFO(CRC_RPM_RequestHelper.vehicleOwnerUpdateRequest(request), CRC_Constants.RPM_CREDENTIALS.DeveloperName);
            System.debug(soapResponse);
            response.put('response', soapResponse);
            RPM_APIController.createLog('Saleforce', 'RPM', 'Create Release Problem',  'request', soapResponse, 'http://uat.eai.iaai.com/IAAI.Services/Assignment.svc', 'Success');
           
            return response;

        } catch (Exception e) {
            System.debug(e.getMessage()+'---'+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, Object> changeStorageLocationOnAssignment(Map<String, Object> request) {
        try {
            Map<String, Object> response = new Map<String, Object>();
            RPM_ReleaseAssignmentController.BasicHttpBinding_IAssignment obj = new RPM_ReleaseAssignmentController.BasicHttpBinding_IAssignment();
            Blob headerValue = Blob.valueOf(CRC_Constants.RPM_CREDENTIALS.DeveloperName + ':' + CRC_Constants.RPM_CREDENTIALS.Password__c);
            String authorizationHeader = 'BASIC '+ EncodingUtil.base64Encode(headerValue);
            Map<String,String> inputHeaderMap = new  Map<String,String>();
            inputHeaderMap.put('Authorization', authorizationHeader);
            obj.inputHttpHeaders_x = inputHeaderMap;
            obj.timeout_x = Integer.valueOf(CRC_Constants.RPM_CREDENTIALS.Callout_Time_Limit__c);
            String soapResponse = obj.IAAI_ASSIGNMENT_INFO(CRC_RPM_RequestHelper.changeStorageLocationOnAssignment(request), CRC_Constants.RPM_CREDENTIALS.DeveloperName);
            System.debug(soapResponse);
            response.put('response', soapResponse);
            RPM_APIController.createLog('Saleforce', 'RPM', 'changeStorageLocationOnAssignment',  'request', soapResponse, 'http://uat.eai.iaai.com/IAAI.Services/Assignment.svc', 'Success');
           
            return response;

        } catch (Exception e) {
            System.debug(e.getMessage()+'---'+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, Object> manageReleaseCharges(Map<String, Object> request){
        try {
            Map<String, Object> response = new Map<String, Object>();
            RPM_ReleaseAssignmentController.BasicHttpBinding_IAssignment obj = new RPM_ReleaseAssignmentController.BasicHttpBinding_IAssignment();
            Blob headerValue = Blob.valueOf(CRC_Constants.RPM_CREDENTIALS.DeveloperName + ':' + CRC_Constants.RPM_CREDENTIALS.Password__c);
            String authorizationHeader = 'BASIC '+ EncodingUtil.base64Encode(headerValue);
            Map<String,String> inputHeaderMap = new  Map<String,String>();
            inputHeaderMap.put('Authorization', authorizationHeader);
            obj.inputHttpHeaders_x = inputHeaderMap;
            obj.timeout_x = Integer.valueOf(CRC_Constants.RPM_CREDENTIALS.Callout_Time_Limit__c);
            String soapResponse = obj.IAAI_ASSIGNMENT_INFO(CRC_RPM_RequestHelper.manageReleaseCharges(request), CRC_Constants.RPM_CREDENTIALS.DeveloperName);
            System.debug(soapResponse);
            response.put('response', soapResponse);
            CRC_RPM_RequestHelper.parseRPMResponse(soapResponse);
            RPM_APIController.createLog('Saleforce', 'RPM', 'manageReleaseProblem',  'request', soapResponse, 'http://uat.eai.iaai.com/IAAI.Services/Assignment.svc', 'Success');
           
            return response;

        } catch (Exception e) {
            System.debug(e.getMessage()+'---'+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, Object> saveStorageCharges(Map<String, Object> request){
        try {
            Map<String, Object> response = new Map<String, Object>();
            RPM_ReleaseAssignmentController.BasicHttpBinding_IAssignment obj = new RPM_ReleaseAssignmentController.BasicHttpBinding_IAssignment();
            Blob headerValue = Blob.valueOf(CRC_Constants.RPM_CREDENTIALS.DeveloperName + ':' + CRC_Constants.RPM_CREDENTIALS.Password__c);
            String authorizationHeader = 'BASIC '+ EncodingUtil.base64Encode(headerValue);
            Map<String,String> inputHeaderMap = new  Map<String,String>();
            inputHeaderMap.put('Authorization', authorizationHeader);
            obj.inputHttpHeaders_x = inputHeaderMap;
            obj.timeout_x = Integer.valueOf(CRC_Constants.RPM_CREDENTIALS.Callout_Time_Limit__c);
            String soapResponse = obj.IAAI_ASSIGNMENT_INFO(CRC_RPM_RequestHelper.saveStorageChargesFlatOrDaily(request), CRC_Constants.RPM_CREDENTIALS.DeveloperName);
            System.debug(soapResponse);
            response.put('response', soapResponse);
            Map<String, Object> jsonResponse = CRC_RPM_RequestHelper.parseRPMResponse(soapResponse);
            if(String.valueOf(jsonResponse.get('STATUS_CODE')) == 'ACCEPT') {
                System.debug('Inside Success');
                RPM_APIController.refreshFromRPM(String.valueOf(request.get('CASE_ID')));
            }
            RPM_APIController.createLog('Saleforce', 'RPM', 'manageReleaseProblem',  'request', soapResponse, 'http://uat.eai.iaai.com/IAAI.Services/Assignment.svc', 'Success');
           
            return response;

        } catch (Exception e) {
            System.debug(e.getMessage()+'---'+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getReleaseProblemCodePicklistValues() {
        try {
            return new Map<String, Object>{'values' => JSON.serialize(Schema.SObjectType.Task.fields.getMap().get('Release_Problem_Code__c').getDescribe().getPicklistValues())};
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}