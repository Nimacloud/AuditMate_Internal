import { LightningElement, api } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import STATIC_RESOURCES from '@salesforce/resourceUrl/AuditmateCustomer';


export default class CustomerInsightChart extends LightningElement {

    @api label = 'Maintenance'
    @api percent;
    @api isQuantity = false;

    connectedCallback() {

        const chartjs = STATIC_RESOURCES + '/js/chartjs.js';

        loadScript(this, chartjs).then(() => {
            this.initializeChart();
        });
    }

    initializeChart() {

        let chartCanvas = this.template.querySelector('canvas');

        let value = 0;
        let remainValue = 0;

        if (this.isQuantity) {
            value = parseFloat(this.percent);
            remainValue = 0;
        }
        else {
            value = parseFloat(this.percent);
            remainValue = 100 - parseFloat(this.percent);
        }

        console.log(this.label, value, remainValue);

        let myChart = new Chart(chartCanvas, {
            type: 'doughnut',
            data: {
                datasets: [{
                    data: [value, remainValue],
                    backgroundColor: [
                        '#21cca5',
                    ]
                }]
            },
            options: {
                reponsive: true,
            }
        });

    }


}