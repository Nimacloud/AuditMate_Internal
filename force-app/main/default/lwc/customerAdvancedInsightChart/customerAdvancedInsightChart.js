import { LightningElement, api, track } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import STATIC_RESOURCES from '@salesforce/resourceUrl/AuditmateCustomer';

export default class CustomerAdvancedInsightChart extends LightningElement {


    @api label = 'Maintenance'
    @api showAmount = false
    @api variant = false
    @api hasThirdAmount = false;

    @track percent;

    @api wrapper = {
        total: undefined,
        firstAmount: 100,
        secondAmount: 200,
        thirdAmount: 300,
        firstAmountLabel: 'Completed on time',
        secondAmountLabel: 'Completed late',
        thirdAmountLabel: 'Incompleted',
    }

    labels = []
    data = []

    colors = [
        '#45861b',
        '#21cca5',
        '#91d212'
    ]

    variantColors = [
        '#3296ed',
        '#77b9f2',
        '#9d53f2'
    ]

    totalAmount = 0;

    connectedCallback() {

        this.totalAmount = parseFloat(this.wrapper.firstAmount) + parseFloat(this.wrapper.secondAmount) + parseFloat(this.wrapper.thirdAmount);
        this.totalAmount /= 1000;
        this.totalAmount = this.totalAmount.toFixed(0);

        if (this.wrapper.total !== undefined) {
            this.percent = Math.floor(parseFloat(this.wrapper.total) / 1000);
        }

        this.labels = [this.wrapper.firstAmountLabel, this.wrapper.secondAmountLabel]
        this.data = [parseFloat(this.wrapper.firstAmount), parseFloat(this.wrapper.secondAmount)];

        if (this.hasThirdAmount) {
            this.labels = [this.wrapper.firstAmountLabel, this.wrapper.secondAmountLabel, this.wrapper.thirdAmountLabel]
            this.data = [parseFloat(this.wrapper.firstAmount), parseFloat(this.wrapper.secondAmount), parseFloat(this.wrapper.thirdAmount)]
        }

        const chartjs = STATIC_RESOURCES + '/js/chartjs.js';
        loadScript(this, chartjs).then(() => {
            this.initializeChart();
        });
    }

    initializeChart() {

        let chartCanvas = this.template.querySelector('canvas');

        let myChart = new Chart(chartCanvas, {
            type: 'doughnut',
            data: {
                labels: this.labels,
                datasets: [{
                    data: this.data,
                    backgroundColor: this.variant ? this.variantColors : this.colors,
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