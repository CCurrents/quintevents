/**
 * Created by joshlequire1 on 9/26/22.
 */

import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue, createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import CONSENTTRANSACTION_OBJECT from '@salesforce/schema/ConsentTransaction__c';
import EVENTINTEREST_FIELD from '@salesforce/schema/ConsentTransaction__c.EventInterest__c';
import TYPE_FIELD from '@salesforce/schema/ConsentTransaction__c.Type__c';
import SOURCE_FIELD from '@salesforce/schema/ConsentTransaction__c.Source__c';
import CONTACT_FIELD from '@salesforce/schema/ConsentTransaction__c.Contact__c';
import PERSONCONTACTID_FIELD from '@salesforce/schema/Account.PersonContactId';

export default class CreateConsentTransaction extends LightningElement {

@api recordId;

consentTransactionObject = CONSENTTRANSACTION_OBJECT;
eventInterestField = EVENTINTEREST_FIELD;
typeField = TYPE_FIELD;
sourceField = SOURCE_FIELD;
contactField = CONTACT_FIELD;

eventInterestValue;
typeValue = 'Unsubscribe';
sourceValue = 'Agent';

// get the Contact Id for this Person Account
@wire(getRecord, { recordId: '$recordId', fields: PERSONCONTACTID_FIELD })
    personAccount;

get personContactId() {
    return getFieldValue(this.personAccount.data, PERSONCONTACTID_FIELD);
}

// detect changes to form fields for record creation

handleEventInterestChange(event){
    this.EventInterestValue = event.target.value;
}

handleTypeChange(event){
    this.typeValue = event.target.value;
}

handleSourceChange(event){
    this.sourceValue = event.target.value;
}

createConsentTransaction(){

    const fields = {
        'EventInterest__c' : this.eventInterestValue,
        'Type__c' : this.typeValue,
        'Source__c' : this.sourceValue,
        'Contact__c' : this.personContactId
    };

    const recordInput = {
      'apiName' : 'ConsentTransaction__c',
       fields
    };

    createRecord(recordInput)
    .then(consentTransaction => {
        this.closeModal();
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Consent Transaction Created',
                variant: 'success'
            }),
          );
    })
    .catch(error => {
        this.closeModal();
        this.dispatchEvent(
            new ShowToastEvent({
               title: 'Error creating record',
               message: error.body.message,
               variant: 'error',
            }),
        );

    });
}


handleCancel(event) {
       // Close the screen
       this.closeModal();
    }

closeModal(){
    this.dispatchEvent(new CloseActionScreenEvent());
}

}