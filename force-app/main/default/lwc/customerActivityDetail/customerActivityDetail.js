import { LightningElement, api, track } from 'lwc';

export default class CustomerActivityDetail extends LightningElement {

    @api record;
    @track showDetailModal = false;

    handleClick() {

        this.showDetailModal = !this.showDetailModal;
    }



}