@isTest
public with sharing class CaseCloseActionControllerTest {

    @isTest
    public static void itShouldClose() {

        Test.startTest();

        Case[] records = [SELECT Status FROM Case];

        ApexPages.StandardSetController std = new ApexPages.StandardSetController(records);
        std.setSelected(records);

        CaseCloseActionController controller = new CaseCloseActionController(std);
        controller.closeCases();

        Test.stopTest();

        records = [SELECT Status, IsClosed FROM Case];

        for (Case record :records) {
            System.assertEquals(true, record.IsClosed, 'Case should be closed');
        }
    }

    @TestSetup
    public static void makeData() {

        Case caseRecord = new Case(Origin = 'Email');
        insert caseRecord;
    }


}