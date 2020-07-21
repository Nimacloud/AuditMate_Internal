global class SchindlerEmailService2 implements Messaging.InboundEmailHandler {

  global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email,Messaging.InboundEnvelope env) {
    System.debug('SchindlerEmailService handleInboundEmail(Start)'); 

    List<ContentVersion>      cvList  = new List<ContentVersion>();
    List<ContentVersion>      cvList2 = new List<ContentVersion>();
    List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
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
    String toAddress, relatedAccountId = '';
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
      // System.debug('Inserted em message.  New Id: ' + em.Id);
    }
    catch (DmlException e) {
      System.debug(e);  
    }

    Case nc = new Case();
    nc.Subject   = 'Incomming Email - ' + email.subject;
    nc.AccountId = relatedAccountId;
    nc.Comments  = 'Email From: ' + email.fromAddress + ' Email Message: '  + email.plainTextBody;
    try {
      insert nc;
    } catch(DmlException e) {
      System.debug(e); 
    }

    if(cvList.size() > 0) {
      try {
        insert cvList;
        cvList2 = [select id, ContentDocumentId from ContentVersion WHERE Id in :cvList];
        for (ContentVersion cv : cvList2) {
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
        }
        try {
          insert cdlList;
        } catch(DmlException e) {
          System.debug(e); 
        }
      } catch(DmlException e) {
        System.debug(e);
      }
    }
    
    result.success = true;
    System.debug('SchindlerEmailService handleInboundEmail(End)'); 
    return result;

  }
}