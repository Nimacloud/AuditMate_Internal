public without sharing class PortalCaseController {

    public static final String PROPOSAL_SUBJECT = 'Proposal upload';
    public static final String INSPECTION_SUBJECT = 'Inspection upload';
    public static final String CONTRACT_SUBJECT = 'Contract upload';

    @AuraEnabled
    public static Id createProposalCase(Id contentDocumentId) {
        return createCase(PROPOSAL_SUBJECT, contentDocumentId);
    }

    @AuraEnabled
    public static Id createContractCase(Id contentDocumentId) {
        return createCase(CONTRACT_SUBJECT, contentDocumentId);
    }

    @AuraEnabled    
    public static Id createInspectionCase(Id contentDocumentId) {
        return createCase(INSPECTION_SUBJECT, contentDocumentId);
    }    

    private static Id createCase(String requestType, Id contentDocumentId) {
    
        Contact contactRecord = CustomerUserHandler.getCommunityContact();
        
        Case caseRecord = new Case(Subject = requestType);
        caseRecord.Status = 'New';
        caseRecord.ContactId = contactRecord.Id;
        caseRecord.AccountId = contactRecord.AccountId;
        caseRecord.Origin = 'Community';

        insert caseRecord;
        
        ContentDocumentLink link = new ContentDocumentLink();

        if (contentDocumentId != null) {

            link.ContentDocumentId = contentDocumentId;
            link.LinkedEntityId = caseRecord.Id;
            link.ShareType = 'V';

            insert link;
        }

        return link.Id;
    }

    

}