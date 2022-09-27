/**
 * Created by joshlequire1 on 9/19/22.
 */

import {LightningElement, api, track, wire} from 'lwc';
import {NavigationMixin} from 'lightning/navigation';

//Apex
import {refreshApex} from '@salesforce/apex';
import getConsentTransactionsForCampaignMember from '@salesforce/apex/ConsentTransactionRelatedListController.getConsentTransactionsForCampaignMember';
import {logToTable} from "c/utils";

export default class consentTransactionRelatedList extends NavigationMixin(LightningElement) {
    @api flexipageRegionWidth;
    @api recordId;

    @track consentRecords = [];
    @track error;

    isMore = false;
    maxRowsToShow = 0;

    @wire(getConsentTransactionsForCampaignMember, {recordId: '$recordId'})
    wiredContacts({error, data}) {
        if (data) {
            //Filter down to 3 or 5 for small and medium, respectively
            if (this.showTiles) {
                this.maxRowsToShow = 3;
            } else if (!this.isFullScreen) {
                //MEDIUM or LARGE show just 5
                this.maxRowsToShow = 5;
            } else {
                //Show all rows
                //data.length is 0-based
                this.maxRowsToShow = data.length + 1;
            }

            if (data.length > this.maxRowsToShow) {
                this.isMore = true;
                this.consentRecords = data.slice(0, this.maxRowsToShow);
            } else {
                this.consentRecords = data;
            }

            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.consentRecords = undefined;
        }
    }

    get showTiles() {
        return (this.flexipageRegionWidth === 'SMALL');
    }

    get showTable() {
        return (this.flexipageRegionWidth !== 'SMALL');
    }

    get isFullScreen() {
        return (this.flexipageRegionWidth === 'XLARGE');
    }


    get title() {
        if (this.consentRecords) {
            return ('Consent Records (' + this.consentRecords.length + (this.isMore ? '+' : '') + ')');
        } else {
            return ('Consent Records');
        }
    }

    get tableColumns() {
        return [
            {label: 'Id', fieldName: 'Id'},
            {label: 'Name', fieldName: 'Name'},
            {label: 'Contact Name', fieldName: 'Contact__r.Name'},
            {label: 'Lead Name', fieldName: 'Lead__r.Name'},
            {label: 'Type', fieldName: 'Type__c'},
            {label: 'Info Request', fieldName: 'QNGInfoRequest__r.Name'},
            {
                label: 'Created', fieldName: 'CreatedDate', type: 'date',
                typeAttributes: {year: "numeric", month: "numeric", day: "numeric", hour: "2-digit", minute: "2-digit"}
            }
        ];
    }

    handleViewAll(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
                componentName: 'c__consentTransactionRelatedList'
            },
            state: {
                c__recordId: this.recordId
            }
        });

    }

}