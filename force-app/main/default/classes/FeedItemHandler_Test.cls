@isTest
public class FeedItemHandler_Test { 
    static testMethod void FeedItemHandler_Test1()
    {
        
            Account objAc = new Account(Name ='test');
            insert objAc;
            contact objCon = new contact(LastName ='test', AccountId =objAc.Id );
            insert objCon;
            ID FeedbackRT_Id = Schema.getGlobalDescribe().get('CASE').getDescribe().getRecordTypeInfosByName().get('Buyer Feedback').getRecordTypeId();
            ID BuyerServicesRT_ID = Schema.getGlobalDescribe().get('CASE').getDescribe().getRecordTypeInfosByName().get('Buyer Services').getRecordTypeId();
            Case recBuyerServiceCase = new Case(AccountId = objAc.id, ContactId= objCon.Id,Subject ='test case', status = 'new', RecordTypeId=BuyerServicesRT_ID, Description ='test');
            insert recBuyerServiceCase;
            Case recBuyerServiceCase1 = new Case(AccountId = objAc.id, ContactId= objCon.Id,Subject ='test case', status = 'new', RecordTypeId=BuyerServicesRT_ID, Description ='test');
            insert recBuyerServiceCase1;
            recBuyerServiceCase.Status = 'Closed';
            update recBuyerServiceCase;
            FeedItem objeFeedItem = new FeedItem( body = 'test', ParentId=recBuyerServiceCase.Id);
            FeedItem objeFeedItem1 = new FeedItem( body = 'test12', ParentId=recBuyerServiceCase1.Id);
            insert objeFeedItem1;
        	
             Database.SaveResult result = Database.insert(objeFeedItem, false);
       		 //objeFeedItem1.ParentId = recBuyerServiceCase.Id;
       		 Database.SaveResult result1 = Database.Update(objeFeedItem1, false);
            
            
          }
}