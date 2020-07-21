import { LightningElement, api, track } from 'lwc';
import acceptProposal from '@salesforce/apex/PortalProposalController.acceptProposal';
import declineProposal from '@salesforce/apex/PortalProposalController.declineProposal';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CustomerProposalActions extends LightningElement {

    @api record;

    @track showAcceptModal = false;
    @track showDeclineModal = false;

    handleDecline() {
        this.showDeclineModal = true;
    }

    handleAccept() {
        this.showAcceptModal = true;
    }

    handleCloseModal() {
        this.showDeclineModal = false;
        this.showAcceptModal = false;

        this.dispatchEvent(new CustomEvent('closemodal'));
    }

}