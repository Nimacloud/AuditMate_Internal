import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import getUnits from '@salesforce/apex/PortalController.getUnits';
import getUnitsAndInspections from '@salesforce/apex/PortalController.getUnitsAndInspections';
import getProposalsHistory from '@salesforce/apex/PortalController.getProposalsHistory';
import getAcceptedProposals from '@salesforce/apex/PortalController.getAcceptedProposals';

import getInspectionFindings from '@salesforce/apex/PortalController.getInspectionFindings';
import getStateRecordsWithInspections from '@salesforce/apex/PortalController.getStateRecordsWithInspections';
import getStateRecords from '@salesforce/apex/PortalController.getStateRecords';
import getPreventiveActivities from '@salesforce/apex/PortalController.getPreventiveActivities';
import getUpcomingActivities from '@salesforce/apex/PortalController.getUpcomingActivities';

import getInvoices from '@salesforce/apex/PortalController.getInvoices';
import getOpenInvoices from '@salesforce/apex/PortalController.getOpenInvoices';
import getDisputedInvoices from '@salesforce/apex/PortalController.getDisputedInvoices';
import getDueInvoices from '@salesforce/apex/PortalController.getDueInvoices';
import getSelectedAccount from '@salesforce/apex/CustomerUserHandler.getSelectedAccount';

import getMaintenanceActivityCount from '@salesforce/apex/PortalActivityController.getMaintenanceActivityCount';
import getTestingFiveActivityCount from '@salesforce/apex/PortalActivityController.getTestingFiveActivityCount';
import getTestingOneActivityCount from '@salesforce/apex/PortalActivityController.getTestingOneActivityCount';

import Id from '@salesforce/user/Id';

export default class CustomerSummary extends NavigationMixin(LightningElement) {

    userId = Id
    @track accountId;

    @track units = []

    @track disputedInvoices = 0
    @track openInvoices = 0
    @track dueInvoices = 0
    @track inspectionFindings = 0;
    @track stateRecords = 0;

    @track openProposals = 0;
    @track historyProposals = 0;

    @track maintenanceCompletionRate;
    @track testingCompletionRate;
    @track avgResponseTime = 0;

    @track upcomingMaintenance;
    @track upcomingCat1;
    @track upcomingCat5;

    @track dataRecord;
    @track testingFive;
    @track testingOne;
    @track maintenanceWrapper;
    @track showCharts;

    @api
    refresh(accountId) {

        this.accountId = accountId;
        this.showCharts = undefined;

        if (this.accountId) {

            this._getUnits(this.accountId)
            .then(() => {
                return accountId;
            })
            .then(accountId => {
                this._getInvoices(this.accountId);
                return accountId;
            })
            .then(accountId => {

                getMaintenanceActivityCount({accountId :this.accountId})
                .then(wrapper => {
                    this.maintenanceWrapper = wrapper;
                    return accountId;
                })
            })
            .then(accountId => {
                getTestingFiveActivityCount({accountId :this.accountId})
                .then(wrapper => {
                    this.testingFive = wrapper;
                    return accountId;
                })
            })
            .then(accountId => {
                getTestingOneActivityCount({accountId :this.accountId})
                .then(wrapper => {
                    this.testingOne = wrapper;
                    return accountId;
                })
            })
            .then(accountId => {
                this._getOpenInvoices(this.accountId);
                return accountId;
            })
            .then(accountId => {
                this._getDisputedInvoices(this.accountId);
                return accountId;
            })
            .then(accountId => {
                this._getDueInvoices(this.accountId);
                return accountId;
            })
            .then(accountId => {
                this._getStateRecords(this.accountId);
                return accountId;
            })
            .then(accountId => {
                this._getInspectionFindings(this.accountId);
                return accountId;
            })
            .then(accountId => {
                this._getAcceptedProposals(this.accountId);
                return accountId;
            })
            .then(accountId => {
                this._getProposalsHistory(this.accountId);
                return accountId;
            })
            .then(accountId => {
                this._getUpcomingActivities(this.accountId);
                return accountId;
            })
            .then(accountId => {
                getSelectedAccount({accountId: this.accountId})
                .then((accountRecord) => {
                    this.showCharts = true;
                })
            })
        }
    }
    _getUnits(accountId) {

        return getUnits({userId: this.userId, accountId: accountId}).then(units => {
            //
            //
            this.units = units;
        })
    }

    _getInvoices(accountId) {

        getInvoices({userId: this.userId, accountId: accountId}).then(invoices => {
            //
            //
        })
    }

    _getStateRecords(accountId) {

        getStateRecords({userId: this.userId, accountId: accountId}).then(stateRecords => {
            //
            //

            if (stateRecords && stateRecords.length >= 0) {
                this.stateRecords = stateRecords.length;
            }

        })
    }

    _getProposalsHistory(accountId) {

        getProposalsHistory({userId: this.userId, accountId: accountId}).then(proposalHistory => {
            //
            //

            if (proposalHistory && proposalHistory.length >= 0) {
                this.historyProposals = proposalHistory.length;
            }
        })
    }

    _getAcceptedProposals(accountId) {

        getAcceptedProposals({userId: this.userId, accountId: accountId}).then(proposals => {
            //
            //

            if (proposals && proposals.length >= 0) {
                this.openProposals = proposals.length;
            }
        })
    }

    _getUpcomingActivities(accountId) {

        getUpcomingActivities({accountId: accountId}).then(preventiveActivities => {



            this.upcomingMaintenance = undefined;
            this.upcomingCat1 = undefined;
            this.upcomingCat5 = undefined;
            this.dataRecord = undefined;
            let m = 0;
            let c5 = 0;
            let c1 = 0;

            if (preventiveActivities && preventiveActivities.length > 0) {
                this.upcomingActivities = preventiveActivities

                preventiveActivities.forEach(element => {

                    if (element.Type__c === 'MNT') {
                        m ++;
                    }
                    else if (element.Type__c === 'TEST') {

                        if (element.Category__c === 'Category 1') {
                            c1 ++;
                        }
                        else if (element.Category__c === 'Category 5') {
                            c5 ++;
                        }
                    }
                });
            }

            this.dataRecord = {
                total: undefined,
                firstAmount: m,
                secondAmount: c1,
                thirdAmount: c5,
                firstAmountLabel: 'Maintenance',
                secondAmountLabel: 'Category 1',
                thirdAmountLabel: 'category 5',
            }

            this.upcomingMaintenance = m;
            this.upcomingCat1 = c1;
            this.upcomingCat5 = c5;
            //


            //
        })
    }

    _getDueInvoices(accountId) {

        getDueInvoices({userId: this.userId, accountId: accountId}).then(invoices => {
            //
            //

            if (invoices && invoices.length >= 0) {
                this.dueInvoices = invoices.length;
            }
        })
    }

    _getDisputedInvoices(accountId) {

        getDisputedInvoices({userId: this.userId, accountId: accountId}).then(invoices => {
            //
            //

            if (invoices && invoices.length >= 0) {
                this.disputedInvoices = invoices.length;
            }
        })
    }

    _getOpenInvoices(accountId) {

        getOpenInvoices({userId: this.userId, accountId: accountId}).then(invoices => {
            //
            //

            if (invoices && invoices.length >= 0) {
                this.openInvoices = invoices.length;
            }

        })
    }

    _getInspectionFindings(accountId) {

        getInspectionFindings().then(inspectionFindings => {

            if (inspectionFindings && inspectionFindings.length >= 0) {

                let openInspections = inspectionFindings.filter(element => {
                    return element.Status__c === 'Open'
                })

                this.inspectionFindings = openInspections.length;
            }

        })
    }

    navigateInvoicesClick() {

        this[NavigationMixin.Navigate](
            {
                type: 'comm__namedPage',
                attributes: {
                    name: 'Finance__c'
                }
            }
        )
    }

    navigateInspectionsClick() {

        this[NavigationMixin.Navigate](
            {
                type: 'comm__namedPage',
                attributes: {
                    name: 'Compliance__c'
                }
            }
        )
    }

    navigateProposalsClick() {

        this[NavigationMixin.Navigate](
            {
                type: 'comm__namedPage',
                attributes: {
                    name: 'Proposal__c'
                }
            }
        )
    }

    navigateServicesClick() {

        this[NavigationMixin.Navigate](
            {
                type: 'comm__namedPage',
                attributes: {
                    name: 'Service__c'
                }
            }
        )
    }

}