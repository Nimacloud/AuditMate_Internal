@isTest (SeeAllData=true)
public without sharing class SchindlerOcrStagingTest {

  @isTest
  public static void test1() {
    String result;
    List<OCR_Send_Log__c> unstagedList = [SELECT Id,JsonVersionId__c FROM OCR_Send_Log__c WHERE Status__c = 'Sent' AND Staged__c = false LIMIT 1];
    if(unstagedList.size() > 0) {
      OCR_Send_Log__c logRec = unstagedList[0];
      SchindlerOcrStaging.sendEmail('Test for code coverage');
      result = SchindlerOcrStaging.launch(logRec.JsonVersionId__c);
      System.debug(result);
    }
  }

}