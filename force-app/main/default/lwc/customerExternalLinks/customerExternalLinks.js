import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { loadScript } from 'lightning/platformResourceLoader';
import STATIC_RESOURCES from '@salesforce/resourceUrl/AuditmateCustomer';

export default class CustomerExternalLinks extends NavigationMixin(LightningElement) {

    @api message = 'SAFE Repair'
    @api icon = 'external-1'

    @track pic;

    _getlink() {

        if (this.message === 'SAFE Maintenance') {
            return 'https://auditmate.com/what-is-safe/safe-maintenance/'
        }
        else if (this.message === 'SAFE Modernization') {
            return 'https://auditmate.com/what-is-safe/safe-modernization/'
        }
        else if (this.message === 'SAFE Repair') {
            return 'https://auditmate.com/what-is-safe/safe-large-repair/'
        }
        else if (this.message === 'SAFE Inspection') {
            return 'https://auditmate.com/what-is-safe/safe-physical-audit/'
        }
    }

    handleClick(event) {

        this[NavigationMixin.Navigate](
            {
                type: 'standard__webPage',
                attributes: {
                    url: this._getlink()
                }
            }
        )
    }

    connectedCallback() {

        this.pic = STATIC_RESOURCES + '/images/' + this.icon + '.png';
    }


}