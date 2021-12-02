@isTest
private class DuplicateContact_Test {
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
    @isTest
    private static void test1(){
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        UserRole ur = new UserRole(Name = 'Other');
        insert ur;
        
        
        
        User ebiz = createTestUser(ur.Id, pf.Id, 'Ebiz', 'E-Business Development');
        insert ebiz;
         User TestUser = createTestUser(ur.Id, pf.Id, 'Test', 'User');
        insert TestUser;
        
        system.debug('Name  ' +ebiz);
        
        Account objAccount;
        
        contact objCon;
        contact objCon1;
        contact objCon2;
        
        system.runAs(ebiz){
            objAccount = new Account(Name = 'testAccount');
            insert objAccount;
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.allowSave = true; //Controlls bypass
            dml.DuplicateRuleHeader.runAsCurrentUser = true;
            
            objCon = new Contact(FirstName = 'Test',LastName = 'test',AccountId=objAccount.Id, MobilePhone = '8273812311', Buyer_Employee_ID__c = '12345');
            //insert objCon;
            Database.insert(objCon, dml);
            
        }
        /*contact ob =[SELECT Id, LastName, FirstName, AccountId,Phone, MobilePhone, Buyer_Employee_ID__c,HomePhone,
                     OtherPhone, Email, MailingStreet, MailingState, MailingPostalCode, MailingCity, MailingCountry,
                     OtherStreet, OtherState, OtherCity, OtherPostalCode, OtherCountry, AC_Created_Date__c,
                     AC_Created_User__c, AC_Login__c, AC_Modified_Date__c, AC_Modified_User__c, AC_User_ID__c,Buyer_Type__c
                     FROM Contact
                     WHERE createdBy.Name = 'Ebiz E-Business Development' AND Buyer_Employee_ID__c != Null AND Buyer_Employee_ID__c != ''
                     ORDER BY CreatedDate ASC];
        system.debug('ob '+ob);*/
        system.runAs(TestUser){
            objAccount = new Account(Name = 'testAccount');
            insert objAccount;
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.allowSave = true; //Controlls bypass
            dml.DuplicateRuleHeader.runAsCurrentUser = true;
            
            objCon1 = new Contact(FirstName = 'Test',LastName = 'test',AccountId=objAccount.Id, MobilePhone = '8273812311', Buyer_Employee_ID__c = '12345');
            //insert objCon;
            Database.insert(objCon1, dml);
            objCon2 = new Contact(FirstName = 'Test',LastName = 'test',AccountId=objAccount.Id, MobilePhone = '8273812311', Buyer_Employee_ID__c = '12345');
            //insert objCon;
            Database.insert(objCon2, dml);
            
        }
        Test.startTest();
            DuplicateContact obj = new DuplicateContact();
            DataBase.executeBatch(obj);
            Test.stopTest();
    }
    
}