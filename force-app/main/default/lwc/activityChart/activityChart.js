import { LightningElement, api, track } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import STATIC_RESOURCES from '@salesforce/resourceUrl/AuditmateCustomer';

const COLORS = [
    '#3296ed',
    '#77b9f2',
    '#9d53f2'
]

const LABELS = [
    'Completed on time',
    'Completed late',
    'Not completed'
]

export default class ActivityChart extends LightningElement {

    @api label = 'Maintenance'
    @api wrapper;

    connectedCallback() {

        const data = [this.wrapper.completedActivities, this.wrapper.lateActivities, this.wrapper.incompletedActivities];

        console.log(data);

        const chartjs = STATIC_RESOURCES + '/js/chartjs.js';
        loadScript(this, chartjs).then(() => {
            this.initializeChart(data);
        });
    }

    get showChart() {

        console.log(this.label, this.wrapper.isMonthlyFrequency);

        if (this.wrapper.isMonthlyFrequency && this.wrapper.isMonthlyFrequency == true) {
            return true
        }
        else {
            return false;
        }

    }

    initializeChart(data) {

        let chartCanvas = this.template.querySelector('canvas');

        let myChart = new Chart(chartCanvas, {
            type: 'doughnut',
            data: {
                labels: LABELS,
                datasets: [{
                    data: data,
                    backgroundColor: COLORS
                }]
            },
            options: {
                reponsive: true,
                legend: {
                    position: 'right',
                },
            }
        });

    }


}