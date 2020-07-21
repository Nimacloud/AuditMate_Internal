public with sharing class GoogleDirectoryController {

    public static final String GROUP_MEMBER_SCOPE = 'https://www.googleapis.com/auth/admin.directory.group.member';
    public static final String GROUPS_SCOPE = 'https://www.googleapis.com/auth/admin.directory.group';

    public static final String CLIENT_ID = Google_Settings__c.getOrgDefaults().Client_Id__c;
    public static final String CLIENT_SECRET = Google_Settings__c.getOrgDefaults().Client_Secret__c;
    public static final String REDIRECT_URI = Google_Settings__c.getOrgDefaults().Redirect_Uri__c;

    public void init() {

        String code = ApexPages.currentPage().getParameters().get('code');

        if (code != null) {

            String body = 'code='     + EncodingUtil.urlEncode(code , 'UTF-8') +
                    '&client_id='     + EncodingUtil.urlEncode(CLIENT_ID, 'UTF-8') +
                    '&client_secret=' + EncodingUtil.urlEncode(CLIENT_SECRET, 'UTF-8') +
                    '&redirect_uri='  + EncodingUtil.urlEncode(REDIRECT_URI, 'UTF-8') +
                    '&grant_type=authorization_code';

            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://www.googleapis.com/oauth2/v4/token');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            req.setBody(body);

            HttpResponse res = (new Http()).send(req);

            Map<String,Object> response = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());

            if (response.get('access_token') != null && response.get('refresh_token') != null) {
                Google_Settings__c settings = Google_Settings__c.getOrgDefaults();
                settings.Access_Token__c  = String.valueOf(response.get('access_token'));
                settings.Refresh_Token__c = String.valueOf(response.get('refresh_token'));
                upsert settings;
            }
        }
    }


    public String getClientId() {
        return CLIENT_ID;
    }


    public String getRedirectUri() {
        return REDIRECT_URI;
    }

    public String getScopes() {
        return String.join(new String[] {GROUPS_SCOPE, GROUP_MEMBER_SCOPE}, ' ');
    }

    // @future(callout=true)
    public static String createEmailGroup(Id accountId, String accountEmail) {

        String message = null;

        if (Test.isRunningTest()) {
            // return null;
        }

        Google_Settings__c settings = Google_Settings__c.getOrgDefaults();
        settings.Access_Token__c = refreshToken(settings.Refresh_Token__c);

        if (settings.Access_Token__c != null) {

            Map<String, String> data = new Map<String, String>();
            data.put('email', accountEmail);

            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://www.googleapis.com/admin/directory/v1/groups');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', 'Bearer ' + settings.Access_Token__c);
            req.setBody(JSON.serialize(data));

            HttpResponse res = (new Http()).send(req);
            String body = res.getBody();

            if (res.getStatusCode() == 200) {

                Map<String, Object> bodyJson = (Map<String, Object>) JSON.deserializeUntyped(body);
                String groupKey = (String) bodyJson.get('id');

                createEmailGroupMember(groupKey, settings.Access_Token__c);
                update new Account(Id = accountId, Auditmate_Email__c = accountEmail);
            }
            else {
                message = body;
            }

            upsert settings;
        }
        else {
            System.assert(false, 'Error while trying to refresh Access Token');
        }

        return message;
    }

    public static void createEmailGroupMember(String groupKey, String accessToken) {

        Google_Settings__c settings = Google_Settings__c.getOrgDefaults();
        settings.Access_Token__c = accessToken;

        if (settings.Access_Token__c != null) {

            Map<String, String> requestBody = new Map<String, String>();
            requestBody.put('email', 'support@auditmate.com');
            requestBody.put('role', 'MEMBER');

            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://www.googleapis.com/admin/directory/v1/groups/' + groupKey + '/members');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', 'Bearer ' + settings.Access_Token__c);
            req.setBody(JSON.serialize(requestBody));

            HttpResponse res = (new Http()).send(req);
        }
        else {
            System.assert(false, 'Error while trying to refresh Access Token');
        }
    }


    private static String refreshToken(String refreshToken) {

        String body =
                'client_id='      + EncodingUtil.urlEncode(CLIENT_ID, 'UTF-8') +
                '&client_secret=' + EncodingUtil.urlEncode(CLIENT_SECRET, 'UTF-8') +
                '&refresh_token=' + EncodingUtil.urlEncode(refreshToken, 'UTF-8') +
                '&grant_type=refresh_token';

        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://www.googleapis.com/oauth2/v4/token');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody(body);

        HttpResponse res = (new Http()).send(req);

        Map<String,Object> response = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());

        return String.valueOf(response.get('access_token'));
    }

}