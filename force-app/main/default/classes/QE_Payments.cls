/**
 * @File Name          : QE_Payments.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/11/2020, 12:45:04 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/11/2020   jagrawal@addonblue.com     Initial Version
**/
public class QE_Payments {
    
    public Id quoteId;
    public Id additionalSigneeId;
    public String authErrorMessage {get; set;}
    public String userAuthToken {get; set;}
    public String selectedStripeCardId {get; set;}
    public String cNumber {get; set;}
    public String expMonth {get; set;}
    public String expYear {get; set;}
    public String cvc {get; set;}
    public String transactionErrorMessage {get; set;}
    public boolean userAuthenticated {get; set;}
    public boolean paymentInfoConfirmed {get; set;}
    public Boolean internationalStripe = false;
    
    public Quote quote {get; set;}
    public QE360_Quote_Additional_Signee__c additionalSignee {get; set;}
    public QE360_Stripe_Customer__c qeStripeCustomer {get; set;}
    public CurrentClient currentClient {get; set;}
    
    private Map<String,QE_StripeCard> mapOfCardIdandCardData = new Map<String,QE_StripeCard>();
    
    
    // Constructor
    public QE_Payments(ApexPages.StandardController stdController) {
        authenticateUser();
        // Get params from url
        // quoteId = ApexPages.currentPage().getParameters().get('id');
        // additionalSigneeId = ApexPages.currentPage().getParameters().get('asid');
        // try {
        //     // Get Quote Data
        //     quote = [
        //         select Id, Email, BillingName, BillingStreet, BillingCity, BillingState, BillingPostalCode, 
        //         Payment_Page_Access_Token__c, Opportunity.Owner.Email, GrandTotal, Grand_Total__c, Event__r.Name, Payment_Terms__c, OpportunityId,
        //         Event__r.International_Stripe__c
        //         from Quote 
        //         where Id = :quoteId
        //     ];
        //     internationalStripe = quote.Event__r.International_Stripe__c;
        //     System.debug('quote:::'+quote);
        //     // Save current client's data in currentClient class
        //     currentClient = new CurrentClient();
        //     currentClient.billingName = quote.BillingName;
        //     currentClient.billingStreet = quote.BillingStreet;
        //     currentClient.billingCity = quote.BillingCity;
        //     currentClient.billingState = quote.BillingState;
        //     currentClient.billingPostalCode = quote.BillingPostalCode;
        //     currentClient.email = quote.Email;
        //     currentClient.paymentPageAccessToken = quote.Payment_Page_Access_Token__c;
        //     currentClient.amount = quote.Grand_Total__c;
        //     currentClient.paymentTerm = quote.Payment_Terms__c;
            // Get Additional signee Data
            /* Not doing additional signees anymore
            if (additionalSigneeId != null) {
                additionalSignee = [
                    select Id, Name, Street_Address__c, City__c, State__c, Zip_Code__c, Country__c, Email__c,
                        Amount__c, Payment_Page_Access_Token__c, Quote_Standard__c, Stripe_Customer__c
                    from QE360_Quote_Additional_Signee__c 
                    where Id = :additionalSigneeId
                ];
                // Save current client's data in currentClient class
                currentClient.billingName = additionalSignee.Name;
                currentClient.billingStreet = additionalSignee.Street_Address__c;
                currentClient.billingCity = additionalSignee.City__c;
                currentClient.billingState = additionalSignee.State__c;
                currentClient.billingPostalCode = additionalSignee.Zip_Code__c;
                currentClient.email = additionalSignee.Email__c;
                currentClient.paymentPageAccessToken = additionalSignee.Payment_Page_Access_Token__c;
                currentClient.amount = additionalSignee.Amount__c;
            }
            */
        // } catch (Exception e) {
        //     System.debug('Exception => '+e.getLineNumber());
        //     System.debug('Exception => '+e.getCause());
        //     System.debug('Exception => '+e.getMessage());
        // }
    }
    
    // Authenticate User
    public PageReference authenticateUser() {
        getSignedQuotePDFId();
        // String trimmedUserAuthToken = userAuthToken.trim();
        // if (currentClient.paymentPageAccessToken == trimmedUserAuthToken) {
        //     userAuthenticated = true;
        //     authErrorMessage = null;
        //     // Get or Create QE Stripe Customer based on current client's email
        //     getQeStripeCustomer();
        // } else {
        //     authErrorMessage = 'Invalid token. Please try again.';
        // }
        return null;
    }
    
    // Get signed quote url
    public String getSignedQuotePDFId() {
        getQeStripeCustomer();
        // List<dsfs__DocuSign_Status__c> docuSignStatuses = new List<dsfs__DocuSign_Status__c>();
        // docuSignStatuses = [
        //     select Id, Name, dsfs__Envelope_Status__c, (select Id from Attachments)
        //     from dsfs__DocuSign_Status__c
        //     where Standard_Quote__c = :quote.Id and dsfs__Envelope_Status__c = 'Completed'
        //     order by CreatedDate desc
        // ];
        // if (docuSignStatuses.size() > 0) {
        //     return docuSignStatuses.get(0).attachments.get(0).Id;
        // } else {
            return null;
        // }
    }
    
    // Get Stripe Customer
    void getQeStripeCustomer() {
        getExistingCardOptions();
        // Get QE Stripe Customer from current client's email
        // QE360_Stripe_Customer_Helper qescHelper = new QE360_Stripe_Customer_Helper();
        // qeStripeCustomer = new QE360_Stripe_Customer__c();
        // qeStripeCustomer = qescHelper.getStripeCustomer(currentClient.email, currentClient.billingName, internationalStripe);
        // if(internationalStripe) {
        //     // International Stripe
        //    currentClient.stripeCustomerId = qeStripeCustomer.International_Stripe_Customer_Id__c;
        // } else {
        //     // Regular Stripe
        //    currentClient.stripeCustomerId = qeStripeCustomer.Stripe_Customer_Id__c;
        // }
        // currentClient.qeStripeCustomerId = qeStripeCustomer.Id;
        // System.debug('qeStripeCustomer: '+qeStripeCustomer);
    }
    
    // Get existing card options for current User/qeStripeCustomer
    public List<SelectOption> getExistingCardOptions() {
        List<SelectOption> options = new List<SelectOption>();
         confirmPaymentInfo();
        // Get list of cards if we have stripe customer id
        // if (currentClient.stripeCustomerId != null) {
        //     // Get stripe customer cards
        //     List<QE_StripeCard> currentCustomerCards = new List<QE_StripeCard>();
        //     System.debug('currentClient.stripeCustomerId: '+currentClient.stripeCustomerId);
        //     QE_StripeCustomer stripeCustomer = QE_StripeCustomer.getCustomer(currentClient.stripeCustomerId, internationalStripe);
        //     System.debug('INTL?: '+internationalStripe);
        //     System.debug('stripeCustomer: '+stripeCustomer);
           
        //     if(stripeCustomer.cards != null) {
        //         currentCustomerCards = stripeCustomer.cards.stripeData;
        //     } else {
        //         currentCustomerCards = stripeCustomer.sources.stripeData;
        //     }
        //     for (QE_StripeCard stripeCard : currentCustomerCards) {
        //         if (stripeCard.stripeType == null) {
        //             options.add(new SelectOption(stripeCard.Id , ' ...'+stripeCard.last4));
        //         } else {
        //             options.add(new SelectOption(stripeCard.Id , stripeCard.stripeType+' ...'+stripeCard.last4));
        //         }
                
        //         mapOfCardIdandCardData.put(stripeCard.Id, stripeCard);
        //     }
        //     // This will get Id of first card from above list of cards
        //     if (selectedStripeCardId == null) {
        //         selectedStripeCardId = options.get(0).getValue();
        //     }
        // } else {
        //     selectedStripeCardId = 'newcard';
        // }
        options.add(new SelectOption('newcard', 'Add new Payment Method'));
        return options;
    }
    
    // Confirm Payment
    public PageReference confirmPaymentInfo() {
        createCharge(null,null);
        // If had error first time, clear it and resubmit data
        // transactionErrorMessage = null;
        // // New Card
        // if (selectedStripeCardId == 'newcard') {
        //     // Card Properties
        //     Map<String, String> properties = new Map<String, String>();
        //     properties.put('card[number]', cnumber);
        //     properties.put('card[exp_year]', expYear);
        //     properties.put('card[exp_month]', expMonth);
        //     properties.put('card[cvc]', cvc);
        //     properties.put('card[name]', currentClient.billingName);
        //     properties.put('card[address_line1]', currentClient.billingStreet);
        //     properties.put('card[address_city]', currentClient.billingCity);
        //     properties.put('card[address_state]', currentClient.billingState);
        //     properties.put('card[address_zip]', currentClient.billingPostalCode);
        //     properties.put('card[metadata][savedb]', 'true');
        //     // Existing Stripe Customer
        //     if (currentClient.stripeCustomerId != null) {
        //         // Add Card
        //         try {
        //             QE_StripeCard stripeCard = QE_StripeCard.create(currentClient.stripeCustomerId, properties, internationalStripe);
        //             // Error 
        //             if (stripeCard.error != null) {
        //                 transactionErrorMessage = stripeCard.error.message;
        //             }
        //             // Success
        //             currentClient.stripeCardId = stripeCard.id;
        //             mapOfCardIdandCardData.put(stripeCard.id, stripeCard);
        //         } catch (Exception e) {
        //             System.debug('Exception => '+e.getLineNumber());
        //             System.debug('Exception => '+e.getCause());
        //         }
        //     } else {
        //         // New Stripe Customer 
        //         // Properties
        //         properties.put('email', currentClient.email);
        //         properties.put('metadata[savedb]', 'true');
        //         properties.put('metadata[salesRepEmail]', quote.Opportunity.Owner.Email);
        //         try {
        //             QE_StripeCustomer stripeCustomer = QE_StripeCustomer.create(properties,null,internationalStripe);
        //             // Success
        //             System.debug('stripeCustomer: '+stripeCustomer);
        //             currentClient.stripeCustomerId = stripeCustomer.id;
        //             if(stripeCustomer.cards != null) {
        //                 currentClient.stripeCardId = stripeCustomer.cards.stripeData[0].id;
        //                 mapOfCardIdandCardData.put(stripeCustomer.cards.stripeData[0].id, stripeCustomer.cards.stripeData[0]);
        //             } else {
        //                 currentClient.stripeCardId = stripeCustomer.sources.stripeData[0].id;
        //                 mapOfCardIdandCardData.put(stripeCustomer.sources.stripeData[0].id, stripeCustomer.sources.stripeData[0]);
        //             }
        //         } catch (QE_StripeException se) {
        //             // Error
        //             transactionErrorMessage = se.getMessage();
        //         }
        //     }
        // } else {
        //     // Existing Card
        //     currentClient.stripeCardId = selectedStripeCardId;
        // }
        
        // // Success
        // if (transactionErrorMessage == null) {
        //     // Create Charge
        //     try {
        //         System.debug('currentClient.stripeCustomerId => '+currentClient.stripeCustomerId);
        //         System.debug('currentClient.stripeCardId => '+currentClient.stripeCardId);
        //         createCharge(currentClient.stripeCustomerId, currentClient.stripeCardId);
        //     } catch (Exception e) {
        //         System.debug('Exception => '+e.getLineNumber());
        //         System.debug('Exception => '+e.getCause());
        //         System.debug('Exception => '+e.getMessage());
        //     }
        //     // Create/Update QE360_Stripe_Customer
        //     // International Stripe
        //     if (internationalStripe) {
        //         if (qeStripeCustomer.International_Stripe_Customer_Id__c == null) {
        //             qeStripeCustomer.International_Stripe_Customer_Id__c = currentClient.stripeCustomerId;
        //             upsert qeStripeCustomer;
        //         }
        //     }
        //     // Standard Stripe
        //     if (!internationalStripe) {
        //         if (qeStripeCustomer.Stripe_Customer_Id__c == null) {
        //             qeStripeCustomer.Stripe_Customer_Id__c = currentClient.stripeCustomerId;
        //             upsert qeStripeCustomer;
        //         }
        //     }
        // }
        return null;
    }
    
    // Create Charge
    public void createCharge(String stripeCustomerId, String stripeCardId) {
        CurrentClient obj = new CurrentClient();
        obj.paymentPageAccessToken = '';
        obj.email = '';
        obj.billingName = '';
        obj.billingStreet = '';
        obj.billingCity = '';
        obj.billingState = '';
        obj.billingPostalCode = '';
        obj.amount = 10;
        obj.paymentTerm = '';
        obj.qeStripeCustomerId = '';
        obj.stripeCustomerId = '';
        obj.stripeCardId = '';
        // PAYMENT TERMS: 100%
        // if (currentClient.paymentTerm == '100%') {
        //     // Clear Properties Map
        //     Map<String, String> properties = new Map<String, String>();
        //     properties.put('capture', 'true'); // 
        //     properties.put('source', currentClient.stripeCardId);
        //     properties.put('metadata[savedb]', 'true');
        //     properties.put('metadata[event_name]', quote.Event__r.Name);
        //     properties.put('metadata[quote_id]', quote.id);
        //     QE_StripeCharge stripeCharge = QE_StripeCharge.create(currentClient.stripeCustomerId, currentClient.amount, properties, null, internationalStripe);
        //     System.debug('stripeCharge: '+stripeCharge);
        //     // Error
        //     if (stripeCharge.error != null) {
        //         transactionErrorMessage = stripeCharge.error.message;
        //         System.debug('stripeCharge.failure_message: '+stripeCharge.failure_message);
        //     } else {
        //         // Success
        //         // Create QE Stripe Charge
        //         paymentInfoConfirmed = true;
        //         QE360_Stripe_Charge__c qeStripeCharge = new QE360_Stripe_Charge__c();
        //         qeStripeCharge.Amount__c = (stripeCharge.amount/100);
        //         qeStripeCharge.Captured__c = stripeCharge.captured;
        //         if(stripeCharge.card != null) {
        //             qeStripeCharge.Last4__c = stripeCharge.card.last4;
        //             qeStripeCharge.Stripe_Card_Id__c = stripeCharge.card.id;
        //         } else {
        //             qeStripeCharge.Last4__c = stripeCharge.source.last4;
        //             qeStripeCharge.Stripe_Card_Id__c = stripeCharge.source.id;
        //         }
        //             qeStripeCharge.Quote__c = quote.Id;
        //         if (additionalSignee != null) {
        //             qeStripeCharge.Quote_Additional_Signee__c = additionalSignee.Id; // This might change (to Account or Contact)
        //         }
                
        //         qeStripeCharge.Stripe_Charge_Id__c = stripeCharge.id;
        //         qeStripeCharge.Stripe_Customer__c = currentClient.qeStripeCustomerId;
        //         insert qeStripeCharge;
        //     }
        // }
        // // PAYMENT TERMS: Not 100%
        // if (currentClient.paymentTerm != '100%') {
        //     // Get payment terms
        //     paymentInfoConfirmed = true;
        //     List<Opportunity_Payment_Terms__c> quoteOpptPaymentTemrs = [
        //         select id, Amount__c, Opportunity__c, Payment_Due_Date__c, Payment_Term__c, Percentage_Of_Payment__c
        //         from Opportunity_Payment_Terms__c
        //         where Opportunity__c = :quote.OpportunityId and Payment_Term__c = :currentClient.paymentTerm
        //     ];
        //     // Create QE Stripe Charge to save card data for future use
        //     List<QE360_Stripe_Charge__c> stripeChargesToBeCreated = new List<QE360_Stripe_Charge__c>();
        //     for (Opportunity_Payment_Terms__c paymentTerm : quoteOpptPaymentTemrs) {
        //         QE360_Stripe_Charge__c qeStripeCharge = new QE360_Stripe_Charge__c();
        //         qeStripeCharge.Amount__c = paymentTerm.Amount__c;
        //         qeStripeCharge.Payment_Due_Date__c = paymentTerm.Payment_Due_Date__c;
        //         qeStripeCharge.Last4__c = mapOfCardIdandCardData.get(stripeCardId).last4;
        //         qeStripeCharge.Quote__c = quote.Id;
        //         if (additionalSignee != null) {
        //             qeStripeCharge.Quote_Additional_Signee__c = additionalSignee.Id; // This might change (to Account or Contact)
        //         }
        //         qeStripeCharge.Stripe_Card_Id__c = stripeCardId;
        //         qeStripeCharge.Stripe_Customer__c = currentClient.qeStripeCustomerId;
        //         stripeChargesToBeCreated.add(qeStripeCharge);
        //     }
        //     insert stripeChargesToBeCreated;
        // }
    }
    
    // Current User
    public class CurrentClient {
        public String paymentPageAccessToken {get; set;}
        public String email {get; set;}
        public String billingName {get; set;}
        public String billingStreet {get; set;}
        public String billingCity {get; set;}
        public String billingState {get; set;}
        public String billingPostalCode {get; set;}
        public Decimal amount {get; set;}
        public String paymentTerm {get; set;}
        private String qeStripeCustomerId {get; set;}
        private String stripeCustomerId {get; set;}
        private String stripeCardId {get; set;}
    }
    
}