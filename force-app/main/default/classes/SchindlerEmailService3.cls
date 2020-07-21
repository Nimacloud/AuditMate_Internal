global class SchindlerEmailService3 implements Messaging.InboundEmailHandler {

  Static Final Integer PDF_MAX_SIZE = 200000;

  global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email,Messaging.InboundEnvelope env) {
    System.debug('SchindlerEmailService handleInboundEmail(Start *)'); 

    List<ContentVersion>      cvList  = new List<ContentVersion>();
    List<ContentVersion>      cvList2 = new List<ContentVersion>();
    List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
    List<OCR_Send_Log__c> logList     = new List<OCR_Send_Log__c>();
    Database.SaveResult[] srList;
    Boolean needsOcrCheck = false;

    // Create an InboundEmailResult object for returning the result of the Apex Email Service
    Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();

    if(email.textAttachments != null) {
      if(email.textAttachments.size() > 0) {
        Messaging.InboundEmail.TextAttachment[] textAttachList = email.textAttachments;
        for(Messaging.InboundEmail.TextAttachment textFile : textAttachList) {
          ContentVersion tempContentInsert = new ContentVersion();
          tempContentInsert.Title          = textFile.fileName;
          tempContentInsert.VersionData    = Blob.valueof(textFile.body);
          tempContentInsert.PathOnClient   = '/' + textFile.fileName ;
          cvList.add(tempContentInsert);
        }
      }
    }

    if(email.binaryAttachments != null) {
      if(email.binaryAttachments.size() > 0) {
        needsOcrCheck = true;
        Messaging.InboundEmail.BinaryAttachment[] binAttachList = email.binaryAttachments;
        for(Messaging.InboundEmail.BinaryAttachment binFile : binAttachList) {
          System.debug(binFile);
          ContentVersion tempContentInsert = new ContentVersion();
          tempContentInsert.Title        = binFile.fileName;
          tempContentInsert.VersionData  = binFile.body;
          tempContentInsert.PathOnClient = '/' + binFile.fileName ;
          cvList.add(tempContentInsert);
        }
      }
    }

    /*
      Accounts_mdt is a 1:1 map to Accounts that have InternalEmailAddress__c populated. This should be done by Account triggers, but it is a manual process at the moment to add the account.
      This means the records returened by the query here for Id (and name) based on InternalEmailAddress__c are cached and the soql does not count for governor limits.
      https://help.salesforce.com/articleView?id=custommetadatatypes_limitations.htm&type=5
    */
    String toAddress, relatedAccountId = '',newId;
    Boolean noErrors = true;

    if(Test.isRunningTest()){
      toAddress = 'graham.smith@auditmate.com';
    } else {
      toAddress = email.toAddresses[0];
    }

    List<Account__mdt> relatedAccounts;
    relatedAccounts = [SELECT AccountId__c, AccountName__c FROM Account__mdt WHERE InternalEmailAddress__c = :toAddress LIMIT 1];
    if(relatedAccounts.size() == 1) {
      relatedAccountId = relatedAccounts[0].AccountId__c;
    } else{
      relatedAccounts  = [SELECT AccountId__c, AccountName__c FROM Account__mdt WHERE InternalEmailAddress__c = 'SchindlerDefaultEmail'];
      relatedAccountId = relatedAccounts[0].AccountId__c;
    }

    EmailMessage em = new EmailMessage();
    em.Source__c         = 'SchindlerEmailService';
    em.TextBody          = email.plainTextBody;
    em.Subject           = email.subject;
    em.FromAddress       = email.fromAddress;
    em.ToAddress         = toAddress;
    em.FromName          = email.fromName;
    em.MessageIdentifier = email.messageId;
    em.NeedsOcrCheck__c  = needsOcrCheck;
    em.Account__c        = relatedAccountId;

    try {
      insert em;
    }
    catch (DmlException e) {
      System.debug(e);  
    }

    Case nc = new Case();
    nc.Subject   = 'Incoming Email - ' + email.subject;
    nc.AccountId = relatedAccountId;
    nc.Comments  = 'Email From: ' + email.fromAddress + ' Email Message: '  + email.plainTextBody;
    try {
      insert nc;
    } catch(DmlException e) {
      System.debug(e); 
    }

    if(cvList.size() > 0) {
      srList = Database.insert(cvList, false);
      for (Database.SaveResult sr : srList) {
        if (!sr.isSuccess()) {
          noErrors = false;
          for(Database.Error err : sr.getErrors()) {
            System.debug(err.getStatusCode() + ': ' + err.getMessage());
          }
        } else {
          newId = sr.getId();
          System.debug('SchindlerEmailService3 inserted ContentVersion Id: ' + newId);
        }
      }

      if(noErrors) {
        cvList2 = [SELECT Id,Title,Checksum,ContentDocumentId,ContentSize,FileType FROM ContentVersion WHERE Id in :cvList];
        for (ContentVersion cv : cvList2) {
          System.debug('CV Check');
          System.debug(cv);
          ContentDocumentLink cl = new ContentDocumentLink();
          cl.ContentDocumentId = cv.ContentDocumentId;
          cl.LinkedEntityId    = em.Id;  // Link attachments to the email.
          cl.ShareType         = 'V';
          cl.Visibility        = 'AllUsers';          
          cdlList.add(cl);
          ContentDocumentLink cl2 = new ContentDocumentLink();
          cl2.ContentDocumentId = cv.ContentDocumentId;
          cl2.LinkedEntityId    = nc.Id; // Link attachments to the case.
          cl2.ShareType         = 'V';
          cl2.Visibility        = 'AllUsers';
          cdlList.add(cl2);

          /*
          
          OCR will be bypassed for the moment 

          if(cv.FileType == 'PDF') {
            if(cv.ContentSize > PDF_MAX_SIZE) {
              System.debug(cv.Title + ' is too large to send to the OCR Api');
            } else {
              OCR_Send_Log__c logRec = new OCR_Send_Log__c();
              // logRec.Checksum__c      = cv.Checksum;
              logRec.PdfVersionId__c  = cv.Id;
              logRec.Title__c         = cv.Title;
              logRec.Account__c       = relatedAccountId;
              logRec.Case__c          = nc.Id; // Relate to the case that has the pdf.
              logRec.Status__c        = '';
              logList.add(logRec);
            }
          }  
          */

        }

        srList = Database.insert(cdlList, false);
        for (Database.SaveResult sr : srList) {
          if (!sr.isSuccess()) {
            noErrors = false;
            for(Database.Error err : sr.getErrors()) {
              System.debug(err.getStatusCode() + ': ' + err.getMessage());
            }
          } else {
            newId = sr.getId();
            System.debug('SchindlerEmailService3 inserted ContentDocumentLink Id: ' + newId);
          }
        }

        if(noErrors) {
          srList = Database.insert(logList, false);
          for (Database.SaveResult sr : srList) {
            if (!sr.isSuccess()) {
              noErrors = false;
              for(Database.Error err : sr.getErrors()) {
                System.debug(err.getStatusCode() + ': ' + err.getMessage());
              }
            } else {
              newId = sr.getId();
              System.debug('SchindlerEmailService3 inserted OCR_Send_Log__c Id: ' + newId);
            }
          }
        }
      }

    }
    
    result.success = noErrors;
    System.debug('SchindlerEmailService handleInboundEmail(End)'); 
    return result;

  }
}