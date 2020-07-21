@isTest (SeeAllData=true)
public without sharing class OcrBatchProcessHelperTest {

  @isTest
  public static void test1() {

  // launch OcrBatchProcessHelper 10 seconds from now.
  Datetime newDatetime = DateTime.now().addSeconds(10);
  String sch = String.valueOf(newDatetime.second()) + ' ' + 
               String.valueOf(newDatetime.minute()) + ' ' + 
               String.valueOf(newDatetime.hour())   + ' ' + 
               String.valueOf(newDatetime.day())    + ' ' + 
               String.valueOf(newDatetime.month())  + ' ? ' + 
               String.valueOf(newDatetime.year());
  OcrBatchProcessHelper obph = new OcrBatchProcessHelper();
  
  test.starttest();
  String jobID = system.schedule('OcrBatchProcessHelper to run once at ' + sch, sch, obph);
  test.stopTest();

  }

}