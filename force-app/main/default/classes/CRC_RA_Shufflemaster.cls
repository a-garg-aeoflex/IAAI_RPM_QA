public with sharing class CRC_RA_Shufflemaster {

    public static list<Case> getOrderedRA(){
        List<Case> listRA = new List<Case>();
        listRA = [SELECT Id,CRC_Assignment_Date_Time__c,CRC_Assignment_Type__c, CRC_Mileage__c, CRC_Process_Status__c,CRC_Priority__c,
        CRC_Provider_SLA__c,Account.CRC_Provider_SLA__c,Status,Account.CRC_Same_Day__c, CRC_Release_Problem_Follow_Up_Datetime__c, Branch__c, Branch__r.Name, Stock__c, Stock__r.Name,CRC_Salvage_Provider__c, CRC_Salvage_Provider__r.Name,RecordTypeId From Case where isclosed = false and case.owner.Name = 'Priority Assignments'  order by CRC_Assignment_Date_Time__c];

        List<Case> listorderedCasefinal = new List<Case>();
        
        List<Case> listorderedRA0 = new List<Case>();
        List<Case> listorderedRA01 = new List<Case>();
        List<Case> listorderedRA1 = new List<Case>();
        List<Case> listorderedRA11 = new List<Case>();
        List<Case> listorderedRA2 = new List<Case>();
        List<Case> listorderedRA3 = new List<Case>();
        List<Case> listorderedRA4 = new List<Case>();
        List<Case> listorderedRA5 = new List<Case>();
        List<Case> listorderedRA6 = new List<Case>();
        List<Case> listorderedRA7 = new List<Case>();
        List<Case> listorderedRA8 = new List<Case>();
        List<Case> listorderedRA9 = new List<Case>();

        Id storageLocationRT =  Schema.SObjectType.Case.getRecordTypeInfosByName().get('CRC Storage Location').getRecordTypeId();
        Id residentialRT =  Schema.SObjectType.Case.getRecordTypeInfosByName().get('CRC Residential').getRecordTypeId();
        Integer recOrder = 1;
        for(Case objRA : listRA){
            
            Set<String> assignmentType = new Set<String>();
            if(objRA.CRC_Assignment_Type__c != null){
				assignmentType.addAll(objRA.CRC_Assignment_Type__c.split(';')); 
            }
            //Wait Release for 1 hour customers must be worked within 1 biz hour and no activity 	
			
            if(objRA.Status == 'Wait Release' &&  objRA.Account.CRC_Provider_SLA__c == '1 Hour' && objRA.recordTypeId == storageLocationRT){
                listorderedRA0.add(objRA); 
            }
            else if(objRA.Status == 'Wait Release' &&  objRA.Account.CRC_Provider_SLA__c == '1 Hour' && objRA.recordTypeId == residentialRT){
                listorderedRA01.add(objRA); 
            }//Wait Release for 2 hour customers must be worked within 2 biz hours
            else if(objRA.Status == 'Wait Release' && objRA.Account.CRC_Provider_SLA__c == '2 Hours' && objRA.recordTypeId == storageLocationRT){
                listorderedRA1.add(objRA); 
            }
            else if(objRA.Status == 'Wait Release' && objRA.Account.CRC_Provider_SLA__c == '2 Hours' && objRA.recordTypeId == residentialRT){
                listorderedRA11.add(objRA); 
            }//RP with VIC for same day customer(s) within 80 miles, no specific follow-up time
            else if( objRA.Status == 'Release Problem' && assignmentType.contains('VIC') && objRA.Account.CRC_Same_Day__c == true && objRA.CRC_Mileage__c <= 80 ){
                listorderedRA2.add(objRA); 
            }//RP without VIC for same day customer(s) within 80 miles, no specific follow-up time
            else if(objRA.Status == 'Release Problem' && !assignmentType.contains('VIC') && objRA.Account.CRC_Same_Day__c == true && objRA.CRC_Mileage__c <= 80){
                listorderedRA3.add(objRA); 
            }//Follow-up time remaining (least time left to most time left)with vic 
            else if(objRA.CRC_Release_Problem_Follow_Up_Datetime__c != null  && assignmentType.contains('VIC')){
                listorderedRA4.add(objRA); 
            }//Follow-up time remaining (least time left to most time left)(non vic)
            else if(objRA.CRC_Release_Problem_Follow_Up_Datetime__c != null  && !assignmentType.contains('VIC')){
                listorderedRA5.add(objRA); 
            }//All Others: storage locations(with vic)
            else if(objRA.recordTypeId == storageLocationRT  && assignmentType.contains('VIC') ){
                listorderedRA6.add(objRA); 
            }//All Others: storage locations non vic 
            else if(objRA.recordTypeId == storageLocationRT && !assignmentType.contains('VIC')){
                listorderedRA7.add(objRA); 
            }//All Others: residential locations with vic 
            else if(objRA.recordTypeId == residentialRT && assignmentType.contains('VIC') ){
               listorderedRA8.add(objRA); 
            }//All Others: residential locations non vic 
            else if(objRA.recordTypeId == residentialRT && !assignmentType.contains('VIC')){
               listorderedRA9.add(objRA); 
            }
            
        }
      
        Integer recO = 1;
        CRC_Sorting.ascending(listorderedRA0 , Case.CRC_Assignment_Date_Time__c);
        for(Case ra :listorderedRA0){
            if(ra.CRC_Priority__c != recO){
                ra.CRC_Priority__c = recO;
                listorderedCasefinal.add(ra);
            }
            recO++;
        }
        CRC_Sorting.ascending(listorderedRA01 , Case.CRC_Assignment_Date_Time__c);
        for(Case ra :listorderedRA01){
            if(ra.CRC_Priority__c != recO){
                ra.CRC_Priority__c = recO;
                listorderedCasefinal.add(ra);
            }
            recO++;
        }
        CRC_Sorting.ascending(listorderedRA1 , Case.CRC_Assignment_Date_Time__c);
        for(Case ra :listorderedRA1){
            if(ra.CRC_Priority__c != recO){
                ra.CRC_Priority__c = recO;
                listorderedCasefinal.add(ra);
            }
            recO++;
        }
        CRC_Sorting.ascending(listorderedRA11 , Case.CRC_Assignment_Date_Time__c);
        for(Case ra :listorderedRA11){
            if(ra.CRC_Priority__c != recO){
                ra.CRC_Priority__c = recO;
                listorderedCasefinal.add(ra);
            }
            recO++;
        }
        CRC_Sorting.ascending(listorderedRA2 , Case.CRC_Assignment_Date_Time__c);
        for(Case ra :listorderedRA2){
            if(ra.CRC_Priority__c != recO){
                ra.CRC_Priority__c = recO;
                listorderedCasefinal.add(ra);
            }
            recO++;
        }
        CRC_Sorting.ascending(listorderedRA3 , Case.CRC_Assignment_Date_Time__c);
        for(Case ra :listorderedRA3){
            if(ra.CRC_Priority__c != recO){
                ra.CRC_Priority__c = recO;
                listorderedCasefinal.add(ra);
            }
            recO++;
        }
        CRC_Sorting.ascending(listorderedRA4 , Case.CRC_Release_Problem_Follow_Up_Datetime__c);
        for(Case ra :listorderedRA4){
            if(ra.CRC_Priority__c != recO){
                ra.CRC_Priority__c = recO;
                listorderedCasefinal.add(ra);
            }
            recO++;
        }
        CRC_Sorting.ascending(listorderedRA5 , Case.CRC_Release_Problem_Follow_Up_Datetime__c);
        for(Case ra :listorderedRA5){
            if(ra.CRC_Priority__c != recO){
                ra.CRC_Priority__c = recO;
                listorderedCasefinal.add(ra);
            }
            recO++;
        }
        CRC_Sorting.ascending(listorderedRA6 , Case.CRC_Assignment_Date_Time__c);
        for(Case ra :listorderedRA6){
            if(ra.CRC_Priority__c != recO){
                ra.CRC_Priority__c = recO;
                listorderedCasefinal.add(ra);
            }
            recO++;
        }
        CRC_Sorting.ascending(listorderedRA7 , Case.CRC_Assignment_Date_Time__c);
        for(Case ra :listorderedRA7){
            if(ra.CRC_Priority__c != recO){
                ra.CRC_Priority__c = recO;
                listorderedCasefinal.add(ra);
            }
            recO++;
        }
        CRC_Sorting.ascending(listorderedRA8 , Case.CRC_Assignment_Date_Time__c);
        for(Case ra :listorderedRA8){
            if(ra.CRC_Priority__c != recO){
                ra.CRC_Priority__c = recO;
                listorderedCasefinal.add(ra);
            }
            recO++;
        }
        CRC_Sorting.ascending(listorderedRA9 , Case.CRC_Assignment_Date_Time__c);
        for(Case ra :listorderedRA9){
            if(ra.CRC_Priority__c != recO){
                ra.CRC_Priority__c = recO;
                listorderedCasefinal.add(ra);
            }
            recO++;
        }
        
        return listorderedCasefinal;
     }
    
    

}