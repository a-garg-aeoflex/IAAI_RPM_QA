/**
* Lev
* @date 2020
*
* @group Lead
* @group-content ../../ApexDocContent/Lead.htm
*
* @description ApexCoverage for LeadTrigger,LeadDispatcher and LeadServices
*/
@IsTest (SeeAllData=false)

private with sharing class LeadTriggerServicesTest {
    static List<Account> accts;
    static Lead ld;
    static user user11;
    static List<User> usrs;
    static List<Contact> cons;
    static Group queue;
    static Group BrokerLeadSupp;
    static {
        Map<String,String> settings = new Map<String,String>();
        user user12 = TestDataFactory.createUser(false, 'Johntest111', 'System Administrator',null);
        system.runAs(user12)
        {
            
            
            UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
            insert r;
            user11 = TestDataFactory.createUser(false, 'Johntest1', 'System Administrator',null);
            user11.UserRoleId = r.Id;
            insert  user11;
            usrs = new List<User>{TestDataFactory.createUser(false, 'iiatester1341', 'System Administrator')};
                insert usrs;
        }
        
        system.runAs(user11){
            
             /*BrokerLeadSupp = new Group(Name='Broker Lead Support', DeveloperName = 'Broker_Lead_Support', Type='Queue');
        insert BrokerLeadSupp;*/
            
            for(EnvironmentSetting__mdt envSetting:LeadTriggerDispatcher.ENVIRONMENT_SETTINGS){
                settings.put(envSetting.DeveloperName,envSetting.Value__c);
            }  
            accts = TestDataFactory.createAccounts(false,2, 'Salvage');
            accts[0].BI_ID__c = '12123';   
            accts[0].OwnerId = user11.id;
            accts[1].BI_ID__c = '1212322';   
            accts[1].OwnerId = user11.id;
            insert accts;
            
            cons = TestDataFactory.createContact(false,2, accts);
            for(Integer i=0;i<cons.size();i++){
                cons.get(i).Email = 'test' + String.Valueof(i) + '@testiia.com';
            }
            cons[0].Is_Owner__c = true;
            insert cons;
        }
        List<Account> accts = [Select Id,Broker_Owner__c,Name FROM Account];
        
        
        ld = TestDataFactory.createLeads(false,1,'Smith','smith1@none.com',settings.get('LeadTriggerSource'),settings.get('LeadTriggerRecordType'))[0];   
        
        queue = [select Id, Name, DeveloperName from Group where DeveloperName='Bidder_Lead_Support' LIMIT 1][0];
        system.debug('queue '+queue);
        
    }
    @IsTest
    static void leadAssignOwnerPositive(){
        System.Test.startTest();
        ld.Related_Account__c = accts[0].Id;
        ld.OwnerId = queue.Id;
        insert ld;
        
        System.Test.stopTest();
        Lead updateLead = [SELECT Id,OwnerId,Related_Account__c FROM Lead WHERE Id =:ld.Id];
        system.debug('updateLead '+updateLead);
        User u = [Select Id,Email FROM User WHERE email = 'iiatester1341@testmail.com'];
        system.debug('u '+u);
        //System.assertEquals(u.Id, updateLead.OwnerId);
    }
    
    @IsTest 
    static void leadAssignNoAccountNegative(){
        System.Test.startTest();
        ld.OwnerId = queue.Id;
        insert ld;
        System.Test.stopTest();  
        system.debug('ld.Id '+ld.Id);
        Lead updatedLead = [Select id,owner.Id,owner.name FROM lead where Id =: ld.Id];
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
    static void leadAssignNoBrokerOwnerNegative(){
        cons[0].Is_Owner__c = false;
        accts[0].Broker_Owner__c = null;
        update cons;
        update accts;
        System.Test.startTest();       
        ld.Related_Account__c = accts[0].Id;
        insert ld;
        System.Test.stopTest();       
        
        Lead updateLead = [SELECT Id,OwnerId,Related_Account__c FROM Lead WHERE OwnerId =:queue.Id];
        System.assertEquals(queue.Id, updateLead.OwnerId);
    }
    @IsTest 
    static void leadAssignUserIsNotInCommunity(){
        
        System.Test.startTest();      
        system.debug('accts[1].Id '+accts[1].Id);
        ld.Related_Account__c = accts[1].Id;
        insert ld;
        System.Test.stopTest();       
        system.debug('queue.Id '+queue.Id);
        //system.debug('queue.Name '+queue.Name);
        Lead updateLead = [SELECT Id,OwnerId,Related_Account__c FROM Lead WHERE OwnerId =:queue.Id];
        System.assertEquals(queue.Id, updateLead.OwnerId);
    }
}