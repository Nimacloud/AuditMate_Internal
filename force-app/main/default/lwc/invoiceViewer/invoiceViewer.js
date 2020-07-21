/* eslint-disable no-console */
import { LightningElement, wire} from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterAllListeners } from 'c/pubsub';
import  getPdfDocId from '@salesforce/apex/InvoiceViewerController.getPdfDocId';

export default class InvoiceViewer extends LightningElement {

  @wire(CurrentPageReference) pageRef;
  urlPrefix;
 
  title  = 'Invoice Pdf Viewer';
  srcUrl = ''; // 'https://graham--developer1.lightning.force.com/lightning/r/ContentDocument/06955000001Ph28AAC/view';

  connectedCallback() {
    console.log('InvoiceViewer.connectedCallback')
    registerListener('invoiceSelected', this.handleInvoiceSelected, this);
    const loc      = window.location.href;
    this.urlPrefix = loc.substring(0,loc.indexOf('.com')+4) + '/lightning/r/ContentDocument/';
    console.log(`prefix : ${this.urlPrefix}`);
  }

  disconnectedCallback() {
    unregisterAllListeners(this);
  }

  refreshPdf(cvId) {
     getPdfDocId({contentVersionId: cvId}).then(result => {
     this.srcUrl = `${this.urlPrefix}${result}/view`;
     console.log('newUrl',this.srcUrl);
   });
  }
   
  handleInvoiceSelected(payload) {
    console.log('Invoice_Viewer --> payload:',payload);
    this.refreshPdf(payload);
   }

 
}