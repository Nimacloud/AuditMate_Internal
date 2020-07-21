global class OcrBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {

  global Map<Id,OCR_Send_Log__c> toalSentLogMap = new Map<Id,OCR_Send_Log__c>();
  global Map<String,Id> jsonTitleOcrLogLookupMap = new map<String,Id>();

  Map<Id,OCR_Send_Log__c> ocrLogMap;
  Map<Id,OCR_Send_Log__c> pdfSendMap;
  Map<Id,OCR_Send_Log__c> pdfRemainingMap;

  global Set<Id> pdfIds;
	global Set<Id> pdfIdsRemaining;
	
  global Integer TotalRecCount = 0;
  global Integer TotalOcrCount = 0;
	global Datetime startTime;
  global Integer batchSize;
  global Integer batchCount = 0;
  global String endpoint;
  global String apiKey;

  private List<ContentVersion> cvList  = new List<ContentVersion>();

  private String jsonCvIdList = '';

	global OcrBatch(Map<Id,OCR_Send_Log__c> ocrLogMapIn) {
    ocrLogMap = ocrLogMapIn;
    startTime = DateTime.now();
    batchSize = 3; // OCR requests take around 20 seconds for a 36K Pdf.  Maximum time allowed is 120 seconds, so this should be OK.
    
    List<OCR_Api_Details__mdt> ocrDetails = [Select Endpoint__c, Apikey__c From OCR_Api_Details__mdt LIMIT 1];
    OCR_Api_Details__mdt ocrDetail = ocrDetails[0];
    endpoint = ocrDetail.Endpoint__c;
    apiKey   = ocrDetail.Apikey__c;
	}	

  global Database.QueryLocator start(Database.BatchableContext BC){
  
		/*
      ocrLogMap = new Map<String,OCR_Send_Log__c>([
        SELECT Id, PdfVersionId__c, Checksum__c, Title__c,Resend__c, Status__c,Result__c  
        From OCR_Send_Log__c  WHERE Status__c = 'Unsent']);
    */
    // AuditmateUtility.incIntVal('OcrBatchCount');

    pdfSendMap      = new Map<Id,OCR_Send_Log__c>();
    pdfRemainingMap = new Map<Id,OCR_Send_Log__c>();

    Integer recCnt = 0;
    String cIdCsv = '';
    OCR_Send_Log__c rec;
    for(Id key : ocrLogMap.keySet()) {
      recCnt++;
      System.debug('Cnt: ' + recCnt.format() + '  key: ' + key);  
      rec = ocrLogMap.get(key);
      String srcTitle  = rec.Title__c;
      String baseTitle = srcTitle.substringBefore('.');
      String newTitle  = baseTitle + '.Json';
      if(!this.jsonTitleOcrLogLookupMap.containsKey(newTitle)) {
        this.jsonTitleOcrLogLookupMap.put(newTitle,rec.Id); // Store newTitle and logId for use in finish.  
      }
      if(recCnt <= this.batchSize) {
        pdfSendMap.put(rec.Id,rec);
        cIdCsv += '\'' + rec.PdfVersionId__c + '\',';
      } else {
        pdfRemainingMap.put(rec.Id,rec);
      }
    }
    cIdCsv = cIdCsv.removeEnd(',');
    String sQuery = 'SELECT Id,Title,ContentSize,ContentDocumentId,VersionData FROM ContentVersion WHERE Id IN (' + cIdCsv + ') ORDER BY Title';	
    System.debug(sQuery);
    System.debug('Start ' + this.endpoint);
    System.debug('Start ' + this.apiKey);
		batchCount++;	
		
		return Database.getQueryLocator(sQuery);
	}

  global void execute(Database.BatchableContext BC, List<sObject> scope){
		Integer successCount = 0;
		for (sObject s : scope) {
			ContentVersion cv = (ContentVersion) s;			
      Blob pdfBlob = cv.VersionData;
      Integer cvSize = cv.ContentSize;
      String cvSizeStr = cvSize.format();
      System.debug('File: ' + cv.Title + ' size: ' + cvSizeStr);
      System.debug('Time Before OCR:');
      System.debug(Datetime.Now());

      HTTPResponse res;
      if(Test.isRunningTest()) {
        res = new HTTPResponse();
        res.setStatusCode(200);
      } else {
        res = OcrRequest2.getOcrResponse(this.endpoint,this.apiKey,pdfBlob); // Can't call this from a Test method.
      }
      System.debug('Time After OCR:');
      System.debug(Datetime.Now());

      System.debug(res);
      if(res != null) {
        
        String srcTitle  = cv.Title;
        String baseTitle = srcTitle.substringBefore('.');
        String newTitle  = baseTitle + '.Json';
        String output;

        if(res.getStatusCode() == 200) {
          successCount++;
//        String endTime    = 'End ' + datetime.now().format('yyyy.MM.dd HH:mm:ss z');

          if(Test.isRunningTest()) { 
            output = 'This is a test';
          } else {
            output = res.getBody();
          }

          String escaped    = output.escapeHtml4();
          Blob outputBlob   = Blob.valueOf(escaped);
          String output64   = EncodingUtil.base64Encode(outputBlob);

          ContentVersion tempContentInsert = new ContentVersion();
          tempContentInsert.Title          = newTitle;
          tempContentInsert.VersionData    = Blob.valueof(output64);
          tempContentInsert.PathOnClient   = '/' + newTitle;
          cvList.add(tempContentInsert);
        } else {
          System.debug('Callout returned error');  
        }
      } else {
        System.debug('Callout failed - check log.');
      }

    }		

    TotalOcrCount += successCount;
  }
  
	global void finish(Database.BatchableContext BC){

    // AuditmateUtility.decIntVal('OcrBatchCount');
    
    List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
    List<OCR_Send_Log__c> ocrUpdateList = new List<OCR_Send_Log__c>();
    String updatedId;

    try {
      insert cvList;
      System.debug('Inserted JSON ContentVersion records');
      OCR_Send_Log__c ocrUpdateRec;
      List<ContentVersion> cvList2 = [select id, Title, ContentDocumentId from ContentVersion WHERE Id in :cvList];

      for(ContentVersion jsonRec : cvList2) {
        String jsonId = jsonRec.Id;
        String jsonTitle = jsonRec.Title;
        Id logId = this.jsonTitleOcrLogLookupMap.get(jsonTitle);
        ocrUpdateRec = new OCR_Send_Log__c();
        ocrUpdateRec.Id = logId;
        ocrUpdateRec.JsonVersionId__c = jsonRec.Id;
        ocrUpdateRec.Status__c = 'Sent';
        ocrUpdateList.add(ocrUpdateRec);
        ContentDocumentLink cl = new ContentDocumentLink();
        cl.ContentDocumentId = jsonRec.ContentDocumentId;
        cl.LinkedEntityId    = logId;
        cl.ShareType         = 'V';
        cl.Visibility        = 'AllUsers';
        cdlList.add(cl);
        this.jsonCvIdList += '\'' + jsonId  + '\',';
      }
      this.jsonCvIdList = jsonCvIdList.removeEnd(',');

      Database.SaveResult[] srList = Database.insert(cdlList, false);
      for (Database.SaveResult sr : srList) {
        if (!sr.isSuccess()) {
          for(Database.Error err : sr.getErrors()) {
            System.debug(err.getStatusCode() + ': ' + err.getMessage());
          }
        } else {
          updatedId = sr.getId();
          System.debug('OcrBatch finish inserted ContentDocumentLink Id: ' + updatedId);
        }
      }

      Database.SaveResult[] srList2 = Database.update(ocrUpdateList, false);
      for (Database.SaveResult sr : srList2) {
        if (!sr.isSuccess()) {
          for(Database.Error err : sr.getErrors()) {
            System.debug(err.getStatusCode() + ': ' + err.getMessage());
          }
        } else {
          updatedId = sr.getId();
          System.debug('OcrBatch finish updated OCR_Send_Log__c Id: ' + updatedId);
        }
      }      

    } catch (DmlException e) {
      System.debug(e);
    }

		if (pdfRemainingMap.size() > 0) {
      //fire again
      System.debug('fire again');
      Id batchInstanceId = Database.executeBatch(new OcrBatch(pdfRemainingMap));
			} else {
        System.debug('OcrBatch - batch Count:' + batchCount.format() );
        System.debug('OcrBatch - TotalOcrCount: ' + TotalOcrCount.format() );
    }
  }

}