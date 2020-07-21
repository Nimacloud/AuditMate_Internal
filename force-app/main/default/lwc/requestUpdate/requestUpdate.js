import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import requestUpdates from '@salesforce/apex/PortalNotificationController.requestUpdates';

export default class RequestUpdate extends LightningElement {

    @api accountId
    @api ids

    handleClick() {

        let equipmentIds = Object.values(this.ids);

        equipmentIds = equipmentIds.filter((element) => {
            return element !== undefined;
        })

        if (equipmentIds.length > 0) {

            requestUpdates({equipmentIds: equipmentIds})
            .then((response) => {

                this._alertToast({
                    title: 'Success',
                    message: 'Request Sent',
                    variant: 'success'
                });
            })
            .catch((response) => {

                this._alertToast({
                    title: 'Error',
                    message: response,
                    variant: 'error'
                })
            })
        }
        else {

            this._alertToast({
                title: 'Warning',
                message: 'No Rows Selected',
                variant: 'warning'
            })
        }
    }

    _alertToast(eventDetail) {

        this.dispatchEvent(new ShowToastEvent(eventDetail));
    }

}