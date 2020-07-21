import { LightningElement, api, track } from 'lwc';

import getStateRecords from '@salesforce/apex/PortalController.getStateRecords';
import getInspectionFindings from '@salesforce/apex/PortalController.getInspectionFindings';
import getUnits from '@salesforce/apex/PortalController.getUnits';

export default class CustomerCompliance extends LightningElement {

    @track accountId;

    // Tabs
    @track wrapper = {};
    @track stateRecords = [];
    @track openInspections = [];

    // Unit Combobox
    @track units;
    @track elevatorValue = 'All';
    elevatorOptions = [];
    
    _loadElevatorOptions() {

        this.elevatorOptions = [
            {label: 'All Elevators', value: 'All'}
        ];        

        if (this.units && this.units.length > 0) {
            this.units.forEach(element => {
                this.elevatorOptions.push({
                    label: element.Display_Name__c,
                    value: element.Id
                })
            })
        }

        this.elevatorValue = 'All';
    }    

    handleElevatorChange(event) {

        this.elevatorValue = event.detail.value;
        let selectedId = event.detail.value;

        this.stateRecords = this.wrapper['states'].filter(element => {
            return this._getFilterEvaluationStates(element, selectedId);
        })

        this.openInspections = this.wrapper['inspections'].filter(element => {
            return this._getFilterEvaluationInspections(element, selectedId);
        })                              
    }    

    _getFilterEvaluationInspections(record, value) {
        return (value === 'All') ? true : record.State_Inspection__r.Equipment__c === value;
    }

    _getFilterEvaluationStates(record, value) {
        return (value === 'All') ? true : record.Equipment__c === value;
    }    

    _getUnits() {

        return getUnits({userId: this.userId, accountId: this.accountId}).then(records => {

            if (records && records.length > 0) {
                this.units = records;
            } 
        })
    }    

    _getStateRecords() {

        return getStateRecords({accountId: this.accountId})
        .then(records => {

            console.log('getStateRecords');
            console.log(records);

            this.wrapper['states'] = records;
            this.stateRecords = records;
        })
    }

    _getInspectionFindings() {

        return getInspectionFindings({accountId: this.accountId})
        .then(records => {

            console.log('getInspectionFindings');
            console.log(records);

            this.wrapper['inspections'] = records;
            this.openInspections = records;
        })
    }    

    @api
    refresh(accountId) {

        this.accountId = accountId;

        if (this.accountId) {

            this._getUnits()
            .then(() => {

                this._getInspectionFindings();
                this._getStateRecords();
                this._loadElevatorOptions();
            })    
        }
    }        

}