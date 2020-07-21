import { LightningElement, api } from 'lwc';

export default class CustomerProposalOpen extends LightningElement {

    @api records;

    handleCloseModal() {

        this.dispatchEvent(new CustomEvent('refreshdata'));
    }

}