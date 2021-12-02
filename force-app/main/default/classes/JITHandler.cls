/**
* @author LevDigital
* @date 2020
*
* @group Contact
* @group-content ../../ApexDocContent/User.htm
*
* @description JITHandler customJitHandler that will throw an error the single signon error page if guest user but logged into Auction Center
*/
global with sharing class JITHandler implements Auth.SamlJitHandler {
    private class JitException extends Exception{}
    private void handleUser(boolean create, User u, Map<String, String> attributes,
        String federationIdentifier, boolean isStandard) {
        if(!create) {
            for(String attribute:attributes.keySet()){
                 if(attribute == 'Email'){
                    u.Email = attributes.get(attribute);
                }
                if(attribute == 'PhoneNumber'){
                    u.Phone= attributes.get(attribute);
                }
            }
            System.debug('user: ' + u);
            update u;
            System.debug('aft user: ' + u);
        }else{
            //throw new JitException('Name:');
        }
    }
    private void handleJit(boolean create, User u, Id samlSsoProviderId, Id communityId, Id portalId,
        String federationIdentifier, Map<String, String> attributes, String assertion) {
        if(communityId != null || portalId != null) {
            handleUser(create, u, attributes, federationIdentifier, false);
        } else {
            handleUser(create, u, attributes, federationIdentifier, true);
        }
    }
    global User createUser(Id samlSsoProviderId, Id communityId, Id portalId,
        String federationIdentifier, Map<String, String> attributes, String assertion) {
        string language = '';
        if(attributes.containsKey('LanguagePreference')){
            language = attributes.get('LanguagePreference');
        }
        string err = '&language=' + language + '&info=' + Utils.encrypt(JSON.serialize(attributes));        
        User u = new User( TimeZoneSidKey = err);
        return u;
    
    }

    global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId,
        String federationIdentifier, Map<String, String> attributes, String assertion) {
        User u = [SELECT Id, FirstName, ContactId FROM User WHERE Id=:userId];
 
        handleJit(false, u, samlSsoProviderId, communityId, portalId,
            federationIdentifier, attributes, assertion);
    }
    private class custException extends Exception{}
}