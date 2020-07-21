@isTest (SeeAllData=true)
public without sharing class OcrBatchStagingHelperTest {

@isTest
public static void test1() {

  // launch OcrBatchStagingHelper 10 seconds from now.
  Datetime newDatetime = DateTime.now().addSeconds(10);
  String sch = String.valueOf(newDatetime.second()) + ' ' + 
               String.valueOf(newDatetime.minute()) + ' ' + 
               String.valueOf(newDatetime.hour())   + ' ' + 
               String.valueOf(newDatetime.day())    + ' ' + 
               String.valueOf(newDatetime.month())  + ' ? ' + 
               String.valueOf(newDatetime.year());
  OcrBatchStagingHelper obsh = new OcrBatchStagingHelper();
  
  test.starttest();
  // Need OCR_LOG sent unstaged record.
  String jobID = system.schedule('OcrBatchStagingHelper to run once at ' + sch, sch, obsh);
  test.stopTest();

  }

}