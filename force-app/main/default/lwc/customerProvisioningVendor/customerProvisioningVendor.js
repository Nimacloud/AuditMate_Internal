import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';



import STATIC_RESOURCES from '@salesforce/resourceUrl/AuditmateCustomer';

export default class CustomerProvisioningVendor extends NavigationMixin(LightningElement) {

    @api vendorName = "otis"
    @api vendorId

    logo

    connectedCallback() {

        this.logo = STATIC_RESOURCES + '/images/vendors/' + this.vendorName + '.png';
    }

}