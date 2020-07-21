import { LightningElement, api } from 'lwc';
import STATIC_RESOURCES from '@salesforce/resourceUrl/AuditmateCustomer';
import { loadStyle } from 'lightning/platformResourceLoader';

export default class CustomerFinanceCellStatus extends LightningElement {

    @api statusValue;
    @api systemValue;

    paidLogo;
    voidLogo;

    get isVoid() {
        return this.statusValue === 'Void'
    }

    get isValid() {
        return this.systemValue === 'Verified as Valid'
    }

    connectedCallback() {

        this.paidLogo = STATIC_RESOURCES + '/images/table-status-1.png'
        this.voidLogo = STATIC_RESOURCES + '/images/table-status-2.png'
        loadStyle(this, STATIC_RESOURCES + '/css/style.css');
    }

}