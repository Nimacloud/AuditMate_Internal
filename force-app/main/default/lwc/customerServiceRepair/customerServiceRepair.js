import { LightningElement, api, track } from 'lwc';

export default class CustomerServiceRepair extends LightningElement {

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

}