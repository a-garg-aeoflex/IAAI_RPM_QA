@isTest
private class W9EmailAttachmentClass_Test {
 static testMethod void getW9EmailAttachmentTest(){
     List<Id> lstId = new List<Id>();
     Account testAccount = new Account();
        testAccount.Name='Test Account' ;
        insert testAccount;
     lstId.add(testAccount.Id);
     ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true,
         	Document_Type__c = 'W-9'
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = testAccount.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
     W9EmailAttachmentClass.getW9EmailAttachment(lstId);
 }
}