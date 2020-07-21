@isTest (SeeAllData=true)
private class OcrSchedulerTest {

  // This proved to be too hard to figure out how to use with test data, so it needs an email with an attachment that has not been sent to OCR. 
  @isTest
  private static void test1() {
    List<OCR_Send_Log__c> sendList = [SELECT ContentVersionId__c,Id,Resend__c,Title__c FROM OCR_Send_Log__c WHERE Title__C LIKE '%Pdf' LIMIT 1];
  
    if(sendList.size() == 1) {
      sendList[0].Resend__c = true; // Ensure a file can be sent.
      Update sendList;
      OcrScheduler.OcrSchedule(); 
    }
  }

}