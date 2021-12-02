@isTest
public class GoogleReCAPTCHAController_Test {
    
    @isTest
    private  static void TestSubmit(){
        GoogleReCAPTCHAController objGooRecCon = new GoogleReCAPTCHAController();        
        ApexPages.currentPage().getParameters().put('g-recaptcha-response','yahoo');
        Test.setMock(HttpCalloutMock.class, new Mockup_GoogleReCAPTCHAController_Test());
        objGooRecCon.submit();
    }
    
    @isTest
    private  static void TestgetKnowledgeArticleList1(){
        
        ApexPages.currentPage().getParameters().put('g-recaptcha-response','yahoo');
        Test.setMock(HttpCalloutMock.class, new Mockup_GoogleReCAPTCHAController_Test());
        GoogleReCAPTCHAController objGooRecCon = new GoogleReCAPTCHAController(); 
        objGooRecCon.submit();
        
        Account testAcc = new Account(
            Name = 'testAccount',          
            BillingState = 'California',
            BillingStreet = '6410 via Real',
            BillingPostalCode = '93013',
            BillingCity = 'Carpinteria',
            Industry = 'Construction'
        );
        insert testAcc ;
        
        Contact c1 = new Contact(AccountId = testAcc.id, FirstName = 'Test', LastName = 'Contact', Email='c-aray@lynda.com');
        c1.MailingState = 'California';
        c1.MailingCountry = 'United States';
        insert c1;
        
        topic newTopic = new topic(NetworkId = '0DB3g000000TN1j', name = 'test');
        insert newTopic;
        
        knowledge__kav newArticle = new knowledge__kav(Title='test', summary='xyz',
                                                       urlname='xyz', recordTypeId ='0121U000000b8HEQAY');
        string topicID = newTopic.Id;
        insert newArticle;
        
        String articleId = newArticle.Id;
        TopicAssignment Topicass = new TopicAssignment(TopicId = topicID, EntityId = c1.Id, NetworkId = '0DB3g000000TN1j');
        insert Topicass;
        boolean archived = false;
        
        //KbManagement.PublishingService.publishArticle(articleId, true);
        test.startTest();
        
        
        GoogleReCAPTCHAController.getKnowledgeArticleList('en_US');
        GoogleReCAPTCHAController.handleCheckBoxChange('caseDescription', 'en_US');
        
        test.stopTest();
        
    }
    
    @isTest
    private  static void TestgetKnowledgeArticleList(){
        case oj = new case(subject = 'test');
        insert oj;
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content hkajsjjsklalkskalksksllakklskalkjdjaklskllkkajskjdjlak'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        system.debug('----- '+documents.size());
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = oj.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
        List<Map<String, Object>> objTes = new List<Map<String, Object>>();
        Map<String, Object> objTe = new Map<String, Object>();
        objTe.put('str',cdl);
        objTes.add(objTe);
        
        GoogleReCAPTCHAController.createCommunityCase('strSuppliedName', 'strSuppliedEmail@dot.com', '9999999999', 'strDescription', 'Password Reset', 'Password Reset', 'BuyerId', false, objTes);
        GoogleReCAPTCHAController.createContact(new case(subject='testing case'));
        // GoogleReCAPTCHAController.uploadFiles(objTes, oj.Id);
    }
    @isTest
    private  static void TestgetKnowledgeArticleList2(){
        blob obj =  Blob.valueof('Some random String');
        GoogleReCAPTCHAController.saveFile('strFileName', obj);
    }
    
}