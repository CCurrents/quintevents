/**
* @File Name          : QNGOnlineSaleCtrl.cls
* @Description        : 
* @Author             : jagrawal@addonblue.com
* @Group              : 
* @Last Modified By   : ratiksinghal@addonblue.com
* @Last Modified On   : 04-22-2022
* @Modification Log   : 
* Ver       Date            Author                 Modification
* 1.0    4/9/2020   lpanchal@addonblue.com     Initial Version
* 1.1    7/11/2020  jagrawal@addonblue.com     Added code for Retail Hotel Line Items
* 1.2    7/17/2020  jagrawal@addonblue.com     Added code to populate BillingName and ShippingName on Quote
* 1.3    7/24/2020  jagrawal@addonblue.com     Added condition to check if the Transportation Products exists on the current package or not
* 1.4    8/04/2020  jagrawal@addonblue.com     #476 Changes added for GPE Orders
* 1.5    8/26/2020  jagrawal@addonblue.com     #476 Added code to refer the PBE for Price on Package and Stay QLIs
* 1.6    8/28/2020  jagrawal@addonblue.com     #513 Added code for setting the Discount which is coming in JSON as the QLI Unit Price
* 1.7    9/14/2020  jagrawal@addonblue.com     #521 Commented this line to not set the unitprice manually rather the calculation for the same is added to QuoteTriggerHelper
* 1.8    9/22/2020  jagrawal@addonblue.com     #537 Added the Retail Hotels detail to Rooming List
* 1.9    11/13/2020 jagrawal@addonblue.com     #451 Protectgroup Integration
* 2.0    12/11/2020 jagrawal@addonblue.com     #608 Set Account Owner as Simon King for GPE Online Order
* 2.1    12/17/2020 jagrawal@addonblue.com     #659 Rewards Discount
* 2.2    11/26/2020 kchavda@addonblue.com      #627 Get the exchange rate date from the JSON for Online Orders
* 2.3    01/11/2021 jagrawal@addonblue.com     #695 Retail Hotel for Online Orders
* 2.4    01/21/2021 fsuraitawala@addonblue.com #715 QNG Quote from Salesforce
* 2.5    02/16/2021 kchavda@addonblue.com      #794 Mark QNG Quote from Salesforce Orders as Online Orders
* 2.6    02/17/2021 fsuraitawala@addonblue.com #753 and #774 package products are being assingned to correct Package
* 2.7    03/08/2021 vshah@addonblue.com        #848 Online Order - Create Opportunity, Quote and Order only if there are no errors
* 2.8    03/26/2021 kchavda@addonblue.com      #883 Mark Quote to Online Order Opportunities as Online Order
* 2.9    03/30/2021 kchavda@addonblue.com      #887 Add Accounting App Link on Opportunity for Online Order
* 3.0    03/30/2021 kchavda@addonblue.com      #882 Online order not going in 3/25/21
* 3.1    04/09/2021 kchavda@addonblue.com      #900 Quote status stuck to 'Draft' instead of 'Signed - Approved' for some online Orders
* 3.2    04/29/2021 kchavda@addonblue.com     #891 Add Order Purchase date on Order for Online Order
* 3.3    04/29/2021 fsuraitawala@addonblue.com #958 Populate "Accounting App Link" for Quote to Online Order
* 3.4    07/25/2021 fsuraitawala@addonblue.com #1033 club seacret Price change
**/
@RestResource(urlMapping='/qngOnlineSales/*')
global with sharing class QNGOnlineSaleCtrl {
    public static Boolean isQNGStay = true;
    
    public class wrpQLIRooming {
        public QuoteLineItem stayQLI;
        public Rooming_List__c roomingList;
    }
    
    public static Boolean newOnlineLead = false;
    public static Product2 retailHotelProduct;
    public static Boolean isUOB = false;
    
    @HttpPost
    global static void create() {
        savepoint sp1 = Database.setSavepoint();
        RequestResponse_Log__c objRequestResponse_Log = new RequestResponse_Log__c();
        try {
            RestRequest request = RestContext.request;
            RestContext.response.addHeader('Content-Type', 'application/json');
            
            String jsonString = request.requestBody.toString();
            objRequestResponse_Log.Request__c = jsonString;
            objRequestResponse_Log.Class_Name__c = 'QNGOnlineSaleCtrl';

            QNG_JSON2Apex objSale = (QNG_JSON2Apex) JSON.deserialize(jsonString, QNG_JSON2Apex.class);
            QNG_JSON2Apex.Sale Sale = objSale.Sale;
            
            String errorString = '';
            String strResponseBody = '';
            String QuoteID = null;
            
            // #608 Set Account Owner as Simon King for GPE Online Order - Start
            List<Pricebook2> lstPricebook = [Select Id, Name, GPE_Event__c, GPT_Event_Id__c from Pricebook2 where Id = :sale.eventId];
            
            //#715 QNG Quote from Salesforce
            if(String.isNotBlank(sale.quoteId)) {
                List<Quote> lstQuote = new List<Quote>([Select Id, Status, Pricebook2Id, OpportunityId, Opportunity.Accounting_App_Link__c, (Select Id FROM QuoteLineItems WHERE Product2.Name = 'Protect Group') FROM Quote WHERE Id = :sale.quoteId LIMIT 1]);
                
                if(lstQuote.size() > 0) {
                    if(lstQuote[0].Status == 'Signed - Approved'){
                        strResponseBody = '{"status" : "Failed", "Message" : "Quote already Signed - Approved"}';
                        objRequestResponse_Log.Response__c = strResponseBody;
                        objRequestResponse_Log.Status_Code__c = 'Failed';
                        RestContext.response.responseBody = Blob.valueOf(strResponseBody);
                    } else {
                        QuoteID = lstQuote[0].Id;
                        if(lstQuote[0].OpportunityId != null){
                            Opportunity OpptoUpdate = new Opportunity(id=lstQuote[0].OpportunityId);
                            OpptoUpdate.Online_Order__c = true;
                            //#958 Populate "Accounting App Link" for Quote to Online Order
                            if(String.isNotBlank(sale.accountingAppLink) && OpptoUpdate.Accounting_App_Link__c != sale.accountingAppLink) {
                                OpptoUpdate.Accounting_App_Link__c = sale.accountingAppLink;
                            }
                            TriggerHandler.bypass('OpportunityTriggerHandler');
                            update OpptoUpdate;
                            TriggerHandler.clearBypass('OpportunityTriggerHandler');                          
                        }
                        if(String.isNotBlank(Sale.protectGroupId)){
                            if(lstQuote[0].QuoteLineItems.size() > 0){
                                QuoteLineItem objQLI = new QuoteLineItem();
                                objQLI.Id = lstQuote[0].QuoteLineItems[0].Id;
                                if(objQLI.UnitPrice != sale.protectGroupAmount){
                                    //objQLI.UnitPrice = (sale.currencyCharged != 'USD') ?  sale.protectGroupAmount * sale.exchangeRate : sale.protectGroupAmount; //VKHOPADE - commented line - #1193
                                    objQLI.UnitPrice = sale.protectGroupAmount;
                                    TriggerHandler.bypass('QuoteTriggerHandler');
                                    update objQLI;
                                    TriggerHandler.clearBypass('QuoteTriggerHandler');
                                }
                            } else {
                                List<PriceBookEntry> lstPBE = new List<PriceBookEntry>([Select Id, Product2Id From PriceBookEntry WHERE Product2.Name = 'Protect Group' AND Pricebook2Id = :lstQuote[0].Pricebook2Id AND CurrencyIsoCode = :sale.currencyCharged]);
                                if(lstPBE.size() > 0){
                                    QuoteLineItem objQLI = new QuoteLineItem();
                                    objQLI.PriceBookEntryId = lstPBE[0].Id;
                                    objQLI.Product2Id = lstPBE[0].Product2Id;
                                    objQLI.QuoteId = QuoteID ;
                                    objQLI.Quantity = 1;
                                    if(sale.protectGroupAmount != null) {
                                        //objQLI.UnitPrice = (sale.currencyCharged != 'USD') ? sale.protectGroupAmount * sale.exchangeRate : sale.protectGroupAmount ; //VKHOPADE - commented line - #1193
                                        objQLI.UnitPrice = sale.protectGroupAmount;
                                    } else {
                                        objQLI.UnitPrice = 0.00;
                                    }
                                    objQLI.Record_Type__c = 'a La Carte';
                                    TriggerHandler.bypass('QuoteTriggerHandler');
                                    insert objQLI;
                                    TriggerHandler.clearBypass('QuoteTriggerHandler');
                                }
                            }
                        }
                    }
                } else {
                    strResponseBody = '{"status" : "Failed", "Message" : "Quote not found"}';
                    objRequestResponse_Log.Status_Code__c = 'Failed';
                    objRequestResponse_Log.Response__c = strResponseBody;
                    RestContext.response.responseBody = Blob.valueOf(strResponseBody);
                }
            } else {
                Contact contact = getAccount(Sale, lstPricebook);
                QuoteID = createOpportunity(contact, Sale, lstPricebook);
            }
            
            if(QuoteID != null) {
                // #608 Set Account Owner as Simon King for GPE Online Order - End
                Quote qtObj = new Quote();
                qtObj.Id = QuoteID;
                qtObj.Status = 'Signed - Approved';    
                qtObj.Timestamp__c = String.valueof(Datetime.now());
                //#1034 Don't mark "Quote to Online Order" as "Online Orders"
                //if(String.isNotBlank(sale.quoteId)) qtObj.Online_Order__c = true; //#794 Mark QNG Quote from Salesforce Orders as Online Orders
                if(String.isNotBlank(sale.purchaseDate)) qtObj.Purchase_Date__c = Date.parse(sale.purchaseDate);
                update qtObj;
                List<Order> lstOrders = new List<Order>();
                lstOrders = [Select Id, Name, QuoteId, OpportunityId,Protect_Group_Id__c,Quote_to_Online_Order__c FROM Order where quoteId =:QuoteID ];
                if(lstOrders.size() > 0) {
                    //#451 Protectgroup Integration
                    Boolean isOrderUpdate = false;
                    Order objOrder = new Order();
                    objOrder.Id = lstOrders[0].Id;
                    if(String.isNotBlank(Sale.protectGroupId)){
                        objOrder.Protect_Group_Id__c = Sale.protectGroupId;
                        isOrderUpdate = true;
                    }
                    //#706 Add new field "qngOrderId" to Order object -- START
                    if(String.isNotBlank(Sale.qngOrderId)){
                        objOrder.QNG_Order_Id__c = Sale.qngOrderId;
                        isOrderUpdate = true;
                    }
                    //#706 Add new field "qngOrderId" to Order object -- END
                    
                    //#794 Mark QNG Quote from Salesforce Orders as Online Orders
                    if(String.isNotBlank(Sale.quoteId)){
                        objOrder.Quote_to_Online_Order__c = true;
                        isOrderUpdate = true;
                    }
                   
                    if(isOrderUpdate){
                        // #645 Temporary fix for Too many SOQL error due to Order Update -- START
                        TriggerHandler.bypass('OrderTriggerHandler');
                        update objOrder;
                        TriggerHandler.clearBypass('OrderTriggerHandler');
                        // #645 Temporary fix for Too many SOQL error due to Order Update -- END
                    }
                    strResponseBody = '{"status" : "Success", "OrderId" : "'+lstOrders[0].Id+'","OpportunityId" : "'+lstOrders[0].OpportunityId+'"}';
                    RestContext.response.responseBody = Blob.valueOf(strResponseBody);
                    objRequestResponse_Log.Order__c = lstOrders[0].Id;
                    objRequestResponse_Log.Opportunity__c = lstOrders[0].OpportunityId;
                    objRequestResponse_Log.Status_Code__c = 'Success';
                } else {
                    strResponseBody = '{"status" : "Failed", "Message" : "Order not found"}';
                    objRequestResponse_Log.Response__c = strResponseBody;
                    objRequestResponse_Log.Status_Code__c = 'Failed';
                    RestContext.response.responseBody = Blob.valueOf(strResponseBody);
                }
                
                objRequestResponse_Log.Quote__c = QuoteID;
                objRequestResponse_Log.Response__c = strResponseBody;
            }
        } catch(Exception e) {
            system.debug('Exception ex: '+e.getMessage()+'---'+e.getLineNumber());
            objRequestResponse_Log.Response__c = 'Exception:- '+e.getMessage()+'=\nLineNumber=>'+e.getLinenumber()+'\nStackTrace:-'+e.getStackTraceString();
            objRequestResponse_Log.Status_Code__c = 'Failed';
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf('{"status" : "failed", "Message" : "'+e.getMessage()+'"}');
            Database.rollback(sp1);
        }
        
        insert objRequestResponse_Log;
    }
    
    // #608 Set Account Owner as Simon King for GPE Online Order
    private static Contact getAccount(QNG_JSON2Apex.Sale sale,List<Pricebook2> lstPricebook) {
        Account account;
        Contact contact;
        Lead lead;
        if ((contact = findAccount(sale.email)) != null) {
            //account = new Account();
            account = contact.Account;
            System.debug('Account--!!'+account);
            //account.Id = contact.AccountId;
            if(String.isnotEmpty(sale.promoterId))
                account.Promoters_Name__c = sale.promoterId;
            if(String.isnotEmpty(sale.resellerId))
                account.Resellers_Name__c = sale.resellerId;
            account.Google_Analytics_ID__c = sale.googleAnalyticsId;
            account.Google_Analytics_Site_ID__c = sale.googleAnalyticsSiteId;
            //account.Copy_Billing_to_Shipping_Address__c = true;
            account.BillingStreet = sale.street;
            account.BillingCity = sale.city;
            account.BillingPostalCode = sale.zip;
            account.BillingCountry = sale.country;
            account.BillingState = sale.state;
            account.ShippingStreet = sale.street;
            account.ShippingCity = sale.city;
            account.ShippingPostalCode = sale.zip;
            account.ShippingCountry = sale.country;
            account.ShippingState = sale.state;
            account.Marketing_Email_Consent__c = 'Yes';
            account.Phone = sale.phone;
            if(account.Owner.Name == 'Quinton Escobar') isUOB = true;
            if(account.IsPersonAccount){
                if(!Test.isRunningTest()){
                    account.Event_Interest_Picklist_PB__pc = sale.eventId;
                }
                account.Company_Name__pc = sale.company_name;
            }
            update account;
            //return account;
            return contact;
        } else if ((lead = findLead(sale.email)) != null) {
            lead.Google_Analytics_ID__c = sale.googleAnalyticsId;
            lead.Google_Analytics_Site_ID__c = sale.googleAnalyticsSiteId;
            lead.FirstName = sale.firstName;
            lead.LastName = sale.lastName;
            lead.Street = sale.street;
            lead.City = sale.city;
            lead.State = sale.state;
            lead.PostalCode = sale.zip;
            lead.Country = sale.country;
            lead.Phone = sale.phone;
            lead.Marketing_Email_Consent__c = 'Yes';
            lead.Promoters_Name__c = sale.promoterId;
            lead.Resellers_Name__c = sale.resellerId;
            lead.Company = sale.company_name;
            lead.Company_Name__c = sale.company_name;
            system.debug('sale.eventId'+sale.eventId);
            lead.Event_Interest_Picklist_PB__c = sale.eventId;   
            if(lead.Owner.Name == 'Quinton Escobar') isUOB = true;
            update lead;
            return convertLead(lead);
        } else {
            // #608 Set Account Owner as Simon King for GPE Online Order
            lead = createLead(sale,lstPricebook);
            isUOB = true;
            return convertLead(lead);
        }
    }
    
    private static Contact findAccount(String email) {
        // #425 Added code to consider Secondary Email as well.
        List<Contact> contacts = [SELECT Id, AccountId, Account.IsPersonAccount, Account.OwnerId, Account.Owner.Name, Account.RecordTypeId FROM Contact WHERE AccountId != null and (Email = :email OR Secondary_Email__c = :email) LIMIT 1];
        if (contacts.size() == 0) {
            return null;
        } else {
            return contacts[0]; //[SELECT Id,IsPersonAccount FROM Account WHERE Id = :contacts[0].AccountId];
        }
    }
    
    private static Lead findLead(String email) {
        // #425 Added code to consider Secondary Email as well.
        List<Lead> leads = [SELECT Id, Name, Company, Company_Name__c, Lead_Type__c, OwnerId, Owner.Name FROM Lead WHERE (Email = :email OR Secondary_Email__c = :email) and IsConverted = false LIMIT 1];
        if (leads.size() == 0) {
            return null;
        } else {
            return leads[0];
        }
    }
    // #608 Set Account Owner as Simon King for GPE Online Order - Start
    public static Lead createLead(QNG_JSON2Apex.Sale sale, List<Pricebook2> lstPricebook) {
        Lead lead = new Lead();
        //#368 Code to use Sales Rep as owner for new Lead and 
        System.debug('lstPricebook[0].GPE_Event__c##' + lstPricebook[0].GPE_Event__c);
        if(lstPricebook[0].GPE_Event__c){
            System.debug('System.Label.GPE_Online_Order_OwnerId##' + System.Label.GPE_Online_Order_OwnerId);
            lead.OwnerId = System.Label.GPE_Online_Order_OwnerId;
        }
        else{
            lead.OwnerId = System.Label.QNGLeadOwnerID;
        }
        // #608 Set Account Owner as Simon King for GPE Online Order - End
        lead.City = sale.city;
        lead.Country = sale.country;
        lead.Email = sale.email;
        lead.FirstName = sale.firstName;
        lead.LastName = sale.lastName;
        lead.LeadSource = 'web ' + sale.site;
        lead.Lead_Type__c = 'Person';
        lead.PostalCode = sale.zip;
        lead.State = sale.state;
        lead.Street = sale.street;
        lead.Phone = sale.phone;
        lead.Marketing_Email_Consent__c = 'Yes';
        lead.Source__c = 'web ' + sale.site;
        lead.Google_Analytics_ID__c = sale.googleAnalyticsId;
        lead.Google_Analytics_Site_ID__c = sale.googleAnalyticsSiteId;
        if(String.isnotEmpty(sale.promoterId))
            lead.Promoters_Name__c = sale.promoterId;
        if(String.isnotEmpty(sale.resellerId))    
            lead.Resellers_Name__c = sale.resellerId;
        lead.Company = sale.company_name;
        lead.Company_Name__c = sale.company_name;
        //OwnerId = Label.Online_Order_OwnerId,
        lead.Event_Interest_Picklist_PB__c = sale.eventId;
        system.debug('lead'+lead);
        insert lead;
        newOnlineLead = true;
        return lead;
    }
    
    private static Contact convertLead(Lead lead) {
        // #243 Too many SOQL issue resolution -- START
        Database.LeadConvertResult result = LeadConversionHelper.convert(lead);
        //Database.LeadConvertResult result = LeadConversionHelper.convert(lead.Id);
        // #243 Too many SOQL issue resolution -- END
        if (result.isSuccess()) {
            Contact contact = [SELECT Id, AccountId,Account.IsPersonAccount, Account.OwnerId, Account.RecordTypeId FROM Contact WHERE Id =:result.getContactId()];
            Account account = contact.Account;//[SELECT Id FROM Account WHERE Id = :result.getAccountId()];
            account.Copy_Billing_to_Shipping_Address__c = true;
            account.Marketing_Email_Consent__c = 'Yes';
            update account;
            //return account;
            return contact;
        } else {
            return null;
        }
    }
    
    private static String createOpportunity(Contact primaryContact, QNG_JSON2Apex.Sale sale, List<Pricebook2> lstPricebook) {
        System.debug('email--'+sale.email);
        set<QNG_JSON2Apex.LineItems> OnlineSaleLineItemSet =  new set<QNG_JSON2Apex.LineItems>();
        Account account = primaryContact.Account;
        /* Commented the SOQL by Jheel
        * Account account = [
        SELECT Id, OwnerId, RecordTypeId, IsPersonAccount
        FROM Account
        WHERE Id = :acct.Id
        ];*/
        //List<Pricebook2> lstPricebook = [Select Id,Name, GPE_Event__c, GPT_Event_Id__c from Pricebook2 where Id =: sale.eventId];
        if(lstPricebook.isEmpty()){
            return 'Event not found';
        }
        
        // Primary Contact should be the person placing order
        // Commented the SOQL by Jheel
        //Contact primaryContact = [Select Id From Contact Where Email = :sale.email Limit 1];
        //Contact billtoShiptoContact = [Select Id From Contact Where FirstName =: sale.firstName And LastName =: sale.lastName Limit 1];
        String paymentTermsStr = sale.paymentTerms == null ? '100%' : sale.paymentTerms;
        Date oppCloseDate = String.isNotBlank(sale.purchaseDate) ? Date.parse(sale.purchaseDate): System.today();
        Opportunity opportunity = new Opportunity(
            AccountId = account.Id,
            Primary_Contact__c = primaryContact.Id,
            //Name = lstPricebook[0].Name, //'Online Sale', // NAME OF PRICEBOOK GET THAT FROM EVENT ID
            CloseDate = oppCloseDate,
            Contact_Site__c = sale.site,
            Currency_Charged__c = sale.currencyCharged,
            CurrencyIsoCode = sale.currencyCharged,
            Discount_Code__c = sale.discountCode,
            LeadSource = 'web ' + sale.site,
            OwnerId = newOnlineLead ? Label.Not_Assigned_UserId : account.OwnerId,
            RecordTypeId = opportunityRecordType(account),
            StageName = 'Closed Won',
            Pricebook2Id = sale.eventId,
            Payment_Terms__c = paymentTermsStr,
            Payment_Method__c = String.isNotBlank(sale.paymentMethod) ? sale.paymentMethod : 'Credit Card',
            Phone__c = sale.phone,
            Bill_To_Name__c = sale.firstName + ' ' + sale.lastName,
            Billing_Street__c = sale.street,
            Billing_City__c = sale.city,
            Reward_Percentage__C = sale.h4hRewardPercentage,
            Billing_State_Province__c = sale.state,
            Billing_Zip_Postal_Code__c = sale.zip,
            Billing_Country__c = sale.country,
            PO_Number__c = sale.purchaseOrderNumber,
            Ship_To_Name__c = sale.firstName + ' ' + sale.lastName,
            Shipping_Street__c = sale.street,
            Shipping_City__c = sale.city,
            Shipping_State_Province__c = sale.state,
            Shipping_Zip_Postal_Code__c = sale.zip,
            Shipping_Country__c = sale.country,
            Total_After_Discount__c = sale.totalAfterDiscount,
            Total_Charged_In_Currency__c = sale.totalChargedInCurrency,
            Visitor_Country__c = sale.visitorCountry,
            API__c = (sale.api != null ? sale.api : false),
            Accounting_App_Link__c = sale.accountingAppLink
        );
        // #476 Changes added for GPE Orders -- START
        if(lstPricebook[0].GPE_Event__c){
            if(lstPricebook[0].Name.startswith('GPE - ')){
                opportunity.Name = lstPricebook[0].Name;
            }else{
                opportunity.Name = 'GPE - ' + lstPricebook[0].Name;
            }
            opportunity.GPE_Online_Order__c = true;
            opportunity.Paid_in_Full__c = true;
            opportunity.GPE_Event_Name__c = opportunity.Name;
        } else {
            opportunity.Name = lstPricebook[0].Name;
        }
        // #476 Changes added for GPE Orders -- END
        opportunity.Online_Order__c = true;
        insert opportunity;
        system.debug('opportunity'+opportunity);
        Quote objQuote = new Quote(
            Primary_Contact__c = primaryContact.Id,
            //Name = lstPricebook[0].Name,//'Online Sale', // NAME OF OPPORTUNITY 
            OpportunityId = opportunity.id,          
            CurrencyIsoCode = sale.currencyCharged,
            OwnerId = newOnlineLead ? Label.Not_Assigned_UserId : account.OwnerId,           
            Status = 'Draft',           
            Payment_Terms__c = paymentTermsStr,
            Payment_Method__c = String.isNotBlank(sale.paymentMethod) ? sale.paymentMethod : 'Credit Card',  
            // #424 BillingName field populated by Jheel
            BillingName = sale.firstName + ' ' + sale.lastName,         
            BillingStreet = sale.street,
            BillingCity = sale.city,          
            BillingState = sale.state,
            BillingPostalCode = sale.zip,
            BillingCountry = sale.country,           
            ShippingStreet = sale.street,
            ShippingCity = sale.city,
            ShippingState = sale.state,
            ShippingPostalCode = sale.zip,
            ShippingCountry = sale.country,
            // #424 ShippingName field populated by Jheel
            ShippingName = sale.firstName + ' ' + sale.lastName,
            // #266 Added for Change Order Issue
            Selected_Payment_Term__c = paymentTermsStr,
            GPE_Exchange_Rate__c = sale.exchangeRate,
            Pricebook2Id = sale.eventId,
            UOB__c = isUOB,
            Purchasing_Site__c = sale.site
        );
        // #476 Changes added for GPE Orders -- START
        if(lstPricebook[0].GPE_Event__c){
            if(lstPricebook[0].Name.startswith('GPE - ')){
                objQuote.Name = lstPricebook[0].Name;
            } else {
                objQuote.Name = 'GPE - ' + lstPricebook[0].Name;
            }
            objQuote.GPE_Online_Order__c = true;
        } else {
            objQuote.Name = lstPricebook[0].Name;
        }
        // #476 Changes added for GPE Orders -- END
        objQuote.Online_Order__c = true;
        //#1160 - RoomCash Change --START
        if(sale.pointsAwarded != null && sale.pointsAwarded != 0) {
            objQuote.Total_RoomCash_Points__c = sale.pointsAwarded;
        }
        //#1160 - RoomCash Change --END
        insert objQuote;
        
        //#753 and #774 package products are being assingned to correct Package
        if(objQuote.Id != null) {
            addQuoteLineItem(objQuote, sale);
        }
        return String.valueof(objQuote.Id);
    }
    
    private static string opportunityRecordType(Account account) {        
        String typeName = account.IsPersonAccount ? 'Person' : 'Business';
        String RecordTypeName = '';        
        if(typeName == 'Person') RecordTypeName = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Person Opportunity').getRecordTypeId();
        else if(typeName == 'Business') RecordTypeName = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Business Opportunity').getRecordTypeId();        
        return RecordTypeName;
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////// LOGIC TO CREATE QUOTE LINE ITEMS ////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    private static void addQuoteLineItem(Quote objQuote, QNG_JSON2Apex.Sale sale) {
        //#753 and #774 package products are being assingned to correct Package        
        Set<Id> setPackageId = new Set<Id>();
        Set<Id> setHotelStayId = new Set<Id>();
        Set<Id> setAllProductId = new Set<Id>();
        Map<Id, Set<Id>> mapPackgeWithBundle = new Map<Id, Set<Id>>();
        for(QNG_JSON2Apex.LineItems item : sale.lineItems) {
            if(null != item.packageId && String.isNotBlank(item.packageId)){
                setPackageId.add(item.packageId);
                setAllProductId.add(item.packageId);
            }
            //Stay Logic
            if(item.Stays != null && item.Stays.size() > 0) {
                for(QNG_JSON2Apex.Stays objStay : item.Stays) {
                    if(String.isNotBlank(objStay.stayid) && objStay.stayQty != null && objStay.stayQty > 0) {
                        setAllProductId.add(objStay.stayid);
                        setHotelStayId.add(objStay.stayid);
                    }
                }
            }
        }
        if(!setPackageId.isEmpty()){
            for(Products_Bundle__c item: [Select Parent_Product__c, Type__c, Child_product__c FROM Products_Bundle__c 
                                          WHERE Parent_Product__c in :setPackageId and Type__c = 'Package Product']) { 
                setAllProductId.add(item.Child_product__c);
                if(mapPackgeWithBundle != null && mapPackgeWithBundle.containskey(item.Parent_Product__c)){
                    Set<Id> setIds = mapPackgeWithBundle.get(item.Parent_Product__c);
                    setIds.add(item.Child_product__c);
                    mapPackgeWithBundle.put(item.Parent_Product__c, setIds);
                } else {
                    mapPackgeWithBundle.put(item.Parent_Product__c, new Set<Id>{item.Child_product__c});
                }
            }
        }
        Map<Id, Id> mapStay2Hotel = new Map<Id, Id>();
        Map<Id, Id> mapHotel2Transportation = new Map<Id, Id>();
        if(!setHotelStayId.isEmpty()){
            for(Products_Bundle__c objBundle : [Select Parent_Product__c, Type__c, Child_product__c FROM Products_Bundle__c 
                                                WHERE Child_Product__c IN:setHotelStayId and Type__c = 'Hotel Stay']){
                mapStay2Hotel.put(objBundle.Child_product__c, objBundle.Parent_Product__c);
                setAllProductId.add(objBundle.Parent_Product__c);
            }
            if(mapStay2Hotel != null && mapStay2Hotel.size() > 0){
              for(Products_Bundle__c objBundle : [Select Parent_Product__c, Type__c, Child_product__c FROM Products_Bundle__c 
                                                  WHERE Parent_Product__c in :mapStay2Hotel.values() and Type__c = 'Hotel Transportation']){
                  mapHotel2Transportation.put(objBundle.Parent_Product__c, objBundle.Child_product__c);
                  setAllProductId.add(objBundle.Child_product__c);
              }  
            }
        }
        Map<Id, PricebookEntry> mapProductWithPBE = new Map<Id, PricebookEntry>();
        Map<Id,Product2> mapProducts = new Map<Id,Product2>(); 
        if(!setAllProductId.isEmpty()){
            mapProducts = new Map<Id,Product2>([SELECT Id, Type__c, Club_Seacret_Price__c, H4H_RatePlan_Code__c, Name FROM Product2 WHERE Id in :setAllProductId]);
            mapProductWithPBE = getPricebookEntries(setAllProductId, sale);
        }
        List<QuoteLineItem> lstQuoteLineItem = new List<QuoteLineItem>();
        Integer i = 0;
        Integer j = 0;
        Map<String, QuoteLineItem> mapPackageLineItem = new Map<String, QuoteLineItem>();
        Map<String, QuoteLineItem> mapHotelLineItem = new Map<String, QuoteLineItem>();
        Map<String, QuoteLineItem> mapTransLineItem = new Map<String, QuoteLineItem>();
        List<QuoteLineItem> lstPackageProductLineItem = new List<QuoteLineItem>();
        List<QuoteLineItem> lstStayLineItem = new List<QuoteLineItem>();
        List<wrpQLIRooming> lstwrpQLIROOM = new List<wrpQLIRooming>();
        
        for(QNG_JSON2Apex.LineItems objLineItem : sale.lineItems) {
            if(objLineItem.packageId != null && mapProductWithPBE.containskey(objLineItem.packageId)){
                QuoteLineItem packageLineItem = new QuoteLineItem();
                packageLineItem.Quantity = objLineItem.packageQty;
                packageLineItem.QuoteId = objQuote.Id;
                //#1033 club seacret Price change
                if(objLineItem.seacret != null && objLineItem.seacret && !objQuote.GPE_Online_Order__c) {
                    if(mapProducts != null && mapProducts.containsKey(objLineItem.packageId)) {
                        Decimal ClubSeacretPrice = mapProducts.get(objLineItem.packageId).Club_Seacret_Price__c;
                        System.debug('ClubSeacretPrice :'+ClubSeacretPrice);
                        if(objQuote.currencyISOCode == 'USD') {
                            packageLineItem.UnitPrice = ClubSeacretPrice != null ? ClubSeacretPrice : null;
                        } else {
                            packageLineItem.UnitPrice = ClubSeacretPrice != null ? calculateUnitPriceforGPEItems(sale.exchangeRate, ClubSeacretPrice, objLineItem.packageQty) : null;
                        }
                    }
                } else {
                    //#476 Changed code to take price based on the PBE with the CurrencyISOCode
                    if(objQuote.GPE_Online_Order__c && objQuote.currencyISOCode != 'USD' && sale.exchangeRate != null) {
                        packageLineItem.UnitPrice = calculateUnitPriceforGPEItems(sale.exchangeRate, objLineItem.packagePrice, objLineItem.packageQty);
                        packageLineItem.GPE_Total_Price__c = (objLineItem.packagePrice * objLineItem.packageQty) * sale.exchangeRate;
                    } else {                            
                        packageLineItem.UnitPrice = (mapProductWithPBE.get(objLineItem.packageId).UnitPrice != null ? mapProductWithPBE.get(objLineItem.packageId).UnitPrice.setScale(2, RoundingMode.CEILING) : null);
                        if(objQuote.GPE_Online_Order__c) {
                            packageLineItem.GPE_Total_Price__c = packageLineItem.UnitPrice * objLineItem.packageQty;
                        }
                    }
                }
                packageLineItem.Record_Type__c = 'Package';
                packageLineItem.PriceBookEntryId = mapProductWithPBE.get(objLineItem.packageId).Id;
                packageLineItem.Product2Id = objLineItem.packageId;
                mapPackageLineItem.put(string.valueof(i), packageLineItem);
                System.debug('packageLineItem: '+packageLineItem);
            }
                if(mapPackgeWithBundle != null && mapPackgeWithBundle.containsKey(objLineItem.packageId)){
                    for(Id productId : mapPackgeWithBundle.get(objLineItem.packageId)){
                        QuoteLineItem productLineItem = new QuoteLineItem();
                        productLineItem.Quantity = objLineItem.packageQty;
                        productLineItem.QuoteId = objQuote.Id;
                        productLineItem.UnitPrice = 0.00;
                        productLineItem.Record_Type__c = 'Package Product';
                        productLineItem.PriceBookEntryId = mapProductWithPBE.get(productId).Id;
                        productLineItem.Quote_Package__c = string.valueof(i);
                        productLineItem.Product2Id = productId;
                        lstPackageProductLineItem.add(productLineItem);
                    }
                }
                
                //Stay Logic
                if(objLineItem.Stays != null && objLineItem.Stays.size() > 0) {
                    for(QNG_JSON2Apex.Stays objStay : objLineItem.Stays) {
                        if(String.isNotBlank(objStay.stayid) && objStay.stayQty != null && objStay.stayQty > 0) {
                            //Hotel Stay
                            if(mapProductWithPBE != null && mapProductWithPBE.containsKey(objStay.stayid)){
                                for(Integer RoomQty = 0; RoomQty < objStay.stayQty; RoomQty++) {
                                    QuoteLineItem StayLineItem = new QuoteLineItem();
                                    StayLineItem.Quantity = 1;
                                    StayLineItem.QuoteId = objQuote.Id;
                                    StayLineItem.UnitPrice = (mapProductWithPBE.get(objStay.stayid).UnitPrice != null? mapProductWithPBE.get(objStay.stayid).UnitPrice.setscale(2,RoundingMode.CEILING):null);
                                    StayLineItem.Record_Type__c = 'Hotel Stay';
                                    StayLineItem.PriceBookEntryId = mapProductWithPBE.get(objStay.stayid).Id;
                                    StayLineItem.Quote_Package__c = string.valueof(i);
                                    StayLineItem.Hotel_Package_Id__c = string.valueof(j);
                                    StayLineItem.Product2Id = objStay.stayid;
                                    StayLineItem.Room_Quantity__c = objStay.stayQty;
                                    lstStayLineItem.add(StayLineItem);
                                    
                                    Rooming_List__c roomList = new Rooming_List__c();
                                    if(mapProducts != null && mapProducts.containsKey(objStay.stayid)){
                                        roomList.H4H_RatePlan_Code__c = mapProducts.get(objStay.stayid).H4H_RatePlan_Code__c;
                                    }
                                    roomList.Number_of_Adults__c = 2;
                                    roomList.Quote__c = objQuote.Id;
                                    roomList.Product__c = objStay.stayid;
                                    roomList.QNG_Rooming_List_Id__c = objStay.qngRoomingListId;
                                    
                                    wrpQLIRooming wrpOliRoom = new wrpQLIRooming();
                                    wrpOliRoom.stayQLI = StayLineItem;
                                    wrpOliRoom.roomingList = roomList;
                                    lstwrpQLIROOM.add(wrpOliRoom);
                                }
                            }
                            //Package Hotel and Hotel Transportation
                            if(mapStay2Hotel != null && mapStay2Hotel.containskey(objStay.stayid)){
                                QuoteLineItem hotelLineItem = new QuoteLineItem();
                                hotelLineItem.Quantity = (null != objLineItem.hotelQty) ? objLineItem.hotelQty : 1;
                                hotelLineItem.QuoteId = objQuote.Id;
                                hotelLineItem.UnitPrice = (null != objLineItem.hotelPrice) ? objLineItem.hotelPrice : 0.00;
                                hotelLineItem.Record_Type__c = 'Package Hotel';
                                hotelLineItem.PriceBookEntryId = mapProductWithPBE.get(mapStay2Hotel.get(objStay.stayid)).Id;
                                hotelLineItem.Quote_Package__c = string.valueof(i);
                                hotelLineItem.Product2Id = mapStay2Hotel.get(objStay.stayid);
                                hotelLineItem.Room_Quantity__c = objStay.stayQty;
                                mapHotelLineItem.put(string.valueof(j), hotelLineItem);
                                
                                if(objLineItem.includeTransportation && mapHotel2Transportation != null 
                                    && mapHotel2Transportation.containsKey(mapStay2Hotel.get(objStay.stayid))){
                                    QuoteLineItem objQLILineItemTrans = new QuoteLineItem();
                                    objQLILineItemTrans.Quantity = objLineItem.packageQty;
                                    objQLILineItemTrans.QuoteId =  objQuote.Id;
                                    objQLILineItemTrans.UnitPrice = mapProductWithPBE.get(mapHotel2Transportation.get(mapStay2Hotel.get(objStay.stayid))).UnitPrice;
                                    objQLILineItemTrans.PriceBookEntryId = mapProductWithPBE.get(mapHotel2Transportation.get(mapStay2Hotel.get(objStay.stayid))).Id;
                                    objQLILineItemTrans.Product2Id = mapHotel2Transportation.get(mapStay2Hotel.get(objStay.stayid));                
                                    objQLILineItemTrans.Record_Type__c = 'Hotel Transportation'; 
                                    objQLILineItemTrans.Quote_Package__c = string.valueof(i);
                                    objQLILineItemTrans.Hotel_Package_Id__c = string.valueof(j);
                                    mapTransLineItem.put(objStay.stayid, objQLILineItemTrans);
                                }
                            }
                        }
                    }
                }
            //}
            
            i++;
            j++;
        }
        
        List<QuoteLineItem> lstAllLineItem = new List<QuoteLineItem>();
        
        // If has discount then add discount line item to opportunity
        if(sale.discount > 0) {
            // Query get discount pricebook entry this event
            List<Product2> discountProd = new List<Product2>();
            Map<Id, PricebookEntry> PricebookEntryfrDicountObjMap =new Map<Id, PricebookEntry>(); 
            set<Id> dicProductsId = new set<Id>();
            discountProd =  [Select Id, Primary_Price_Book__c From Product2 
                             WHERE Primary_Price_Book__c = :sale.eventId AND Product2.Type__c = 'Discount' And Name = 'Discount' And IsActive = True];
            // Add discount line item if relted pricebook entry found.
            if(discountProd != null && discountProd.size() > 0) {
                dicProductsId.add(discountProd[0].Id);
                PricebookEntryfrDicountObjMap = getPricebookEntries(dicProductsId,sale);
                
                QuoteLineItem objQLI = new QuoteLineItem();
                objQLI.QuoteId = objQuote.Id;
                objQLI.PricebookEntryId = PricebookEntryfrDicountObjMap.get(discountProd[0].Id).Id;
                objQLI.Quantity = 1;
                // #513 Added code for setting the Discount which is coming in JSON as the QLI Unit Price
                objQLI.UnitPrice = -(sale.discount != null && sale.discount != 0? sale.discount.setscale(2,RoundingMode.CEILING):sale.discount); // Not being used but TotalPrice or UnitPrice is required for OLI thats why setting it.
                if(objQuote.GPE_Online_Order__c) objQLI.GPE_Total_Price__c = objQLI.UnitPrice * objQLI.Quantity;
                objQLI.Record_Type__c = 'A La Carte';
                objQLI.ProductType__c = 'Discount';
                System.debug('discobjQLI'+objQLI);
                lstAllLineItem.add(objQLI);
            } else {
                System.debug('No Discount: Discount PricebookEntry not found');
            }
        } else {
            System.debug('No Discount: Discount amount is not greater than 0');
        }
        
        // If has h4hPointsSpent then add h4hPointsSpent line item to Quote
        System.debug('****sale.h4hPointsSpent****'+sale.h4hPointsSpent);
        if(sale.h4hPointsSpent != null && sale.h4hPointsSpent != '' && Double.valueof(sale.h4hPointsSpent) > 0) {
            // Query get discount pricebook entry this event
            System.debug('****sale.h4hPointsSpent****'+sale.h4hPointsSpent);
            List<PricebookEntry> Pbe = new List<PricebookEntry>([
                SELECT Id FROM PricebookEntry WHERE Pricebook2Id =:sale.eventId AND Product2.Type__c = 'Reward Discount' 
                AND Product2.Name = 'Reward Discount' AND Product2.IsActive = True AND CurrencyIsoCode = :objQuote.CurrencyIsoCode
            ]);
            system.debug('****Pbe size***' +Pbe.size());
            // Add h4hPointsSpent line item if related pricebook entry found.
            if(Pbe.size() > 0) {
                QuoteLineItem objRewardQLI = new QuoteLineItem();
                Quote currentQuote = [SELECT Id, Pricebook2.Program__r.Name, CurrencyISOCode FROM Quote WHERE Id = :objQuote.Id LIMIT 1];
                System.debug('currentQuote.Pricebook2.Program__r.Name@'+currentQuote.Pricebook2.Program__r.Name);
                if(currentQuote.Pricebook2.Program__r.Name != null && currentQuote.Pricebook2.Program__r.Name.contains('F1 E')){
                    objRewardQLI.QuoteId = objQuote.Id;
                    objRewardQLI.PricebookEntryId =  Pbe[0].Id;
                    objRewardQLI.Quantity = 1;
                    objRewardQLI.Unitprice = Utility.convert(-Double.valueof(sale.h4hPointsSpent), objQuote.currencyISOCode, Date.valueof(objQuote.createdDate)); 
                    if(objRewardQLI.Unitprice != null) {
                        objRewardQLI.Unitprice = objRewardQLI.Unitprice.setscale(2,RoundingMode.CEILING);
                    }
                    objRewardQLI.Record_Type__c = 'A La Carte';
                    objRewardQLI.ProductType__c = 'Reward Discount';
                    objRewardQLI.Description = 'Hotels 4 Hope Points used';
                    lstAllLineItem.add(objRewardQLI);
                }
            } else {
                System.debug('No H4H Points Spent1: PricebookEntry not found');
            }
        } else {
            System.debug('No H4H Points Spent');
        }
        
        // #399 Changes to create Retail Hotel Line Items with Rooming Lists -- START
        List<QuoteLineItem> lstRetailQLIs = new List<QuoteLineItem>();  
        if(sale.retailHotelLineItems != null && sale.retailHotelLineItems.size() > 0) {
            lstRetailQLIs.addAll(createRetailLineItems(sale.retailHotelLineItems, objQuote, null, sale));
            lstAllLineItem.addAll(lstRetailQLIs);
        }
        // #399 Changes to create Retail Hotel Line Items with Rooming Lists -- END
        
        // #476 Changes added for GPE Orders -- START
        Map<String, PricebookEntry> priceMap = new Map<String, PricebookEntry>();
        for(PricebookEntry objPBE: [SELECT Id,Product2Id,Product2.GPT_Article_Id__c,Product2.Type__c,Product2.Name,Pricebook2Id FROM PricebookEntry 
                                    WHERE Product2.Type__c IN ('Shipping and Handling','Protect Group')
                                    AND Pricebook2Id =: sale.eventId AND CurrencyIsoCode =:sale.currencyCharged 
                                    AND Product2.Primary_Price_Book__c =: sale.eventId]) { 
            priceMap.put(objPBE.Pricebook2Id+'#'+objPBE.Product2.Type__c, objPBE); 
        }
        System.debug('priceMap-->'+priceMap);
        if(objQuote.GPE_Online_Order__c){
            if(priceMap != null && priceMap.containskey(sale.eventId+'#Shipping and Handling')){
                QuoteLineItem newQLI = new QuoteLineItem();
                newQLI.QuoteId = objQuote.Id;
                newQLI.Quantity = 1;
                newQLI.UnitPrice = 0;//sale.totalChargedInCurrency * 0.035; // #521 Commented this line to not set the unitprice manually rather the calculation for the same is added to QuoteTriggerHelper
                newQLI.PriceBookEntryId = priceMap.get(sale.eventId+'#Shipping and Handling').Id;
                newQLI.Record_Type__c = 'a La Carte';
                lstAllLineItem.add(newQLI);
            }
        }
        // #451 Protectgroup Integration
        System.debug('sale.protectGroupAmount@@'+sale.protectGroupAmount);
        if((objQuote.Online_Order__c || objQuote.GPE_Online_Order__c) && sale.protectGroupAmount != null){
            if(priceMap != null && priceMap.containskey(sale.eventId+'#Protect Group')){
                QuoteLineItem newQLI = new QuoteLineItem();
                newQLI.QuoteId = objQuote.Id;
                newQLI.Quantity = 1;
                System.debug('sale.protectGroupAmount after@@'+sale.protectGroupAmount);
                newQLI.UnitPrice = sale.protectGroupAmount;
                System.debug('newQLI.UnitPrice@@'+newQLI.UnitPrice);
                newQLI.PriceBookEntryId = priceMap.get(sale.eventId+'#Protect Group').Id;
                newQLI.Record_Type__c = 'a La Carte';
                newQLI.Product2Id = priceMap.get(sale.eventId+'#Protect Group').Product2Id;
                lstAllLineItem.add(newQLI);
            }
        }
        
        System.debug('@@@mapPackageLineItem: '+mapPackageLineItem);
        if(!mapPackageLineItem.isEmpty()){
            lstAllLineItem.addall(mapPackageLineItem.values());
        }
        if(!mapHotelLineItem.isEmpty()){
            lstAllLineItem.addall(mapHotelLineItem.values());
        }
        if(!lstPackageProductLineItem.isEmpty()) {
            lstAllLineItem.addall(lstPackageProductLineItem);
        }
        if(!lstStayLineItem.isEmpty()) {
            lstAllLineItem.addall(lstStayLineItem);
        }
        if(!mapTransLineItem.isEmpty()) {
            lstAllLineItem.addall(mapTransLineItem.values());
        }
        
        if(!lstAllLineItem.isEmpty()) {
            insert lstAllLineItem;
        }
        
        List<QuoteLineItem> updateLineItems = new List<QuoteLineItem>();
        if(!mapHotelLineItem.isEmpty()  && !mapPackageLineItem.isEmpty()) {
            for(QuoteLineItem objItem : mapHotelLineItem.values()) {
                objItem.Quote_Package__c = mapPackageLineItem.get(objItem.Quote_Package__c).Id;
                updateLineItems.add(objItem);
            }
        }
        if(!lstPackageProductLineItem.isEmpty()  && !mapPackageLineItem.isEmpty()) {
            for(QuoteLineItem objItem : lstPackageProductLineItem){
                objItem.Quote_Package__c = mapPackageLineItem.get(objItem.Quote_Package__c).Id;
                updateLineItems.add(objItem);
            }
        }
        if(!lstStayLineItem.isEmpty()) {
            for(QuoteLineItem objItem : lstStayLineItem){
                if(!mapPackageLineItem.isEmpty()){
                    objItem.Quote_Package__c = mapPackageLineItem.get(objItem.Quote_Package__c).Id;
                }
                objItem.Hotel_Package_Id__c = mapHotelLineItem.get(objItem.Hotel_Package_Id__c).Id;
                updateLineItems.add(objItem);
            }
        }
        if(!mapTransLineItem.isEmpty()) {
            for(QuoteLineItem objItem : mapTransLineItem.values()){
                if(!mapPackageLineItem.isEmpty()){
                    objItem.Quote_Package__c = mapPackageLineItem.get(objItem.Quote_Package__c).Id;
                }
                objItem.Hotel_Package_Id__c = mapHotelLineItem.get(objItem.Hotel_Package_Id__c).Id;
                updateLineItems.add(objItem);
            }
        }
        System.debug('@@@updateLineItems: '+updateLineItems);
        if(updateLineItems.size() > 0) {
            TriggerHandler.bypass('QuoteLineItemTriggerHandler');
            TriggerHandler.bypass('QuoteTriggerHandler');
            upsert updateLineItems;
            TriggerHandler.clearBypass('QuoteTriggerHandler');
            TriggerHandler.clearBypass('QuoteLineItemTriggerHandler');
        }
        
        System.debug('@@@@After Upsert');
        List<Rooming_List__c> lstRoomingList = new List<Rooming_List__c>();
        Integer a = 0;
        if(sale.retailHotelLineItems != null && sale.retailHotelLineItems.size() > 0) {
            for(QNG_JSON2Apex.RetailHotelLineItems retail : sale.retailHotelLineItems){
                Rooming_List__c roomList = new Rooming_List__c();
                roomList.Hotel_Id__c = retail.HotelId;
                roomList.H4H_RatePlan_Code__c = 'ARN'+retail.RoomCode;
                roomList.H4H_Room_Code__c = retail.RoomCode;
                roomList.Number_of_Adults__c = 2;
                roomList.Quote__c = objQuote.Id;
                roomList.H4H_Reservation_Id__c = retail.ReservationId;
                roomList.H4H_Itinerary_Id__c = retail.ItineraryId;
                roomList.QuoteLineItem_Id__c = lstRetailQLIs[a].Id;
                roomList.Product__c = retailHotelProduct.Id;
                roomList.Quote__c = lstRetailQLIs[a].QuoteId;
                roomList.Quantity__c = retail.RoomQuantity;
                // #537 Add the Retail Hotels detail to Rooming List -- STRAT 
                roomList.Retail_Check_In_date__c = Date.parse(retail.CheckInDate);
                roomList.Retail_Check_Out_date__c = Date.parse(retail.CheckOutDate);
                roomList.Retail_Hotel_Name__c = retail.HotelName;
                // #537 Add the Retail Hotels detail to Rooming List -- END
                roomList.H4H_Hold_Created__c = true;
                roomList.H4H_Reservation_Created__c = true;
                System.debug('@@roomList=>'+roomList);
                a++;
                lstRoomingList.add(roomList);
            }
        }
        if(lstwrpQLIROOM.size() > 0){
            for(wrpQLIRooming wrpQliRoom : lstwrpQLIROOM){
                wrpQliRoom.roomingList.QuoteLineItem_Id__c  = wrpQliRoom.stayQLI.Id;
                wrpQliRoom.roomingList.Quote_Package__c = wrpQliRoom.stayQLI.Quote_Package__c;
                wrpQliRoom.roomingList.Hotel_Package_Id__c = wrpQliRoom.stayQLI.Hotel_Package_Id__c;
                lstRoomingList.add(wrpQliRoom.roomingList);
            }
        }
        if(lstRoomingList.size() > 0) {
            upsert lstRoomingList;
        }
    }
    
    private static List<QuoteLineItem> createRetailLineItems(List<QNG_JSON2Apex.RetailHotelLineItems> retailItems, Quote objQuote, Map<Id, PricebookEntry> PricebookEntryObjMap, QNG_JSON2Apex.Sale sale) {
        List<QuoteLineItem> lstRetailLineItems = new List<QuoteLineItem>();
        List<Product2> lstRetailProduct = new List<Product2>([Select Id from Product2 where Primary_Price_Book__c = :sale.eventId and IsActive = true and Type__c = 'Retail Hotel']);
        Product2 retailProduct;
        if(lstRetailProduct.size() > 0) {
            retailProduct = lstRetailProduct[0];
        } else {
            retailProduct = new Product2(IsActive = true, Type__c = 'Retail Hotel', A_La_Carte__c = true, Auto_Generated_Product__c = true, Available__c = true, Primary_Price_Book__c = objQuote.Pricebook2Id);
            retailProduct.Name = retailItems[0].HotelName;
            retailProduct.Hotel_Id__c = retailItems[0].HotelId;
            retailProduct.Quantity_Per_Order_Threshold__c = 50;
            retailProduct.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Hotel').getRecordTypeId();
            if(String.isNotBlank(retailItems[0].CheckInDate)) {
                retailProduct.Check_In_Date__c = Date.parse(retailItems[0].CheckInDate);
            }
            if(String.isNotBlank(retailItems[0].CheckOutDate)) {
                retailProduct.Check_Out_Date__c = Date.parse(retailItems[0].CheckOutDate);
            }
            insert retailProduct;
        }
        // #399 Changes to create Retail Hotel Line Items with Rooming Lists -- START
        retailHotelProduct = retailProduct;
        //Id pricebookEntryID = getPricebookEntry(retailProduct.Id, 0, opp).Id;
        
        set<Id> retailProductsId = new set<Id>();
        retailProductsId.add(retailProduct.Id);
        //for(QNG_JSON2Apex.RetailHotelLineItems retail : retailItems) {
            //retailProductsId.add(retail.HotelId);
        //}

        PricebookEntryObjMap = getPricebookEntries(retailProductsId,sale);
        for(QNG_JSON2Apex.RetailHotelLineItems retail : retailItems) {
            system.debug('PricebookEntryObjMap'+PricebookEntryObjMap +'retail'+retailProduct.Id);
            QuoteLineItem qliRetail = new QuoteLineItem();
            qliRetail.PricebookEntryId =  (PricebookEntryObjMap.get(retailProduct.Id) != null) ? PricebookEntryObjMap.get(retailProduct.Id).Id : '';
            qliRetail.QuoteId = objQuote.Id;
            qliRetail.Quantity = retail.RoomQuantity == null ? 0 : retail.RoomQuantity;
            //#695 Retail Hotel for Online Orders
            qliRetail.Unitprice = retail.ReservationTotalPrice == null ? 0 : Utility.convert(retail.ReservationTotalPrice/retail.RoomQuantity,objQuote.currencyISOCode,Date.valueof(objQuote.createdDate)); //decimal.valueof(retail.ReservationTotalPrice/retail.RoomQuantity).setscale(2,RoundingMode.CEILING);
            // #537 Added Record Type field to make the QLI display on the Summary Section in Quote
            qliRetail.Record_Type__c = 'A La Carte';
            // #399 Changes to create Retail Hotel Line Items with Rooming Lists -- END
            //qliRetail.RetailHotel_ItineraryId__c = retail.ItineraryId;
            //qliRetail.RetailHotel_RoomCode__c = retail.RoomCode;
            //qliRetail.RetailHotel_ReservationId__c = retail.ReservationId;
            //qliRetail.RetailHotel_ReservationId__c = retail.ReservationId;
            System.debug('sale.pointsAwarded: '+sale.pointsAwarded);
            //#1160 - RoomCash Change --START
            if(sale.pointsAwarded != null && sale.pointsAwarded != 0) {
                qliRetail.RoomCash_Points__c = 50;
                qliRetail.Earned_Reward_Points__c = 50;
            }
            //#1160 - RoomCash Change --END
            qliRetail.ProductType__c = 'A La Carte';
            lstRetailLineItems.add(qliRetail);
        }
        return lstRetailLineItems;
    }
    private static Map<Id, PricebookEntry> getPricebookEntries(Set<Id> productIds, QNG_JSON2Apex.Sale sale) {
        Map<Id, PricebookEntry> productIdPBEMap = new Map<Id, PricebookEntry>();
        List<PricebookEntry> newPBE = new List<PricebookEntry>();
        // #476 Added UnitPrice field in SOQL since it's being used to populate the price for Package and Stay QLIs 
        for(PricebookEntry pbe : [SELECT Id,Product2Id,Product2.H4H_RatePlan_Code__c,Product2.H4H_Room_Code__c,Product2.Hotel_Id__c,
                                  Product2.RecordType.Name,Product2.Name,Product2.Type__c, UnitPrice
                                  FROM PricebookEntry
                                  WHERE Pricebook2Id =:sale.eventId and CurrencyIsoCode =: sale.currencyCharged and Product2Id in :productIds]){
                                      productIdPBEMap.put(pbe.Product2Id, pbe);
                                  }
        System.debug('productIds----'+productIds);
        //System.debug('pricebook-->>'+pricebook);
        System.debug('sale event:@@'+sale.eventId);
        for(Id id1 : productIds){
            System.debug('id1:'+id1);
            if(productIdPBEMap.get(id1) == null && id1 != null){
                PricebookEntry entry = new PricebookEntry(
                    UnitPrice = 0,//product2PriceMap.get(id1),
                    CurrencyIsoCode = sale.currencyCharged, //VKHOPADE - issue 1241
                    Product2Id = id1,
                    Pricebook2Id = Test.isrunningtest() ? Test.getStandardPricebookId() :sale.eventId,//pricebook.Id,
                    IsActive = true,
                    UseStandardPrice = false);
                newPBE.add(entry);
            }
        }
        if (newPBE.size() > 0) {
            insert newPBE;
            for(PricebookEntry pbe : [SELECT Id,Product2Id,Product2.H4H_RatePlan_Code__c,Product2.H4H_Room_Code__c,Product2.Hotel_Id__c,
                                      Product2.RecordType.Name,Product2.Name,Product2.Type__c,UnitPrice
                                      FROM PricebookEntry
                                      WHERE Id In :newPBE]){
                                          productIdPBEMap.put(pbe.Product2Id, pbe);
                                      }
        }
        
        return productIdPBEMap;
    }
    public static decimal calculateUnitPriceforGPEItems(Decimal exchangeRate,Decimal packagePrice, Integer Quantity){
        Decimal finalunitPrice = 0.0;
        Decimal packagePricewithQuantity;
        Decimal TotalUnitPrice;
        packagePricewithQuantity = packagePrice * Quantity;
        TotalUnitPrice = (packagePricewithQuantity * exchangeRate).setscale(2,RoundingMode.CEILING);
        finalunitPrice = (TotalUnitPrice/Quantity).setscale(3);
        return finalunitPrice;
    }
}