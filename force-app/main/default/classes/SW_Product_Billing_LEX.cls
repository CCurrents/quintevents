/**
 * @File Name          : SW_Product_Billing_LEX.cls
 * @Description        : 
 * @Author             : jthakkar@addonblue.com
 * @Group              : 
 * @Last Modified By   : fsuraitawala@addonblue.com
 * @Last Modified On   : 04-15-2022
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    27/1/2020   jthakkar@addonblue.com     Initial Version
**/ 
 
/*********************************************************************************/
public class SW_Product_Billing_LEX {
    
    /**
    * @description  : Opportunity Payment Term record generates
    * @author       : jthakkar@addonblue.com | 28/2/2020 
    * @param        : quoteId(Quote Id), oppPaymentTermList(List of Id of Opportunity Payment Term)
    * @return       : List of Id of Opportunity Payment Term
    **/
    @AuraEnabled 
    public static List<Payment_Term__c> saveOpportunityPaymentTerm(String quoteId, String jsonPTList, String paymentTerm, Boolean paymentTermChanged, String paymentMethod) {
        
        List<Payment_Term__c> oppPaymentTermList = (List<Payment_Term__c>)JSON.deserialize(jsonPTList,List<Payment_Term__c>.class);

        List<Payment_Term__c> lstOppPaymentTerms = new List<Payment_Term__c>();
        Payment_Term__c objPaymentTerm;
        
        system.debug('###saveOpportunityPaymentTerm=='+quoteId+'###'+oppPaymentTermList+'###paymentTerm=='+paymentTerm+'###paymentMethod=='+paymentMethod+'###paymentTermChanged=='+paymentTermChanged);
        
        Quote objQuote = [select id, OpportunityId, CurrencyISOCode, Payment_Method__c, AccountId, Original_Quote__c, Selected_Payment_Term__c FROM Quote WHERE Id =: quoteId];
        
        /* Delete Existing Records of Opportunity Payment Term related to this Quote */
        List<Payment_Term__c> lstOfOppPaymentTerms;
        if(quoteId != null && String.isempty(objQuote.Original_Quote__c)){
            lstOfOppPaymentTerms = [select Id, Percentage_Of_Payment__c, Payment_Due_Date__c, Amount__c, Quote__c, CurrencyISOCode FROM Payment_Term__c where Quote__c =: quoteId AND Status__c != 'Passed'];
            if(lstOfOppPaymentTerms.size() > 0){
                delete lstOfOppPaymentTerms;
            }
            String creditRecordType = Schema.SObjectType.Payment_Term__c.getRecordTypeInfosByName().get('Credit').getRecordTypeId();
            lstOfOppPaymentTerms = [select Id, Percentage_Of_Payment__c, Payment_Due_Date__c, Amount__c, Quote__c, CurrencyISOCode FROM Payment_Term__c where Quote__c =: quoteId AND RecordTypeId =: creditRecordType];
            
            Set<Id> setOfCreditPaymentTerm = new Set<Id>();
            if(lstOfOppPaymentTerms.size() > 0){
                for(Payment_Term__c obj : lstOfOppPaymentTerms){
                    setOfCreditPaymentTerm.add(obj.Id);
                }
            }
            
            String accountCredit = Schema.SObjectType.Charge__c.getRecordTypeInfosByName().get('Account Credit').getRecordTypeId();
            List<Charge__c> lstChargesTobeDeleted = [select Id FROM Charge__c WHERE Payment_Terms__c IN: setOfCreditPaymentTerm AND RecordTypeId =: accountCredit AND Credit_Used__c =: True];
            
            if(lstOfOppPaymentTerms.size() > 0){
                delete lstOfOppPaymentTerms;
            }            
            if(lstChargesTobeDeleted.size() > 0){
                delete lstChargesTobeDeleted;
            }
        }
        
        if(quoteId != null && !String.isempty(objQuote.Original_Quote__c)){
            String creditRecordType = Schema.SObjectType.Payment_Term__c.getRecordTypeInfosByName().get('Credit').getRecordTypeId();
            lstOfOppPaymentTerms = [select Id, Percentage_Of_Payment__c, Payment_Due_Date__c, Amount__c, Quote__c, CurrencyISOCode FROM Payment_Term__c where Quote__c =: quoteId AND RecordTypeId =: creditRecordType];
            Set<Id> setOfCreditPaymentTerm = new Set<Id>();
            if(lstOfOppPaymentTerms.size() > 0){
                for(Payment_Term__c obj : lstOfOppPaymentTerms){
                    setOfCreditPaymentTerm.add(obj.Id);
                }
            }
            String accountCredit = Schema.SObjectType.Charge__c.getRecordTypeInfosByName().get('Account Credit').getRecordTypeId();
            List<Charge__c> lstChargesTobeDeleted = [select Id FROM Charge__c WHERE Payment_Terms__c IN: setOfCreditPaymentTerm AND RecordTypeId =: accountCredit AND Credit_Used__c =: True];
            if(lstChargesTobeDeleted.size() > 0){
                delete lstChargesTobeDeleted;
            }
            
            if(paymentTermChanged == true){
                Set<Id> setOfExistingUnpaidTerms = new Set<Id>();
                for(Payment_Term__c obj : oppPaymentTermList){
                    if(obj.Status__c != 'Passed'){
                        setOfExistingUnpaidTerms.add(obj.Id);
                    }
                }

                lstOfOppPaymentTerms = [select Id, Percentage_Of_Payment__c, Payment_Due_Date__c, Amount__c, Quote__c, CurrencyISOCode FROM Payment_Term__c where Quote__c =: quoteId AND Status__c != 'Passed' AND Id NOT IN : setOfExistingUnpaidTerms];
                if(lstOfOppPaymentTerms.size() > 0){
                    delete lstOfOppPaymentTerms;
                }
            }
        }
                
        /* End of delete Existing Records of Opportunity Payment Term related to this Quote */        
                
               
        Quote quote = new Quote();
        if(oppPaymentTermList.size() > 0){
            for(Payment_Term__c obj : oppPaymentTermList){
                objPaymentTerm = new Payment_Term__c();
                if(!String.isEmpty(obj.Id)){
                    objPaymentTerm.Id = obj.Id;
                }
                objPaymentTerm.Percentage_Of_Payment__c = obj.Percentage_Of_Payment__c;
                objPaymentTerm.Payment_Due_Date__c = obj.Payment_Due_Date__c;
                objPaymentTerm.Amount__c = obj.Amount__c;
                objPaymentTerm.Quote__c = quoteId;
                objPaymentTerm.Status__c = obj.Status__c;
                objPaymentTerm.Credit__c = obj.Credit__c;
                objPaymentTerm.Initial_Payment_Term__c = obj.Initial_Payment_Term__c;
                if(objPaymentTerm.Credit__c == true){
                    objPaymentTerm.RecordTypeId = Schema.SObjectType.Payment_Term__c.getRecordTypeInfosByName().get('Credit').getRecordTypeId();
                }
                
                if(!Test.isRunningTest()){
                    objPaymentTerm.CurrencyISOCode = objQuote.CurrencyISOCode;
                }else{
                    objPaymentTerm.CurrencyISOCode = 'USD';
                }
                if(objQuote.OpportunityId != null){
                    objPaymentTerm.Opportunity__c = objQuote.OpportunityId;
                }
                lstOppPaymentTerms.add(objPaymentTerm);
                
                quote.Id = quoteId;
                if(obj.Percentage_Of_Payment__c == 50){
                    quote.X1_2__c = true;
                    quote.X1_3__c = false;
                    quote.X100__c = false;                                        
                }else if(obj.Percentage_Of_Payment__c == 33.33 || obj.Percentage_Of_Payment__c == 33.34){
                    quote.X1_2__c = false;
                    quote.X1_3__c = true;
                    quote.X100__c = false;                    
                }else if(obj.Percentage_Of_Payment__c == 100){
                    quote.X1_2__c = false;
                    quote.X1_3__c = false;
                    quote.X100__c = true;
                }
                
                if(!String.isEmpty(paymentTerm)){
                    quote.Selected_Payment_Term__c = paymentTerm;
                }
                
                if(!String.isEmpty(paymentMethod)){
                    quote.Payment_Method__c = paymentMethod;
                }
            }
        }
        system.debug('###lstOppPaymentTerms=='+lstOppPaymentTerms);
        if(lstOppPaymentTerms.size() > 0){            
            //Utility.processRecords(lstOppPaymentTerms, 'insert');
            Utility.processRecords(lstOppPaymentTerms, 'upsert');
        }
                
        system.debug('###quote=='+quote);
        if(quote != null){        
            //update quote;
            List<Quote> lstQuotes = new List<Quote>();
            lstQuotes.add(quote);
            system.debug('###lstQuotes=='+lstQuotes);
            Utility.processRecords(lstQuotes, 'update');
        }
                
        if(lstOppPaymentTerms.size() > 0 && quote != null){
            Payment_Term__c creditPaymentTerm = new Payment_Term__c();
            
            for(Payment_Term__c obj : lstOppPaymentTerms){
                if(obj.Credit__c == true){
                    creditPaymentTerm = obj;
                }
            }
                            
            if(creditPaymentTerm != null){
                Charge__c objCharge = new Charge__c();
                objCharge.CurrencyISOCode = quote.CurrencyISOCode;
                objCharge.Payment_Terms__c = creditPaymentTerm.Id;
                objCharge.RecordTypeId = Schema.SObjectType.Charge__c.getRecordTypeInfosByName().get('Account Credit').getRecordTypeId();
                objCharge.Amount__c = creditPaymentTerm.Amount__c;
                objCharge.Account__c = objQuote.AccountId;
                objCharge.Credit_Used__c = true;
                //#591 Set the Status of Charge to Passed
                objCharge.Status__c  = 'Passed';
                system.debug('###objCharge=='+objCharge);
                if(objCharge != null){
                    Utility.processRecords(objCharge, 'insert');
                }
            }
            
        }      
                       
        return lstOppPaymentTerms;
    }
    
    /**
    * @description  : Save Payment Method on Quote
    * @author       : jthakkar@addonblue.com | 28/2/2020 
    * @param        : quoteId (Id of Quotes)
    * @return       : status
    **/
    @AuraEnabled
    public static String savePaymentMethodQuote(String quoteId, String paymentMethod){
        system.debug('###paymentMethod=='+paymentMethod);
        String status;
        if(quoteId != null && !String.isEmpty(paymentMethod)){
            Quote quote = [select Id, Payment_Method__c FROM Quote WHERE Id =: quoteId];
            if(quote != null){
                quote.Payment_Method__c = paymentMethod;
                update quote;
                status = 'SUCCESS';
            }
        }
        return status;
    }
    
    /**
    * @description  : fetching Quote Subtotal
    * @author       : jthakkar@addonblue.com | 28/2/2020 
    * @param        : quoteId (Id of Quotes)
    * @return       : Quote 
    **/
    @AuraEnabled
    public static Quote fetchQuoteSubtotal(String quoteId){
        Quote quote = new Quote();
        if(quoteId != null){
            quote = [SELECT Id, Status, Subtotal, GrandTotal, CurrencyIsoCode, Selected_Payment_Term__c, Original_Quote__r.Selected_Payment_Term__c, 
                     Pricebook2Id, Pricebook2.GPE_Event__c, Payment_Method__c, Original_Quote__c, Opportunity.RecordTypeId, Opportunity.RecordType.Name,
                     (Select Id, Product2.X100_Payment_Term_Required__c, Product2.Name, Product2.Type__c FROM QuoteLineItems 
                      WHERE Product2.X100_Payment_Term_Required__c = true OR (Product2.Name LIKE '%Deposit%' AND Product2.Type__c = 'Deposit')) 
                     FROM Quote WHERE Id =: quoteId];
        }
        return quote;
    }
    
    /**
    * @description  : fetching event payment term
    * @author       : jthakkar@addonblue.com | 28/2/2020 
    * @param        : quoteId (Id of Quotes)
    * @return       : List of Payment Terms
    **/
    @AuraEnabled
    public static List<String> fetchEventPaymentTerms(String quoteId){
        Quote quote;
        List<Event_Payment_Terms__c> lstOfEventPaymentTerms;
        List<Pricebook2> lstPriceBook = new List<Pricebook2>();
        List<String> lstEventPaymentTerms = new List<String>();
        
        if(quoteId != null){
            quote = [select id, Subtotal, Pricebook2Id from quote where id =: quoteId];
            system.debug('###quote=='+quote);
            //lstOfEventPaymentTerms = [select Id, Payment_Term__c, Price_Book__c from Event_Payment_Terms__c WHERE Price_Book__c =: quote.Pricebook2Id];
            lstPriceBook = [select Id, X1_2__c, X1_3__c, X100__c from Pricebook2 WHERE Id =: quote.Pricebook2Id];
            system.debug('###lstPriceBook=='+lstPriceBook);
            if(lstPriceBook.size() > 0){
                for(Pricebook2 obj : lstPriceBook){
                    if(obj.X1_2__c == true){
                        lstEventPaymentTerms.add('1/2');
                    }
                    if(obj.X1_3__c == true){
                        lstEventPaymentTerms.add('1/3');
                    }
                    if(obj.X100__c == true){
                        lstEventPaymentTerms.add('100%');
                    }
                }
            }            
        }
        system.debug('###lstEventPaymentTerms=='+lstEventPaymentTerms);
        return lstEventPaymentTerms;
    }
    
    /**
    * @description  : fetch event payment term records
    * @author       : jthakkar@addonblue.com | 28/2/2020 
    * @param        : quoteId (Id of Quotes)
    * @return       : List of event Payment Terms
    **/    
    @AuraEnabled
    public static List<Event_Payment_Terms__c> fetchEventPaymentTermRecords(String quoteId){
        Quote quote;
        List<Event_Payment_Terms__c> lstOfEventPaymentTerms;
        List<String> lstEventPaymentTerms = new List<String>();
        if(quoteId != null){
            quote = [select id, Subtotal, Pricebook2Id from quote where id =: quoteId];
            system.debug('###quote=='+quote);
            lstOfEventPaymentTerms = [select Id, End_Date__c, Payment_Term__c, Payment_Due_Date__c, Price_Book__c from Event_Payment_Terms__c WHERE Price_Book__c =: quote.Pricebook2Id];
            system.debug('###lstOfEventPaymentTerms=='+lstOfEventPaymentTerms);            
        }
        system.debug('###lstOfEventPaymentTerms=='+lstOfEventPaymentTerms);
        return lstOfEventPaymentTerms;
    }
    
    /**
    * @description  : fetch opp payment term records
    * @author       : jthakkar@addonblue.com | 28/2/2020 
    * @param        : quoteId (Id of Quotes)
    * @return       : List of opp Payment Terms
    **/
    @AuraEnabled
    public static List<Payment_Term__c> fetchOppPaymentTermRecords(String quoteId){
        Quote quote;
        List<Payment_Term__c> lstOfOppPaymentTerms;
        if(quoteId != null){
            //#651 Change Order Credit issue
            lstOfOppPaymentTerms = [Select Id, Name, Percentage_Of_Payment__c, Payment_Due_Date__c, Amount__c, Status__c, Quote__c, CurrencyISOCode, Initial_Payment_Term__c,
                                    Credit__c, Sandbox_Intacct_Failure_Reason__c, RecordType.Name, RecordTypeId, Original_Payment_Term__c, Quote__r.Selected_Payment_Term__c,
                                    Original_Payment_Term__r.Amount__c FROM Payment_Term__c 
                                    WHERE Quote__c =: quoteId]; //#520 Recordtypeid added in SOQL
            system.debug('###lstOfOppPaymentTerms=='+lstOfOppPaymentTerms);
        }
        return lstOfOppPaymentTerms;
    }
    
    /**
    * @description  : total of opp payment term records
    * @author       : jthakkar@addonblue.com | 28/2/2020 
    * @param        : quoteId (Id of Quotes)
    * @return       : List of opp Payment Terms
    **/
    @AuraEnabled
    public static Double fetchTotalOfOppPaymentTermRecords(String quoteId){
        Double sumOfOppPaymentTerms = 0;
        List<Payment_Term__c> lstOfOppPaymentTerms;
        if(quoteId != null){
            lstOfOppPaymentTerms = [select id, Percentage_Of_Payment__c, Payment_Due_Date__c, Amount__c, Status__c, Quote__c, RecordType.Name, RecordTypeId FROM Payment_Term__c where Quote__c =: quoteId]; //#520 Recordtypeid added in SOQL
            system.debug('###lstOfOppPaymentTerms=='+lstOfOppPaymentTerms);
            for(Payment_Term__c obj : lstOfOppPaymentTerms){
                sumOfOppPaymentTerms = sumOfOppPaymentTerms + obj.Amount__c;
            }
        }
        return sumOfOppPaymentTerms;
    }
    
    /**
    * @description  : fetch payment term records for duplicate quote
    * @author       : jthakkar@addonblue.com | 28/2/2020 
    * @param        : quoteId (Id of Quotes)
    * @return       : List of opp Payment Terms
    **/
    @AuraEnabled
    public static Double fetchAmountForDupQuote(String quoteId){        
        List<Payment_Term__c> lstOfPassedPaymentTerms;
        Double paymentTermsTotal = 0.0;
        if(quoteId != null){
            Quote quote = [select id, Grandtotal FROM Quote WHERE Id =: quoteId];
            lstOfPassedPaymentTerms = [select id, Percentage_Of_Payment__c, Payment_Due_Date__c, Amount__c, Quote__c, RecordType.Name, RecordTypeId FROM Payment_Term__c where Quote__c =: quoteId AND Status__c = 'Passed']; //#520 Recordtypeid added in SOQL
            system.debug('###lstOfPassedPaymentTerms=='+lstOfPassedPaymentTerms);
            system.debug('###Quote Grand Total=='+quote.Grandtotal);
            
            for(Payment_Term__c obj : lstOfPassedPaymentTerms){
                paymentTermsTotal = paymentTermsTotal + obj.Amount__c;
            }
            paymentTermsTotal = quote.Grandtotal - paymentTermsTotal;
            system.debug('###paymentTermsTotal=='+paymentTermsTotal);
        }
        return paymentTermsTotal;
    }
    
    /**
    * @description  : fetch payment status for duplicate quote
    * @author       : jthakkar@addonblue.com | 28/2/2020 
    * @param        : quoteId (Id of Quotes)
    * @return       : payment status
    **/
    @AuraEnabled
    public static String fetchPaymentStatusForDupQuote(String quoteId){        
        List<Payment_Term__c> lstOfPassedPaymentTerms;
        String paymentStatus;
        Integer countForPassed = 0;        
        if(quoteId != null){
            lstOfPassedPaymentTerms = [select id, Percentage_Of_Payment__c, Payment_Due_Date__c, Amount__c, Status__c, Quote__c, RecordType.Name FROM Payment_Term__c where Quote__c =: quoteId];
            system.debug('###lstOfPassedPaymentTerms=='+lstOfPassedPaymentTerms);

            for(Payment_Term__c obj : lstOfPassedPaymentTerms){
                if(obj.Status__c == 'Passed'){
                    countForPassed = countForPassed + 1;
                }
            }
            system.debug('###countForPassed=='+countForPassed);
            if(countForPassed == 0){
                paymentStatus = 'Unpaid';
            }else if(countForPassed == lstOfPassedPaymentTerms.size()){
                paymentStatus = 'Paid';
            }else{
                paymentStatus = 'Partially Paid';
            }
        }
        system.debug('###paymentStatus=='+paymentStatus);
        return paymentStatus;
    }
    
    /**
    * @description  : fetch event payment term highest date
    * @author       : jthakkar@addonblue.com | 28/2/2020 
    * @param        : quoteId (Id of Quotes)
    * @return       : Date
    **/    
    @AuraEnabled
    public static Date fetchEventPaymentTermHighestDate(String quoteId){
        Quote quote;
        List<Event_Payment_Terms__c> lstOfEventPaymentTerms;
        List<String> lstEventPaymentTerms = new List<String>();
        Date maxDate = Date.Today();
        if(quoteId != null){
            quote = [select id, Subtotal, Pricebook2Id from quote where id =: quoteId];
            system.debug('###quote=='+quote);
            if(!Test.isRunningTest()){
                Pricebook2 Pricebook = [select Id, LastPaymentDueDate__c FROM Pricebook2 WHERE Id =: quote.Pricebook2Id];
                if(Pricebook.LastPaymentDueDate__c != null){
                    maxDate = Date.valueof(Pricebook.LastPaymentDueDate__c);
                }
            }
            /* Commented by Jimmy Thakkar as requested in #248 */
            /*
            lstOfEventPaymentTerms = [select Id, End_Date__c, Payment_Term__c, Payment_Due_Date__c, Price_Book__c from Event_Payment_Terms__c WHERE Price_Book__c =: quote.Pricebook2Id];
            system.debug('###lstOfEventPaymentTerms=='+lstOfEventPaymentTerms);            
            for(Event_Payment_Terms__c obj : lstOfEventPaymentTerms){
                if(obj.End_Date__c > maxDate){
                    maxDate = obj.End_Date__c;
                }
            }*/
            
        }
        system.debug('###maxDate=='+maxDate);
        return maxDate;
    }
    
    /**
    * @description  : Total Credit From Account
    * @author       : jthakkar@addonblue.com | 28/2/2020 
    * @param        : quoteId (Id of Quotes)
    * @return       : Date
    **/
    @AuraEnabled
    public static Quote getTotalCreditFromAccount(string recordId) {
        //#689 Credit change - Updates SOQL
        Quote objQuote = new Quote();
        if(recordId != null) {
            objQuote = [Select Id, CurrencyIsoCode, GrandTotal, Selected_Payment_Term__c, PriceBook2Id, PriceBook2.Credit_Applicable_Cut_Off_Date__c,
                        Account.USD_Total_Credit_Available__c, Account.CAD_Total_Credit_Available__c, Account.EUR_Total_Credit_Available__c,
                        Account.GBP_Total_Credit_Available__c, Account.AUD_Total_Credit_Available__c, Account.SAR_Total_Credit_Available__c, Account.THB_Total_Credit_Available__c
                        FROM Quote where id = :recordId];
        }
        
        return objQuote;
    }
     /**
    * @description  : #886 fetching payment term record Type Id
    * @author       : fsuraitawala@addonblue.com | 03/30/2021 
    * @param        : 
    * @return       : String
    **/
    @AuraEnabled
    public static String fetchRecordTypeId(){
        RecordType objRT = [Select Id, SobjectType, Name FROM RecordType WHERE SobjectType = 'Payment_Term__c' and Name = 'Credit'];
        return objRT.Id;
    }
}