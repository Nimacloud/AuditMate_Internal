@IsTest(SeeAllData=true)
public without sharing class InvoiceFixerControllerTest {

  /*
  @testSetup static void setup() {

    Schindler_Invoice_History__c newRec   = new Schindler_Invoice_History__c();
    newRec.Bill_To__c	         = 'HEALTH SYSTEMS ACCOUNTS PAYABLE-CONTRACTS 190 E BANNOCK ST BOISE ID 83712-6241';
    newRec.Billing_Id__c       = '5000043237';
    newRec.Contract__c         = '4100086022';
    newRec.ContentVersionId__c = 'This is a test';
    newRec.Description__c      = '01/12/2019 SERVICE CALL ON ELEVATOR 71 WAS REQUESTED BY TED. CUSTOMER REPORTED: CODE 1 ENTRAPMENT ON MAIN FLOOR WITH PASSENGERS. TECHNICIAN REPORTED: FOUND FATER AND TWO SONS STUCK. FOUND TRIPPED GOVERNER SWITCH. RESET AND CHECKED OPERATION. REFER TO NOTIFICATION 62899351';
    newRec.Duns_Number__c      = '09 480 9993';
    newRec.Expenses__c         = 68.64;
    newRec.Fax__c              = '208 577 5525';
    newRec.Federal_Tax_Id__c   = '09 480 9993';
    newRec.Field_Contact__c    = 'Charles Pogue';
    newRec.Invoice_Date__c     = '2/3/2019';
    newRec.Invoice_Number__c   = '7152874823';
    newRec.Invoice_Total__c    = 537.04;
    newRec.Labor__c            = 468.4;
    newRec.Local_Office__c     = 'Schindler Elevator Corporation 743 MCGREGOR CT STE 140 BOISE ID 83705-5225';
    newRec.Notification__c     = '62899351';
    newRec.Order_No__c         = '5154057331';
    newRec.Order_Type__c       = 'Z1TM';
    newRec.Payer__c            = 'ST LUKE\'S HEALTH SYSTEM 190 E BANNOCK ST BOISE ID 83712-6241';
    newRec.PdfFilename__c      = '12345.pdf';
    newRec.Remit_To__c         = 'Schindler Elevator Corporation';
    newRec.Sales_Contact__c    = 'Diane Rawson';
    newRec.Service_Location__c = 'ST LUKES MERIDIAN MEDICAL CENTER 1102.5336. PW1 10200201.736050.76050 EAGLE RD MERIDIAN ID 83642-6308';
    newRec.Sub_Total__c        = 537.04;
    newRec.Tax__c              = 0.0;
    newRec.Telephone__c        = '208 577 5524';
    newRec.Problems__c         = 'No problems';
    newRec.Problem_Count__c    = 0;

    insert newRec;
  }
  */

  @IsTest public static void Test1() {
    List<ContentVersion> testList = [SELECT ContentSize,FileType,Id,LastModifiedDate,Title FROM ContentVersion WHERE FileType = 'JSON' AND ContentSize > 40000 ORDER BY LastModifiedDate DESC NULLS LAST LIMIT 2];
    ContentVersion testRec = testList[0];
    String jsonTitle = testRec.Title;
    String pdfTitle  = jsonTitle.replace('.json','.pdf');
    Schindler_Invoice_History__c testData = InvoiceFixerController.getInvoiceData('cvId',testRec.Id,'');
    System.debug('testData');
    System.debug(testData);
    System.assertNotEquals(testData.ContentVersionId__c,null,'Test data is not empty');

    Schindler_Invoice_History__c testData2 = InvoiceFixerController.getInvoiceData('Pdf','',pdfTitle);
    System.debug('testData2');
    System.debug(testData2);
    System.assertNotEquals(testData2.ContentVersionId__c,null,'Test data2 is not empty');    
  }

}