@IsTest
public class UserSubscritionWrapper_Test {
	
	static testMethod void testParse() {
		String json = '[{\"user\":{\"buyerId\":\"9327\"},\"subscriptionId\":\"101\",\"subscriptionName\":\"Tire Thread Depth\",\"subscribedDate\":\"2020-11-19T23:22:02.51825+00:00\",\"unSubscribedDate\":null,\"renewalDate\":\"2020-12-19T23:22:02.51825+00:00\",\"payment\":{\"ccId\":\"223492\",\"ppId\":\"\",\"paymentMethods\":\"CC\",\"amount\":2501.0,\"paymentType\":\"Regular\"},\"subscriptionStatus\":\"RenewalPending\",\"pageSource\":\"RenewalPPHandler\",\"deviceType\":\"MobileBrowser\",\"fee_Type_Code\":null,\"subscriptionCMSId\":\"123ljkupdate100\"}]';
		List<UserSubscritionWrapper> obj = UserSubscritionWrapper.parse(json);
		System.assert(obj != null);
	}
}