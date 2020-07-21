import { LightningElement, api, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import STATIC_RESOURCES from '@salesforce/resourceUrl/AuditmateCustomer';

export default class CustomerInformationPanel extends LightningElement {

    @api icon = undefined
    @api label = "Maintenance"
    @api value = null
    @api message = ""
    @api helptext = ""
    @api isDate = false
    @api isCurrency = false
    @api compact = false
    @api units = ""
    @api messageIfNull = "false";

    @track pic;

    connectedCallback() {

        this.pic = STATIC_RESOURCES + '/images/' + this.icon + '.png'
        loadStyle(this, STATIC_RESOURCES + '/css/style.css');
    }

    get valueResult() {

        if (this.value !== null && this.value !== '' && this.value !== undefined) {
            return this.value + " " + this.units
        }
        else {
            return "Unspecified";
        }
    }

    get showMessage() {

        if (this.messageIfNull === 'true' && (this.value === null || this.value === '' || this.value === undefined)) {
            return true
        }

        return false
    }

    get hasUnits() {

        let result = false;
        if (this.units.length > 0) {
            result = true;
        }

        return result;
    }

    get hasHelpText() {

        let result = false;
        if (this.helptext.length > 0) {
            result = true;
        }

        return result;
    }

    get hasMessage() {

        let result = false;
        if (this.message.length > 0) {
            result = true;
        }

        return result;
    }
}