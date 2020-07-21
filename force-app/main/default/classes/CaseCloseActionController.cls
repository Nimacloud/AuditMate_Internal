public with sharing class CaseCloseActionController {

    private ApexPages.StandardSetController std;

    public CaseCloseActionController(ApexPages.StandardSetController std) {
        this.std = std;
    }

    public PageReference closeCases() {

        Case[] caseRecords = std.getSelected();

        for (Case caseRecord :caseRecords) {

            if (Schema.Case.getSObjectType().getDescribe().fields.getMap().get('Status').getDescribe().isUpdateable()) {
                caseRecord.Status = 'Closed';
            }
        }

        if (Schema.sObjectType.Contact.isUpdateable()) {
            update caseRecords;
        }

        return new Pagereference('/lightning/o/Case/list');
    }

}