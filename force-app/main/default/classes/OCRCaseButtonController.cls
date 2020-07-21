public with sharing class OCRCaseButtonController {

    private ApexPages.StandardController std;

    public OCRCaseButtonController(ApexPages.StandardController std) {
        this.std = std;
    }

    public PageReference createInvoiceAction() {

        OCRService.processInvoiceCaseAsync(std.getId());

        return std.view();
    }
}