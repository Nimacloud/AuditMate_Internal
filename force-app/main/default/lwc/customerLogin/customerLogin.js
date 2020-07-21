import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import STATIC_RESOURCES from '@salesforce/resourceUrl/AuditmateCustomer';
import login from '@salesforce/apex/PortalLoginController.login';

export default class CustomerLogin extends NavigationMixin(LightningElement) {

    pic;
    logo;

    @track errorMessage;
    @track showError = false;

    handleLogin(event) {

        let username = this.template.querySelector(".input-username").value;
        let password = this.template.querySelector(".input-password").value;

        let that = this;

        login({username: username, password: password})
        .then((result) => {

            console.log(result);

            document.location = result;
        })
        .catch((result) => {
            this.errorMessage = result.body.message;
            this.showError = true;
        })


    }

    connectedCallback() {

        this.pic = STATIC_RESOURCES + '/images/powered.png';
        this.logo = STATIC_RESOURCES + '/images/auditmate-logo.png';
    }

}