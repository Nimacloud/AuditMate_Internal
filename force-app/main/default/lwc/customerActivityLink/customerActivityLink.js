import { LightningElement, api } from 'lwc';

export default class CustomerActivityLink extends LightningElement {

    @api record;

    get link() {

        return "/customers/s/schindler-maintenance-activity/" + this.record.activity.Id;
    }

}