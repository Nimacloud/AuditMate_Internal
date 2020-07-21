@IsTest (SeeAllData=true)
public without sharing class InvoiceViewerControllerTest {

  @IsTest public static void Test1() {
    List<ContentVersion> testList = [SELECT Id FROM ContentVersion WHERE FileType = 'JSON' AND ContentSize > 40000 ORDER BY LastModifiedDate DESC NULLS LAST LIMIT 2];
    ContentVersion testRec = testList[0];
   
    String testDocId = InvoiceViewerController.getPdfDocId(testRec.Id);
    System.debug('testDocId');
    System.debug(testDocId);
    System.assertNotEquals(testDocId,null,'Test data is not empty');
  }

}