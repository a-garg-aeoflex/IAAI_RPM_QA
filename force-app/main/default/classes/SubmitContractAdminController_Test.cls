@isTest
private class SubmitContractAdminController_Test {
    static testMethod void getCurrentAccountTestWithNoValue(){
        RecordType objRed = [SELECT DeveloperName,Id,Name FROM RecordType WHERE DeveloperName = 'Prospect_Account'];
        Account objAccount = new Account();
        objAccount.Name = 'test Account Contract Admin';
        objAccount.RecordTypeId = objRed.Id;
        insert objAccount;
        Test.startTest();
      	SubmitContractAdminController.checkMedatoryFieldAccount reponse = SubmitContractAdminController.getCurrentAccount(objAccount.Id);
        SubmitContractAdminController.submitApprovalProcess(objAccount.Id);
        Test.stopTest();
    }
    static testMethod void getCurrentAccountTestWithSomeValueFEIN(){
        Account objAccount = new Account();
        objAccount.Name = 'test Account Contract Admin';
        objAccount.FEIN__c = '123456';
        insert objAccount;
        Test.startTest();
      	SubmitContractAdminController.checkMedatoryFieldAccount reponse = SubmitContractAdminController.getCurrentAccount(objAccount.Id);
        //SubmitContractAdminController.submitApprovalProcess(objAccount.Id);
        Test.stopTest();
    }
     static testMethod void getCurrentAccountTestWithSomeValue(){
         RecordType objRed = [SELECT DeveloperName,Id,Name FROM RecordType WHERE DeveloperName = 'Prospect_Account'];
        Account objAccount = new Account();
        objAccount.Name = 'test Account Contract Admin';
         objAccount.RecordTypeId = objRed.Id;
        objAccount.FEIN__c = '123456';
         //objAccount.VRD_Level__c = 'Level 2';
        insert objAccount;
        Test.startTest();
      	SubmitContractAdminController.checkMedatoryFieldAccount reponse = SubmitContractAdminController.getCurrentAccount(objAccount.Id);
        SubmitContractAdminController.submitApprovalProcess(objAccount.Id);
        Test.stopTest();
         
         
    }
     static testMethod void getCurrentAccountTestWithSomeValue01(){
         RecordType objRed = [SELECT DeveloperName,Id,Name FROM RecordType WHERE DeveloperName = 'Prospect_Account'];
        Account testAccount = new Account();
        testAccount.Name='Test Account' ;
         testAccount.RecordTypeId = objRed.Id;
        insert testAccount;    
         
     	ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true,
         	Document_Type__c = 'W-9'
         	//ContentDocumentId = documents[0].Id
        );
         
        insert contentVersion; 
         
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
         system.debug('== size '+documents.size());
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = testAccount.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
         
         Test.startTest();
         SubmitContractAdminController.updateContentVersion(testAccount.Id, documents[0].Id);
         Test.stopTest();
        
     }
   static testMethod void getCurrentAccountTestWithSomeValue02(){
        Branch__c obj =  new Branch__c(Name='test', Phone__c='889878788');
        insert obj;
        RecordType objRed = [SELECT DeveloperName,Id,Name FROM RecordType WHERE DeveloperName = 'Prospect_Account'];
        
        Account objAccount = new Account();
         objAccount.RecordTypeId = objRed.Id;
        objAccount.Name = 'test Account Contract Admin';       
        insert objAccount;
        
      	SubmitContractAdminController.checkMedatoryFieldAccount reponse = SubmitContractAdminController.getCurrentAccount(objAccount.Id);
      
        objAccount.Branch__c = obj.id;
        update objAccount;
        reponse = SubmitContractAdminController.getCurrentAccount(objAccount.Id);
        
         objAccount.FEIN__c = '1221';
        update objAccount;
        reponse = SubmitContractAdminController.getCurrentAccount(objAccount.Id);   
        
        objAccount.ShippingCity = 'test';
        update objAccount;
      reponse = SubmitContractAdminController.getCurrentAccount(objAccount.Id);
          objAccount.ShippingStreet = 'test';
        update objAccount;
         reponse = SubmitContractAdminController.getCurrentAccount(objAccount.Id);
         
    }


}