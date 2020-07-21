@isTest (SeeAllData=true)
public without sharing class OcrBatchHelperTest {

@isTest
public static void test1() {

  // launch OcrBatchHelper 10 seconds from now.
  Datetime newDatetime = DateTime.now().addSeconds(10);
  String sch = String.valueOf(newDatetime.second()) + ' ' + 
               String.valueOf(newDatetime.minute()) + ' ' + 
               String.valueOf(newDatetime.hour())   + ' ' + 
               String.valueOf(newDatetime.day())    + ' ' + 
               String.valueOf(newDatetime.month())  + ' ? ' + 
               String.valueOf(newDatetime.year());
  OcrBatchHelper obh = new OcrBatchHelper();
  
  test.starttest();
  // Need OCR_LOG unsent record.
  String jobID = system.schedule('OcrBatchHelper to run once at ' + sch, sch, obh);
  test.stopTest();

  }

}