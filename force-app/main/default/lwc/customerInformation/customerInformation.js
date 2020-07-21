import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';

import getUnits from '@salesforce/apex/PortalController.getUnits';

import NAME_FIELD from '@salesforce/schema/User.Name';
import EMAIL_FIELD from '@salesforce/schema/User.Email';
import PHONE_FIELD from '@salesforce/schema/User.Phone';
import STREET_FIELD from '@salesforce/schema/User.Street';
import STATE_FIELD from '@salesforce/schema/User.State';
import POSTAl_FIELD from '@salesforce/schema/User.PostalCode';
import CITY_FIELD from '@salesforce/schema/User.City';

export default class CustomerInformation extends LightningElement {

    userId = Id
    @track units

    @wire(getRecord, { recordId: '$userId', fields: [NAME_FIELD, EMAIL_FIELD, PHONE_FIELD, STREET_FIELD, STATE_FIELD, POSTAl_FIELD, CITY_FIELD] }) record;

    get nameValue() {
        let result = '';
        return this.record.data ? getFieldValue(this.record.data, NAME_FIELD) : '';
        return result;
    }

    get phoneValue() {
        let result = '';
        return this.record.data ? getFieldValue(this.record.data, PHONE_FIELD) : '';
        return result;
    }
    
    get emailValue() {
        let result = '';
        return this.record.data ? getFieldValue(this.record.data, EMAIL_FIELD) : '';
        return result;
    }
    
    get addressValue() {

        let result = '';

        if (this.record.data) {

            result = getFieldValue(this.record.data, STREET_FIELD) + ', ' +
                getFieldValue(this.record.data, CITY_FIELD) + ', ' +
                getFieldValue(this.record.data, STATE_FIELD) + ' ' +
                getFieldValue(this.record.data, POSTAl_FIELD);
        }

        return result;
    }    


    @api
    refresh(accountId) {

        getUnits({userId: this.userId, accountId: accountId}).then(units => {
            this.units = units;
        })
    }

}