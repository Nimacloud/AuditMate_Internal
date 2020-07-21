public without sharing class PortalProposalController {

    @AuraEnabled
    public static void acceptProposal(Id proposalId, String message) {

        Proposal__c record = new Proposal__c(Id = proposalId);
        record.Customer_Comments__c = message;
        record.CustomerStatus__c = 'Accepted';
        update record;
    }

    @AuraEnabled
    public static void declineProposal(Id proposalId, String message) {

        Proposal__c record = new Proposal__c(Id = proposalId);
        record.Customer_Comments__c = message;
        record.CustomerStatus__c = 'Declined';
        update record;
    }
}