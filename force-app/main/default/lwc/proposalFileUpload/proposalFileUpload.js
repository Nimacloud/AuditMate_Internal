import { LightningElement, api, track } from 'lwc';

import createCase from '@salesforce/apex/PortalCaseController.createProposalCase';

export default class ProposalFileUpload extends LightningElement {

    @api accountId

    @track showModal = false;
    @track showConfirmationModal = false;

    handleClick() {

        this.showModal = !this.showModal;
    }

    get acceptedFormats() {
        return ['.pdf'];
    }

    handleUploadFinished(event) {

        let contentDocumentId = event.detail.files[0].documentId;
        console.log(event.detail.files[0].documentId);

        createCase({contentDocumentId: contentDocumentId})
        .then((linkId) => {
            console.log(linkId);
            this.showModal = false;
            this.showConfirmationModal = true;
        })
        .catch((error) => {
            console.error(error);
        })

    }

    handleCloseModal(event) {

        this.showConfirmationModal = false;
        this.showModal = false;
    }

}