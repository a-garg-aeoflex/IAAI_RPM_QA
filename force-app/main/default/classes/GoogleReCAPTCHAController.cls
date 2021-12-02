public without sharing class  GoogleReCAPTCHAController {
    public class CustomException extends Exception {
        string message;
    }
    
    public Boolean verified { get; private set; }
    public String response  { 
        get {
            return ApexPages.currentPage().getParameters().get('g-recaptcha-response');
        }
    }
    public String firstName{get;set;}
    public String lastName{get;set;}
    public String publicKey {get;set;}
    public case objCase{get;set;}
    
    private String remoteHost{
        get {
            String ret = '127.0.0.1';
            //Also could use x-original-remote-host
            Map<String, String> hdrs = ApexPages.currentPage().getHeaders();
            if (hdrs.get('x-original-remote-addr')!= null)
                ret = hdrs.get('x-original-remote-addr');
            else if (hdrs.get('X-Salesforce-SIP')!= null)
                ret = hdrs.get('X-Salesforce-SIP');
            return ret;
        }
    }
    
    //Google Secret Key
    private static String secretKey = System.Label.secretKey;
    private static String baseUrl = System.Label.baseUrl;
    
    //Constructor
    public GoogleReCAPTCHAController(){
        this.publicKey = System.Label.publicKey;
        this.verified = false;
        objCase = new case();
    }
    
    public PageReference submit(){
        if (response == null ){
            //Google recaptcha empty response
            return null;
        }
        HttpResponse res = getGoogleReCAPTCHAResponse(baseUrl,'secret=' + secretKey + '&remoteip=' + remoteHost + '&response=' + response);
        if (res != null ) {
            JSONParser parser = JSON.createParser(res.getBody());
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'success')) {
                    parser.nextToken();
                    this.verified = parser.getBooleanValue();
                    break;
                }
            }            
        }   
        if(this.verified){
            //Add your logic
            system.debug('Verified');
            return null;
            
        }
        else{
            //Stay on page to re-try reCAPTCHA
            return null; 
        }
    }
    
    //Get Google reCAPTCHA Service Response 
    private static HttpResponse getGoogleReCAPTCHAResponse(string requestURL, string body){
        HttpResponse response = null;
        HttpRequest req = new HttpRequest();
        req.setEndpoint(requestURL);
        req.setMethod('POST');
        req.setBody (body);
        try{
            Http http = new Http();
            response = http.send(req);
            System.debug('ReCAPTCHA Response-' + response);
            System.debug('ReCAPTCHA Body-' + response.getBody());
        }
        catch(System.Exception ex){
            System.debug('ERROR Message-' + ex.getMessage());
        }
        return response;
    }
    @AuraEnabled
    public static Case createContact(Case objCase){
        
        insert objCase;
        return objCase;  
        
        
    }
    
    @AuraEnabled(cacheable=true)
    public static List<knowledge__kav> getKnowledgeArticleList(string lang){
        system.debug('lang '+lang);
        list<knowledge__kav> lstArticle = [SELECT Id, urlname, PublishStatus, CreatedDate, 
                                                  CreatedById, ArticleNumber, Title, FirstPublishedDate, 
                                                  Language 
                                           FROM knowledge__kav WHERE recordType.DeveloperName = 'FAQ' 
                                           AND language = :lang];
        return lstArticle;
    }
   
    @AuraEnabled(cacheable=true)
    public static List<knowledge__kav> handleCheckBoxChange(String caseDescription, string language){
        system.debug('caseDescription '+caseDescription);
        system.debug('language '+language);
        string objL = language;
        List<knowledge__kav> foundKnowledgeArticle = new List<knowledge__kav>() ;
        if(caseDescription <> null){
            map<string, List<knowledge__kav>> mapOfKnowledgeArticle = new map<string, List<knowledge__kav>>();
            List<string> searchkeyWord = caseDescription.split(' ');
            list<String> lstCaseDeflectionKeyWord = System.Label.caseDeflectionKeywords.split(',');            
            mapOfKnowledgeArticle = handleMapOfKnowledgeArticle();
            system.debug('mapOfKnowledgeArticle '+mapOfKnowledgeArticle.size());
            
            for(string strkeywords:lstCaseDeflectionKeyWord){
                system.debug(' caseDescription ');
                system.debug(' caseDescription.containsIgnoreCase(strkeywords '+caseDescription.containsIgnoreCase(strkeywords));
                if(caseDescription.containsIgnoreCase(strkeywords)){
                    system.debug('mapOfKnowledgeArticle.get(strkeywords) '+mapOfKnowledgeArticle.get(strkeywords));
                    foundKnowledgeArticle.addAll(mapOfKnowledgeArticle.get(strkeywords));
                }
                
            }
            system.debug('foundKnowledgeArticle size'+foundKnowledgeArticle.size());
        }else{
            foundKnowledgeArticle = [SELECT Id, urlname, PublishStatus, CreatedDate, 
                                     CreatedById, ArticleNumber, Title, FirstPublishedDate, 
                                     Language
                                     FROM knowledge__kav WHERE recordType.DeveloperName = 'FAQ'AND Language= :objL ];
        }
         return foundKnowledgeArticle;
    }
   
   
    public static map<string, List<knowledge__kav>> handleMapOfKnowledgeArticle(){
        map<string, List<knowledge__kav>> mapOfKnowledgeArticle = new map<string, List<knowledge__kav>>();
        map<string, knowledge__kav> mapOfTitleKnowledgeArticle = new map<string, knowledge__kav>();
        list<String> lstCaseDeflectionKeyWord = System.Label.caseDeflectionKeywords.split(',');
        for(knowledge__kav objKA :[Select Id, urlname, PublishStatus, CreatedDate, 
                                   CreatedById, ArticleNumber, Title, FirstPublishedDate, 
                                   Language 
                                   From knowledge__kav ]){
                                       mapOfTitleKnowledgeArticle.put(objKA.Title,objKA);
                                   }
        for(string strKeyword:lstCaseDeflectionKeyWord){
            list<knowledge__kav> lstKn =new list<knowledge__kav>();
            for(string KATitle:mapOfTitleKnowledgeArticle.keySet()){
                if(KATitle.containsIgnoreCase(strKeyword) ){
                    knowledge__kav objKA = new knowledge__kav();
                    lstKn.add(mapOfTitleKnowledgeArticle.get(KATitle));
                    mapOfKnowledgeArticle.put(strKeyword, lstKn); 
                }
            }            
        }       
        return mapOfKnowledgeArticle;         
    }
    @AuraEnabled
    public static String createCommunityCase(string strSuppliedName, String strSuppliedEmail, 
                                             string strSuppliedPhone, String strDescription, string strCaseType, 
                                             string strCaseSubType, string BuyerId, boolean isGuestUser,  
                                             List<Map<String, Object>> files){        
        system.debug('jjjj'); 
        system.debug('isGuestUser '+isGuestUser); 
        Case objCaseIn = new case();
        try{            
            objCaseIn.subject ='Case Submitted on IAA Help';
            objCasein.Origin = 'IAA Help';            
            user objUser = [SELECT Id,Name FROM User WHERE name ='Help Community Site Guest User' Limit 1];
            if(isGuestUser){
                objCaseIn.OwnerId = objUser.Id;
            }else{
                objCaseIn.OwnerId = userinfo.getUserId();
            }
            Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Help_Broker_Community').getRecordTypeId();
            id  Broker_EmployeeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Broker_Employee').getRecordTypeId();            
            Database.DMLOptions dmo = new Database.DMLOptions();           
            dmo.EmailHeader.triggerAutoResponseEmail= true;            
            objCaseIn.recordTypeId = caseRecordTypeId;
            objCaseIn.SuppliedName = strSuppliedName;
            objCaseIn.SuppliedEmail = strSuppliedEmail;
            system.debug('>>Email '+ objCaseIn.SuppliedEmail);           
            objCaseIn.SuppliedPhone = strSuppliedPhone;  
            objCaseIn.Description = strDescription;
            objCaseIn.Case_Type__c = strCaseType;
            objCaseIn.Case_Subtype__c  = strCaseSubType;
            objCaseIn.Buyer_ID__c = BuyerId;
            //objCaseIn.setOptions(dmo);
            List<contact> obj = new List<contact>();
            if(objCaseIn.Buyer_ID__c <> null && objCaseIn.Buyer_ID__c <> ''){
                String caBUYId = 'BUY-'+objCaseIn.Buyer_ID__c;
                String FcrsBuyId = 'Buy-'+objCaseIn.Buyer_ID__c;
                String allSmbuy = 'buy-'+objCaseIn.Buyer_ID__c;
                
                List<Account> lstAccount = new List<Account>();
                lstAccount = [SELECT Id, Name FROM Account WHERE (BI_Id__c =: objCaseIn.Buyer_ID__c OR BI_Id__c =: caBUYId OR BI_Id__c =: FcrsBuyId OR BI_Id__c =: allSmbuy)];
                if(!lstAccount.isEmpty()){
                    objCaseIn.AccountId = lstAccount[0].Id;
                    obj = [SELECT Id, Name,AccountId, email, Phone, MobilePhone, AssistantPhone, OtherPhone, HomePhone  FROM Contact WHERE
                          ((AccountId =:objCaseIn.AccountId) AND (email =:objCaseIn.SuppliedEmail OR Phone =:objCaseIn.SuppliedPhone 
                            OR MobilePhone = :objCaseIn.SuppliedPhone OR HomePhone =:objCaseIn.SuppliedPhone 
                            OR OtherPhone =: objCaseIn.SuppliedPhone OR AssistantPhone =:objCaseIn.SuppliedPhone))];
                    if(!obj.isEmpty()){
                        objCaseIn.ContactId = obj[0].Id;
                    }
                }
            }
            Database.insert(objCaseIn);            
            if(files<> null && files.size() > 0 && objCaseIn <> null){
                uploadFiles(files,objCaseIn.Id);
            }             
        }catch(exception e){
            System.debug(Logginglevel.ERROR, e.getMessage()+' '+e.getLineNumber());            
        }	 
        return objCaseIn.id;
    }     
    
    
    @AuraEnabled
    public static ContentVersion saveFile(Id idParent, String strFileName, Blob base64Data) {
        
        ContentVersion cv = new ContentVersion();
        cv.Title = strFileName;
        cv.PathOnClient = '/' + strFileName;
        cv.FirstPublishLocationId = idParent;
        cv.VersionData = base64Data;
        cv.IsMajorVersion = true;
        system.debug('working');
        Insert cv;
        system.debug('working cv '+cv.Id);
        
        
        return cv;
    }
    
    @AuraEnabled
    public static ContentVersion saveFile(String strFileName, Blob base64Data) {
        
        ContentVersion cv = new ContentVersion();
        cv.Title = strFileName;
        cv.PathOnClient = '/' + strFileName;
        cv.VersionData = base64Data;
        cv.IsMajorVersion = true;
        system.debug('working');
        Insert cv;
        system.debug('working cv '+cv.Id);
        return cv;
    }
    /*
    @AuraEnabled
    public static list<contentversion> releatedFiles(Id idParent){
        list<id> lstConDocs = new list<id>();
        for(ContentDocumentLink cntLink : [Select Id, ContentDocumentId From ContentDocumentLink Where LinkedEntityId =:idParent]) {
            lstConDocs.add(cntLink.ContentDocumentId);
        }
        if(!lstConDocs.isEmpty()) {
            return [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :lstConDocs];
        }
        else {
            return null;
        }
        
    }*/
    public class relatedFile {
        public String PathOnClient;
        public String Title;
        public Blob VersionData;
    }
    
    @AuraEnabled
    public static List<ContentVersion> uploadFiles(List<Map<String, Object>> files, Id caseId){
        Boolean isSuccess = false;
        List<ContentVersion> relatedDocuments = new List<ContentVersion>();
        for (Map<String, Object> file : files) {
            String fileJson = JSON.serialize(file);
            relatedFile relatedDocument = (relatedFile) JSON.deserialize(fileJson, relatedFile.class);
            relatedDocuments.add(saveFile(caseId,relatedDocument.Title,relatedDocument.VersionData)); 
        }
        return relatedDocuments;
    }
}