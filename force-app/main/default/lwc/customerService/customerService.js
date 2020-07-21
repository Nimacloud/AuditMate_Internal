import { LightningElement, track, api } from 'lwc';

import getUnits from '@salesforce/apex/PortalController.getUnits';
import getServiceCallbackActivities from '@salesforce/apex/PortalController.getServiceCallbackActivities';

export default class CustomerService extends LightningElement {

    // displayed records;
    _units = [];
    _callbacks = [];
    @track units = [];
    @track callbacks = [];
    @track accountId;

    // Unit Combobox
    @track elevatorValue = 'All';
    elevatorOptions = [];

    handleElevatorChange(event) {

        this.elevatorValue = event.detail.value;
        let selectedId = event.detail.value;

        this.units = this._units.filter(element => {
            return this._getFilterEvaluation(element, selectedId);
        })

        this.callbacks = this._callbacks.filter(element => {
            return (selectedId === 'All') ? true : element.equipment.Id === selectedId;
        })

        console.log(this.callbacks);
    }

    _getFilterEvaluation(record, value) {
        return (value === 'All') ? true : record.Id === value;
    }

    _loadElevatorOptions() {

        this.elevatorOptions = [
            {label: 'All Elevators', value: 'All'}
        ];

        this._units.forEach(element => {
            this.elevatorOptions.push({
                label: element.Display_Name__c,
                value: element.Id
            })
        })

        this.elevatorValue = 'All';
    }

    _getUnits() {

        return getUnits({userId: this.userId, accountId: this.accountId}).then(records => {

            if (records && records.length >= 0) {
                this.units = records;
                this._units = records;
            }
        })
    }

    _getCallbacks() {
        return getServiceCallbackActivities({accountId: this.accountId})
    }

    @api
    refresh(accountId) {

        this.accountId = accountId;
        let that = this;

        if (this.accountId) {

            // getFuntion(this.accountId);

            this._getUnits()
            .then(() => {
                this._loadElevatorOptions();

                // return getServiceCallbackActivities(accountId);
                return this._getCallbacks();
            })
            .then((result) => {
                if (result && result.length >= 0) {
                    this._callbacks = result;
                    this.callbacks = this._callbacks;
                }
            })
        }
    }

}