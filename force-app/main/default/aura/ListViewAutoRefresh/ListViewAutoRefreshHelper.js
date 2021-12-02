({
	toggleAutoRefresh: function (component) {
		let refreshing = component.get('v.refreshing');

		if (!refreshing) {
			const refreshInterval = component.get('v.refreshInterval');
			const intervalId = window.setInterval(() => {
				this.refreshListView(component);
			}, refreshInterval * 1000);
			component.set('v.intervalId', intervalId);
			component.set('v.refreshing', true);
		} else {
			const intervalId = component.get('v.intervalId');
			window.clearInterval(intervalId);
			component.set('v.intervalId', null);
			component.set('v.refreshing', false);
		}
	},

	refreshListView: function (component) {
		let navigationItemAPI = component.find('navigationItemAPI');
		navigationItemAPI.getSelectedNavigationItem().then((response) => {
			// Only refresh if viewing an object-page
			const objPage = 'standard__objectPage';
			if (
				response.pageReference &&
				response.pageReference.type === objPage &&
				response.pageReference.attributes.objectApiName == 'Case'
			) {
				// Do the refresh
				navigationItemAPI.refreshNavigationItem().catch(function (error) {
					console.log('Error in auto-refresh', error);
				});
			}
		});
	}
});