/*********************************************************************
@ Description: This class is used to store the response of user      *
@			   subcriptions API										 *
@ CreatedDate: 27/Jan/2021											 *
*********************************************************************/

public class UserSubscritionWrapper {
    
    public class Payment {
		public String ccId;
		public String ppId;
		public String paymentMethods;
		public Double amount;
		public String paymentType;
	}

	public class User {
		public String buyerId;
	}

	public User user;
	public String subscriptionId;
	public String subscriptionName;
	public String subscribedDate;
	public string unSubscribedDate;
	public String renewalDate;
	public Payment payment;
	public String subscriptionStatus;
	public String pageSource;
	public String deviceType;
	public String fee_Type_Code;
	public String subscriptionCMSId;  
    
    

	
	public static List<UserSubscritionWrapper> parse(String json) {
		return (List<UserSubscritionWrapper>) System.JSON.deserialize(json, List<UserSubscritionWrapper>.class);
	}

}