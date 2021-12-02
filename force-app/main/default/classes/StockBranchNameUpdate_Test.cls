@isTest
private class StockBranchNameUpdate_Test  {
    @isTest static void StockBranchNameUpdateTest1(){  
        Id propectAccountRecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Account').getRecordTypeId();
        Id karBSAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('KAR BS Account').getRecordTypeId();
         
        Stock__c objStock = new Stock__c(Name = '9910273',Payment_Branch_Number__c = '12341234', Branch_number__c= '12341234');
        insert objStock;
        Stock__c objStock1 = new Stock__c(Name = '2739910',Payment_Branch_Number__c = '1224', Branch_number__c= '12341234');
        insert objStock1;
        Stock__c objStock2 = new Stock__c(Name = '1099732',Payment_Branch_Number__c = '12341234', Branch_number__c= '1223');
        insert objStock2;
        
        Branch__c objBranch = new Branch__c(Name = 'Test Branch1',Phone__c='1230123011',
                                            Branch_Number__c ='12341234');
        Branch__c objBranch1 = new Branch__c(Name = 'Test Branch12',Phone__c='1239012341',
                                            Branch_Number__c ='1223');
        Branch__c objBranch2 = new Branch__c(Name = 'Test Branch12',Phone__c='1239012344',
                                            Branch_Number__c ='1224');
        insert objBranch;
        
        Test.startTest();
        StockBranchNameUpdate objStoBraNameUpd = new StockBranchNameUpdate();
        database.executeBatch(objStoBraNameUpd);
        Test.stopTest();
    }
}