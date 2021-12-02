({
	navigate : function(component, event, helper) {
    var address = '/';
    var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
      "url": address,
      "isredirect" :false
    });
    urlEvent.fire();
  }

})