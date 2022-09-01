global class convertOptyTOQuote_LIV_GOLF_London implements Database.Batchable<sObject>, Database.Stateful {
    
     global Integer recordsProcessed = 0;
    global Set<String> setOptyId;
    global Date oppCloseDate;
    global convertOptyTOQuote_LIV_GOLF_London(Set<String> setIds){
        this.setOptyId = setIds;
        //this.oppCloseDate = closeDate;
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('Select Id From Opportunity WHERE Id IN :setOptyId');
    }
    global void execute(Database.BatchableContext bc, List<Opportunity> scope) {
    
	system.debug('inside execute');
    system.debug('setOptyId  = ' + setOptyId);
    system.debug('scope = ' + scope);
        
 for(Opportunity objOpty: scope){
     
     AddOpportunityAndQuote_LEX.createQuoteFromOpportunity(objOpty.Id);
     
      /*  String message = '';
     	String opportunityId = '';
        try{ 
            opportunityId = objOpty.Id;
            System.debug('opportunityId-->'+opportunityId);
            // #664 "Create Quote" button on opportunity page should not allow to create quote if that opportunity already has "Active" order on it.
           /* List<Order> lstorder = [select Id,Status from Order where OpportunityId=:opportunityId AND Status = 'Active'];
            if(lstorder.size() > 0){
                message = 'Error : '+System.Label.CreateQuoteOrderErrorMessage;
                return message;
            } */
           /* List<Opportunity> opportunityList = [Select id,Name,Primary_Contact__c,Pricebook2Id,Pricebook2.Name,Primary_Contact__r.Name,StageName,
                                              Primary_Contact__r.MailingStreet,Primary_Contact__r.MailingCity,Primary_Contact__r.MailingState,Primary_Contact__r.MailingCountry,
                                              Primary_Contact__r.MailingPostalCode,Primary_Contact__r.OtherStreet,Primary_Contact__r.OtherCity,Primary_Contact__r.OtherState,Primary_Contact__r.OtherCountry,
                                              Primary_Contact__r.OtherPostalCode, OwnerId,Travel_Agent__c from Opportunity where id=: opportunityId];
            System.debug('opportunityList-->'+opportunityList);
            if(!opportunityList.isEmpty()){
                    Quote objquote = new Quote(Name = opportunityList[0].Pricebook2.Name,
                                           opportunityId = opportunityList[0].Id,
                                           Pricebook2Id = opportunityList[0].Pricebook2Id,
                                           BillingStreet = opportunityList[0].Primary_Contact__r.OtherStreet,
                                           BillingCity = opportunityList[0].Primary_Contact__r.OtherCity,
                                           BillingState = opportunityList[0].Primary_Contact__r.OtherState,
                                           BillingCountry = opportunityList[0].Primary_Contact__r.OtherCountry,
                                           BillingPostalCode = opportunityList[0].Primary_Contact__r.OtherPostalCode,
                                           // #463 Added code to make Quote Owner same as Opportunity Owner
                                           OwnerId = opportunityList[0].OwnerId,
                                           ShippingStreet = opportunityList[0].Primary_Contact__r.MailingStreet,
                                           ShippingCity = opportunityList[0].Primary_Contact__r.MailingCity,
                                           ShippingState = opportunityList[0].Primary_Contact__r.MailingState,
                                           ShippingCountry = opportunityList[0].Primary_Contact__r.MailingCountry,
                                           ShippingPostalCode = opportunityList[0].Primary_Contact__r.MailingPostalCode,
                                           BillingName = opportunityList[0].Primary_Contact__r.Name,
                                           ShippingName = opportunityList[0].Primary_Contact__r.Name
                                           );
                
                if(opportunityList[0].StageName == 'Closed Won'){
                    message = 'Error : '+System.Label.CreateQuoteErrorMessage;//Opportunity is closed Won you can not create a Quote.';
                }
                else if(opportunityList[0].StageName == 'Canceled'){
                    message = 'Error : '+System.Label.Canceled_Opportunity_Error_Message;//Opportunity is Canceled you can not create a Quote.';
                }
                else{
                    Utility.processRecords(objquote, 'insert');
                    message = objquote.id;
                }
            }
        }catch(exception ex){
            system.debug('Error==>'+ex.getMessage()+' Line Number==>'+ex.getLineNumber());
            message = 'Error: '+ ex.getMessage();
        } */
        //return message;
      }
    }
    
    global void finish(Database.BatchableContext bc) {
        System.debug(recordsProcessed + ' records processed. Shazam!');
    } 
}