/**
 * @File Name          : QuoteUtility.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 6/3/2020, 10:09:42 PM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    3/15/2020   jagrawal@addonblue.com     Initial Version
**/
public with sharing class QuoteUtility {

    /**
    * @description 
    * @author jagrawal@addonblue.com | 3/15/2020 
    * @param newQuoteList 
    * @return void 
    **/
    public static void quoteApprovalHandling(List<Quote> newQuoteList){
        Set<String> quoteId_Set = new set<String>();
        for (Quote currentQuote : newQuoteList) {
            quoteId_Set.add(currentQuote.Id);
        }
        Id userId=userInfo.getUserId();
        System.debug('userId==>'+userId);
        for (Quote currentQuote : newQuoteList) {
            if ( currentQuote.Status == 'Draft - Needs Review' ) {
                // create the new approval request to submit
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Submitted for approval. Please approve.');
                req.setObjectId(currentQuote.Id);
                // submit the approval request for processing
                if(!Approval.isLocked(currentQuote.Id)){
                    try{
                        Approval.ProcessResult result = Approval.process(req);
                        // display if the reqeust was successful
                        System.debug('Submitted for approval successfully: '+result.isSuccess());
                    }catch(Exception e){
                        currentQuote.addError('Approval Process ALREADY_IN_PROCESS, This Quote is currently in an approval process. A record can be in only one approval process at a time ');
                    }
                }
            }                             
        }
    }
    
    /**
    * @description 
    * @author jagrawal@addonblue.com | 3/15/2020 
    * @param newQuoteList 
    * @return void 
    **/
    public static void quoteSignedApprovalHandling(List<Quote> newQuoteList, Map<Id, Quote> oldQuoteMap){
        Set<String> quoteId_Set = new set<String>();
        for (Quote currentQuote : newQuoteList) {
            quoteId_Set.add(currentQuote.Id);
        }
        Id userId=userInfo.getUserId();
        System.debug('quoteSignedApprovalHandling==>'+userId);
        for (Quote currentQuote : newQuoteList) {            
            if ( currentQuote.Status == 'Signed - Needs Review' && oldQuoteMap.get(currentQuote.Id).status != 'Signed - Needs Review') {
                // create the new approval request to submit
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Submitted for approval. Please approve.');
                req.setObjectId(currentQuote.Id);
                req.setProcessDefinitionNameOrId('Signed_Quote_With_H4H');
                // submit the approval request for processing
                if(!Approval.isLocked(currentQuote.Id)){
                    try{
                        Approval.ProcessResult result = Approval.process(req);
                        // display if the reqeust was successful
                        System.debug('Submitted for approval successfully: '+result.isSuccess());
                    }catch(Exception e){
                        currentQuote.addError('Approval Process ALREADY_IN_PROCESS, This Quote is currently in an approval process. A record can be in only one approval process at a time ');
                    }
                }
            }                  
        }
    }
    

    /**
    * @description : DocuSign quote Status Update
    * @author jagrawal@addonblue.com | 3/3/2020 
    * @param List<Id> quoteIds 
    * @param string calledBy 
    * @return void 
    **/
    public static void updateQuoteStatusDocuSign(List<Id> quoteIds, string calledBy) {
        String salesforceBaseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        // Query quote data and related quote line items
        List<Quote> quotes = new List<Quote>([
            Select Id, Opportunity.Pricebook2.isActive, Opportunity.Payment_Terms__c, Opportunity.Comment__c, GrandTotal,
            Opportunity.Pricebook2.Name, Draft_Reasons_For_Review_Operations__c, Draft_Reasons_For_Review_Sales__c, Opportunity.Pricebook2Id,
            (Select Id, Product2Id, Product2.IsActive, Product2.Current_Inventory__c, Product2.Allocated__c, Product2.Requires_Double_Approval__c, 
            Product2.Threshold__c, Product2.Available__c, Product2.Quantity_Per_Order_Threshold__c, Quantity, Product2.Name, Product2.Id,
            Product2.Requires_Approval_Upon_Signature__c,Product2.H4H_Approval_Required__c, Product2.RecordType.Name From QuoteLineItems)
            From Quote Where Id In :quoteIds
        ]);
        // For each quote and line item check approval criteria.
        List<Quote> signedQuotesWithCriteriaChecked = new List<Quote>();
        for(Quote quote : Quotes) {
            // Quote/Oppt related criteria.
            String signedReasonsForReviewOperations = '';
            String signedReasonsForReviewSales = '';
            String signedReasonsForReviewH4H = '';
            //Commented on 03-31-2020 by Jimmy, as instructed by Pratik
            /*
            if(!String.isBlank(quote.Opportunity.Comment__c) && (quote.Opportunity.Pricebook2.Name == 'Super Bowl 2019 - Hall of Fame Experiences' || quote.Opportunity.Pricebook2.Name == 'Super Bowl 2019')) {
                signedReasonsForReviewOperations += '- Has Comments: ' + quote.Opportunity.Comment__c + '<br> And Quote contains Product from ' + quote.Opportunity.Pricebook2.Name + '<br>';
            }*/
            // Quote Line Item related criteria
            for(QuoteLineItem qli : quote.QuoteLineItems) {
                // Product's inventory forecast, ignoring this for RecordType "Package"
                Decimal productInventoryForcast = 0;
                if(qli.Quantity != null && qli.Product2.Current_Inventory__c != null && qli.Product2.RecordType.Name != 'Package' && qli.Product2.RecordType.Name != 'Hotel') {
                    productInventoryForcast = qli.Product2.Current_Inventory__c - qli.Quantity;
                }
                System.debug('productdetail'+qli.Product2.IsActive+'--'+qli.Product2.Requires_Approval_Upon_Signature__c+'--'+qli.Product2.Requires_Double_Approval__c);
                // Product is not Active
                if(!qli.Product2.IsActive) {signedReasonsForReviewOperations += '- Inactive Product/Package: '+'<a href="'+salesforceBaseUrl+'/'+qli.Product2.Id+'">'+qli.Product2.Name+'</a>'+'<br>';  }
                // Product requires approval upon signing
                if(qli.Product2.Requires_Approval_Upon_Signature__c) {signedReasonsForReviewOperations += '- Product Requires Approval Upon Signature: '+'<a href="'+salesforceBaseUrl+'/'+qli.Product2.Id+'">'+qli.Product2.Name+'</a>'+'<br>'; }
                // Product requires double approval.
                if(qli.Product2.Requires_Double_Approval__c) {signedReasonsForReviewOperations += '- Product Requires Double Approval: '+'<a href="'+salesforceBaseUrl+'/'+qli.Product2.Id+'">'+qli.Product2.Name+'</a>'+'<br>'; }
                // Product is Not "Available" and Product's inventory forcast goes below zero.
                if(!qli.Product2.Available__c && productInventoryForcast < 0 && qli.Product2.RecordType.Name != 'Package' && qli.Product2.RecordType.Name != 'Hotel') {signedReasonsForReviewOperations += '- Limited inventory is available: '+'<a href="'+salesforceBaseUrl+'/'+qli.Product2.Id+'">'+qli.Product2.Name+'</a>'+'<br>'; }
                // Product is Not "Available" and Product's inventory forcast goes below product's threshold.
                if(!qli.Product2.Available__c && productInventoryForcast < qli.Product2.Threshold__c && qli.Product2.RecordType.Name != 'Package' && qli.Product2.RecordType.Name != 'Hotel') {
                    signedReasonsForReviewOperations += '- Threshold limit reached: '+'<a href="'+salesforceBaseUrl+'/'+qli.Product2.Id+'">'+qli.Product2.Name+'</a>'+'<br>';
                }
                //added for h4h approval process.
                if(qli.Product2.H4H_Approval_Required__c) {
                    signedReasonsForReviewH4H += 'Required H4H Approval.' + '<a href="'+salesforceBaseUrl+'/'+qli.Product2.Id+'">'+qli.Product2.Name+'</a>'+'<br>';
                }
            }
            // Check if Quote needs reveiw/approval
            if(signedReasonsForReviewH4H != '' || signedReasonsForReviewOperations != '' || signedReasonsForReviewSales != '') {
                quote.Signed_Reasons_For_Review_Operations__c = signedReasonsForReviewOperations;
                quote.Signed_Reasons_For_Review_Sales__c = signedReasonsForReviewSales;
                quote.Signed_Reasons_For_Review_H4H__c = signedReasonsForReviewH4H;
                quote.Status = 'Signed - Needs Review';
            } else {
                quote.Status = 'Signed - Approved';
				quote.Timestamp__c = String.valueOf(Datetime.Now());
            }
            signedQuotesWithCriteriaChecked.add(quote);
        }
        // Update quotes whoes criteria has been checked
        system.debug('###'+signedQuotesWithCriteriaChecked);
        if(signedQuotesWithCriteriaChecked.size() > 0) {
            Utility.processRecords(signedQuotesWithCriteriaChecked, 'update');
        }
    }

}