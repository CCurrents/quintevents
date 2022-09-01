/**
* @description       : 
* @author            : ratiksinghal@addonblue.com
* @group             : 
* @last modified on  : 02-28-2022
* @last modified by  : fsuraitawala@addonblue.com
**/
Public class IntacctSalesInvoiceController {
    Public String currentRecordId {get;set;}
    Public Payment_Term__c inv{get;set;}
    Public String dueDate{get;set;}
    Public String invDate{get;set;}
    Public Decimal paymentDue{get;set;}
    Public Decimal Commission{get;set;}
    Public String currencySymbol{get;set;}
    Public String invoiceNumber{get;set;}
    Public String OrderPackages{get;set;}
    String myId = ApexPages.currentPage().getParameters().get('Id');
    
    Public IntacctSalesInvoiceController(ApexPages.StandardController controller) {
        System.debug('payment Id ***'+ myId);
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
        inv = [SELECT Id, Status__c, Order__c, Quote__r.Company_Name__c, Quote__r.BillingName, Order__r.Is_Business_Account__c, 
               Order__r.BillingStreet, Order__r.BillingState, Order__r.BillingPostalCode, Order__r.BillingCountry, Customer_Email__c, 
               Order__r.PO_Number__c, Order__r.OrderNumber, Opportunity_Currency__c, Opportunity__r.Order_s_Packages__c, Order__r.EffectiveDate, 
               Pricebook_Name__c, Converted_Amount__c, Payment_Due_Date__c, Commission__c, Balance_Due__c, Intacct_Id__c, Order__r.BillingCity, 
               Order__r.International_Stripe__c, Amount__c, Order__r.Account.RecordType.Name
               FROM Payment_Term__c 
               WHERE Id = :myId LIMIT 1];
        if(null != inv.Order__r) {
            invDate = inv.Order__r.EffectiveDate.format();
        }
        dueDate = inv.Payment_Due_Date__c.format();
        if(inv.Intacct_Id__c != null) {
            invoiceNumber = inv.Intacct_Id__c.contains('Sales Invoice-') ? inv.Intacct_Id__c.remove('Sales Invoice-') : inv.Intacct_Id__c;
        }
        OrderPackages =  inv.Opportunity__r.Order_s_Packages__c != null ? inv.Opportunity__r.Order_s_Packages__c.replace('\r\n', '<br/>') : '--';
        getCurrencySymbol(inv.Opportunity_Currency__c);
    }
    
    Public void getCurrencySymbol(String currencyString) {
        if(currencyString == 'EUR') {
            currencySymbol = '€';
        } else if(currencyString == 'GBP') {
            currencySymbol = '£';
        } else {
            currencySymbol = '$';
        }
    }
}