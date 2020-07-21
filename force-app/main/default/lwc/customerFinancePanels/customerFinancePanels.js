import { LightningElement, api, track } from 'lwc';

export default class CustomerFinancePanels extends LightningElement {

    @api wrapper

    get openInvoicesQuantity() {
        return this.wrapper['open'] ? this.wrapper['open'].length : 0;
    }

    get disputedInvoicesQuantity() {
        return this.wrapper['disputed'] ? this.wrapper['disputed'].length : 0;
    }
    
    get paidInvoicesQuantity() {

        return this.wrapper['paid'] ? this.wrapper['paid'].length : 0;
    }    

    get openInvoicesAmount() {

        let result = 0;

        if (this.wrapper['open']) {
            this.wrapper['open'].forEach(element => {
                result += parseFloat(element.Invoice_Total__c);
            });
        }

        return result;
    }

    get paidInvoicesAmount() {

        let result = 0;

        if (this.wrapper['paid']) {
            this.wrapper['paid'].forEach(element => {
                result += parseFloat(element.Invoice_Total__c);
            });
        }

        return result;
    }
    
    get disputedInvoicesAmount() {

        let result = 0;

        if (this.wrapper['disputed']) {
            this.wrapper['disputed'].forEach(element => {
                result += parseFloat(element.Invoice_Total__c);
            });
        }

        return result;
    }        

}