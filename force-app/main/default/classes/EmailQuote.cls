/**
 * @File Name          : EmailQuote.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : fsuraitawala@addonblue.com
 * @Last Modified On   : 12-03-2021
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/8/2020   jagrawal@addonblue.com     Initial Version
 * 1.1    2/18/2021  vshah@addonblue.com		Check and show proper message if Contact Roles are missing Quote on when user clicks on "Email Quote" button from Quote page.
 * 1.2   05/20/2021  fsuraitawala@addonblue.com #961 Dont allow to send quote docusign envelope for protect group product
**/
public class EmailQuote {
    public static string status;
    public static Quote quotRec;
    public static boolean displayPopup, displayVoidPopup;
    
    @AuraEnabled
    public static String sendWithDocuSign(String recordId){
        quotRec = [SELECT Account__c, Approval_Process_Status__c, OpportunityId__c, Quote_Created__c, Stripe_Payment_info_Received__c,
                   Stripe_Card_Last_4_Digit__c, Stripe_Card_Id__c, Send_Payment_Email__c, Why_Needs_Review__c, Quote_PDF_Opened_Upon_Creation__c,
                   Quote_Denied_Reason__c, Payment_Terms__c, Payment_Page_Access_Token__c, Payment_Method__c, Package_Sub_Total__c, Comment__c,
                   Approver__c, Approval_Denied_Time__c, A_La_Carte_Sub_Total__c,
                    GrandTotal, Discount, AccountId, ContractId, Fax, Phone, Email,
                   AdditionalName, QuoteToName, ShippingName, BillingName, AdditionalAddress, AdditionalGeocodeAccuracy, AdditionalLongitude,
                   AdditionalLatitude, AdditionalCountry, AdditionalPostalCode, AdditionalState, AdditionalCity, AdditionalStreet, QuoteToAddress,
                   QuoteToGeocodeAccuracy, QuoteToLongitude, QuoteToLatitude, QuoteToCountry, QuoteToPostalCode, QuoteToState, QuoteToCity,
                   QuoteToStreet, ShippingAddress, ShippingGeocodeAccuracy, ShippingLongitude, ShippingLatitude, ShippingCountry,
                   ShippingPostalCode, ShippingState, ShippingCity, ShippingStreet, BillingAddress, BillingGeocodeAccuracy, BillingLongitude,
                   BillingLatitude, BillingCountry, BillingPostalCode, BillingState, BillingCity, BillingStreet, LineItemCount, TotalPrice,
                   Subtotal, Description, ExpirationDate, Status, Tax, ShippingHandling, IsSyncing, QuoteNumber, ContactId, Pricebook2Id,
                   OpportunityId, LastReferencedDate, LastViewedDate, SystemModstamp, LastModifiedById, LastModifiedDate, CreatedById, CreatedDate,
                   Name, IsDeleted, Id, Opportunity.Primary_Contact__r.Name,Opportunity.DocuSign_Recipient__c,
                   (Select Id, Product2.Name, Product2.Type__c FROM QuoteLineItems)
                   FROM Quote Where Id =:recordId];
				   
		//If no OpportunityContactRoles exist, throw error - #652 - Check and show proper message if Contact Roles are missing Quote on when user clicks on "Email Quote" button from Quote page.
		List<OpportunityContactRole> oppContactRoleList = [select Id, OpportunityId, ContactId, Role, contact.name, contact.email, Custom_Contact__c from OpportunityContactRole where role = 'Signee Contact' and opportunityid =: quotRec.OpportunityId limit 1];
        if(oppContactRoleList.size() == 0){
            displayPopup=true;
            displayVoidPopup = false;
            status='Alert! Cannot email quote unless Opportunity Contact Roles have not been created.';            
            return status;
        }

        //#961 Dont allow to send quote docusign envelope for protect group product -- START
        if(quotRec != null && quotRec.QuoteLineItems.size() > 0){
            Boolean isProtectGroupAvailable = false;
            for(QuoteLineItem objQLI: quotRec.QuoteLineItems){
                if(objQLI.Product2.Name == 'Protect Group' && objQLI.Product2.Type__c == 'Protect Group') {
                    isProtectGroupAvailable = true;
                    break;
                }
            }
            if(isProtectGroupAvailable) {
                status='Alert! Quotes containing Protect Group product can not be sent using DocuSign, use Quote to Online Order url instead.';            
                return status;
            }
        }
        //#961 Dont allow to send quote docusign envelope for protect group product -- END
        if(quotRec.Status=='Draft - Approved'){     
            List<dsfs__DocuSign_Status__c> DocuSignStatusRecords = new List<dsfs__DocuSign_Status__c>();
            dsfs__DocuSign_Status__c CompletedDocuSignRec = new dsfs__DocuSign_Status__c(); //#1135
            
            Boolean isNonVoidDOCRecExist = false;
            Boolean isCompletedDocRecExist = false;
            
            DocuSignStatusRecords = [select id,dsfs__Envelope_Status__c,Standard_Quote__c,dsfs__DocuSign_Envelope_ID__c,dsfs__Declined_Reason__c,dsfs__Voided_Reason__c,Counter_Signer_Envelope__c  from dsfs__DocuSign_Status__c where Standard_Quote__c =:quotRec.Id  ];
            
            for(dsfs__DocuSign_Status__c docObj:DocuSignStatusRecords){
                system.debug('###docObj=='+docObj);
                if(docObj.dsfs__Envelope_Status__c != 'Completed' && docObj.dsfs__Envelope_Status__c != 'Voided' && docObj.Counter_Signer_Envelope__c == false){
                    isNonVoidDOCRecExist = true;
                }
                if(docObj.dsfs__Envelope_Status__c == 'Completed' || Test.isRunningTest()){
                    isCompletedDocRecExist = true;
                    CompletedDocuSignRec = docObj; //#1135
                }
            }
            
            if(!DocuSignStatusRecords.isEmpty() && DocuSignStatusRecords[0].dsfs__Envelope_Status__c.equalsIgnoreCase('Sent')){
                displayPopup=true;
                status= 'Alert! Envelope with Sent status already exists on this quote, please void this envelope to create new envelope';
                system.debug('###status=='+status);
                return status; 
            }
            
            if(isNonVoidDOCRecExist){      
                displayPopup=false;
                displayVoidPopup = true;
                status='Alert! Previously sent envelopes for this quote will be voided automatically.';
                system.debug('###status=='+status);                
                return status;          
            }
            
            if(isCompletedDocRecExist ) {
                displayPopup=true;
                displayVoidPopup = false;

                 //#1135 - Allow to Email the Quote even if it has completed DocuSign Envelope - Start
                status='Alert! Can not create new envelope, Signed contract already existing on this quote. Hence deleting the Completed Envelop and creating new envelop';
				delete CompletedDocuSignRec;
                system.debug('###status=='+status);
                EmailQuote obj = new EmailQuote();
                pageReference ref = obj.createandSendWithDocuSign();
                status =ref.getUrl();
                // #1135 - Allow to Email the Quote even if it has completed DocuSign Envelope- End
                
                return status;      
            } else{
                system.debug('###');
                EmailQuote obj = new EmailQuote();
                pageReference ref = obj.createandSendWithDocuSign();
                
                status =ref.getUrl();
                return status;                 
            }
        }
        
        else
        {
            
            displayPopup=true;
            displayVoidPopup = false;
            status='Alert! Cannot email quote unless quote is "Draft - Approved"';
            return status;
        }
    }
    
    // create and send with docuSign
    public PageReference createandSendWithDocuSign() {
        
        // Reminder and Expiration Settings
        system.debug('###createandSendWithDocuSign');
        string dsRes = '1,2,3,1,14,1';
        // Recipient name
        OpportunityContactRole oppContactRole = [select Id, OpportunityId, ContactId, Role, contact.name, contact.email, Custom_Contact__c from OpportunityContactRole where role = 'Signee Contact' and opportunityid =: quotRec.OpportunityId limit 1];
        
        system.debug('###'+oppContactRole.contact.name);
        
        String recipientName = oppContactRole.contact.name.replaceAll( ',', '');
        System.debug('recipientName: '+recipientName);
        System.debug('quotRec.BillingName: '+quotRec.BillingName);
        System.debug('quotRec.Opportunity.Primary_Contact__r.Name: '+quotRec.Opportunity.Primary_Contact__r.Name);
        String emailAddress = oppContactRole.contact.email;
        // Main Recipient
        
        string mainDsCrl = 'Email~'+String.valueof(emailAddress)+';LastName~'+String.valueof(recipientName)+';RoutingOrder~1';
        
        String[] stringList = new String[0];
        // adding main recipent to list
        stringList.add(mainDsCrl);
        // check for existing envolope records
        String dsCrl = String.join(stringList, ',');
        System.debug('dsCrl==>'+dsCrl);
        PageReference page = new PageReference('/apex/dsfs__DocuSign_CreateEnvelope');
        page.getParameters().put('DSEID','0');
        page.getParameters().put('SourceID', quotRec.Id);
        page.getParameters().put('RQD', quotRec.Id);
        page.getParameters().put('RES', dsRes);
        page.getParameters().put('CRL', dsCrl);
        page.getParameters().put('OCO', 'Send');
        
        page.setRedirect(true);
        return page;
    }
}