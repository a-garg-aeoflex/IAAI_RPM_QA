({
    init: function (cmp, event, helper) {
        
            cmp.set('v.columns', [
               
                {label: 'Case Number', fieldName: 'CaseNumber', type: 'text'},
                {label: 'Subject', fieldName: 'Subject', type: 'text'},
                {label: 'Description', fieldName: 'Description', type: 'text'},
               
                
            ]);
                
            helper.fetchData(cmp, event);
            
	},  
     
 	handleSelect : function(cmp, event, helper) {
    
    	var selectedRows = event.getParam('selectedRows'); 
    	console.log(selectedRows[0].Id);
    	 var cmpCaseEvent = cmp.getEvent("CaseDetailRec"); 
    	 cmpCaseEvent.setParams({"selsObjRec" : selectedRows[0] }); 
        cmpCaseEvent.setParams({"selectedCaseId" : selectedRows[0].Id }); 
    	console.log("Value set");
		cmpCaseEvent.fire(); 
    	
    
    
	},
    handleHeaderAction: function (cmp, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');

        switch (action.name) {
            case 'show_details':
                alert('Showing Details: ' + JSON.stringify(row));
                break;
            case 'delete':
                helper.removeBook(cmp, row);
                break;
        }
    }
    
});