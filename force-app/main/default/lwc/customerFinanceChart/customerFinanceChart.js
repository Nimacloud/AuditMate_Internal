import { LightningElement, api, track } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import STATIC_RESOURCES from '@salesforce/resourceUrl/AuditmateCustomer';

export default class CustomerFinanceChart extends LightningElement {

    @track showChart = false;

    @api openAmount = 10;
    @api disputedAmount = 50;
    @api paidAmount = 8;

    @track totalAmount = 0;

    connectedCallback() {

        this.totalAmount = parseFloat(this.openAmount) + parseFloat(this.disputedAmount) + parseFloat(this.paidAmount);

        console.log(this.openAmount, this.disputedAmount, this.paidAmount, this.totalAmount)

        const chartjs = STATIC_RESOURCES + '/js/chartjs.js';

        loadScript(this, chartjs).then(() => {
            this.initializeChart();
        });
    }

    initializeChart() {

        let chartCanvas = this.template.querySelector('canvas');

        let myChart = new Chart(chartCanvas, {
            type: 'pie',
            data: {
                labels: ['Open', 'Disputed', 'Paid'],
                datasets: [{
                    data: [this.openAmount.toFixed(2), this.disputedAmount.toFixed(2), this.paidAmount.toFixed(2)],
                    backgroundColor: [
                        '#45861b',
                        '#21cca5',
                        '#91d212'
                    ]
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