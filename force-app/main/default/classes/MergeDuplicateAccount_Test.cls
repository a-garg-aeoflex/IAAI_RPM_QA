@isTest
private class MergeDuplicateAccount_Test
{
    
     public static User createTestUser(Id roleId, Id profID, String fName, String lName)
    {
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
       
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User tuser = new User(  firstname = fName,
                                lastName = lName,                              
                                email = uniqueName + '@test' + orgId + '.org',
                                Username = uniqueName + '@test' + orgId + '.org',
                                EmailEncodingKey = 'ISO-8859-1',
                                Alias = uniqueName.substring(18, 23),
                                TimeZoneSidKey = 'America/Los_Angeles',
                                LocaleSidKey = 'en_US',
                                LanguageLocaleKey = 'en_US',
                                ProfileId = profId,
                                UserRoleId = roleId);
        return tuser;
    }
    
    static testMethod void testMethod1() 
    {
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
       
        UserRole ur = new UserRole(Name = 'Other');
        insert ur;
        User userDerell = createTestUser(ur.Id, pf.Id, 'Jenkins', 'Derell');
        system.debug('Name  ' +userDerell.Name);
        try
        {
           user userName =  [Select Name,Id FROM User Where Name = 'Derell Jenkins'];
            system.debug('Id '+userName.Id +' Name '+userName.Name);
            Id propectAccountRecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Account').getRecordTypeId();
            system.debug('userDerell '+userDerell);
             system.runAs(userName){
                 Database.DMLOptions dml = new Database.DMLOptions();
                 dml.DuplicateRuleHeader.allowSave = true; //Controlls bypass
                 dml.DuplicateRuleHeader.runAsCurrentUser = true;

                 Account objAcc = new Account(Name = 'Test Account1', BillingState='Test Billing State', BillingCity='Test Billing City', Phone='1001001234', RecordTypeId = propectAccountRecordTypeId);
                 insert objAcc;
                 list<Account>  lstAccount = new List<Account>();
				 Account objAccount1 = new Account(Name = 'Test Account3', BillingState='Test Billing State', BillingCity='Test Billing City', Phone='1001001234',ShippingState='test Shipping state', RecordTypeId = propectAccountRecordTypeId); 
                 Database.insert(objAccount1, dml);
                 Account objAccount2 = new Account(Name = 'Test Account2', BillingState='Test Billing State', BillingCity='Test Billing City', Phone='1001001234', RecordTypeId = propectAccountRecordTypeId); 
                 Database.insert(objAccount2, dml);
                   
                
            }
                     
            Test.startTest();
            MergeDuplicateAccount obj = new MergeDuplicateAccount();
            DataBase.executeBatch(obj);
            Test.stopTest();
         }
         Catch(DMLException e)
         {
            system.debug('ERROR : '+ e.getMessage() +' line number ' +e.getLineNumber());
         }
        
        
    }
    
    
}