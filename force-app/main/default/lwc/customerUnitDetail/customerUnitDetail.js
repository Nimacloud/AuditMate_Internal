import { LightningElement, api, track } from 'lwc';

export default class CustomerUnitDetail extends LightningElement {

    @api record;
    @track showDetailModal = false;

    handleClick() {

        this.showDetailModal = !this.showDetailModal;
    }

}