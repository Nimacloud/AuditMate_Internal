import { LightningElement, api} from 'lwc';

export default class CustomerNotification extends LightningElement {

    @api title = 'Thanks!'
    @api message
    @api messageType = 'success'

    handleClose() {
        this.dispatchEvent(new CustomEvent('closemodal'));
    }

}