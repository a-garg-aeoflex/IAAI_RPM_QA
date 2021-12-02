@isTest
private class LeadTriggerHandler_Test{
    static List<Account> accts121;
    static Lead ld1;
    static user user111;
    static List<User> usrs;
    static List<Contact> cons1;
    static Group queue;
    static Group BrokerLeadSupp;
    static {
        Map<String,String> settings = new Map<String,String>();
        user user121 = TestDataFactory.createUser(false, 'Johntest111', 'System Administrator',null);
        system.runAs(user121)
        {
            
            
            UserRole r1 = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
            insert r1;
            user111 = TestDataFactory.createUser(false, 'Johntest1', 'System Administrator',null);
            user111.UserRoleId = r1.Id;
            insert  user111;
            usrs = new List<User>{TestDataFactory.createUser(false, 'iiatester1341', 'System Administrator')};
                insert usrs;
        }
        
        system.runAs(user111){
            
           
            
            for(EnvironmentSetting__mdt envSetting:LeadTriggerDispatcher.ENVIRONMENT_SETTINGS){
                settings.put(envSetting.DeveloperName,envSetting.Value__c);
            }  
            accts121 = TestDataFactory.createAccounts(false,2, 'Salvage');
            accts121[0].BI_ID__c = '12123';   
            accts121[0].OwnerId = user111.id;
         
            accts121[1].BI_ID__c = '1212322';   
            accts121[1].OwnerId = user111.id;
            insert accts121;
            
            cons1 = TestDataFactory.createContact(false,2, accts121);
            for(Integer i=0;i<cons1.size();i++){
                cons1.get(i).Email = 'test1' + String.Valueof(i) + '@testiia.com';
            }
            cons1[0].Is_Owner__c = true;
            insert cons1;
        }
        List<Account> accts212 = [Select Id,Broker_Owner__c,Name FROM Account];
        
        
        ld1 = TestDataFactory.createLeads(false,1,'Smith1','smith@none1.com',settings.get('LeadTriggerSource'),settings.get('LeadTriggerRecordType'))[0];   
        
        queue = [select Id, Name, DeveloperName from Group where DeveloperName='Bidder_Lead_Support' LIMIT 1][0];
        system.debug('queue '+queue);
        
    }
    @IsTest
    static void leadAssignOwnerPositive1(){
        System.Test.startTest();
        ld1.Related_Account__c = accts121[0].Id;
        ld1.OwnerId = queue.Id;
        insert ld1;
        
        System.Test.stopTest();
        Lead updateLead = [SELECT Id,OwnerId,Related_Account__c FROM Lead WHERE Id =:ld1.Id];
        system.debug('updateLead '+updateLead);
        User u = [Select Id,Email FROM User WHERE email = 'iiatester1341@testmail.com'];
        system.debug('u '+u);
        //System.assertEquals(u.Id, updateLead.OwnerId);
    }
    
    @IsTest 
    static void leadAssignNoAccountNegative1(){
        System.Test.startTest();
        ld1.OwnerId = queue.Id;
        insert ld1;
        System.Test.stopTest();  
        system.debug('ld.Id '+ld1.Id);
        Lead updatedLead = [Select id,owner.Id,owner.name FROM lead where Id =: ld1.Id];
        system.debug('updatedLead '+updatedLead);
        //system.debug('updatedLead Owner DevNam'+updatedLead.owner.);
        system.debug('updatedLead Owner '+updatedLead.owner.Name);
        system.debug('updatedLead OwnerId '+updatedLead.ownerId);
        system.debug('queue.Id '+queue.Id);
        //system.debug('queue.Id '+queue.Name);
        Lead updateLead = [SELECT Id, OwnerId, Related_Account__c FROM Lead WHERE OwnerId =:queue.Id];
        system.debug('updateLead '+updatedLead);
        System.assertEquals(queue.Id, updateLead.OwnerId);
    }
    
    @IsTest 
    static void leadAssignNoBrokerOwnerNegative1(){
         
        cons1[0].Is_Owner__c = false;
        accts121[0].Broker_Owner__c = null;
        update cons1;
        update accts121;
        System.Test.startTest();       
        ld1.Related_Account__c = accts121[0].Id;
        insert ld1;
        System.Test.stopTest();       
        
        Lead updateLead = [SELECT Id,OwnerId,Related_Account__c FROM Lead WHERE OwnerId =:queue.Id];
        System.assertEquals(queue.Id, updateLead.OwnerId);
    }
    @IsTest 
    static void leadAssignUserIsNotInCommunity1(){
        
        System.Test.startTest();      
        system.debug('accts[1].Id '+accts121[1].Id);
        ld1.Related_Account__c = accts121[1].Id;
        insert ld1;
        System.Test.stopTest();       
        system.debug('queue.Id '+queue.Id);
        //system.debug('queue.Name '+queue.Name);
        Lead updateLead = [SELECT Id,OwnerId,Related_Account__c FROM Lead WHERE OwnerId =:queue.Id];
        System.assertEquals(queue.Id, updateLead.OwnerId);
    }
    static testMethod void leadAssignment() {
        try{
            Account objAcc = new Account(Name ='Test', Is_Broker_created__c = true, BI_Id__C='BUY-121121');
            insert objAcc;
            Lead objLead = new Lead(FirstName ='First', Company='test', LastName ='Last', Buyer_Id__c = 'BUY-121121');
            insert objLead;
        }catch(exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('This Buyer already converted as Broker') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }       
    }
}