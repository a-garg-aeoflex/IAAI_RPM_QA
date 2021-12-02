@isTest
public class DELETE_LookupRollupSummarySchedule_Test {
    
    @isTest
    public static void DELETE_LookupRollupSummarySchedule_Test_Method1(){
        List<dlrs__LookupRollupSummaryScheduleItems__c> lstIDER = new List<dlrs__LookupRollupSummaryScheduleItems__c>();
       	dlrs__LookupRollupSummary__c objDLR = new dlrs__LookupRollupSummary__c();
        
        objDLR.dlrs__AggregateResultField__c = 'N/A';
        objDLR.dlrs__CalculateJobId__c = 'test1244';
        objDLR.dlrs__ChildObject__c = 'N/A';
        objDLR.dlrs__CalculateJobId__c = '1231112';
        objDLR.dlrs__CalculationMode__c = '';
        
        objDLR.Name = 'CurrentYearGross';
        objDLR.dlrs__UniqueName__c = 'mdt:m051U000000QcEMQA0';
        
        objDLR.dlrs__ParentObject__c = 'N/A';
        objDLR.dlrs__RelationshipField__c = 'N/A';
        objDLR.dlrs__FieldToAggregate__c = 'N/A';
        insert objDLR;    
        
        dlrs__LookupRollupSummaryScheduleItems__c obj = new dlrs__LookupRollupSummaryScheduleItems__c();
        obj.dlrs__LookupRollupSummary__c = objDLR.Id;
        obj.dlrs__QualifiedParentID__c = 'itr1982';
             
        insert obj;
       
     Test.startTest();
         DELETE_LookupRollupSummaryScheduleItems obje = new DELETE_LookupRollupSummaryScheduleItems(50,true ); 
        DELETE_LookupRollupSummaryScheduleItems obje1 = new DELETE_LookupRollupSummaryScheduleItems();
        Database.executeBatch( obje );  
      Test.stopTest();
         
    }
}