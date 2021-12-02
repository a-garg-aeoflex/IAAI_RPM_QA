({
    doInit : function(cmp, event) {
         cmp.set("v.myRecordId", cmp.get("v.recordId"));
     },
    handleUploadFinished: function (cmp, event) {
        // Get the list of uploaded files
		var uploadedFiles = event.getParam("files");
        console.log("Files uploaded : " + uploadedFiles[0].documentId);
        var action = cmp.get("c.updateContentVersion");
        console.log("test 1");
        action.setParams({
            "accountId" : cmp.get("v.recordId"),
            "documentId": uploadedFiles[0].documentId
        });
        action.setCallback(this, function(response) {
            console.log("test 1");
             var state = response.getState();
            console.log(' callback status '+state);
			 if (state === "SUCCESS") {  
                 console.log("content version is updated");
                  $A.get('e.force:refreshView').fire()
                  $A.get("e.force:closeQuickAction").fire();
                 
             }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
    });
     $A.enqueueAction(action);
    }
})