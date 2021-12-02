({
	doInit: function (component, event, helper) {
		var action = component.get('c.getProfileName');
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === 'SUCCESS') {
				var retunredValue = response.getReturnValue();
				if (retunredValue != 'CRC Release Agent') {
					component.set('v.controlledRefresh', true);
				}

				helper.toggleAutoRefresh(component);
			}
		});
		$A.enqueueAction(action);
	},
	autoRefresh: function (component, event, helper) {
		helper.toggleAutoRefresh(component);
	}
});