global class W9EmailAttachmentClass {
 @InvocableMethod(label='W9 Email attachment' description='this class used to w9 attachment email from process builder')
  public static void getW9EmailAttachment(List<Id> recordIds) {
    Map<String, String> mapOfContentType = new Map<String, String>();
    mapOfContentType.put('JPG', 'image/jpeg');
    mapOfContentType.put('PDF', 'application/pdf');
    mapOfContentType.put('PNG', 'image/png');
    system.debug('userInfo.getUserId() '+userInfo.getUserId());
    String emailAddress = System.Label.ContractAdminEmailAddress;
     system.debug('emailAddress '+emailAddress);
    Id recordId = recordIds[0];
    List<String> accountNames = new List<String>();
     
    List<Account> accounts = [SELECT Name,Account_Owner_Approver__c, Account_Owner_Requester__c FROM Account WHERE Id = :recordId];
    
    List<ContentDocumentLink> listCDL = [SELECT ContentDocumentId, Id, IsDeleted, LinkedEntityId, ShareType,
                                                SystemModstamp, Visibility 
                                        FROM ContentDocumentLink 
                                        WHERE LinkedEntityId =:recordId];
      List<Id> lstContentDocumentlist = new List<Id>();
      for(ContentDocumentLink objCDL : listCDL){
          lstContentDocumentlist.add(objCDL.ContentDocumentId);
      }
       system.debug('lstContentDocumentlist '+lstContentDocumentlist);
      ContentVersion objCV = new ContentVersion();
       ContentDocument objCD = new ContentDocument();
      if(!listCDL.isEmpty()){
          objCV = [SELECT Checksum, ContentBodyId, ContentDocumentId, ContentLocation, ContentModifiedById,
                          ContentModifiedDate, ContentSize, ContentUrl, CreatedById, CreatedDate, Description, Document_Type__c,
                          ExternalDataSourceId, ExternalDocumentInfo1, ExternalDocumentInfo2, FeaturedContentBoost,
                          FeaturedContentDate, FileExtension, FileType, FirstPublishLocationId, Id, IsAssetEnabled,
                          IsDeleted, IsLatest, IsMajorVersion, LastModifiedById, LastModifiedDate, NegativeRatingCount,
                          Origin, OwnerId, PathOnClient, PositiveRatingCount, PublishStatus, RatingCount, ReasonForChange,
                          SharingOption,SharingPrivacy,SystemModstamp,TagCsv,TextPreview,Title,VersionData, VersionNumber 
                   FROM ContentVersion
                   WHERE Document_Type__c = 'W-9'AND ContentDocumentId IN : lstContentDocumentlist Order By LastModifiedDate DESC  Limit 1];
     }
      system.debug('objCV '+objCV);  
      if(objCV.ContentDocumentId != null ){
          objCD = [SELECT ContentModifiedDate,ContentSize,FileExtension,FileType,Id,
                          LastModifiedDate,LatestPublishedVersionId,PublishStatus,Title 
                   FROM ContentDocument 
                   WHERE Id =: objCV.ContentDocumentId
                   ORDER BY ContentModifiedDate DESC];
      }
     
      Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
    // Set the recipient address
    message.setToAddresses(new String[] { emailAddress }); 
      String salesforceAutomatedEmailAddress = System.Label.salesforce_Automated_Email;
      OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =: salesforceAutomatedEmailAddress limit 1];
    message.setOrgWideEmailAddressId(owea[0].Id);
      //message.setTargetObjectId(); 
      message.setWhatId(recordId);
      //message.setInReplyTo(accounts[0].Account_Owner_Requester__c);
      message.setSaveAsActivity(false);      
      List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
      Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();     
      efa.setFileName(objCV.Title +'.'+ objCV.FileExtension);
      efa.setBody(objCV.VersionData);
      efa.setContentType(mapOfContentType.get(objCV.FileType));

     attachments.add(efa);
    
    message.setFileAttachments(attachments);
      EmailTemplate objEmailTemp = [SELECT ApiVersion,Body,BrandTemplateId,CreatedById,CreatedDate,Description,
                                           DeveloperName,Encoding,EnhancedLetterheadId,FolderId,FolderName,
                                           HtmlValue,Id,IsActive,LastModifiedById,LastModifiedDate,
                                           LastUsedDate,Markup,Name,NamespacePrefix,OwnerId,RelatedEntityType,
                                           Subject,SystemModstamp,TemplateStyle,TemplateType,TimesUsed,
                                           UiType 
                                    FROM EmailTemplate 
                                    WHERE DeveloperName='ContractAdminApprovalEmailTemplate'];
      if (objEmailTemp != Null) {
          Account objA = [SELECT Id, Name, Branch__c,Branch__r.Name, VRD_Level__c, Phone, FEIN__c, IBuyFast_Manual_Auto__c,
                                        ShippingStreet, ShippingCity, ShippingState, ShippingCountry, 
                                        ShippingPostalCode,ownerId
                                 FROM Account
                                 WHERE Id =: recordId Limit 1];
         
          message.setSubject('Approval Request for Account '+objA.Name);
          String Body ='Hi Team,<Br/><Br/>'+'Branch: '+objA.Branch__r.Name+'<Br/>';

            Body = Body+ ' VRD Level : '+objA.VRD_Level__c+'<Br/>'+'IBuyFast-Manual/Auto : '+String.valueOf(objA.IBuyFast_Manual_Auto__c)+'<Br/>';
            Body = Body+ ' Name : '+ objA.Name+'<BR />'; 
            Body = Body+ ' Shipping Address: '+ objA.ShippingStreet+', ' +objA.ShippingCity +', ' +objA.ShippingState +', ' + objA.ShippingCountry +' PIN Code '+objA.ShippingPostalCode+'<BR />';
            Body = Body+ ' Phone : '+ objA.Phone+'<BR />';  
            Body = Body+ ' FEIN : '+ objA.FEIN__c+'<BR /> <BR />';  
            string urler =URL.getSalesforceBaseUrl().toExternalForm()+'/'+objA.Id;
          system.debug('urler '+urler);
          Body = Body+ ' Account Link : '+ '<a href="'+urler+'">'+urler+'</a>'; 
       
          message.setHtmlBody(Body);
          system.debug('message '+message.getToAddresses());
      }
      
      try {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
      } catch (Exception e) {
             throw e;
        }
  }
   
}