public with sharing class OCRClient {

    // private static final String ENDPOINT = 'https://api.cloudmersive.com/ocr/pdf/toText';
    // private static final String APIKEY = '7528cec8-97f3-42ea-a166-11a0481440ec';
    private static final String ENDPOINT = 'https://api-na-ca1-premium.cloudmersive.com/ocr/pdf/to/lines-with-location';

    private static final String APIKEY = 'd79848ae-4928-475e-8ede-b9c46046ccd8';

    private HttpRequest request;

    public OCRClient() {

        request = new HttpRequest();
        request.setMethod('POST');
        request.setHeader('apikey', APIKEY);
        request.setEndpoint(ENDPOINT);
        request.setTimeout(120000);
        request.setHeader('Content-Type', 'multipart/form-data');
    }

    public HttpResponse send(Blob body) {

        request.setBodyAsBlob(body);
        return (new Http()).send(request);
    }

}