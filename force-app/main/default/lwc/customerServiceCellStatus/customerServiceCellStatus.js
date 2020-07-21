import { LightningElement, api } from 'lwc';
import STATIC_RESOURCES from '@salesforce/resourceUrl/AuditmateCustomer';

export default class CustomerServiceCellStatus extends LightningElement {

    @api dueValue;

    currentLogo;
    dueLogo;

    get isDue() {

        return this.dueValue > 0;
    }    

    connectedCallback() {

        this.currentLogo = STATIC_RESOURCES + '/images/table-status-1.png'
        this.dueLogo = STATIC_RESOURCES + '/images/table-status-2.png'        
    }

}