import { LightningElement, track, wire } from 'lwc';
import getAccounts from '@salesforce/apex/CustomerUserHandler.getAccounts';
import setDefaultAccountId from '@salesforce/apex/CustomerUserHandler.setDefaultAccountId';
import getDefaultAccountId from '@salesforce/apex/CustomerUserHandler.getDefaultAccountId';

export default class CustomerAccountSelection extends LightningElement {

    @track value
    @track options
    @track showOptions;

    handleChange(event) {

        console.log(event.detail.value)

        setDefaultAccountId({accountId :event.detail.value}).then(() => {
            this.dispatchEvent(new CustomEvent('accountchange', {detail: {
                accountId: event.detail.value
            }}));
        })
    }

    connectedCallback() {

        this.options = [];

        getAccounts().then(values => {

            if (values) {

                values.forEach(element => {
                    this.options.push(
                        { label: element.Name , value: element.Id },
                    )
                });

                getDefaultAccountId().then((resultAccountId) => {

                    if (resultAccountId && resultAccountId != null) {
                        this.value = resultAccountId;
                    }
                })

                this.showOptions = true;
            }
        })

    }

}