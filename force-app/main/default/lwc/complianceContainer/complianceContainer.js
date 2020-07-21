import { LightningElement, track } from 'lwc';
import getDefaultAccountId from '@salesforce/apex/CustomerUserHandler.getDefaultAccountId';

export default class ComplianceContainer extends LightningElement {

    @track accountId;

    connectedCallback() {

        getDefaultAccountId().then((resultAccountId) => {

            if (resultAccountId && resultAccountId != null) {
                console.log('accountset', resultAccountId)
                this.accountId = resultAccountId;
            }        

            this.refreshChildren();
        })
    }

    handleAccountChange(event) {

        console.log(JSON.stringify(event.detail));
        console.log(event.detail.accountId)
        this.accountId = event.detail.accountId

        this.refreshChildren();
    }

    refreshChildren() {

        // trigger component refresh: 
        this.template.querySelector('c-customer-compliance').refresh(this.accountId)
        this.template.querySelector('c-customer-information').refresh(this.accountId);        
    }

}