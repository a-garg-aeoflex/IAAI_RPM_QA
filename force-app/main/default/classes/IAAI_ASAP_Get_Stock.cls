public class IAAI_ASAP_Get_Stock {

    public String CARVIO = 'CARVIO';
    Public String CrNotes;
    public  Stock__c basicAuthCallout(VPE_Listings__c v){
        system.debug('-----ASAP2---'+v);
        String PickUpPhoneNumber;
        string  ProviderPhoneNumber;
        if((v.Pickup_Phone_Number__c <> null && (v.Pickup_Phone_Number__c).length() >= 10 ) ||((v.Provider_Phone_Number__c <> null) && v.Provider_Phone_Number__c.length() >= 10)){
            if((v.Pickup_Phone_Number__c).length() >= 10){
                system.debug('v.Pickup_Phone_Number__c '+v.Pickup_Phone_Number__c);
                PickUpPhoneNumber = (v.Pickup_Phone_Number__c).reverse();
                system.debug('PickUpPhoneNumber '+PickUpPhoneNumber);
                PickUpPhoneNumber = PickUpPhoneNumber.substring(0, 10);
                PickUpPhoneNumber = PickUpPhoneNumber.reverse();
                system.debug('PickUpPhoneNumber 1 '+PickUpPhoneNumber);
                v.Pickup_Phone_Number__c = PickUpPhoneNumber;
            } 
            if((v.Provider_Phone_Number__c).length() >= 10){
                 system.debug('v.Provider_Phone_Number__c '+v.Provider_Phone_Number__c);
                ProviderPhoneNumber = (v.Provider_Phone_Number__c).reverse();
                system.debug('ProviderPhoneNumber '+ProviderPhoneNumber);
                ProviderPhoneNumber = ProviderPhoneNumber.substring(0, 10);
                ProviderPhoneNumber = ProviderPhoneNumber.reverse();
                system.debug('ProviderPhoneNumber 1 '+ProviderPhoneNumber);
                v.Provider_Phone_Number__c = ProviderPhoneNumber;
            }
            
        }      
    String Note =    'PLEASE SCHEDULE PICK UP WITH OWNER AND ADVISE YOU ARE CALLING ON BEHALF OF CARVIO, HAVE DRIVER CALL AHEAD.  NO CHECK/TITLE EXCHANGE = NO PICK UP.\n'
                     +'TOW DRIVER MUST HAVE CHECK IN THE AMOUNT OF '+ v.Original_Bid_Offer_Amount__c +  ' MUST BE EXCHANGED FOR TITLE AT THE TIME OF PICK UP*** \n'+
                     'ASK FOR KEYS.   \n'+      
					 'PLEASE REACH OUT TO VEHICLE PURCHASINGE PROGRAM TEAM WITH ANY QUESTIONS VIA EMAIL AT VehiclePurchasingProgram@IAAI.com \n'+
                     '***DO NOT CHANGE LOCATION FROM A STORAGE LOCATION TO A RESIDENTIAL LOCATION** THIS REMOVES THE PAYMENT INFORMATION FROM THE RELEASE SCREEN. \n';

     if(v.VPE_Listing_Partner__c <> null && v.VPE_Listing_Partner__r.Name == CARVIO){
     CrNotes = Note;
     }

        
        String InputXML = '<STAGING>' 
                        +'<ASSIGNMENT_TYPE>STD</ASSIGNMENT_TYPE>'
                        +'<INS_CO_CD>PULS</INS_CO_CD>'
                        +'<INS_CO_OFFICE_CD>PM</INS_CO_OFFICE_CD>'
                        +'<INS_CO_NAME>PULS</INS_CO_NAME>'
                        +'<SENDER>VPES</SENDER>'
                        +'<VIN>'+v.VIN__c+'</VIN>'
                        +'<VEH_LOC_ZIP>'+v.Pickup_Zip__c+'</VEH_LOC_ZIP>'
                        +'<CLAIMANT_FIRST_NAME>'+v.Provider_First_Name__c+'</CLAIMANT_FIRST_NAME>'
                        +'<CLAIMANT_LAST_NAME>'+v.Provider_Last_Name__c+'</CLAIMANT_LAST_NAME>'
                        +'<VEH_LOC_FIRST_NAME>'+v.Provider_First_Name__c+'</VEH_LOC_FIRST_NAME>'
                        +'<VEH_LOC_LAST_NAME>'+v.Provider_Last_Name__c+'</VEH_LOC_LAST_NAME>'
                        +'<CLAIMANT_PHONE>'+v.Provider_Phone_Number__c+'</CLAIMANT_PHONE>'
                        +'<VEH_LOC_ADDRESS1>'+v.Pickup_street__c+'</VEH_LOC_ADDRESS1>'
                        +'<VEH_LOC_CITY>'+v.Pickup_City__c+'</VEH_LOC_CITY>'
                        +'<VEH_LOC_STATE>'+v.Pickup_State__c+'</VEH_LOC_STATE>'
                        +'<VEH_LOC_PHONE>'+v.Pickup_Phone_Number__c+'</VEH_LOC_PHONE>'
                        +'<VEH_KEYS_INDICATOR>'+v.Has_Keys__c+'</VEH_KEYS_INDICATOR>'
                        +'<VEH_YEAR>'+v.Model_Year__c+'</VEH_YEAR>'
                        +'<VEH_MAKE>'+v.Make__c+'</VEH_MAKE>'
                        +'<VEH_MODEL>'+v.Model__c+'</VEH_MODEL>'
                        +'<CLAIM_NO>'+v.Claim__c+'</CLAIM_NO>'
                        +'<ADVANCE_ADMIN >'+v.Original_Bid_Offer_Amount__c+'</ADVANCE_ADMIN >'
                        +'<ADJUSTER_COMMENTS>'+'NOTE :'+CrNotes+'</ADJUSTER_COMMENTS>'
                       /* +'<ADJUSTER_FIRST_NAME>'+v.Adjuster_First_Name__c+'</ADJUSTER_FIRST_NAME>'
                        +'<ADJUSTER_LAST_NAME>'+v.Adjuster_Last_Name__c+'</ADJUSTER_LAST_NAME>'
                        +'<ADJUSTER_PHONE>'+v.Adjuster_Number__c+'</ADJUSTER_PHONE>'
                        +'<HANDLER_FIRST_NAME>'+v.Handler_First_Name__c+'</HANDLER_FIRST_NAME>'
                        +'<HANDLER_LAST_NAME>'+v.Handler_Last_Name__c+'</HANDLER_LAST_NAME>'
                        +'<HANDLER_PHONE>'+v.Handler_Number__c+'</HANDLER_PHONE>'
                        +'<CLAIM_NO>'+v.Claim__c+'</CLAIM_NO>'
                        +'<TOWER_NOTES>'+v.Tower_Notes__c+'</TOWER_NOTES>'
                        +'<ADJUSTER_COMMENTS>'+'Original Bid Offer Amount : '+v.Original_Bid_Offer_Amount__c+'|| Notes :'+v.Adj_Notes__c+'</ADJUSTER_COMMENTS>'*/
              +'</STAGING>';
        

            this.mDebugUntruncated(InputXML);           
            system.debug('---ASAP STAGING VPE--'+v);
        
            String soapResponse;
        
            soapResponse = new AsapWsdl.BasicHttpBinding_assignment().funProcessAssignment(InputXML);
            
       
            DOM.Document document = new DOM.Document();
            document.load(soapResponse);
        
            system.debug('---ASAP Res--'+soapResponse);
        
            Dom.XMLNode root = document.getRootElement();   
            Stock__c st = new Stock__c();
            //ERROR_FLAG
            //ERROR_DESCRIPTION
            st.ASAP_Error__c  = '';
            if(string.valueOf(root.getChildElement('ERROR_FLAG', null) != null ? root.getChildElement('ERROR_FLAG', null).getText():'0') =='N'){
             st.ASAP_Error__c = 'ASAP update was successful';   
            }else{
            st.ASAP_Error__c = string.valueOf( root.getChildElement('ERROR_DESCRIPTION', null) != null ? root.getChildElement('ERROR_DESCRIPTION', null).getText():'0');  
            }
        
           
            st.Branch_number__c = root.getChildElement('BRANCH_NUMBER', null) != null ? root.getChildElement('BRANCH_NUMBER', null).getText():'0';
            st.Stock__c = root.getChildElement('STOCK_NUMBER', null) !=null ? root.getChildElement('STOCK_NUMBER', null).getText() :'0' ;
            st.Name = root.getChildElement('STOCK_NUMBER', null) !=null ? root.getChildElement('STOCK_NUMBER', null).getText() :'0' ;
 
        return st;
    }
    
      public void mDebugUntruncated(String sMsg) {
                for (Integer i = 0; i < sMsg.length(); i=i+300) {
                    Integer iEffectiveEnd = (i+300 > (sMsg.length()-1) ? sMsg.length()-1 : i+300);
                    System.debug('---->>--'+sMsg.substring(i,iEffectiveEnd));
                }
            }
}