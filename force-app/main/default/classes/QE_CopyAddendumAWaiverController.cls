/* **************************************************************************
* Controller Class: QE_CopyAddendumAWaiverController
*
* Purpose/Methods:
* - To Copy Addendum A Waiver from related event.
*
* Unit Test:  QE_CopyAddendumAWaiverControllerTest 
* 
************************************************************************** */
public with sharing class QE_CopyAddendumAWaiverController{
    public QE_CopyAddendumAWaiverController(){}
    
    /**************************************************************************
       Purpose: Get the terms and condition field from event.
       Parameters: 
       Returns: PageReference 
       Throws [Exceptions]: 
    ****************************************************************************/
    public PageReference copyAddendumAWaiverController(){
       // Getting opprotunity id from the url parameters.
       String opportunityId = Apexpages.currentPage().getParameters().get('id');
       Opportunity oppRecord = [select id, Addendum_A_Waiver__c, Event__r.Addendum_A_Waiver__c from Opportunity where id =: opportunityId ];
       // Event's terms and conditions is blank then we are returning null.
       if(String.isBlank(oppRecord.Event__r.Addendum_A_Waiver__c)){
           return null;
       }
       oppRecord.Addendum_A_Waiver__c = oppRecord.Event__r.Addendum_A_Waiver__c;
       update oppRecord;
       // Update the terms and condition and refreshing the opportunity record.
       return new PageReference('/'+oppRecord.id);
    }
}