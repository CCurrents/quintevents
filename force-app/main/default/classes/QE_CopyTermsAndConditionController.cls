/* **************************************************************************
* Controller Class: QE_CopyTermsAndConditionController
* Created by Jakin Prajapati: 01/01/2019
*
* Purpose/Methods:
* - To Copy Terms and condition from related event.
*
* Unit Test:  QE_CopyTermsAndConditionControllerTest 
* 
* Modifications:
* - Jakin Prajapati 01/01/2019 – Initial Development
************************************************************************** */
public with sharing class QE_CopyTermsAndConditionController{
    public QE_CopyTermsAndConditionController(){}
    
    /**************************************************************************
       Purpose: Get the terms and condition field from event.
       Parameters: 
       Returns: PageReference 
       Throws [Exceptions]: 
    ****************************************************************************/
    public PageReference copyTermsAndConditionToOpportunity(){
       // Getting opprotunity id from the url parameters.
       String opportunityId = Apexpages.currentPage().getParameters().get('id');
       Opportunity oppRecord = [select id, Terms_And_Conditions__c, Event__r.Terms_And_Conditions__c from Opportunity where id =: opportunityId ];
       // Event's terms and conditions is blank then we are returning null.
       if(String.isBlank(oppRecord.Event__r.Terms_And_Conditions__c)){
           return null;
       }
       oppRecord.Terms_And_Conditions__c = oppRecord.Event__r.Terms_And_Conditions__c;
       update oppRecord;
       // Update the terms and condition and refreshing the opportunity record.
       return new PageReference('/'+oppRecord.id);
    }
}