public with sharing class PortalLoginController {

    @AuraEnabled
    public static String login(String username, String password) {

        String startUrl = '/';
        
        PageReference result = Site.login(username, password, startUrl);
        
        return result != null ? result.getUrl() : null;
    }    
}