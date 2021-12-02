({
    init : function(component, event, helper) {
        console.log('init');
        if(component.get('v.send_relay_state') === false){
            helper.saveStartURL(component,event);
        }else{
            helper.saveAttributesAndRedirect(component,event);
        }       
    }
})