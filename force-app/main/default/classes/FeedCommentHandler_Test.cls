@isTest
public class FeedCommentHandler_Test {
    static testMethod void madalliaSurveyCaseCreation_Test1()
    {
        try
            
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
            FeedItem objeFeedItem1 = new FeedItem( body = 'test', ParentId=recBuyerServiceCase1.Id);
            insert objeFeedItem1;
             Database.SaveResult result = Database.insert(objeFeedItem, false);
            FeedComment recFeedComment = new FeedComment(CommentBody ='test case', FeedItemId=objeFeedItem.Id);
            FeedComment recFeedComment1 = new FeedComment(CommentBody ='test case',FeedItemId=objeFeedItem1.Id);
            insert recFeedComment1;
            Database.SaveResult result1 = Database.insert(recFeedComment, false);
            Database.SaveResult result2 = Database.Update(recFeedComment1, false);
            
            // throw new exception('Case can not be updated, to update closed case reopen it.'); // 1. If we get to this line it means an error was not added and the test class should throw an exception here. 2. MyException class extends Exception.
            
        }catch(Exception e){
            
            Boolean expectedExceptionThrown =  e.getMessage().contains('Case can not be updated, to update closed case reopen it') ? true : false;
            
            System.AssertEquals(expectedExceptionThrown, true);
            
        } 
    }
}