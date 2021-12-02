({
    doInit:function(component,event,helper){
         var opt =[]; 
        opt.push({label:'All',isChecked:false});
        var action = component.get("c.getPickListValuesIntoList");
        action.setCallback(this, function(result) {
            if (component.isValid() && result.getState() === "SUCCESS"){
                var resultData = result.getReturnValue(); 
                for(var i = 0;i<resultData.length;i++){
                opt.push({label:resultData[i],isChecked:false});
                }
                component.set("v.options",opt);
              
            }
        });
        $A.enqueueAction(action);
        //component.set("v.options",opt);
        helper.selectOptionHelper(component,'All','true');       
    },
    openDropdown:function(component,event,helper){
        $A.util.addClass(component.find('dropdown'),'slds-is-open');
        $A.util.removeClass(component.find('dropdown'),'slds-is-close');
    },
    closeDropDown:function(component,event,helper){
        $A.util.addClass(component.find('dropdown'),'slds-is-close');
        $A.util.removeClass(component.find('dropdown'),'slds-is-open');
    },
    selectOption:function(component,event,helper){        
        var label = event.currentTarget.id.split("#BP#")[0];
        var isCheck = event.currentTarget.id.split("#BP#")[1];
        helper.selectOptionHelper(component,label,isCheck);
    }
})