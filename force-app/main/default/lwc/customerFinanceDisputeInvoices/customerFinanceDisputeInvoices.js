import { LightningElement, api } from 'lwc';

export default class CustomerFinanceDisputeInvoices extends LightningElement {

    @api records;

    handleCloseModal() {

        this.dispatchEvent(new CustomEvent('refreshdata'));
    }
}