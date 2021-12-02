public class PGN_PageInfo {
	
    @AuraEnabled
    public Integer currentPageNumber {get;set;}
    
    @AuraEnabled
    public Integer totalPages {get;set;}
    
    @AuraEnabled
    public List<Integer> pageCounter {get;set;}
    
    @AuraEnabled
    public Integer pageDiff {get;set;}
    

}