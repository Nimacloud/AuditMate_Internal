public without sharing class OcrBatchHelper implements Schedulable {  

  // This is scheduled to run every 5 minutes.

  public void execute(SchedulableContext SC) {

  //  Integer currentBatchCount = AuditmateUtility.getIntVal('OcrBatchCount');
  //  if(currentBatchCount < 30 ) {
    Map<Id,OCR_Send_Log__c> ocrLogMap;

    if(Test.isRunningTest()) { 
      ocrLogMap = new Map<Id,OCR_Send_Log__c>([
        SELECT Id, PdfVersionId__c, Title__c,Resend__c, Status__c,Result__c  
        From OCR_Send_Log__c  WHERE (Status__c = 'Unsent' OR Resend__c = true) AND Result__c != 'Errors!' LIMIT 1
      ]);
    } else {
      ocrLogMap = new Map<Id,OCR_Send_Log__c>([
        SELECT Id, PdfVersionId__c, Title__c,Resend__c, Status__c,Result__c  
        From OCR_Send_Log__c  WHERE (Status__c = 'Unsent' OR Resend__c = true) AND Result__c != 'Errors!' LIMIT 9
      ]);
    }
  
      Integer mapSize = ocrLogMap.size();
      if(mapSize > 0) {
        Id batchInstanceId = Database.executeBatch(new OcrBatch(ocrLogMap));
        System.debug('OcrBatchHelper Found ' + mapSize.format() + ' records in OCR_Send_Log__c to be sent to OCR.');
        System.debug('OcrBatch started.  Job Id:');
        System.debug(batchInstanceId);
      } else {
        System.debug(datetime.now().format('yyyy.MM.dd HH:mm:ss z') + ' OcrBatchHelper did not see any unsent records in OCR_Send_Log__c.');
      }
  //  } else {
  //    System.debug('OcrBatchHelper sees currentBatchCount = ' + currentBatchCount.format());
  //    System.debug('OcrBatchHelper is not launching OcrBatch at this time');
  //  }
  }
}