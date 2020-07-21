global class OcrRequest2 {

  public static HttpResponse getOcrResponse(String endpoint, String apiKey, Blob pdfBlob) {
    HTTPResponse res;
    HttpRequest req = new HttpRequest();
    req.setEndpoint(endpoint); // e.g. https://api.cloudmersive.com/ocr/pdf/to/lines-with-location
    req.setMethod('POST');
    req.setHeader('Apikey', apiKey);
    req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
    req.setHeader('preprocessing', 'auto');
    req.setBodyAsblob(pdfBlob);
    req.setTimeout(120000);
    Http http = new Http();
    try {
      res = http.send(req);
    } catch (System.CalloutException coEx) {
      System.debug(coEx);
      System.debug(coEx.getMessage());
      System.debug(coEx.getTypeName());
      System.debug('Callout failed');
    }
    return res;
  }  

}