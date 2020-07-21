import { LightningElement, api } from 'lwc';

export default class CustomerFinanceOpenInvoices extends LightningElement {

    @api records;

    handleCloseModal() {

        this.dispatchEvent(new CustomEvent('refreshdata'));
    }

}