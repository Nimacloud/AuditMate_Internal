import { LightningElement, api } from 'lwc';

import { loadStyle } from 'lightning/platformResourceLoader';
import STATIC_RESOURCES from '@salesforce/resourceUrl/AuditmateCustomer';

export default class CustomerFinanceInvoices extends LightningElement {

    @api elevatorValue = 'All';
    @api allInvoices = []        

    connectedCallback() {

        loadStyle(this, STATIC_RESOURCES + '/css/style.css');
    }

}