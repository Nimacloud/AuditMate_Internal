/* eslint-disable no-case-declarations */
/* eslint-disable no-console */
import { LightningElement, wire, track } from 'lwc';
import getInvoiceData from '@salesforce/apex/InvoiceFixerController.getInvoiceData';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent } from 'c/pubsub';

export default class InvoiceFixer extends LightningElement {

  @wire(CurrentPageReference) pageRef;

  options = [
    {'label': 'CV ID', 'value': 'CvId'},
    {'label': 'Pdf',   'value': 'Pdf'}
  ];

  problemsTabLabel = 'Problems'
  currentInput = 'CvId';
  pdfFilename;
  contentVersionId;
  historyId;
  problemCount=0;
  problems;
  problemsOriginal;

  handleClick(event) {
    const btnName = event.currentTarget.dataset.button;
    console.log('click:',btnName);
    switch (btnName) {
      case 'Get data' :
        this.getData();
        break;
      case 'Debug' :
        this.showDebugInfo();
        break;
      default:
        break;
    }
  }

  handleChange(event) {
    const field = event.target.name;
    switch(field) {
      case 'inp-cvid' :
        this.contentVersionId = event.target.value;
        break;
      case 'inp-pdf' :
        this.pdfFilename = event.target.value;
        break;
      case 'inp-problems' :
        this.problems = event.target.value;
        console.log('fire problem change', this.problems);
        fireEvent( this.pageRef, "problemChange",  this.problems ); // Problems are separated from InvoiceForm, for a better UX.
        break;
      case 'inp-problemCount' :
        if(event.target.checkValidity()) {
          this.problemCount = event.target.value;
          this.setTabLabel();
          fireEvent( this.pageRef, "problemCountChange",  this.problemCount ); // InvoiceForm listens for these events.
        }
        break;
      default:
    }
  }

  handleChange2(event) {
    this.currentInput = event.detail.value;
  }

  getData() {
    let cv='',fn='';
    if(this.contentVersionId) {
      cv = this.contentVersionId.trim();
    }
    if(this.pdfFilename) {
      fn = this.pdfFilename.trim();
    }
    getInvoiceData({CurrentInput: this.currentInput, JsonContentVersionId: cv, PdfFilename: fn} ).then(result => {
      if(result) {
        console.log(result);

        this.historyId        = result.Id;
        this.problemCount     = result.Problem_Count__c;
        this.problems         = result.Problems__c;
        this.contentVersionId = result.ContentVersionId__c;
        this.pdfFilename      = result.PdfFilename__c;
        this.problemsOriginal = this.problems;

        this.invoiceData = {
          HistoryId          : result.Id,
          PdfFilename        : result.PdfFilename__c, 
          InvoiceNumber      : result.Invoice_Number__c, 
          InvoiceDate        : result.Invoice_Date__c, 
          BillingId          : result.Billing_Id__c, 
          LocalOffice        : result.Local_Office__c, 
          BillTo             : result.Bill_To__c, 
          ContentVersionId   : result.ContentVersionId__c, 
          Contract           : result.Contract__c, 
          Description        : result.Description__c, 
          DunsNumber         : result.Duns_Number__c, 
          Expenses           : result.Expenses__c, 
          Fax                : result.Fax__c, 
          FederalTaxId       : result.Federal_Tax_Id__c, 
          FieldContact       : result.Field_Contact__c, 
          InvoiceTotal       : result.Invoice_Total__c, 
          Notification       : result.Notification__c,
          Labor              : result.Labor__c, 
          OrderNo            : result.Order_No__c, 
          OrderType          : result.Order_Type__c, 
          Payer              : result.Payer__c, 
          RemitTo            : result.Remit_To__c, 
          SalesContact       : result.Sales_Contact__c, 
          ServiceLocation    : result.Service_Location__c, 
          Subtotal           : result.Sub_Total__c, 
          Tax                : result.Tax__c, 
          Telephone          : result.Telephone__c,
          Problems           : result.Problems__c,
          ProblemCount       : result.Problem_Count__c
        };

        this.setTabLabel();
        this.showDebugInfo();

        fireEvent( this.pageRef, "invoiceData",     this.invoiceData );      // Listener: invoiceForm
        fireEvent( this.pageRef, "invoiceSelected", this.contentVersionId ); // Listener: invoiceViewer
      }
    });
  }

  setTabLabel() {
    if(this.problemCount > 0) {
      this.problemsTabLabel = `Problems (${this.problemCount})`;
    } else {
      this.problemsTabLabel = 'Problems';
    }
  }

  showDebugInfo() {
    console.log('this.invoiceData',      this.invoiceData);
    console.log('--------------------------------------------');
    console.log('this.historyId       ', this.historyId       );
    console.log('this.problemCount    ', this.problemCount    );
    console.log('this.problems        ', this.problems        );
    console.log('this.contentVersionId', this.contentVersionId);
  }

}