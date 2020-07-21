public without sharing class OcrBatchStagingHelper implements Schedulable {  
  // This is scheduled to run every 10 minutes.

  public void execute(SchedulableContext SC) {
   
    // Integer currentBatchCount = AuditmateUtility.getIntVal('OcrBatchCount');
    // if(currentBatchCount < 30 ) {
      AggregateResult[] cnts = [SELECT Count(Id) Cnt FROM OCR_Send_Log__c WHERE Status__c = 'Sent' AND Staged__c = false];
      Integer unstagedCnt = (Integer) cnts[0].get('Cnt');
      if( unstagedCnt > 0) {
        System.debug('OcrBatchStagingHelper Found ' + unstagedCnt.format() + ' records in OCR_Send_Log__c requiring staging.');
        Id batchInstanceId = Database.executeBatch(new OcrBatchStaging());
        System.debug('OcrBatchStagingHelper started new OcrBatchStaging.  Job Id:');
        System.debug(batchInstanceId);
      } else {
        System.debug(datetime.now().format('yyyy.MM.dd HH:mm:ss z') + ' OcrBatchStagingHelper did not see any unstaged sent record in OCR_Send_Log__c.');
      }
    // } else {
    //   System.debug('OcrBatchStagingHelper sees currentBatchCount = ' + currentBatchCount.format());
    //   System.debug('OcrBatchStagingHelper is not launching OcrBatchStaging at this time');
    // }
  }

}