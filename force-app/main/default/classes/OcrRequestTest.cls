@isTest
private class OcrRequestTest {

  @testSetup static void setup() {
    OCR_Send_Log__c logRec = new OCR_Send_Log__c();
    logRec.ContentVersionId__c = '06855000001Ns4BAAS';
    logRec.Title__c            = 'TEST LOG REC';
    insert logRec;

    String tS    = 'Test Blob';
    Blob   tb    = Blob.valueof(tS);
    String tb64  = EncodingUtil.base64Encode(tb);
    
    ContentVersion cvRec = new ContentVersion();
    cvRec.Title             = 'TEST CV REC';
    cvRec.PathOnClient      = '/Test.pdf';
    cvRec.VersionData       = Blob.valueof(tb64);
    insert cvRec;
  }

  private class RestMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      // Create a fake response
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody('{"example":"test"}');
      res.setStatusCode(200);
      return res;
    }
  }

  @isTest
  static void testRest() {
    String logId,contentVersionId;
    List<OCR_Send_Log__c> sendList = [SELECT Id,ContentVersionId__c,Title__c FROM OCR_Send_Log__c WHERE Title__c = 'TEST LOG REC' Limit 1];
    OCR_Send_Log__c logRec = sendList[0]; 
    List<ContentVersion> cvList = [SELECT ContentDocumentId,Id,Title,VersionData FROM ContentVersion WHERE Title = 'TEST CV REC' Limit 1];
    ContentVersion cvRec = cvList[0];
    logId            = logRec.Id;  // logId and contentVersionId are not coupled here, but they are in reality.  Not an issue for testing.
    contentVersionId = cvRec.Id;
    Test.setMock(HttpCalloutMock.class, new RestMock());  
    Test.startTest(); 
    OcrRequest.callOcr(logId,contentVersionId);
    Test.stopTest();
  }

}