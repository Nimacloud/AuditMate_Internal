global class OcrRequest {

  public static HttpResponse getOcrResponse(Blob pdfBlob) {

    List<OCR_Api_Details__mdt> ocrDetails = [Select Endpoint__c, Apikey__c From OCR_Api_Details__mdt LIMIT 1];
    OCR_Api_Details__mdt ocrDetail = ocrDetails[0];
    String endpoint,apiKey;
    endpoint = ocrDetail.Endpoint__c;
    apiKey   = ocrDetail.Apikey__c;

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
    } catch (CalloutException coEx) {
      System.debug('Callout failed');
    }
    return res;
  }  

  @future (callout=true)
  public static void callOcr(Id logId, String contentVersionId) {
    System.debug('OcrRequest.callOcr()');
    String startTime = 'Start ' + datetime.now().format('yyyy.MM.dd HH:mm:ss z');

    List<ContentVersion> pdfList =  [SELECT Checksum,ContentDocumentId,ContentSize,Id,Title,VersionData FROM ContentVersion WHERE Id = :contentVersionId LIMIT 1];
    Blob   pdfBlob  = pdfList[0].VersionData;
    String inputFileName  = pdfList[0].Title;
    String outputFileName = inputFileName.substringBefore('.') + '.json';

    HTTPResponse res = OcrRequest.getOcrResponse(pdfBlob);
    if(res.getStatusCode() == 200) {
      String endTime    = 'End ' + datetime.now().format('yyyy.MM.dd HH:mm:ss z');
      String output     = res.getBody();
      String status     = res.getStatus();
      String statusCode = res.getStatusCode().format();
      String escaped    = output.escapeHtml4();
      Blob outputBlob   = Blob.valueOf(escaped);
      String output64   = EncodingUtil.base64Encode(outputBlob);
      
      System.System.debug('Status: ' + status + ' Code: ' + statusCode);
  
      List<ContentVersion>      cvList  = new List<ContentVersion>();
      List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
  
      ContentVersion tempContentInsert = new ContentVersion();
      tempContentInsert.Title          = outputFileName;
      tempContentInsert.VersionData    = Blob.valueof(output64);
      tempContentInsert.PathOnClient   = '/' + outputFileName;
      cvList.add(tempContentInsert);
  
      try {
        insert cvList;
        System.debug('Inserted ContentVersion');
        List<ContentVersion> cvList2 = [select id, ContentDocumentId from ContentVersion WHERE Id in :cvList];
        ContentDocumentLink cl = new ContentDocumentLink();
        cl.ContentDocumentId = cvList2[0].ContentDocumentId;
        cl.LinkedEntityId    = logId;
        cl.ShareType         = 'V';
        cl.Visibility        = 'AllUsers';
        cdlList.add(cl);
        try {
          insert cdlList;
          System.debug('Inserted ContentDocumentLink');
        } catch(DmlException e) {
  
          System.debug(e); 
        }
      } catch (DmlException e) {
        System.debug(e);
      }
    } else {
      System.debug('Callout returned error');  
    }
  }

}