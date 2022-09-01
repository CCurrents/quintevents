global class QE_dcusignStatusNotificationBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
   
   global String message = 'Hello,<br/> Below are the link of the Quote Records were docusign status is completed but quote status is not Signed-Approved or Signed - Needs Review, please go through the below link(s) and update status.<br/>';
   global set<Id> setQuoteId = new set<Id>();
   global Database.QueryLocator start(Database.BatchableContext BC){
      String completeStatus = 'Completed';
      String signAppStatus = 'Signed - Approved';
      String signNeedAppStatus = 'Signed - Needs Review';
      return Database.getQueryLocator('Select Id,dsfs__Envelope_Status__c,Standard_Quote__r.Status,Standard_Quote__c from dsfs__DocuSign_Status__c where Standard_Quote__c != null and dsfs__Envelope_Status__c =:completeStatus and Standard_Quote__r.Status = \'Draft - Approved\'');
   }

   global void execute(Database.BatchableContext BC, List<dsfs__DocuSign_Status__c> docuScope){
   System.debug('Check docusign Record-->'+docuScope);
       for(dsfs__DocuSign_Status__c docuList : docuScope){          
          message += URL.getSalesforceBaseUrl().toExternalForm()+'/'+docuList.Standard_Quote__c+'<br/>';
          setQuoteId.add(docuList.Standard_Quote__c);          
       }
   }
   
   global void finish(Database.BatchableContext BC){
        if(setQuoteId != null && setQuoteId.size()>0){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();        
            String[] to = new String[]{}; 
            to.addall(system.label.Mismatch_Email_Notification.split(','));
            email.setToAddresses(to);
            
            email.setSubject('Quote Status not Updated as Signed-Approved or Signed - Needs Review.');
            
            email.setHtmlBody(message);
            try{
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            }catch(exception e){
                apexpages.addmessage(new apexpages.message(apexpages.severity.error,e.getMessage()));
            }
        }
   }
}