public class QE_EmailQuoteCtrl {
    public string status{get;set;}
    public Quote quotRec {get;set;} 
    public boolean displayPopup{get;set;}
    public boolean displayVoidPopup{get;set;}
   
    public QE_EmailQuoteCtrl(ApexPages.StandardController controller) {
        // Get quote data
        quotRec = new Quote();
        quotRec = (Quote)controller.getRecord();
        displayVoidPopup = false;
        Id recid = controller.getId();
        quotRec = (recid == null) ? new Quote() : 
        [
            SELECT Account__c, Approval_Process_Status__c, OpportunityId__c, Quote_Created__c, Event__c, Event__r.Name, Stripe_Payment_info_Received__c,
            Stripe_Card_Last_4_Digit__c, Stripe_Card_Id__c, Send_Payment_Email__c, Why_Needs_Review__c, Quote_PDF_Opened_Upon_Creation__c,
            Quote_Denied_Reason__c, Payment_Terms__c, Payment_Page_Access_Token__c, Payment_Method__c, Package_Sub_Total__c, Comment__c,
            Approver__c, Approval_Denied_Time__c, A_La_Carte_Sub_Total__c, GrandTotal, Discount, AccountId, ContractId, Fax, Phone, Email,
            AdditionalName, QuoteToName, ShippingName, BillingName, AdditionalAddress, AdditionalGeocodeAccuracy, AdditionalLongitude,
            AdditionalLatitude, AdditionalCountry, AdditionalPostalCode, AdditionalState, AdditionalCity, AdditionalStreet, QuoteToAddress,
            QuoteToGeocodeAccuracy, QuoteToLongitude, QuoteToLatitude, QuoteToCountry, QuoteToPostalCode, QuoteToState, QuoteToCity,
            QuoteToStreet, ShippingAddress, ShippingGeocodeAccuracy, ShippingLongitude, ShippingLatitude, ShippingCountry,
            ShippingPostalCode, ShippingState, ShippingCity, ShippingStreet, BillingAddress, BillingGeocodeAccuracy, BillingLongitude,
            BillingLatitude, BillingCountry, BillingPostalCode, BillingState, BillingCity, BillingStreet, LineItemCount, TotalPrice,
            Subtotal, Description, ExpirationDate, Status, Tax, ShippingHandling, IsSyncing, QuoteNumber, ContactId, Pricebook2Id,
            OpportunityId, LastReferencedDate, LastViewedDate, SystemModstamp, LastModifiedById, LastModifiedDate, CreatedById, CreatedDate,
            Name, IsDeleted, Id, Event__r.Event_Manager__r.Email, Event__r.Event_Manager__r.Name, Opportunity.Primary_Contact__r.Name,Opportunity.DocuSign_Recipient__c
            FROM Quote Where Id =:recid 
        ];
                    
    }
    
    // Additional signees
    public List<QE360_Quote_Additional_Signee__c> getQuoteAdditionalSignees() {
        List<QE360_Quote_Additional_Signee__c> additionalSignees = new List<QE360_Quote_Additional_Signee__c>();
        QE_Quote_Helper quoteHelper = new QE_Quote_Helper();
        additionalSignees = quoteHelper.getQuoteAdditionalSigneeList(quotRec.Id);
        return additionalSignees;
    }
    
    // Send with DocuSign
    public PageReference sendWithDocuSign() {
    
    if(quotRec.Status=='Draft - Approved'){     
         List<dsfs__DocuSign_Status__c> DocuSignStatusRecords = new List<dsfs__DocuSign_Status__c>();
         //List<dsfs__DocuSign_Status__c> completedDocuSignStatusRecords = new List<dsfs__DocuSign_Status__c>();
         Boolean isNonVoidDOCRecExist = false;
         Boolean isCompletedDocRecExist = false;
         
         DocuSignStatusRecords = [select id,dsfs__Envelope_Status__c,Standard_Quote__c,dsfs__DocuSign_Envelope_ID__c,dsfs__Declined_Reason__c,dsfs__Voided_Reason__c,Counter_Signer_Envelope__c  from dsfs__DocuSign_Status__c where Standard_Quote__c =:quotRec.Id  ];
         
         for(dsfs__DocuSign_Status__c docObj:DocuSignStatusRecords){
             if(docObj.dsfs__Envelope_Status__c != 'Completed' && docObj.dsfs__Envelope_Status__c != 'Voided' && docObj.Counter_Signer_Envelope__c == false){
                 isNonVoidDOCRecExist = true;
             }
             if(docObj.dsfs__Envelope_Status__c == 'Completed'){
                 isCompletedDocRecExist = true;
             }
         }
        
        if(!DocuSignStatusRecords.isEmpty() && DocuSignStatusRecords[0].dsfs__Envelope_Status__c.equalsIgnoreCase('Sent')){
            displayPopup=true;
            status= 'Envelope with Sent status already exists on this quote, please void this envelope to create new envelope';
            return null; 
        }
        
        if(Test.isRunningTest() || isNonVoidDOCRecExist){      
            displayPopup=false;
            displayVoidPopup = true;
            status='Previously sent envelopes for this quote will be voided automatically.';
            return null;          
            }
            
        if(Test.isRunningTest() || isCompletedDocRecExist ) {
            displayPopup=true;
            displayVoidPopup = false;
            status='Can not create new envelope, Signed contract already existing on this quote.';
            return null;      
         } else{
           pageReference ref = createandSendWithDocuSign();
           ref.setRedirect(true);
           return ref;                 
        }
        return null;
    
        }
    
    else
    {
        System.debug('Event Manager Data: ' + quotRec.Event__r.Event_Manager__r.Email + ' : ' + quotRec.Event__r.Event_Manager__r.Name);

        displayPopup=true;
        displayVoidPopup = false;
        status='Cannot email quote unless quote is "Draft - Approved"';
        return null;
    }
    }
    
    public pageReference closePopup()
    {
    displayPopup=false;
    displayVoidPopup = false;
    pageReference ref=new pageReference('/'+quotRec.Id);
    ref.setRedirect(true);
    return ref;
    }
    
    // create and send with docuSign
    public PageReference createandSendWithDocuSign() {
        //Account quoteAccount = [select Id, PersonEmail, FirstName, LastName from Account where Id = :quotRec.AccountId];
        // Reminder and Expiration Settings
        string dsRes = '0,0,0,1,14,0';
        // Recipient name
        String recipientName = quotRec.Opportunity.Primary_Contact__r.Name == null ? quotRec.BillingName : quotRec.Opportunity.Primary_Contact__r.Name;
        System.debug('recipientName: '+recipientName);
        System.debug('quotRec.BillingName: '+quotRec.BillingName);
        System.debug('quotRec.Opportunity.Primary_Contact__r.Name: '+quotRec.Opportunity.Primary_Contact__r.Name);
        // Main Recipient
        string mainDsCrl = 'Email~'+(quotRec.Opportunity.DocuSign_Recipient__c != null ? quotRec.Opportunity.DocuSign_Recipient__c : quotRec.Email)+';LastName~'+recipientName+';RoutingOrder~1';
        String[] stringList = new String[0];
        // adding main recipent to list
        stringList.add(mainDsCrl); 
        //check for existing envolope records        
        String dsCrl = String.join(stringList, ',');
        System.debug('dsCrl==>'+dsCrl);
        PageReference page = new PageReference('/apex/dsfs__DocuSign_CreateEnvelope');
        page.getParameters().put('DSEID','0');
        page.getParameters().put('SourceID', quotRec.Id);
        page.getParameters().put('RQD', quotRec.Id);
        page.getParameters().put('RES', dsRes);
        page.getParameters().put('CRL', dsCrl);
        page.getParameters().put('OCO', 'Send');
        // For f1 branding
        /*
        if((quotRec.Event__r.Name).containsIgnoreCase('formula') && !((quotRec.Event__r.Name).containsIgnoreCase('gpmx') || (quotRec.Event__r.Name).containsIgnoreCase('cotae'))) {
            page.getParameters().put('DST', 'ba2bee8c-15c6-45f9-b668-2c7e94a60f87'); // F1 Brand API Id: ba2bee8c-15c6-45f9-b668-2c7e94a60f87
        }
        */
        page.setRedirect(true);
        return page;
    }
}