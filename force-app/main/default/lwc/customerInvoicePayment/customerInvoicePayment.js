import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import STATIC_RESOURCES from '@salesforce/resourceUrl/AuditmateCustomer';

import payInvoice from '@salesforce/apex/PortalFinanceController.payInvoice';

export default class CustomerInvoicePayment extends LightningElement {

    @api record;
    @track logo

    handleSend(event) {

        event.preventDefault();

        payInvoice({invoiceId: this.record.Id})
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

        this.logo = STATIC_RESOURCES + '/images/invoice-3.png'
    }

}