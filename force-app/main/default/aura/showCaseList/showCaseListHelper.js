({
    fetchData: function (cmp, event) {
        
        //cmp.set('v.AccountId','0015600000LkFkKAAV')
        //cmp.set('v.ContactId','0035600000RAjOHAA1')
       
        var action = cmp.get("c.getCaseList");
    
    	this.showSpinner(cmp, event);
        action.setParams({"AccId":cmp.get("v.AccountId"),
                         "ContactId":cmp.get("v.ContactId")})
        action.setCallback(this, $A.getCallback(function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());  // <-- Works as expected...
                cmp.set("v.caseList", response.getReturnValue());
            }
            else {
                helper.counselLogErrors(response.getError());
            }
            if( cmp.get("v.caseList").length === 0){
                var datatable = cmp.find("datatable");
        $A.util.removeClass(datatable, "slds-show");
            $A.util.addClass(datatable, "slds-hide");
            var Nodatatable = cmp.find("Nodatatable");
        $A.util.removeClass(Nodatatable, "slds-hide");
            $A.util.addClass(Nodatatable, "slds-show");
            }else{
                var datatable = cmp.find("datatable");
        	$A.util.removeClass(datatable, "slds-hide");
            $A.util.addClass(datatable, "slds-show");
            }
            this.hideSpinner(cmp, event);
        }));
        $A.enqueueAction(action);
	},
    
    getRowIndex: function(rows, row) {
        var rowIndex = -1;
        rows.some(function(current, i) {
            if (current.id === row.id) {
                rowIndex = i;
                return true;
            }
        });
        return rowIndex;
    },
    removeBook: function (cmp, row) {
        var rows = cmp.get('v.rawData');
        var rowIndex = this.getRowIndex(rows, row);

        rows.splice(rowIndex, 1);
        this.updateBooks(cmp);
    },
    publishBook: function (cmp, row) {
        var rows = cmp.get('v.rawData');
        var rowIndex = this.getRowIndex(rows, row);

        rows[rowIndex].isPublished = true;
        rows[rowIndex].published = 'Published';
        this.updateBooks(cmp);
    },
    unpublishBook: function (cmp, row) {
        var rows = cmp.get('v.rawData');
        var rowIndex = this.getRowIndex(rows, row);

        rows[rowIndex].isPublished = false;
        rows[rowIndex].published = 'Unpublished';
        this.updateBooks(cmp);
    },
    updateBooks: function (cmp) {
        var rows = cmp.get('v.rawData');
        var activeFilter = cmp.get('v.activeFilter');
        var filteredRows = rows;

        if (activeFilter !== 'all') {
            filteredRows = rows.filter(function (row) {
                return (activeFilter === 'show_published' && row.isPublished) ||
                    (activeFilter === 'show_unpublished' && !row.isPublished);
            });
        }

        cmp.set('v.data', filteredRows);
    },
    getRowActions: function (cmp, row, doneCallback) {
        var actions = [{
            'label': 'Show Details',
            'iconName': 'utility:zoomin',
            'name': 'show_details'
        }];
        var deleteAction = {
            'label': 'Delete',
            'iconName': 'utility:delete',
            'name': 'delete'
        };

        if (row.isPublished) {
            actions.push({
                'label': 'Unpublish',
                'iconName': 'utility:ban',
                'name': 'unpublish'
            });
            deleteAction.disabled = 'true';
        } else {
            actions.push({
                'label': 'Publish',
                'iconName': 'utility:approval',
                'name': 'publish'
            });
        }

        actions.push(deleteAction);

        // simulate a trip to the server
        setTimeout($A.getCallback(function () {
            doneCallback(actions);
        }), 200);
    },
     showSpinner: function (cmp, event) {
        var spinner = cmp.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
     
    hideSpinner: function (cmp, event) {
        var spinner = cmp.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    }
});