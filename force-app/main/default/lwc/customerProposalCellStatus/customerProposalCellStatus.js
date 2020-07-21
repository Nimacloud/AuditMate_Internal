import { LightningElement, api } from 'lwc';
import STATIC_RESOURCES from '@salesforce/resourceUrl/AuditmateCustomer';
import { loadStyle } from 'lightning/platformResourceLoader';

export default class CustomerProposalCellStatus extends LightningElement {

    @api value;
    @api customerStatus;

    approvedLogo;
    declinedLogo;    

    get isValid() {
        return this.value === 'Valid'
    }

    get isValidCustomerStatus() {

        return this.customerStatus === 'Accepted'
    }


    connectedCallback() {
        this.approvedLogo = STATIC_RESOURCES + '/images/table-status-1.png'
        this.declinedLogo = STATIC_RESOURCES + '/images/table-status-2.png'        
        loadStyle(this, STATIC_RESOURCES + '/css/style.css');
    }

}