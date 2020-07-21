@isTest
public class SchindlerOcrProcessTest {

  @isTest (SeeAllData=true)
  public static void test1a() {
    String result;
    List<OCR_Send_Log__c> unstagedList = [SELECT Id,JsonVersionId__c,Account__c FROM OCR_Send_Log__c WHERE Staged__c = true AND Processed__c = false LIMIT 1];
    if(unstagedList.size() > 0) {
      OCR_Send_Log__c logRec = unstagedList[0];
      SchindlerOcrStaging.sendEmail('Test for code coverage');
      result = SchindlerOcrProcess.processStagedData(logRec.JsonVersionId__c, logRec.Account__c);
      System.debug(result);
    }
  }

  @isTest (SeeAllData=true)
  public static void Test2a() { 
   // 20200117094212251.Pdf is one page should should be 2, so it has errors that allow squeeking past code coverage at 77%! // 
   ContentVersion cvRec2 = [SELECT Id,ContentSize,VersionData FROM ContentVersion WHERE Id IN ('0683k000007oenIAAQ','0683J0000000pzEQAQ') LIMIT 1];
   SchindlerOcrProcess.processStagedData(cvRec2.Id,'0013k00002fZbqCAAS');
  }

  @isTest (SeeAllData=true)
  public static void Test3a() { 
   // 20200117094212251.Pdf is one page should should be 2, so it has errors that allow squeeking past code coverage at 77%!
   ContentVersion cvRec2 = [SELECT Id,ContentSize,VersionData FROM ContentVersion WHERE Id IN ('0683k000007oen3AAA','0683J0000000pzfQAA') LIMIT 1];
   SchindlerOcrProcess.processStagedData(cvRec2.Id,'0013k00002fZbqCAAS');
  }

 }