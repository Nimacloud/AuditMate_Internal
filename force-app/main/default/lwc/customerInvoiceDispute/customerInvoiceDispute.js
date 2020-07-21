import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle } from 'lightning/platformResourceLoader';
import STATIC_RESOURCES from '@salesforce/resourceUrl/AuditmateCustomer';

import disputeInvoice from '@salesforce/apex/PortalFinanceController.disputeInvoice';
import getTemplateText from '@salesforce/apex/PortalFinanceController.getTemplateText';

export default class CustomerInvoiceDispute extends LightningElement {

    @api record;
    @track logo;

    templateText;
    placeholder = "Write your reason here…"

    handleSend(event) {

        let comments = this.template.querySelector(".input-comments").value;

        event.preventDefault();

        disputeInvoice({invoiceId: this.record.Id, message: comments})
        .then(() => {

            this.dispatchEvent(new ShowToastEvent({
                title: 'Thanks',
                message: 'We will send you a notification once we review this invoice.',
                variant: 'success'
            }));
            this.dispatchEvent(new CustomEvent('closemodal'));
        })

    }

    handleCancel(event) {

        event.preventDefault();
        this.dispatchEvent(new CustomEvent('closemodal'));
    }

    connectedCallback() {

        this.logo = STATIC_RESOURCES + '/images/invoice-2.png'
        loadStyle(this, STATIC_RESOURCES + '/css/style.css');

        if (this.record.Mate_Support_Status__c === 'Verified as Invalid') {

            getTemplateText({record: this.record})
            .then(resultText => {
                this.templateText = resultText;
            })
        }

    }

    get header() {

        // return this.record.Mate_Support_Status__c === 'Verified as Invalid'
        //     ? "Dispute A Invalid Invoice"
        //     : "Dispute A Valid Invoice";

        return "Dispute An Invoice";
    }

    get title() {

        return this.record.Mate_Support_Status__c === 'Verified as Invalid'
            ? "You are about to dispute an invoice"
            : "You are about to dispute a valid invoice";
    }

    get subtitle() {

        return this.record.Mate_Support_Status__c === 'Verified as Invalid'
            ? "You’ll receive a confirmation email in your email."
            : "You’ll be notified to dispute the invoice once we review your request.";
    }

    get textLabel() {

        return this.record.Mate_Support_Status__c === 'Verified as Invalid'
            ? ""
            : "You believe this invoice is invalid, please tell us why:";
    }

}