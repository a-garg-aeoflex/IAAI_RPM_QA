@isTest
public class IAAI_LCU_RestResource_Test {
@isTest
    static void testRestResource(){
        Account testAccount = new Account(Name='Test Account 1');
        insert testAccount;
        
        Stock__c st = new Stock__c();
        st.Name = 'Test Stock';
        st.Stock__c = '29645700';
        st.Buyer_Name__c = testAccount.Id;
        st.VIN__c = 'ABCD11223344';
        insert st;
        
            
        VPE_Listings__c vp = new VPE_Listings__c();
        vp.VIN__c = 'ABCD11223344';
        vp.Listing_Id__c = '9876543';
        vp.Stock_Lookup__c = st.id;
        Insert vp;
        
        String xmlString = getXmlString();
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = 'services/apexrest/iaai/';
        req.httpMethod = 'POST';
        req.requestBody = blob.valueOf(xmlString);
        RestContext.request = req;
        RestContext.response= res;
        //RestContext.response.responseBody = blob.valueOf(xmlString);
        String response = IAAI_LCU_RestResource.doPost();
        
    }
    
    public static String getXmlString(){
        String xmlStr = '<?xml version="1.0" encoding="utf-8"?>'+
            '<IAAI_LCU xmlns="http://salvage.iaa.com/lifecycleupdate/request/">'+
            '<TRAN_ID>b05c753b-559e-4648-b3c1-45bcd0a2f731</TRAN_ID>'+
            '<CREATE_DATETIME>2021-02-09T23:08:31.097</CREATE_DATETIME>'+
            '<SENT_FROM>IAAI</SENT_FROM>'+
            '<VERSION>IAA-V-2.2</VERSION>'+
            '<IAAI_STOCK_NUMBER>29645700</IAAI_STOCK_NUMBER>'+
            '<PROVIDER>'+
            '<PROVIDER_NAME>Pulsar Motors</PROVIDER_NAME>'+
            '<PROVIDER_OFFICE_IDENTIFIER>217895</PROVIDER_OFFICE_IDENTIFIER>'+
            '<PROVIDER_OFFICE>'+
            '<CONTACT>'+
            '<ADDRESS_LINE1>Two Westbrook Corporate Center</ADDRESS_LINE1>'+
            '<ADDRESS_LINE2>Suite #500</ADDRESS_LINE2>'+
            '<CITY>Westchester</CITY>'+
            '<STATE>IL</STATE>'+
            '<ZIP>60154</ZIP>'+
            '<COUNTRY_CODE>US</COUNTRY_CODE>'+
            '<PHONE_NUMBER1>7084925873</PHONE_NUMBER1>'+
            '</CONTACT>'+
            '</PROVIDER_OFFICE>'+
            '<CLAIM_NUMBER>CARVIO</CLAIM_NUMBER>'+
            '<CLAIM_SUFFIX_NUMBER>0000</CLAIM_SUFFIX_NUMBER>'+
            '<LOSS_DATETIME>2020-10-19T00:00:00.000</LOSS_DATETIME>'+
            '<TYPE_OF_LOSS_CODE>OTH</TYPE_OF_LOSS_CODE>'+
            '<BID_APPROVAL_REQ>N</BID_APPROVAL_REQ>'+
            '<CLAIM_REP>'+
            '<CONTACT>'+
            '<FIRST_NAME>EDI</FIRST_NAME>'+
            '<LAST_NAME>EDI</LAST_NAME>'+
            '<ADDRESS_LINE1>PO Box 98179</ADDRESS_LINE1>'+
            '<ADDRESS_LINE2>Attn: Mike Livingston</ADDRESS_LINE2>'+
            '<CITY>Jackson</CITY>'+
            '<STATE>MS</STATE>'+
            '<ZIP>39298</ZIP>'+
            '<PHONE_NUMBER2>2105316595</PHONE_NUMBER2>'+
            '</CONTACT>'+
            '</CLAIM_REP>'+
            '<INSURED>'+
            '<CONTACT>'+
            '<FIRST_NAME>TARISHA</FIRST_NAME>'+
            '<LAST_NAME>DAVIS</LAST_NAME>'+
            '</CONTACT>'+
            '</INSURED>'+
            '<OWNER>'+
            '<CONTACT>'+
            '<FIRST_NAME>TARISHA</FIRST_NAME>'+
            '<LAST_NAME>DAVIS</LAST_NAME>'+
            '<PHONE_NUMBER1>4242301243</PHONE_NUMBER1>'+
            '</CONTACT>'+
            '</OWNER>'+
            '<VEHICLE_LOCATION>'+
            '<PICKUP_LOCATION_TYPE>BUSINESS</PICKUP_LOCATION_TYPE>'+
            '<CONTACT>'+
            '<COMPANY_NAME>TARISHA DAVIS</COMPANY_NAME>'+
            '<ADDRESS_LINE1>370 BOND ST</ADDRESS_LINE1>'+
            '<CITY>ELK GROOVE</CITY>'+
            '<STATE>IL</STATE>'+
            '<ZIP>60007</ZIP>'+
            '<COUNTRY_CODE>US</COUNTRY_CODE>'+
            '<PHONE_NUMBER1>6305579338</PHONE_NUMBER1>'+
            '</CONTACT>'+
            '</VEHICLE_LOCATION>'+
            '</PROVIDER>'+
            '<SALVOR>'+
            '<BRANCH_CODE>514</BRANCH_CODE>'+
            '<BRANCH_NAME>Chicago-North</BRANCH_NAME>'+
            '<IAA_FEIN_ID>807787888</IAA_FEIN_ID>'+
            '<TITLE_WORK_ONLY_ASSIGNMENT>N</TITLE_WORK_ONLY_ASSIGNMENT>'+
            '<VIC_ASSIGNMENT>N</VIC_ASSIGNMENT>'+
            '<BRANCH>'+
            '<CONTACT>'+
            '<COMPANY_NAME>Chicago-North</COMPANY_NAME>'+
            '<FIRST_NAME>BRANCH</FIRST_NAME>'+
            '<LAST_NAME>MANAGER</LAST_NAME>'+
            '<ADDRESS_LINE1>605 Healy Road</ADDRESS_LINE1>'+
            '<CITY>East Dundee</CITY>'+
            '<STATE>IL</STATE>'+
            '<ZIP>60118</ZIP>'+
            '<COUNTRY_CODE>US</COUNTRY_CODE>'+
            '<PHONE_NUMBER1>8474263786</PHONE_NUMBER1>'+
            '<FAX_NUMBER>8474268595</FAX_NUMBER>'+
            '<EMAIL>QAMailbox@iaai.com</EMAIL>'+
            '</CONTACT>'+
            '</BRANCH>'+
            '</SALVOR>'+
            '<VEHICLE>'+
            '<VEHICLE_TYPE>AUTOMOBILE</VEHICLE_TYPE>'+
            '<VIN>1B3EL36XX4N222915</VIN>'+
            '<YEAR>2004</YEAR>'+
            '<MAKE>DODGE</MAKE>'+
            '<MODEL>STRATUS</MODEL>'+
            '<SERIES>SE</SERIES>'+
            '<BODY_STYLE>SEDAN 4 DOOR</BODY_STYLE>'+
            '<ENGINE>2.4L I4 FI DOHC 16V F4</ENGINE>'+
            '<KEYS_INDICATOR>Y</KEYS_INDICATOR>'+
            '<KEY_FOB>N/A</KEY_FOB>'+
            '<PRIMARY_DAMAGE_CODE>UK</PRIMARY_DAMAGE_CODE>'+
            '<PRIMARY_DAMAGE>Unknown</PRIMARY_DAMAGE>'+
            '</VEHICLE>'+
            '<PROC_STATUS>'+
            
            '<ORIGINAL_ADVANCE_CHG_MAX_AUTHORIZED_AMOUNT>2020</ORIGINAL_ADVANCE_CHG_MAX_AUTHORIZED_AMOUNT>'+
            '<UPDATED_ADVANCE_CHG_MAX_AUTHORIZED_AMOUNT>2020</UPDATED_ADVANCE_CHG_MAX_AUTHORIZED_AMOUNT>'+
            '<UPDATED_ADVANCE_CHG_MAX_AUTHORIZED_BY>Testing</UPDATED_ADVANCE_CHG_MAX_AUTHORIZED_BY>'+
            '<UPDATED_ADVANCE_CHG_MAX_AUTHORIZED_DATETIME>2020-10-19T09:49:09.383</UPDATED_ADVANCE_CHG_MAX_AUTHORIZED_DATETIME>'+
            '<PICKUP_DATETIME>2020-10-19T09:49:09.383</PICKUP_DATETIME>'+
            '<CHECKIN_DATETIME>2020-10-19T09:49:09.383</CHECKIN_DATETIME>'+
            '<TITLE_REC_FROM_SALVAGE_PROVIDER_DATETIME>2020-10-19T09:49:09.383</TITLE_REC_FROM_SALVAGE_PROVIDER_DATETIME>'+
            '<ORIGINAL_TITLE_STATE>test string</ORIGINAL_TITLE_STATE>'+
            '<TITLE_SENT_TO_DMV_DATETIME>2020-10-19T09:49:09.383</TITLE_SENT_TO_DMV_DATETIME>'+
            '<TITLE_REC_FROM_DMV_DATETIME>2020-10-19T09:49:09.383</TITLE_REC_FROM_DMV_DATETIME>'+
            
            
            '<VEHICLE_IMAGES_AVAILABLE_DATETIME>2020-10-19T09:49:09.383</VEHICLE_IMAGES_AVAILABLE_DATETIME>'+
            '<TOWER_IMAGES_AVAILABLE_DATETIME>2020-10-19T09:49:09.383</TOWER_IMAGES_AVAILABLE_DATETIME>'+
            
            
            '<ASSIGNMENT_DATETIME>2020-10-19T09:49:09.383</ASSIGNMENT_DATETIME>'+
            '<SP_PREPAID_TOTAL_AMT>2020</SP_PREPAID_TOTAL_AMT>'+
            '<VEHICLE_INSPECTION_SERVICE>Y</VEHICLE_INSPECTION_SERVICE>'+
            '<IAA_REQUESTED_TO_PAY_ADVANCE_CHARGES>Y</IAA_REQUESTED_TO_PAY_ADVANCE_CHARGES>'+
            '<BRANCH_DEFAULT_ADVANCE_CHG_MAX_AUTHORIZED_AMOUNT>0.00</BRANCH_DEFAULT_ADVANCE_CHG_MAX_AUTHORIZED_AMOUNT>'+
            '<RELEASE_PROBLEMS>'+
            '<RELEASE_PROBLEM>'+
            '<RELEASE_PROBLEM_CODE>TAA</RELEASE_PROBLEM_CODE>'+
            '<RELEASE_PROBLEM_DESCRIPTION>Total Advance Charges Need Approval</RELEASE_PROBLEM_DESCRIPTION>'+
            '<RELEASE_PROBLEM_OPEN_DATETIME>2021-02-09T22:59:35.983</RELEASE_PROBLEM_OPEN_DATETIME>'+
            '<RELEASE_PROBLEM_RESOLVED_DATETIME>2021-02-09T23:01:54.133</RELEASE_PROBLEM_RESOLVED_DATETIME>'+
            '</RELEASE_PROBLEM>'+
            '</RELEASE_PROBLEMS>'+
            '<QUOTED_RELEASE_DATE>2020-10-19T09:49:18.013</QUOTED_RELEASE_DATE>'+
            '<ACTUAL_RELEASE_DATETIME>2021-02-09T23:04:00.543</ACTUAL_RELEASE_DATETIME>'+
            '<DISPATCH_DATETIME>2021-02-09T23:07:35.497</DISPATCH_DATETIME>'+
            '<STORAGE_START_DATE>2020-10-19T00:00:00.000</STORAGE_START_DATE>'+
            '<STORAGE_STOP_DATE>2021-02-11T00:00:00.000</STORAGE_STOP_DATE>'+
            '<NUMBER_OF_DAYS_OF_STORAGE>116</NUMBER_OF_DAYS_OF_STORAGE>'+
            '<VEHICLE_ENHANCED>N</VEHICLE_ENHANCED>'+
            '<VEHICLE_ON_HOLD>N</VEHICLE_ON_HOLD>'+
            '<VEHICLE_COMMENTS>'+
            '  <VEHICLE_COMMENT>'+
            '<COMMENT_DATETIME>2021-02-09T23:06:20.990</COMMENT_DATETIME>'+
            '<COMMENT_AUTHOR>Usha Mandapati</COMMENT_AUTHOR>'+
            '<COMMENT_TEXT>Tow Zone Mileage confirmed 14 mile(s)</COMMENT_TEXT>'+
            '<COMMENT_ID>754247165</COMMENT_ID>'+
            '<COMMENT_CATEGORY>RLS</COMMENT_CATEGORY>'+
            '</VEHICLE_COMMENT>'+
            '<VEHICLE_COMMENT>'+
            '<COMMENT_DATETIME>2021-02-09T23:06:20.990</COMMENT_DATETIME>'+
            '<COMMENT_AUTHOR>Usha Mandapati</COMMENT_AUTHOR>'+
            '<COMMENT_TEXT>Tow Zone Mileage confirmed 14 mile(s)</COMMENT_TEXT>'+
            '<COMMENT_ID>754247165</COMMENT_ID>'+
            '<COMMENT_CATEGORY>RLS</COMMENT_CATEGORY>'+
            '</VEHICLE_COMMENT>'+
            '</VEHICLE_COMMENTS>'+
            '<PROCESS_STATUS_DESC>Pickup En Route</PROCESS_STATUS_DESC>'+
            '<LCU_TRIGGERING_EVENTS>'+
            '<LCU_TRIGGERING_EVENT>'+
            '<LCU_TRIGGERING_EVENT_IAA_NUMBER>1888461310</LCU_TRIGGERING_EVENT_IAA_NUMBER>'+
            '<LCU_TRIGGERING_EVENT_IAA_CODE>RLPD</LCU_TRIGGERING_EVENT_IAA_CODE>'+
            '<LCU_TRIGGERING_EVENT_DESCRIPTION>Actual Release Date</LCU_TRIGGERING_EVENT_DESCRIPTION>'+
            '<LCU_TRIGGERING_EVENT_CREATEDATETIME>2021-02-09T23:04:00.543</LCU_TRIGGERING_EVENT_CREATEDATETIME>'+
            '</LCU_TRIGGERING_EVENT>'+
            '<LCU_TRIGGERING_EVENT>'+
            '<LCU_TRIGGERING_EVENT_IAA_NUMBER>1888461312</LCU_TRIGGERING_EVENT_IAA_NUMBER>'+
            '<LCU_TRIGGERING_EVENT_IAA_CODE>DPDP</LCU_TRIGGERING_EVENT_IAA_CODE>'+
            '<LCU_TRIGGERING_EVENT_DESCRIPTION>Dispatch Tower</LCU_TRIGGERING_EVENT_DESCRIPTION>'+
            '<LCU_TRIGGERING_EVENT_CREATEDATETIME>2021-02-09T23:07:35.500</LCU_TRIGGERING_EVENT_CREATEDATETIME>'+
            '</LCU_TRIGGERING_EVENT>'+
            '</LCU_TRIGGERING_EVENTS>'+
            '</PROC_STATUS>'+
            '<SALE>'+
            '<IBuy_FAST_STATUS>NO</IBuy_FAST_STATUS>'+
            '</SALE>'+
            '</IAAI_LCU>';

        return xmlStr;
        
        
    }
    
}