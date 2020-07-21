public without sharing class InvoiceFixerController {
  
  @AuraEnabled (cacheable=true) 
  public static Schindler_Invoice_History__c getInvoiceData(String CurrentInput,String JsonContentVersionId,String PdfFilename) {
    String filename,jsonTitle,pdfTitle,cvId;

    System.debug('CurrentInput: ' + CurrentInput );
    System.debug('JsonContentVersionId: ' + JsonContentVersionId );
    System.debug('PdfFilename: ' + PdfFilename );
    List<Schindler_Invoice_History__c> dataList;
    Schindler_Invoice_History__c data;

    if(CurrentInput == 'Pdf') {
      if(PdfFilename.toLowerCase().endsWith('.pdf')) {
        pdfTitle = PdfFilename;
      } else {
        pdfTitle = PdfFilename + '.pdf';
      }
      jsonTitle = pdfTitle.replace('.pdf','.json');
      List<ContentVersion> jsonCvList = [SELECT Id,Title,CreatedDate FROM ContentVersion WHERE Title = :jsonTitle ORDER BY LastModifiedDate DESC NULLS LAST LIMIT 2];
      ContentVersion jsonCvRec = jsonCvList[0];
      cvId = jsonCvRec.Id;
    } else {
      cvId = JsonContentVersionId;
      ContentVersion jsonCvRec = [SELECT Title FROM ContentVersion WHERE Id = :JsonContentVersionId];
      jsonTitle = jsonCvRec.Title.toLowerCase();
      pdfTitle  = jsonTitle.replace('.json','.pdf');
    }

    dataList = [SELECT PdfFilename__c,Billing_Id__c,Bill_To__c,ContentVersionId__c,Contract__c,Description__c,Duns_Number__c,Expenses__c,Fax__c,Federal_Tax_Id__c,Field_Contact__c,Id,Invoice_Date__c,Invoice_Number__c,Invoice_Total__c,Labor__c,Local_Office__c,Notification__c,Order_No__c,Order_Type__c,Payer__c,Problems__c,Problem_Count__c,Remit_To__c,Sales_Contact__c,Service_Location__c,Sub_Total__c,Tax__c,Telephone__c FROM Schindler_Invoice_History__c WHERE ContentVersionId__c = :cvId ORDER BY CreatedDate DESC NULLS LAST];    System.debug('cvId: ' + cvId );
    data = dataList[0];
    System.debug('jsonTitle: ' + jsonTitle );
    System.debug('pdfTitle: '  + pdfTitle );
    
    return data;
  }

}