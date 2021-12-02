global class DuplicateContact implements Database.batchable<sobject>, Database.Stateful{ 
   
    global Database.QueryLocator  start(Database.BatchableContext bc) {
        String query = system.Label.DupConEbiz;
        system.debug(' query '+query);
        return Database.getQueryLocator(query); 
    }
    global void execute(Database.BatchableContext bc, List<Contact> lstCon){  
        system.debug('lstCon'+lstCon.size()); 
        for(Contact orginalContact: lstCon){
            findDuplContactEbiz(orginalContact);                
        } 
    }
    global void finish(Database.BatchableContext bc){}
    
    private void findDuplContactEbiz(Contact orgCont){
        contact objContact = orgCont;
        List<String> strFields = new List<String>();
        strFields = (system.Label.mergeFieldsDupContEbiz).split(',');
        List<Contact> lstDuplicateContact = new List<Contact>();
        String prefixBUYBuyerEmployeeId = 'BUY-'+ objContact.Buyer_Employee_ID__c;
        String prefixSBuyBuyerEmployeeId = 'Buy-'+ objContact.Buyer_Employee_ID__c;
        lstDuplicateContact = [SELECT LastName, FirstName,AccountId, Phone, MobilePhone, HomePhone, OtherPhone, Email, 
                               		  MailingStreet, MailingState,Buyer_Employee_ID__c, 
                                      MailingPostalCode, MailingCity, MailingCountry, OtherStreet, OtherState, OtherCity, 
                               		  OtherPostalCode, OtherCountry, AC_Created_Date__c, AC_Created_User__c, AC_Login__c, 
                               		  AC_Modified_Date__c, AC_Modified_User__c, AC_User_ID__c,Buyer_Type__c 
                               FROM Contact                               
                               WHERE (Id !=: objContact.id AND (Buyer_Employee_ID__c <> NULL 
                                         AND Buyer_Employee_ID__c <> '' 
                                         AND (Buyer_Employee_ID__c =: objContact.Buyer_Employee_ID__c 
                                              OR Buyer_Employee_ID__c =:prefixBUYBuyerEmployeeId 
                                              OR Buyer_Employee_ID__c =:prefixSBuyBuyerEmployeeId)))                                      
                               Order by createdDate ASC];
        list<list<Id>> lstDupContactIds = new list<list<Id>>();
        list<Id> dualList = new list<Id>();     
        system.debug('lstDuplicateContact  size '+lstDuplicateContact .size());
        for(Contact objCont :lstDuplicateContact ){    
            system.debug(objCont);
            for(string str: strFields){
                str = str.trim();
                system.debug('strFields Name: '+str);        
                system.debug('Con 1'+objCont);
                if(objCont.get(str) != null && objCont.get(str) != ''){
                    system.debug('Con 2'+objCont);
                    objContact.put(str, objCont.get(str)); 
                    system.debug('objContact 2 '+objContact);
                }
            }
        }
        system.debug('lstDupContactIds size '+lstDupContactIds.size());
        for(Contact dupCon:lstDuplicateContact  ){ 
            system.debug('objContact B4' +objContact);
            if(objContact.Id != dupCon.Id && (objContact.AccountId == dupCon.AccountId || dupCon.AccountId == null)){
                Database.Merge(objContact,dupCon);
            }
            system.debug('objContact After' +objContact);
        }
       /* update objContact;
        delete lstDuplicateContact;*/
    }
 }