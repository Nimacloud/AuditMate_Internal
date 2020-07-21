import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getContentDocumentId from "@salesforce/apex/PortalFileController.getContentDocumentId";

export default class ContractFileDownload extends NavigationMixin(LightningElement) {

    @api objectId;

    handleDownload() {

        let that = this;

        getContentDocumentId({ recordId: this.objectId })
        .then((fileId) => {

            if (fileId == null || fileId == 'null') {

                this.dispatchEvent(new ShowToastEvent({
                    title: 'No File',
                    message: 'There is no file associated',
                    variant: 'warning'
                }));

            }
            else {

                console.log(fileId)
                console.log(window.location.origin);

                let url = window.location.origin + '/customers/sfc/servlet.shepherd/document/download/' + fileId;

                that[NavigationMixin.Navigate]({
                    type: 'standard__webPage',
                    attributes: {
                        url: url
                    }
                });
            }
        });

    }
}