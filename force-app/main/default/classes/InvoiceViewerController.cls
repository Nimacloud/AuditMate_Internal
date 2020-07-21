public without sharing class InvoiceViewerController {

  @AuraEnabled (cacheable=true) 
  public static String getPdfDocId(String contentVersionId) {
    String jsonTitle,pdfTitle,pdfDocId,pdfContentVersionId;

    List<ContentDocument>     jsonDocList = [SELECT Id,Title FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersionId];
    ContentDocument jsonDoc = jsonDocList[0];
    jsonTitle = jsonDoc.Title.toLowerCase();
    pdfTitle  = jsonTitle.replace('.json','.pdf');
System.debug('jsonTitle: ' + jsonTitle);
System.debug('pdfTitle: ' + pdfTitle);
    List<ContentDocument>    pdfDocList = [SELECT Id,Title,LatestPublishedVersionId,LastModifiedDate FROM ContentDocument WHERE Title = :pdfTitle ORDER BY LastModifiedDate DESC NULLS LAST];
    ContentDocument pdfDoc = pdfDocList[0];

    pdfContentVersionId = pdfDoc.LatestPublishedVersionId;
System.debug('pdfContentVersionId ' + pdfContentVersionId);
    List<ContentDocument> finalList = [SELECT Id,LastModifiedDate FROM ContentDocument WHERE LatestPublishedVersionId = :pdfContentVersionId ORDER BY LastModifiedDate DESC NULLS LAST];
pdfDocId = finalList[0].Id;
System.debug('pdfDocId ' + pdfDocId);

    return pdfDocId;
  }

}