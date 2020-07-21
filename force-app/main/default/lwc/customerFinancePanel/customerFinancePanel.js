import { LightningElement, api } from 'lwc';

export default class CustomerFinancePanel extends LightningElement {

    @api label = 'Open Invoices'
    @api value = '3'

    get isInvoiceOpen() {

        return this.label === 'Open Invoices'
    }

}