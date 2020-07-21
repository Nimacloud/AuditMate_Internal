import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import acceptInvoice from '@salesforce/apex/PortalFinanceController.acceptInvoice';
import payInvoice from '@salesforce/apex/PortalFinanceController.payInvoice';
import renegociateInvoice from '@salesforce/apex/PortalFinanceController.renegociateInvoice';
import disputeInvoice from '@salesforce/apex/PortalFinanceController.disputeInvoice';

export default class CustomerFinanceInvoiceDetail extends LightningElement {

    @api record;
    @track showModal = false;

    @api isOpen = false

    @track showPaymentModal = false;
    @track showDisputeModal = false;
    @track showAcceptModal = false;
    @track showRenegociateModal = false;

    handleToggleModal(event) {

        event.preventDefault();
        this.showModal = !this.showModal;
    }

    get validText() {

        if (this.record.SystemStatus__c === 'Verified_As_Valid') {
            return "- Valid";
        }
        if (this.record.SystemStatus__c === 'Verified_As_Invalid') {
            return "- Invalid";
        }
    }

    handleCloseModal() {
        this.showPaymentModal = false;
        this.showDisputeModal = false;
        this.showAcceptModal = false;
        this.showRenegociateModal = false;
        this.showModal = false;
    }

    handlePay() {
        this.showModal = false;
        this.showPaymentModal = true;
    }

    handleDispute() {
        this.showModal = false;
        this.showDisputeModal = true;
    }

    handleAccept() {
        this.showModal = false;
        this.showAcceptModal = true;
    }

    handleRenegociate() {
        this.showModal = false;
        this.showRenegociateModal = true;
    }

    // handlePay() {

    //     let comments = this.template.querySelector(".input-comments").value;

    //     payInvoice({invoiceId: this.record.Id, message: comments})
    //     .then(() => {

    //         this.dispatchEvent(new ShowToastEvent({
    //             title: 'Thanks',
    //             message: 'You will receive a confirmation email.',
    //             variant: 'success'
    //         }));
    //         this.dispatchEvent(new CustomEvent('closemodal'));
    //         this.handleCloseModal();
    //     })
    // }

    // handleDispute() {

    //     let comments = this.template.querySelector(".input-comments").value;

    //     disputeInvoice({invoiceId: this.record.Id, message: comments})
    //     .then(() => {

    //         this.dispatchEvent(new ShowToastEvent({
    //             title: 'Thanks',
    //             message: 'We will send you a notification once we review this invoice.',
    //             variant: 'success'
    //         }));
    //         this.dispatchEvent(new CustomEvent('closemodal'));
    //         this.handleCloseModal();
    //     })
    // }

    // handleAccept() {

    //     acceptInvoice({invoiceId: this.record.Id})
    //     .then(() => {

    //         this.dispatchEvent(new ShowToastEvent({
    //             title: 'Thanks',
    //             message: 'You will receive a confirmation email.',
    //             variant: 'success'
    //         }));
    //         this.dispatchEvent(new CustomEvent('closemodal'));
    //         this.handleCloseModal();
    //     })
    // }

    // handleRenegociate() {

    //     let comments = this.template.querySelector(".input-comments").value;

    //     renegociateInvoice({invoiceId: this.record.Id, message: comments})
    //     .then(() => {

    //         this.dispatchEvent(new ShowToastEvent({
    //             title: 'Thanks',
    //             message: 'You will receive a confirmation email.',
    //             variant: 'success'
    //         }));
    //         this.dispatchEvent(new CustomEvent('closemodal'));
    //         this.handleCloseModal();
    //     })
    // }
}