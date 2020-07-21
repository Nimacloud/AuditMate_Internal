import { LightningElement, api, track } from 'lwc';

export default class CustomerUnitBadge extends LightningElement {

    @api unit;
    @track isHover = false;
    @track showDetailModal = false;    

    handleOver(event) {

        this.isHover = true;
    }

    handleOut() {
        this.isHover = false;
    }

    handleClick() {

        this.showDetailModal = !this.showDetailModal;
    }    

}