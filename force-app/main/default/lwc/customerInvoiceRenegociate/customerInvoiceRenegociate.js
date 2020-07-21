import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import STATIC_RESOURCES from '@salesforce/resourceUrl/AuditmateCustomer';

import renegociateInvoice from '@salesforce/apex/PortalFinanceController.renegociateInvoice';

export default class CustomerInvoiceRenegociate extends LightningElement {

    @api record;
    @track logo

    handleSend(event) {

        let comments = this.template.querySelector(".input-comments").value;

        event.preventDefault();

        renegociateInvoice({invoiceId: this.record.Id, message: comments})
        .then(() => {

            this.dispatchEvent(new ShowToastEvent({
                title: 'Thanks',
                message: 'You will receive a confirmation email.',
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

        this.logo = STATIC_RESOURCES + '/images/invoice-1.png'
    }

}