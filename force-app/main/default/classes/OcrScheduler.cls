public without sharing class OcrScheduler {

  Static Final Integer PDF_MAX_SIZE = 200000;

  public static void OcrSchedule() { 

    // This is called by schedulable class OcrScheduleHeler whcih runs frequently...every 15 minutes.

    // It looks for EmailMessages (created by EmailService) that have binary attachments, determines if attachments
    // are Pdfs and whether any have been sent to OCR Api before (or it has a resend flag) and then updates or inserts
    // into OCR_Send_Log__c.  It then makes a OcrRequest.callOcr callout for each file.  These are @future callouts 
    // to the OCR Api rest endpoints and the results are saved as files and the response logged.

    Integer listLength,i;
    String emailMessageId,accountName,emailSubject;
    List<String>         docIdList    = new List<String>();
    List<String>         checksumList = new List<String>();
    List<ContentVersion> preSendList  = new List<ContentVersion>();
    List<OCR_Send_Log__c> sendList    = new List<OCR_Send_Log__c>();
    List<OCR_Send_Log__c> savedSendList;

    Map<String,OCR_Send_Log__c> sentBeforeMap = new Map<String,OCR_Send_Log__c>();
    OCR_Send_Log__c sentBeforeItem;

    List<ContentDocumentLink> cdlList;
    List<ContentVersion> cvList;

    Date     today = Date.Today();
    Datetime now   = Datetime.Now();

    for (List<EmailMessage> uncheckedMessages : [SELECT Id, Account__r.Name,Subject,Date_Checked__c FROM EmailMessage WHERE NeedsOcrCheck__c = true AND Date_Checked__c = null]) {
      listLength = uncheckedMessages.size();
      for(i=0;i<listLength;i++) {
        emailMessageId = uncheckedMessages[i].Id;
        accountName    = uncheckedMessages[i].Account__r.Name;
        emailSubject   = uncheckedMessages[i].Subject;
        uncheckedMessages[i].Date_Checked__c = today;

        System.debug('Checking ' + emailMessageId + ' ' + accountName + ' ' + emailSubject);

        cdlList = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :emailMessageId];
        for(ContentDocumentLink cdl : cdlList) {
          docIdList.add(cdl.ContentDocumentId);
          System.debug(' ---- ' + cdl.ContentDocumentId );
        }
      }
      try {
        update uncheckedMessages; // Sets Date_Checked__c.
      } catch(DmlException e) {
        System.debug(e);
      }
    }

    if(docIdList.size() > 0) {
      cvList = [SELECT Id,Title,Checksum,ContentSize FROM ContentVersion WHERE FileType = 'Pdf' AND ContentDocumentId IN :docIdList];
      for(ContentVersion cv : cvList) {
        System.debug('Id: '       + cv.Id);
        System.debug('Title: '    + cv.Title);
        System.debug('Checksum: ' + cv.Checksum);
        if(cv.ContentSize > PDF_MAX_SIZE) {
          System.debug(cv.Title + ' is too large to send to the OCR Api');
        } else {
          checksumList.add(cv.Checksum);
          preSendList.add(cv);
        }
      }
  
      // Have any of these files been sent to OCR api before?
      System.debug('Checksum list:');
      System.debug(checksumList);
      List<OCR_Send_Log__c> sentBeforeList = [SELECT Id, ContentVersionId__c, Checksum__c, Title__c,Resend__c From OCR_Send_Log__c WHERE Checksum__c IN :checksumList];
      
      System.debug(sentBeforeList);
      for(OCR_Send_Log__c sentBefore : sentBeforeList) {
        sentBeforeMap.put(sentBefore.Checksum__c,sentBefore);
      }
  
      for(ContentVersion preSendItem : preSendList) {
        if(sentBeforeMap.containsKey(preSendItem.Checksum)) {
          sentBeforeItem = sentBeforeMap.get(preSendItem.Checksum);
          if(sentBeforeItem.Resend__c == true) {
            System.debug('Updating ' + preSendItem.Title + ' as it has been sent before but it has a resend flag.');
            sentBeforeItem.Resend__c = false;
            sendList.add(sentBeforeItem);
          } else {
            System.debug('Skipping ' + preSendItem.Title + ' as it has been sent before and it does not have a resend flag.');
          }
        } else {
          System.debug('Adding ' + preSendItem.Title + ' as it has not been sent before.');
          OCR_Send_Log__c sendItem = new OCR_Send_Log__c();
          sendItem.Checksum__c         = preSendItem.Checksum;
          sendItem.ContentVersionId__c = preSendItem.Id;
          sendItem.Title__c            = preSendItem.Title;
          sendList.add(sendItem);
        }
      }
      System.debug('Final Send List:');
      Integer cnt = sendList.size();
      String cntStr = cnt.format();
      Set<Id> upsertIds = new Set<Id>();
      if(cnt > 0) {
        if(cnt == 1) {
          System.debug('OcrSchedule found 1 file to process.');
        } else {
          System.debug('OcrSchedule found ' + cntStr + ' files to process.');
        }
       
        //  try {upsert sendList};   } catch(DmlException e) {System.debug(e);}
        List<Database.upsertResult> upsertResults = Database.upsert(sendList,false);
        for(Database.upsertResult result : upsertResults) {
          if(result.isSuccess()) {
            upsertIds.add(result.getId());
          }  else {
            for(Database.Error err : result.getErrors()) {
              System.debug(err.getStatusCode() + ': ' + err.getMessage());
            }
          }
        }
        if(upsertIds.size() > 0) {
          savedSendList = [SELECT Id, ContentVersionId__c From OCR_Send_Log__c WHERE Id IN :upsertIds];
          for(OCR_Send_Log__c logRec : savedSendList) {
            System.debug('OCR_Send_Log__c.Id: ' + logRec.Id);
            System.debug('ContentVersionId:   ' + logRec.ContentVersionId__c);
            if(Test.isRunningTest()){
              System.debug('Not making API callout as this is a test...');
            } else {
              System.debug('Making API callout...');
              OcrRequest.callOcr(logRec.Id, logRec.ContentVersionId__c);
            }
          }
        }
      } else {
        System.debug('OcrSchedule did not find any attached files to process.');
      }
    } else {
      System.debug('OcrSchedule did not find any attached files to process.');
    }
  }

}