import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class CustomerServiceMaintenance extends NavigationMixin(LightningElement) {


    @api records;
    @api accountId;

    @track selectedIds = {};

    handleCheckboxChange(event) {


        let isChecked = event.target.checked;
        let recordId = event.target.dataset.recordId;

        if (isChecked === true) {
            this.selectedIds[recordId] = recordId;
        }
        else {
            this.selectedIds[recordId] = undefined;
        }
    }


    handleNavigation(event) {

        event.preventDefault();

        let recordId = event.target.dataset.recordId;

        this[NavigationMixin.Navigate](
            {
                type: 'standard__recordPage',
                attributes: {
                    recordId: recordId,
                    objectApiName: 'Equipment__c',
                    actionName: 'view'
                }
            }
        )

    }
}