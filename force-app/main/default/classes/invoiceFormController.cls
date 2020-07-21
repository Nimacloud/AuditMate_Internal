public without sharing class invoiceFormController {

  @AuraEnabled
  public static string SaveHistoryRec(
    String billTo,
    String billingId,
    String contract,
    String contentVersionId,
    String description,
    String dunsNumber,
    String expenses,
    String fax,
    String federalTaxId,
    String fieldContact,
    String historyId,
    String invoiceDate,
    String invoiceNumber,
    String invoiceTotal,
    String labor,
    String localOffice,
    String notification,
    String orderNo,
    String orderType,
    String payer,
    String remitTo,
    String salesContact,
    String serviceLocation,
    String subtotal,
    String tax,
    String telephone,
    String problems,
    String problemCount) {

    Integer problemCountInt=0;
    Decimal expensesDec=0,invoiceTotalDec=0,laborDec=0,subTotalDec=0,taxDec=0;        
    String expensesStr='',invoiceTotalStr='',laborStr='',subtotalStr='',taxStr='';

    if(!String.isBlank(problemCount)) {
      problemCountInt = Integer.valueOf(problemCount);
    }

    // removeStart('$') is only required for invoiceTotal, but applying it to all in case format of numbers change in future.  If no $ is present, no change.  Same for replaceAll.
    if(!String.isBlank(expenses)) {
      expensesStr     = expenses.removeStart('$').replaceAll(',','');
      expensesStr     = expensesStr.replaceAll(' ','');
      expensesDec     = Decimal.valueOf(expensesStr);
    }
    
    if(!String.isBlank(invoiceTotal)) {
      invoiceTotalStr = invoiceTotal.removeStart('$').replaceAll(',','');
      invoiceTotalStr = invoiceTotalStr.replaceAll(' ','');
      invoiceTotalDec = Decimal.valueOf(invoiceTotalStr);
    } 
    if(!String.isBlank(labor)) {
      laborStr        = labor.removeStart('$').replaceAll(',','');
      laborStr        = laborStr.replaceAll(' ','');
      laborDec        = Decimal.valueOf(laborStr);
    }
    if(!String.isBlank(subtotal)) {
      subtotalStr     = subtotal.removeStart('$').replaceAll(',','');
      subtotalStr     = subtotalStr.replaceAll(' ','');
      subTotalDec     = Decimal.valueOf(subtotalStr);
    } 
    if(!String.isBlank(tax)) {
      taxStr          = tax.removeStart('$').replaceAll(',','');
      taxStr          = taxStr.replaceAll(' ','');
      taxDec          = Decimal.valueOf(taxStr);
    }

    Date invoice_Date = null;
    if(!String.isBlank(tax)) {
      String[] invoiceDateArray = invoiceDate.split('/');
      Integer  invoiceDateMonth = Integer.valueOf(invoiceDateArray[0]);
      Integer  invoiceDateDay   = Integer.valueOf(invoiceDateArray[1]);
      Integer  invoiceDateYear  = Integer.valueOf(invoiceDateArray[2]);
      invoice_Date = Date.newinstance(invoiceDateYear, invoiceDateMonth, invoiceDateDay);
    } 

  /*
    System.debug('historyId: ' + historyId);
    System.debug(invoice_Date);
    System.debug(notification);

    System.debug(localOffice);
    System.debug(serviceLocation);
    System.debug(billTo);
    System.debug(billingId);
    System.debug(dunsNumber);
    System.debug(contract);
    System.debug(orderNo);
    System.debug(orderType);
    System.debug(telephone);
    System.debug(fax);
    System.debug(federalTaxId);
    System.debug(salesContact);
    System.debug(fieldContact);
    System.debug(invoiceNumber);
    System.debug(description);
    System.debug('laborStr        ' + laborStr);
    System.debug('expensesStr     ' + expensesStr);
    System.debug('taxStr          ' + taxStr);
    System.debug('subtotalStr     ' + subtotalStr);
    System.debug('invoiceTotalStr ' + invoiceTotalStr);
    System.debug('remit To '        + remitTo);
    System.debug(payer);
    System.debug(problems);
    System.debug(problemCount);
    */

    List<Schindler_Invoice_History__c> saveList = new List<Schindler_Invoice_History__c>();
    Schindler_Invoice_History__c       newRec   = new Schindler_Invoice_History__c();
    newRec.Id                  = historyId;
    newRec.Bill_To__c	         = billTo;
    newRec.Billing_Id__c       = billingId;
    newRec.Contract__c         = contract;
    newRec.ContentVersionId__c = contentVersionId;
    newRec.Description__c      = description;
    newRec.Duns_Number__c      = dunsNumber;
    newRec.Expenses__c         = expensesDec;
    newRec.Fax__c              = fax;
    newRec.Federal_Tax_Id__c   = federalTaxId;
    newRec.Field_Contact__c    = fieldContact;
    newRec.Invoice_Date__c     = invoice_Date;
    newRec.Invoice_Number__c   = invoiceNumber;
    newRec.Invoice_Total__c    = invoiceTotalDec;
    newRec.Labor__c            = laborDec;
    newRec.Local_Office__c     = localOffice;
    newRec.Notification__c     = notification;
    newRec.Order_No__c         = orderNo;
    newRec.Order_Type__c       = orderType;
    newRec.Payer__c            = payer;
    newRec.Remit_To__c         = remitTo;
    newRec.Sales_Contact__c    = salesContact;
    newRec.Service_Location__c = serviceLocation;
    newRec.Sub_Total__c        = subTotalDec;
    newRec.Tax__c              = taxDec;
    newRec.Telephone__c        = telephone;
    newRec.Problems__c         = problems;
    newRec.Problem_Count__c    = problemCountInt;
    saveList.add(newRec);
    String retVal,errors;
    Database.SaveResult[] srList = Database.update(saveList, false);
    for (Database.SaveResult sr : srList) {
      if (sr.isSuccess()) {
        retVal = sr.getId();
      }
      else {
        for(Database.Error err : sr.getErrors()) {
          System.debug(err.getStatusCode() + ': ' + err.getMessage());
          errors += err.getMessage() + ' ';
        }
        retVal = 'Errors: ' + errors;
      }
    }
    return retVal;
  }
  
}