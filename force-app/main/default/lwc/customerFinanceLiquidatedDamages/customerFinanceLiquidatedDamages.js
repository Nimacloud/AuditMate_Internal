import { LightningElement, api, track } from 'lwc';

export default class CustomerFinanceLiquidatedDamages extends LightningElement {

    @api accountId = '0013k00002fZf1PAAS';
    @track liquidatedDamages = [];
    
    connectedCallback() {


    }
}