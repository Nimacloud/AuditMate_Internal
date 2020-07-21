public without sharing class PortalFileController {

    @AuraEnabled
    public static Id getContentDocumentId(Id recordId) {

        ContentDocumentLink[] link = [SELECT 
                                            ContentDocumentId, 
                                            LinkedEntityId, 
                                            ContentDocument.FileType 
                                        FROM ContentDocumentLink 
                                        WHERE LinkedEntityId = :recordId
                                        AND ContentDocument.FileType = 'PDF'];


        return link.isEmpty() ? null : link[0].ContentDocumentId;
    }

}