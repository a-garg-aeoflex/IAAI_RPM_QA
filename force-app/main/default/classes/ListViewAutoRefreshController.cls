public class ListViewAutoRefreshController {
	@auraEnabled
	public static String getProfileName() {
		String profileName = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].Profile.Name;
		return profileName;
	}
}