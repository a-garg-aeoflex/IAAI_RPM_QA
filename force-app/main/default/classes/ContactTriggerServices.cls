/**
* @author LevDigital
* @date 2020
*
* @group Contact
* @group-content ../../ApexDocContent/Contact.htm
*
* @description ContactTriggerServices on Contact, it gets called from the ContactDispatcher*/
public with sharing class ContactTriggerServices {
    
    public static final List<LanguageSetting__mdt> LANGUAGE_SETTINGS = [select Id,Label,Value__c FROM LanguageSetting__mdt];
    public static final EnvironmentSetting__mdt ENVIRONMENT_SETTING = [select Id,Label,Value__c FROM EnvironmentSetting__mdt WHERE DeveloperName ='CommunityProfileName' LIMIT 1][0];
    
    /*******************************************************************************************************
    * @description 
    * If is Is_Owner__c and from Integration User?, create Community user, 
    * If Buyer_ID__c find related broker account-->? accountId and if isPartner is not set, update it
    * Get Custom MetaData and Map Country to user Locale
    * @param filteredContacts Map Id, List of filtered Contacts
    * 
    * @return Returns void
    */
   
    public static void processFilteredContacts(Map<Id,Contact> filteredContacts) {
        Profile brokerProfile = [SELECT Id,Name FROM Profile WHERE Name =:ENVIRONMENT_SETTING.Value__c];
        Map<String,List<Contact>> acctIdContacts = new Map<String,List<Contact>>();
        Map<String,String> contactIdUser =new Map<String,String>();
        Map<String,String> languages = new Map<String,String>();
        
        for(LanguageSetting__mdt languageSetting:LANGUAGE_SETTINGS){
            languages.put(languageSetting.Label.ToUpperCase(),languageSetting.Value__c);
        }
        for(String contactId: filteredContacts.keySet()){
            Contact con = filteredContacts.get(contactId);
            if(con.AccountId != null){
                if(!acctIdContacts.containsKey(con.AccountId)){
                    acctIdContacts.put(con.AccountId, new List<Contact>{con});
                }else{
                    List<Contact> cons = acctIdContacts.get(con.AccountId);
                    cons.add(con);
                    acctIdContacts.put(con.AccountId, cons);
                }
            }else{
                con.addError('Account Id does not exist for Contact.');
                filteredContacts.remove(con.Id);
            }
        }
        List<Account> nonPartnerAccts = [Select Id,Name,isPartner FROM Account WHERE Id IN: acctIdContacts.keySet() AND isPartner = FALSE];
        for(Account acct:nonPartnerAccts){
            acct.isPartner =true;
        }
        Database.SaveResult[] srList = Database.update(nonPartnerAccts,false);
        for(Integer i=0; i<srList.size(); i++){
            if (!srList.get(i).isSuccess()) {
                //add error and don't process contact in next batch
                if(acctIdContacts.containsKey(nonPartnerAccts.get(i).Id)){
                    List<Contact> cons = acctIdContacts.get(nonPartnerAccts.get(i).Id);
                    for(Contact con:cons){
                        con.addError('Could not set related Account to Partner on Contact');
                        filteredContacts.remove(con.Id);
                    }
                }
            }            
        }

        String hostName =  URL.getSalesforceBaseUrl().getHost();
        hostName = hostName.left(hostName.indexOf('.my.salesforce.com'));
        List<User> usersToCreate = new List<User>();
        for(String contactId: filteredContacts.keySet()){

            Contact con = filteredContacts.get(contactId);
            String language = con.Language_Code__c == Null ? '' : con.Language_Code__c;
            language = languages.containsKey(language.trim().ToUpperCase()) ? languages.get(language.trim().ToUpperCase()) : 'en_US';
            String userName = con.Email + '.' + hostName;
            String name =  con.FirstName + con.LastName;
            User newUser = new User(
                Alias = name.left(8),
                Email = con.Email,
                EmailEncodingKey = 'ISO-8859-1',
                FirstName = con.FirstName,
                LastName = con.LastName,
                LanguageLocaleKey = language,
                LocaleSidKey = 'en_US',
                IsActive = true,
                ProfileId = brokerProfile.Id,
                TimeZoneSidKey = 'America/Chicago',
                UserName = userName,
                ContactId = con.Id,
                FederationIdentifier = con.Email,
                CommunityNickname =userName
            );
            usersToCreate.add(newUser);
        }
        System.Debug('*Creating Users ');
        Database.SaveResult[] srUserList = Database.Insert(usersToCreate,false);
        for(Integer i=0;i<srUserList.size();i++){
            if (srUserList.get(i).isSuccess()) {
                //Update Contact.Broker_Partner_User__c  = usersToCreate.get(i).Id
                contactIdUser.put( usersToCreate.get(i).ContactId,usersToCreate.get(i).Id);
            }
            else{
                string errDBMsg;               
                for(Database.Error err :srUserList.get(i).getErrors()) {
                    errDBMsg =+ err.getStatusCode() + ': ' + err.getMessage() + ' '  + err.getFields() ;           
                }
                Contact con =filteredContacts.get(usersToCreate.get(i).ContactId);
                con.AddError('Error: ' + errDBMsg);                                
            }
        }   
        System.Debug('*Updating Contacts ');
       if(!contactIdUser.isEmpty()) {
            List<Contact> consToUpdate = [SELECT Id,Broker_Partner_User__c FROM Contact WHERE Id IN: contactIdUser.keyset()];
            for(Contact con:consToUpdate){
                con.Broker_Partner_User__c = contactIdUser.get(con.Id);
            }
            Database.SaveResult[] srConsList = Database.update(consToUpdate,false);
            for(Integer i=0; i<srConsList.size(); i++){
                if (!srConsList.get(i).isSuccess()) {
                    string errDBMsg;               
                    for(Database.Error err :srConsList.get(i).getErrors()) {
                        errDBMsg =+ err.getStatusCode() + ': ' + err.getMessage() + ' '  + err.getFields() ;           
                    }
                    system.debug('errDBMsg: '+errDBMsg);
                    Contact con =consToUpdate.get(i);
                    con.AddError('Error: ' + errDBMsg);
                }       
            }
        }  
    }
}