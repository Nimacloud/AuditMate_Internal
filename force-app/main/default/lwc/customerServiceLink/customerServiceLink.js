import { LightningElement, api } from 'lwc';

export default class CustomerServiceLink extends LightningElement {

    @api record;

    get link() {

        return "/customers/s/equipment/" + this.record.Id;
    }

}