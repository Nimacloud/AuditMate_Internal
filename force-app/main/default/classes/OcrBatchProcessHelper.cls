public without sharing class OcrBatchProcessHelper implements Schedulable {  
  // This is scheduled to run every 9 minutes.

  public void execute(SchedulableContext SC) {
   
    // Note: Taking out platform cache use atm, as it interrupts test and I'm not sure it's necessary.
    // Failed Cache.Org.contains() for key 'OcrBatchCount': Org cache is only supported in Data Silo tests
    // Integer currentBatchCount = AuditmateUtility.getIntVal('OcrBatchCount');

    // if(currentBatchCount < 30 ) {
      AggregateResult[] cnts = [SELECT Count(Id) Cnt FROM OCR_Send_Log__c WHERE Staged__c = true AND Processed__c = false];
      Integer unprocessedCnt = (Integer) cnts[0].get('Cnt');
      if( unprocessedCnt > 0) {
        System.debug('OcrBatchProcessHelper Found ' + unprocessedCnt.format() + ' records in OCR_Send_Log__c requiring to process.');
        Id batchInstanceId = Database.executeBatch(new OcrBatchProcess());
        System.debug('OcrBatchProcessHelper started new OcrBatchProcess.  Job Id:');
        System.debug(batchInstanceId);
      } else {
        System.debug(datetime.now().format('yyyy.MM.dd HH:mm:ss z') + ' OcrBatchProcessHelper did not see any unprocessed sent records in OCR_Send_Log__c.');
      }
    // } else {
    //   System.debug('OcrBatchProcessHelper sees currentBatchCount = ' + currentBatchCount.format());
    //   System.debug('OcrBatchProcessHelper is not launching OcrBatchStaging at this time');
    // }
  }

}