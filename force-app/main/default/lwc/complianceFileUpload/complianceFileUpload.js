import { LightningElement, api, track } from 'lwc';

import createCase from '@salesforce/apex/PortalCaseController.createInspectionCase';

export default class ComplianceFileUpload extends LightningElement {

    @api accountId

    @track showModal = false;

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
        })
        .catch((error) => {
            console.error(error);
        })
    }

}