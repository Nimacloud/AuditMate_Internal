public with sharing class OCRService {

    @future(callout=true)
    public static void processInvoiceCaseAsync(Id caseId) {
        processInvoiceCase(caseId);
    }

    public static Schindler_Invoice_History__c processInvoiceCase(Id caseId) {

        Schindler_Invoice_History__c result = null;

        Case caseRecord = OCRServiceUtils.getCase(caseId);
        ContentVersion contentVersionRecord = OCRServiceUtils.getCaseContentVersion(caseRecord.Id);

        OCRClient client = new OCRClient();
        HttpResponse response = client.send(contentVersionRecord.VersionData);

        if (response.getStatusCode() == 200) {

            Map<String, Object> mapping = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            System.debug(JSON.serializePretty(mapping));

            if (mapping.containsKey('OcrPages')) {

                Object[] pages = (Object[]) mapping.get('OcrPages');

                if (!pages.isEmpty()) {

                    Object page = pages[0];

                    result = OCRServiceUtils.insertInvoice(page, caseRecord, contentVersionRecord);
                }
            }
        }
        else {
            // Uncaptured API error
            System.debug(response.getBody());

            result = OCRServiceUtils.insertDummyInvoice(caseRecord, contentVersionRecord, response.getBody());
        }

        return result;
    }

}