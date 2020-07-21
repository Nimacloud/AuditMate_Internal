import { LightningElement, api, track} from 'lwc';

import getOpenInvoices from '@salesforce/apex/PortalController.getOpenInvoices';
import getDisputedInvoices from '@salesforce/apex/PortalController.getDisputedInvoices';
import getPaidInvoices from '@salesforce/apex/PortalController.getPaidInvoices';
import getAllInvoices from '@salesforce/apex/PortalController.getFinanceAllInvoices';

import getUnits from '@salesforce/apex/PortalController.getUnits';

export default class CustomerFinance extends LightningElement {

    @track showCharts = false;
    @track wrapper = {};
    @track units;
    @track accountId;

    @track openInvoices = []
    @track disputedInvoices = []
    @track allInvoices = []

    // Unit Combobox
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

        this.openInvoices = this.wrapper['open'].filter(element => {
            return this._getFilterEvaluation(element, selectedId);
        })
        this.disputedInvoices = this.wrapper['disputed'].filter(element => {
            return this._getFilterEvaluation(element, selectedId);
        })
    }

    _getFilterEvaluation(record, value) {
        return (value === 'All') ? true : record.equipment.Id === value;
    }

    _getUnits() {

        return getUnits({userId: null, accountId: this.accountId}).then(records => {
            console.log('units', this.accountId);
            console.log(records);

            if (records && records.length >= 0) {
                this.units = records;
            }
        })
    }

    _getPaidInvoices() {

        return getPaidInvoices({userId: null, accountId: this.accountId}).then(invoices => {
            console.log('getPaidInvoices', this.accountId);
            console.log(invoices);

            if (invoices && invoices.length >= 0) {
                this.wrapper['paid'] = invoices;
            }
        })
    }

    _getDisputedInvoices() {

        return getDisputedInvoices({userId: null, accountId: this.accountId}).then(invoices => {
            console.log('getDisputedInvoices', this.accountId);
            console.log(invoices);

            if (invoices && invoices.length >= 0) {
                this.wrapper['disputed'] = invoices;
                this.disputedInvoices = invoices;
            }
        })
    }

    _getOpenInvoices() {

        return getOpenInvoices({userId: null, accountId: this.accountId}).then(invoices => {
            console.log('getOpenInvoices', this.accountId);
            console.log(invoices);

            if (invoices && invoices.length >= 0) {
                this.wrapper['open'] = invoices;
                this.openInvoices = invoices;
            }
        })
    }

    _getAllInvoices() {

        return getAllInvoices({accountId: this.accountId}).then(records => {
            console.log('getAllInvoices', this.accountId);
            console.log(records);

            if (records && records.length >= 0) {
                this.allInvoices = records;
            }
        })
    }

    @api
    refresh(accountId) {

        this.accountId = accountId;
        this.wrapper = {};
        this.openInvoices = []
        this.disputedInvoices = []
        this.allInvoices = []


        if (this.accountId) {

            this.showCharts = false;

            this._getUnits()
            .then(() => {
                return this._getOpenInvoices();
            })
            .then(() => {
                return this._getDisputedInvoices();
            })
            .then(() => {
                return this._getPaidInvoices();
            })
            .then(() => {
                return this._getAllInvoices();
            })
            .then(() => {
                this._loadElevatorOptions();
                this.showCharts = true;
            })
        }
    }

    handleRefreshData() {

        this.refresh(this.accountId);
    }
}