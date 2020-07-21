import { LightningElement, track, wire, api } from 'lwc';
import getActiveContract from '@salesforce/apex/PortalContractController.getActiveContract';

export default class Contract extends LightningElement {

    @track accountId;
    @track contractRecord;

    get serviceFrequencyMessage() {

        if (this.contractRecord !== undefined) {

            if (this.contractRecord.Frequency_of_service__c === 'Periodically') {
                return "No Minimum Requirement";
            }
        }

        return "";
    }

    get callbackHoursIncludedMessage() {

        if (this.contractRecord !== undefined) {

            if (this.contractRecord.Call_Back_Coverage__c === 'Regular Business Hours - Undefined') {
                return "Unspecified Vendor Discretion";
            }
        }

        return "";

    }

    @api
    refresh(accountId) {

        this.accountId = accountId;

        if (this.accountId) {

            getActiveContract({accountId: accountId})
            .then((contractRecord) => {

                this.contractRecord = contractRecord;
            })
        }
    }



}