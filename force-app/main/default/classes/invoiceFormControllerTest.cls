@IsTest
public without sharing class invoiceFormControllerTest {

  @testSetup static void setup() {
    Schindler_Invoice_History__c newRec   = new Schindler_Invoice_History__c();
    newRec.ContentVersionId__c = 'This is a test';
    insert newRec;
  }

  @IsTest public static void Test1() {
    List<Schindler_Invoice_History__c> testList = [SELECT Id FROM Schindler_Invoice_History__c WHERE ContentVersionId__c = 'This is a test'];    
    Schindler_Invoice_History__c testRec = testList[0];
    
    String billTo           = 'HEALTH SYSTEMS ACCOUNTS PAYABLE-CONTRACTS 190 E BANNOCK ST BOISE ID 83712-6241';
    String billingId        = '5000043237';
    String contract         = '4100086022';
    String contentVersionId = 'This is a test';
    String description      = '01/12/2019 SERVICE CALL ON ELEVATOR 71 WAS REQUESTED BY TED. CUSTOMER REPORTED: CODE 1 ENTRAPMENT ON MAIN FLOOR WITH PASSENGERS. TECHNICIAN REPORTED: FOUND FATER AND TWO SONS STUCK. FOUND TRIPPED GOVERNER SWITCH. RESET AND CHECKED OPERATION. REFER TO NOTIFICATION 62899351';
    String dunsNumber       = '09 480 9993';
    String expenses         = '68.64';
    String fax              = '208 577 5525';
    String federalTaxId     = '09 480 9993';
    String fieldContact     = 'Charles Pogue';
    String historyId        = testRec.Id;
    String invoiceDate      = '2/3/2019';
    String invoiceNumber    = '7152874823';
    String invoiceTotal     = '537.04';
    String labor            = '468.4';
    String localOffice      = 'Schindler Elevator Corporation 743 MCGREGOR CT STE 140 BOISE ID 83705-5225';
    String notification     = '62899351';
    String orderNo          = '5154057331';         
    String orderType        = 'Z1TM';          
    String payer            = 'ST LUKE\'S HEALTH SYSTEM 190 E BANNOCK ST BOISE ID 83712-6241';
    String pdfFilename      = '12345.pdf';
    String remitTo          = 'Schindler Elevator Corporation';
    String salesContact     = 'Diane Rawson';
    String serviceLocation  = 'ST LUKES MERIDIAN MEDICAL CENTER 1102.5336. PW1 10200201.736050.76050 EAGLE RD MERIDIAN ID 83642-6308';
    String subtotal         = '537.04';
    String tax              = '0.00';
    String telephone        = '208 577 5524';
    String problems         = 'No problems';
    String problemCount     = '0';

    String result = invoiceFormController.SaveHistoryRec(
      billTo,
      billingId,
      contract,
      contentVersionId,
      description,
      dunsNumber,
      expenses,
      fax,
      federalTaxId,
      fieldContact,
      historyId,
      invoiceDate,
      invoiceNumber,
      invoiceTotal,
      labor,
      localOffice,
      notification,
      orderNo,
      orderType,
      payer,
      remitTo,
      salesContact,
      serviceLocation,
      subtotal,
      tax,
      telephone,
      problems,
      problemCount);

    if(result.contains('Errors')) {
      System.assertEquals(true,false,'Error saving record');  
    } else {
      System.assertEquals(true,true,'No Errors saving record');  
    }

  }
}