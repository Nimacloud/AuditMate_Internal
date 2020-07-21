import { LightningElement, api, track } from 'lwc';
import getUnits from '@salesforce/apex/PortalController.getUnits';
import getOpenProposals from '@salesforce/apex/PortalController.getOpenProposals';
import getProposalsHistory from '@salesforce/apex/PortalController.getProposalsHistory';

export default class CustomerProposal extends LightningElement {

    @track showPage = false;

    // Tabs
    @track wrapper = {};
    @track openProposals = [];
    @track historyProposals = [];
    @track accountId;

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

        this.openProposals = this.wrapper['open'].filter(element => {
            return this._getFilterEvaluation(element, selectedId);
        })
        this.historyProposals = this.wrapper['history'].filter(element => {
            return this._getFilterEvaluation(element, selectedId);
        })
    }

    _getFilterEvaluation(record, value) {
        return (value === 'All') ? true : record.Id === value;
    }

    _getUnits() {

        return getUnits({userId: this.userId, accountId: this.accountId}).then(records => {

            if (records && records.length > 0) {
                this.units = records;
            }
        })
    }

    _getOpenProposals() {

        return getOpenProposals({accountId: this.accountId})
        .then(records => {
            this.wrapper['open'] = records;
            this.openProposals = records;
            console.log(JSON.stringify(this.openProposals));
        })
    }

    _getProposalHistory() {

        return getProposalsHistory({accountId: this.accountId})
        .then(records => {
            this.wrapper['history'] = records;
            this.historyProposals = records;
        })
    }

    @api
    refresh(accountId) {

        this.accountId = accountId;
        this.wrapper = {};
        this.openProposals = [];
        this.historyProposals = [];

        if (this.accountId) {

            this.showPage = false;

            this._getUnits()
            .then(() => {

                this._getOpenProposals();
                this._getProposalHistory();
                this._loadElevatorOptions();

                this.showPage = true;
            })
        }
    }

    handleRefreshData() {
        this.refresh(this.accountId);
    }

}