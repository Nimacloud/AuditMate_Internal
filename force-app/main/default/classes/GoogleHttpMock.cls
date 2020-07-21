public with sharing class GoogleHttpMock implements HttpCalloutMock {

    public HttpResponse respond(HttpRequest request) {

        Map<String, String> body = new Map<String, String>();
        body.put('id', '732648');
        body.put('email', 'test@test.com');
        body.put('access_token', '1234');
        body.put('refresh_token', '1234');

        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setBody(JSON.serialize(body));

        return response;
    }
}