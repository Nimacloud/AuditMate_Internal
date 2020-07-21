/* eslint-disable no-console */
import { LightningElement, wire} from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { registerListener, unregisterAllListeners } from 'c/pubsub';
import SaveHistoryRec from '@salesforce/apex/invoiceFormController.SaveHistoryRec';

export default class InvoiceForm extends LightningElement {

  @wire(CurrentPageReference) pageRef;
  hasRendered = false;

  pdfFilename = '';
  invoiceData;
  billingId;
  invoiceNumber;
  localOffice;
  labor;
  laborStr;
  billTo;
  contentVersionId;
  contract;
  description;
  dunsNumber;
  expenses;
  expensesStr;
  fax;
  federalTaxId;
  fieldContact;
  historyId;
  invoiceDate;
  invoiceDateStr;
  invoiceTotal;
  invoiceTotalStr;
  notification;
  orderNo;
  orderType;
  purchaseOrderNo;
  payer;
  remitTo='';
  salesContact;
  serviceLocation;
  subtotal;
  subtotalStr;
  tax;
  taxStr;
  telephone;
  problemCount=0;
  problems;

  taLocalOffice;  
  taBillto;
  taServiceLocation;
  taDescription;
  taPayer;
  taRemitTo;

  connectedCallback() {
    console.log('InvoiceForm.connectedCallback')
    registerListener('invoiceData',       this.handleInvoiceData, this);
    registerListener('problemChange',     this.handleProblemChange, this);
    registerListener('problemCountChange',this.handleProblemCountChange, this);
  }

  /*
  setTaField(field,value) {
    switch(field) {
      case 'LO' :
          this.localOffice = value;
          break;
      default:
    }
   console.log('from setTaField FN() ',this.localOffice);
  }
*/
  renderedCallback() {
    if(!this.hasRendered) {
      this.hasRendered       = true;
      this.taLocalOffice     = this.template.querySelector('.ta-local-office');
      this.taBillto          = this.template.querySelector('.ta-bill-to');
      this.taServiceLocation = this.template.querySelector('.ta-service-location');
      this.taDescription     = this.template.querySelector('.ta-description');
      this.taPayer           = this.template.querySelector('.ta-payer');
      this.taRemitTo         = this.template.querySelector('.ta-remit-to');

      // Note: using inline functions and bind to preserve 'this'.
      // See 'Getting Data into an Event Listener Using this' from https://developer.mozilla.org/en-US/docs/Web/API/EventTarget/addEventListener
      this.taLocalOffice.addEventListener('input', function (event) {
        this.localOffice = event.target.value;
      }.bind(this));

      this.taBillto.addEventListener('input', function (event) { 
        this.billTo = event.target.value;
      }.bind(this))

      this.taServiceLocation.addEventListener('input', function (event) {
        this.serviceLocation = event.target.value;
      }.bind(this))

      this.taDescription.addEventListener('input', function (event) {
        this.description = event.target.value;
      }.bind(this))

      this.taPayer.addEventListener('input', function (event) { 
        this.payer = event.target.value;
      }.bind(this))

      this.taRemitTo.addEventListener('input', function (event) { 
        this.remitTo = event.target.value;
      }.bind(this))
    }
  }

  disconnectedCallback() {
    unregisterAllListeners(this);
  }

  handleProblemChange(payload) {
    console.log('ProblemChange --> payload:',payload);
    this.problems = payload;
  }

  handleProblemCountChange(payload) {
    console.log('ProblemCountChange --> payload:',payload);
    this.problemCount = payload;
  }

  convertDateStr(dateStr) {
    let dateArray = dateStr.split('-');
    let years  = dateArray[0];
    let months = dateArray[1];
    let days   = dateArray[2];
    let retVal = `${months}/${days}/${years}`;
    return retVal;
  }

  handleInvoiceData(payload) {
    console.log('Invoice_Form --> payload:',payload);
    this.problems         = payload.Problems;
    this.problemCount     = payload.ProblemCount;
    this.pdfFilename      = payload.PdfFilename;
    this.invoiceNumber    = payload.InvoiceNumber;

    if(payload.InvoiceDate) {
      this.invoiceDate    = payload.InvoiceDate;
      this.invoiceDateStr = this.convertDateStr(this.invoiceDate);
    }
    
    this.billingId        = payload.BillingId;
    this.localOffice      = payload.LocalOffice;
    this.billTo           = payload.BillTo;
    this.contentVersionId = payload.ContentVersionId;
    this.contract         = payload.Contract;
    this.description      = payload.Description;
    this.dunsNumber       = payload.DunsNumber;
    this.expenses         = payload.Expenses;
    this.fax              = payload.Fax;
    this.federalTaxId     = payload.FederalTaxId;
    this.fieldContact     = payload.FieldContact;
    this.historyId        = payload.HistoryId;
    this.invoiceTotal     = payload.InvoiceTotal;
    this.labor            = payload.Labor;
    this.notification     = payload.Notification;
    this.orderNo          = payload.OrderNo;
    this.orderType        = payload.OrderType;
    this.payer            = payload.Payer;
    this.remitTo          = payload.RemitTo;
    this.salesContact     = payload.SalesContact;
    this.serviceLocation  = payload.ServiceLocation;
    this.subtotal         = payload.Subtotal;
    this.tax              = payload.Tax;
    this.telephone        = payload.Telephone;

    this.laborStr           = this.labor.toFixed(2);
    this.expensesStr        = this.expenses.toFixed(2);
    this.taxStr             = this.tax.toFixed(2);
    this.subtotalStr        = this.subtotal.toFixed(2);
    this.invoiceTotalStr    = this.invoiceTotal.toFixed(2);
    
  }

  saveData() {
    SaveHistoryRec({ 
      billTo          : this.billTo,
      billingId       : this.billingId,
      contract        : this.contract,
      contentVersionId: this.contentVersionId,
      description     : this.description,
      dunsNumber      : this.dunsNumber,
      expenses        : this.expensesStr,
      fax             : this.fax,
      federalTaxId    : this.federalTaxId,
      fieldContact    : this.fieldContact,
      historyId       : this.historyId,
      invoiceDate     : this.invoiceDateStr,
      invoiceNumber   : this.invoiceNumber,
      invoiceTotal    : this.invoiceTotalStr,
      labor           : this.laborStr,
      localOffice     : this.localOffice,
      notification    : this.notification,
      orderNo         : this.orderNo,
      orderType       : this.orderType,
      payer           : this.payer,
      remitTo         : this.remitTo,
      salesContact    : this.salesContact,
      serviceLocation : this.serviceLocation,
      subtotal        : this.subtotalStr,
      tax             : this.taxStr,
      telephone       : this.telephone,
      problems        : this.problems,
      problemCount    : this.problemCount
    } ).then(result => {
      const res = result;
      if(res.indexOf('Errors') == -1) {
        this.dispatchEvent(new ShowToastEvent( {title: 'Record updated', message: `Record ${res} has been saved.`, variant: 'success'}));
        console.log('Save Result: ' + res);
      } else {
        this.dispatchEvent(new ShowToastEvent( {title: 'Salesforce Error', message: `Error: ${res}.`, variant: 'error'}));      
      }
    });
  }

  handleClick(event) {
    const btnName = event.currentTarget.dataset.button;
    console.log('click:',btnName);
    switch (btnName) {
      case 'Save' :
        this.saveData();
        break;
      case 'Debug' :
        this.showDebugInfo();
        break;
      default:
    }
  }

  showDebugInfo() {
    console.log('this.problems:',       this.problems);    
    console.log('this.problemCount:',   this.problemCount);
    console.log('------------------------------------------------');
    console.log('this.invoiceNumber:',  this.invoiceNumber);
    console.log('this.invoiceDate',     this.invoiceDate);
    console.log('this.billingId',       this.billingId);
    console.log('this.fieldContact',    this.fieldContact);
    console.log('this.salesContact',    this.salesContact);
    console.log('this.telephone',       this.telephone);
    console.log('this.fax',             this.fax);
    console.log('this.federalTaxId',    this.federalTaxId);
    console.log('this.dunsNumber',      this.dunsNumber);
    console.log('this.orderType',       this.orderType);
    console.log('this.orderNo',         this.orderNo);
    console.log('this.contract',        this.contract);
console.log('------------------------------------------------');
    console.log('this.localOffice',     this.localOffice);
    console.log('this.billTo',          this.billTo);
    console.log('this.serviceLocation', this.serviceLocation);
    console.log('this.payer',           this.payer);
    console.log('this.remitTo',         this.remitTo);
console.log('------------------------------------------------');
    console.log('this.labor',           this.labor);
    console.log('this.expenses',        this.expenses);
    console.log('this.tax',             this.tax);
    console.log('this.subtotal',        this.subtotal);
    console.log('this.invoiceTotal',    this.invoiceTotal);
    console.log('this.description',     this.description);

    console.log('---------------------------------------------');
    console.log('this.laborStr',        this.laborStr);
    console.log('this.expensesStr',     this.expensesStr);
    console.log('this.taxStr',          this.taxStr);
    console.log('this.subtotalStr',     this.subtotalStr);
    console.log('this.invoiceTotalStr', this.invoiceTotalStr);    
  }

  handleChange(event) {
    const field = event.target.name;
    switch(field) {

      case 'inp-ta-local-office' :
        this.localOffice = event.target.value;
        console.log('inp-ta-local-office');
        console.log(event.target.value);
        break;

      case 'inp-ta-bill-to' :
        this.billTo = event.target.value;
        console.log('inp-ta-bill-to');
        console.log(event.target.value);
        break;

      case 'inp-ta-service-location' :
        this.serviceLocation = event.target.value;
        console.log('inp-ta-service-location');
        console.log(event.target.value);
        break;

      case 'inp-ta-description' :
        this.description    = event.target.value;
        console.log('inp-ta-description');
        console.log(event.target.value);
        break;

      case 'inp-ta-payer' :
        this.payer    = event.target.value;
        console.log('inp-ta--payer');
        console.log(event.target.value);
        break;

      case 'inp-ta-remit-to' :
        this.remitTo    = event.target.value;
        console.log('inp-ta-remit-to');
        console.log(event.target.value);
        break;

      case 'inp-invoice-number' :
        this.invoiceNumber = event.target.value;
        break;

      case 'inp-notification' :
        this.notification = event.target.value;
        break;
      case 'inp-invoice-date' :
         this.invoiceDate = event.target.value;
         this.invoiceDateStr = this.convertDateStr(this.invoiceDate);
         console.log('this.invoiceDateStr',this.invoiceDateStr);
        break;
      case 'inp-billing-id'   :
         this.billingId = event.target.value;
        break;
      case 'inp-field-contact' :
         this.fieldContact = event.target.value;
        break;
      case 'inp-sales-contact' :
         this.salesContact = event.target.value;
        break;
      case 'inp-telephone'  :
         this.telephone = event.target.value;
        break;
      case 'inp-fax'     :
         this.fax = event.target.value;
        break;
      case 'inp-federal-tax-id' :
         this.federalTaxId = event.target.value;
        break;
      case 'inp-duns-number' :
         this.dunsNumber = event.target.value;
        break;
      case 'inp-order-type'   : 
         this.orderType = event.target.value;
        break;
      case 'inp-order-no'    :
         this.orderNo = event.target.value;
        break;
      case 'inp-contract'     : 
         this.contract = event.target.value;
        break;

      case 'inp-labor' :  
        this.laborStr = event.target.value;
        this.labor    = parseFloat(this.laborStr);
        break;

      case 'inp-expenses' : 
        this.expensesStr = event.target.value;
        this.expenses    = parseFloat(this.expensesStr);
        break;
      case 'inp-invoice-total' :  
        this.invoiceTotalStr = event.target.value;
        this.invoiceTotal    = parseFloat(this.invoiceTotalStr);
        break;

      case 'inp-subtotal' :  
        this.subtotalStr = event.target.value;
        this.subtotal    = parseFloat(this.subtotalStr);
        break;
      case 'inp-tax' :
        this.taxStr = event.target.value;
        this.tax    = parseFloat(this.taxStr);
        break;
      default:
    }
  }

}