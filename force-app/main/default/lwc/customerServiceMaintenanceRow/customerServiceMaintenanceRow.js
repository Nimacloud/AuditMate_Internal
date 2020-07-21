import { LightningElement, api } from 'lwc';
import STATIC_RESOURCES from '@salesforce/resourceUrl/AuditmateCustomer';

export default class CustomerServiceMaintenanceRow extends LightningElement {

    @api record;

    currentLogo = STATIC_RESOURCES + '/images/table-status-1.png'
    dueLogo = STATIC_RESOURCES + '/images/table-status-2.png'

    get isDue() {
        return this.record.equipment.Days_PM_Past_Due__c > 0;
    }    

    connectedCallback() {

        this.currentLogo = STATIC_RESOURCES + '/images/table-status-1.png'
        this.dueLogo = STATIC_RESOURCES + '/images/table-status-2.png'        
    }

}