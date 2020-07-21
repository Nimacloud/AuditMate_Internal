import { LightningElement, wire, track } from 'lwc';

import { createRecord, updateRecord } from 'lightning/uiRecordApi';

import getCommunityContact from '@salesforce/apex/CustomerUserHandler.getCommunityContact'
import setAccountVendor from '@salesforce/apex/CustomerUserHandler.setAccountVendor'
import updateExistingAccount from '@salesforce/apex/CustomerUserHandler.updateExistingAccount'
import createNewContact from '@salesforce/apex/CustomerUserHandler.createNewContact'
import createCase from '@salesforce/apex/PortalCaseController.createContractCase';

import CONTACT_OBJECT from '@salesforce/schema/Contact';
import CONTACT_LASTNAME from '@salesforce/schema/Contact.LastName';
import CONTACT_PHONE from '@salesforce/schema/Contact.Phone';
import CONTACT_EMAIL from '@salesforce/schema/Contact.Email';

import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import STATIC_RESOURCES from '@salesforce/resourceUrl/AuditmateCustomer';

export default class CustomerProvisioning extends LightningElement {

    @track acceptedForwardInvoices = false;
    @track password;
    @track showModal = false;
    @track showStatusModal = false;
    @track status = 'FIRST';
    @track username;

    pic;
    logo;

    @track selectedLogo;
    @track selectedVendorId;

    accountId;
    accountOwner;
    contact;

    get showFirstScreen() {
        return this.status === 'FIRST';
    }

    get showSecondScreen() {
        return this.status === 'SECOND';
    }

    get showThirdScreen() {
        return this.status === 'THIRD';
    }

    get showFourthScreen() {
        return this.status === 'FOURTH';
    }

    get acceptedFormats() {
        return ['.pdf'];
    }

    handleVendorClicked(event) {

        let vendorId = event.target.dataset.vendor;
        this.selectedVendorId = vendorId;

        let vendorName = event.target.dataset.vendorName;
        this.selectedLogo = STATIC_RESOURCES + '/images/vendors/selected/' + vendorName + '.png';
        this.status = 'SECOND';
    }

    handleUploadFinished(event) {

        let contentDocumentId = event.detail.files[0].documentId;
        console.log(event.detail.files[0].documentId);

        createCase({contentDocumentId: contentDocumentId})
        .then((linkId) => {
            console.log(linkId);
            this.status = 'THIRD';
        })
        .catch((error) => {
            console.error(error);
        })

    }

    handleContinue(event) {

        if (this.status === 'FIRST') {
            this.status = 'SECOND';
        }
        else if (this.status === 'SECOND') {
            this.status = 'THIRD';
        }
        else if (this.status === 'THIRD') {
            this.status = 'FOURTH';
        }
    }

    handleBack(event) {

        if (this.status === 'SECOND') {
            this.status = 'FIRST';
        }
        else if (this.status === 'THIRD') {
            this.status = 'SECOND';
        }
        else if (this.status === 'FOURTH') {
            this.status = 'THIRD';
        }
    }

    handleVendorContinue(event) {

        console.log("1");

        this.username = this.template.querySelector(".input-username").value;
        this.password = this.template.querySelector(".input-password").value;

        this.status = 'FOURTH';
    }

    handleFinish(event) {

        if (!this.hasAcceptedForwardInvoices()) {
            return;
        }

        let ap = {
            lastName: this.template.querySelector(".ap-username").value,
            email: this.template.querySelector(".ap-email").value,
            phone: this.template.querySelector(".ap-phone").value,
            ownerId: this.accountOwner,
            accountId: this.accountId
        }

        let vap = {
            lastName: this.template.querySelector(".v-username").value,
            email: this.template.querySelector(".v-email").value,
            phone: this.template.querySelector(".v-phone").value,
            ownerId: this.accountOwner,
            accountId: this.selectedVendorId
        }

        let apId = undefined;

        setAccountVendor({accountId: this.selectedVendorId, vendorUsername: this.username, vendorPassword: this.password })
        .then(() => {
            return createNewContact({
                lastName: this.template.querySelector(".ap-username").value,
                email: this.template.querySelector(".ap-email").value,
                phone: this.template.querySelector(".ap-phone").value,
                ownerId: this.accountOwner,
                accountId: this.accountId
            });
        })
        .then((ap) => {
            // Creates the AP
            apId = ap.Id;
            return createNewContact({
                lastName: this.template.querySelector(".v-username").value,
                email: this.template.querySelector(".v-email").value,
                phone: this.template.querySelector(".v-phone").value,
                ownerId: this.accountOwner,
                accountId: this.selectedVendorId
            });
        })
        .then((vap) => {
            // Creates the Vendor Contact
            return updateExistingAccount({
                accountId: this.accountId,
                apContactId: apId,
                vendorContactId: vap.Id
            })
        })
        .then((acc) => {
            this.showModal = false;
            this.showStatusModal = true;
        })
        .catch(error => {
            console.error(error.body);
        })
    }

    connectedCallback() {

        this.pic = STATIC_RESOURCES + '/images/powered.png';
        this.logo = STATIC_RESOURCES + '/images/auditmate-logo.png';

        getCommunityContact().then((record) => {

            console.log(record);

            this.contact = record;
            this.accountId = record.AccountId;
            this.accountOwner = record.Account.OwnerId;

            if (this.contact.Portal_Provisioned__c === false) {
                this.showModal = true;
            }

            if (this.contact.Portal_Provisioned__c === true) {
                this.showStatusModal = true;
            }

            if (this.contact.Portal_Ready__c === true) {
                this.showStatusModal = false;
                this.showModal = false;
            }
        })
    }

    hasAcceptedForwardInvoices() {
        const checkboxField = this.template.querySelector(
            "[data-id='forwardInvoiceCheckbox']"
        ); 
        
        if (!checkboxField.checked ) {

             //set an error
            const errorMsg = "Please accept the email forwarding";
            checkboxField.setCustomValidity(errorMsg);
            checkboxField.reportValidity();

            return false;
        }

        return true;
    }
}