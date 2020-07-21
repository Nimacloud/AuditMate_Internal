import { LightningElement, api, track } from 'lwc';

import getAllActivities from '@salesforce/apex/PortalController.getServiceAllActivities';
import getPeriodActivities from '@salesforce/apex/PortalController.getServicePeriodActivities';


export default class CustomerServiceActivities extends LightningElement {

    @api accountId;
    @api elevatorValue;

    @track selectedIds = {};

    @track records;
    @track dateValue = 'THIS_MONTH';
    @track startDate = undefined;
    @track endDate = undefined;

    @track dateOptions = [
        {label: 'Today', value: 'TODAY'},
        {label: 'This Week', value: 'THIS_WEEK'},
        {label: 'Last Week', value: 'LAST_WEEK'},
        {label: 'This Month', value: 'THIS_MONTH'},
        {label: 'Last Month', value: 'LAST_MONTH'},
        {label: 'Custom', value: 'CUSTOM'}
    ];

    connectedCallback() {



        if (this.dateValue !== 'CUSTOM') {
            this._getAllActivities();
        }
        else {
            this._getPeriodActivities();
        }
    }

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

    handleDateChange(event) {

        this.dateValue = event.detail.value;

        if (this.dateValue !== 'CUSTOM') {
            this._getAllActivities();
        }
    }

    handleStartDateChange(event) {
        this.startDate = event.detail.value;
    }

    handleEndDateChange(event) {
        this.endDate = event.detail.value;
    }

    handleGoClick(event) {

        this._getPeriodActivities();
    }

    get isCustom() {

        return this.dateValue === 'CUSTOM';
    }

    _getPeriodActivities() {

        let _elevatorValue = this.elevatorValue;

        getPeriodActivities({accountId: this.accountId, startDate: this.startDate, endDate: this.endDate})
        .then(activities => {

            if (activities && activities.length > 0) {
                this.records = activities.filter(element => {
                    return this._getFilterEvaluation(element, _elevatorValue);
                });
            }
        });

    }

    _getAllActivities() {

        let _elevatorValue = this.elevatorValue;

        getAllActivities({accountId: this.accountId, period: this.dateValue})
        .then(activities => {

            if (activities && activities.length > 0) {
                this.records = activities.filter(element => {
                    return this._getFilterEvaluation(element, _elevatorValue);
                });
            }
        });
    }

    _getFilterEvaluation(record, value) {
        return (value === 'All') ? true : record.equipment.Id === value;
    }

}