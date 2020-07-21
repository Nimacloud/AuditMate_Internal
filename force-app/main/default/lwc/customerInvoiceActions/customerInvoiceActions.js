import { LightningElement, api, track} from 'lwc';
import getThisMonthActivities from '@salesforce/apex/PortalController.getThisMonthActivities';

export default class CustomerInvoiceActions extends LightningElement {

    @api record
    @api mode;

    @track actionValue;
    @track actionOptions = [];

    @track showPaymentModal = false;
    @track showDisputeModal = false;
    @track showAcceptModal = false;
    @track showRenegociateModal = false;

    get isOpenValid() {
        return this.mode === "open";
    }

    get isDisputeValid() {
        return this.mode === "dispute";
    }

    handlePay() {
        this.showPaymentModal = true;
    }

    handleDispute() {
        this.showDisputeModal = true;
    }

    handleAccept() {
        this.showAcceptModal = true;
    }

    handleRenegociate() {
        this.showRenegociateModal = true;
    }

    handleCloseModal() {
        this.showPaymentModal = false;
        this.showDisputeModal = false;
        this.showAcceptModal = false;
        this.showRenegociateModal = false;

        this.dispatchEvent(new CustomEvent('closemodal'));
    }
}