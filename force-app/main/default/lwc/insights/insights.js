import { LightningElement, api, track } from 'lwc';

import getInsights from '@salesforce/apex/PortalInsightsController.getInsights';

export default class Insights extends LightningElement {

    // displayed records;
    @track dataRecord;
    @track accountId;
    @track showCharts = false

    get maintenanceDuration() {
        return this.dataRecord.maintenanceAverage + " minutes";
    }

    get responseTime() {
        return this.dataRecord.responseAverage + " minutes";
    }

    @api
    refresh(accountId) {

        console.log("refreshing", accountId);

        this.showCharts = false;
        this.accountId = accountId;

        if (this.accountId) {
            getInsights({accountId: accountId})
            .then(dataRecord => {
                console.log(dataRecord);
                this.dataRecord = dataRecord;
                this.showCharts = true;
            })
        }
    }

}