/**
* @File Name          : QuoteSubmitForApprovalBtnClass.cls
* @Description        : 
* @Author             : jagrawal@addonblue.com
* @Group              : 
* @Last Modified By   : fsuraitawala@addonblue.com
* @Last Modified On   : 04-28-2021
* @Modification Log   : 
* Ver       Date            Author              Modification
* 1.0    3/16/2020   jthakkar@addonblue.com     Initial Version
* 1.1    7/22/2020   jagrawal@addonblue.com     Condition Added for Net 30 Payment Terms to check for the Event/Pricebook Start Date within 60 Days
* 1.2    12/03/2020   kchavda@addonblue.com     #636 Changes Order needs to go through Operations Approval
* 1.3    02/19/2021   cshah@addonblue.com       #721 Remove quote approval reason/condition "Quote Grand Total is 0 or Less".
* 1.4    02/19/2021   cshah@addonblue.com       #712 Require Discount related approval only if discount amount is grater than 5% of quote total.
* 1.5    03/02/2021   vshah@addonblue.com       #761 Change order quote needs to go thorough Draft Approval process if QLI is removed or QLI quantity is reduced.
**/
public class QuoteSubmitForApprovalBtnClass {

    public Id quoteId;        

    
    @AuraEnabled
    public static String updateQuoteStatusLightning(String recordId) {
        String response;
        try{
            List<Id> quoteIds = new List<Id>();            
            quoteIds.add(recordId);
            system.debug('###quoteIds=='+quoteIds);
            Quote quote = [select id, Status from Quote where Id =: recordId];
            Attachment attach;
            if(!Test.isRunningTest()){
                attach = [select id, parentId from Attachment WHERE parentId =: recordId];                
            }
            // Update class name from QE_Quote_Helper to QuoteTriggerHelper by Jheel        
            if(quote != null && quote.status == 'Draft' && (attach != null || Test.isRunningTest())){
                updateQuoteStatus(quoteIds, 'Quote-Trigger-AfterInsert');    
                response = 'SUCCESS';
            }else{
                if(attach == null){
                    response = 'Quote PDF must be generated before it can be submitted for approval.';
                }else if(quote.status != 'Draft'){
                    response = 'Quote status must be Draft!';
                }
            }
        }catch(Exception exp){
            if(String.valueof(exp).equals('System.QueryException: List has no rows for assignment to SObject')){
                response = 'Quote PDF must be generated before it can be submitted for approval.';   
            }
            system.debug('###Exception=='+exp);    
        }
        system.debug('###response=='+response);
        return response;     
    }
    
    /**
    * @description : Update Quote Status
    * @author jagrawal@addonblue.com | 3/3/2020 
    * @param List<Id> quoteIds
    * @param string calledBy 
    * @return void 
    **/
    //@future
    public static void updateQuoteStatus(List<Id> quoteIds, string calledBy) {
        String salesforceBaseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        // Query quote data and related quote line items
        List<Quote> quotes = new List<Quote>([
            Select Id, Payment_Method__c, Remove_Processing_Fee__c, Opportunity.Pricebook2.isActive, Opportunity.Pricebook2.Start_Date__c, GrandTotal, Selected_Payment_Term__c, Original_Quote__c,
            Opportunity.Pricebook2.Name, Draft_Reasons_For_Review_Operations__c, Draft_Reasons_For_Review_Sales__c, Draft_Reasons_For_Review_H4H__c,
            Opportunity.Pricebook2Id, ShippingCity, BillingCity, ShippingCountry, BillingCountry, ShippingState, BillingState, 
            ShippingStreet, BillingStreet, ShippingPostalCode, BillingPostalCode, Opportunity.Total_Amount__c,Comment__c,
            (Select Id, Original_Quantity__c, Product2Id, Product2.IsActive, Product2.Current_Inventory__c, Product2.Allocated__c,
            Product2.Requires_Double_Approval__c, Product2.Threshold__c, Product2.Available__c,Product_Types__c,
            Product2.Quantity_Per_Order_Threshold__c, Quantity, Product2.Name, Product2.Id, Product2.RecordType.Name,
            Product2.H4H_Approval_Required__c, TotalPrice, Discount_Description__c,QuoteId,Quote.GrandTotal From QuoteLineItems)
            From Quote Where Id In :quoteIds
        ]);
        // For each quote and line item check approval criteria.
        List<Quote> draftQuotesWithCriteriaChecked = new List<Quote>();

        Manage_Opportunity__c obkManageOpp = Manage_Opportunity__c.getInstance();
        system.debug('obkManageOpp....' + obkManageOpp.Threshold_Amount__c);
        decimal decThresholdAmt = obkManageOpp.Threshold_Amount__c;

        Map<Id,Id> isChangeOrderExist = new Map<Id,Id>();
        Map<Id,Map<Id,Decimal>> mapNewQuoteToQLIQuantity = new Map<Id,Map<Id,Decimal>>();
        Map<Id,List<QuoteLineitem>> mapOriginalQuotetoOriginalQLI = new Map<Id,List<QuoteLineItem>>();
        Map<Id,Integer> mapOriginalProductIdtoNumberOftimesExist = new Map<Id,Integer>();
        Map<Id,Integer> mapNewProductIdtoNumberOftimesExist = new Map<Id,Integer>();
        Map<Id,Boolean> mapProductMissingErrorThrown = new Map<Id,Boolean>();
        Map<Id,Boolean> mapProductQtyReducedErrorThrown = new Map<Id,Boolean>();

        List<ID> listOriginalQuotes = new List<ID>();
        for(Quote quote : Quotes){
            listOriginalQuotes.add(quote.Original_Quote__c);
        }
        
        if(!listOriginalQuotes.isEmpty()){
            for(QuoteLineItem objQLI : [Select Id,Product2ID,Quantity,Product2.Name,QuoteID from QuoteLineItem WHERE QuoteID IN :listOriginalQuotes]){
                if(!mapOriginalQuotetoOriginalQLI.containsKey(objQLI.QuoteID)){
                    List<QuoteLineItem> QuoteLineItemlist = new List<QuoteLineItem>();
                    QuoteLineItemList.add(objQLI);
                    mapOriginalQuotetoOriginalQLI.put(objQLI.QuoteID,QuoteLineItemlist);
                }else{
                    List<QuoteLineItem> QuoteLineItemlist = mapOriginalQuotetoOriginalQLI.get(objQLI.QuoteID);
                    QuoteLineItemlist.add(objQLI);
                    mapOriginalQuotetoOriginalQLI.put(objQLI.QuoteID,QuoteLineItemlist);
                }
                if(mapOriginalProductIdtoNumberOftimesExist.containsKey(objQLI.Product2ID)){
                    Integer numberExisted =  mapOriginalProductIdtoNumberOftimesExist.get(objQLI.Product2ID) + 1;
                    mapOriginalProductIdtoNumberOftimesExist.put(objQLI.Product2ID,numberExisted);
                }else{
                    mapOriginalProductIdtoNumberOftimesExist.put(objQLI.Product2ID,1);
                }
            }
        }

        for(Quote quote : Quotes) {
            // Quote/Oppt related criteria.
            String draftReasonsForReviewOperations = '';
            String draftReasonsForReviewSales = '';
            String draftReasonsForReviewCorporateSales = '';
            //#920 Add text "- Change Order" in Reason for Review - Operations field
            Boolean isOrderChanged = false;
            // Event not Active
            if(!quote.Opportunity.Pricebook2.isActive) {
                draftReasonsForReviewOperations = '- Inactive Event: '+'<a href="'+salesforceBaseUrl+'/'+quote.Opportunity.Pricebook2Id+'">'+quote.Opportunity.Pricebook2.Name+'</a>'+'<br>';
            }
            
			// For Change Order
            if(quote.Original_Quote__c != null){
                isChangeOrderExist.put(quote.Id,quote.Original_Quote__c);
            }
			
            // Quote's opportunity has Comment
            //if(!String.isBlank(quote.Opportunity.Comment__c)) {
              //  draftReasonsForReviewOperations += '- Has Comments: '+quote.Opportunity.Comment__c+'<br>';
            //}
            // Quote has Comment
            if(!String.isBlank(quote.Comment__c)) {
               draftReasonsForReviewOperations += '- Quote has comment: '+quote.Comment__c+'<br>';
            }
            // Quote's opportunity has custom payment terms
            if(quote.selected_payment_term__c == 'Custom' || quote.selected_payment_term__c == 'Custom Terms') {
                draftReasonsForReviewSales += '- Has Custom Payment Terms.'+'<br>';
            }
            
            // Quote's GrandTotal is less than or equal to zero.
            /*if(quote.GrandTotal <= 0 || Test.isRunningTest()) {
                draftReasonsForReviewSales += '- Quote Grand Total is 0 or Less.'+'<br>';
            }*/
            
            //Todo: Address check and amount > 7500
            if(quote.Opportunity.Total_Amount__c > decThresholdAmt && quote.Payment_Method__c == 'Credit Card' &&
                (quote.ShippingCity != quote.BillingCity || quote.ShippingCountry != quote.BillingCountry || quote.ShippingState != quote.BillingState
                    || quote.ShippingStreet != quote.BillingStreet || quote.ShippingPostalCode != quote.BillingPostalCode) || Test.isRunningTest()) {

                draftReasonsForReviewSales += '- Shipping and Billing Address does not match and Opportunity Amount is greater than '+ decThresholdAmt  +'<br>';
            }
            
             // Quote's opportunity has Net 30 payment terms
            // #418 Condition Added for Net 30 Payment Terms to check for the Event/Pricebook Start Date within 60 Days
            if(quote.selected_payment_term__c == 'Net 30' && System.today().addDays(60) >= quote.Opportunity.Pricebook2.Start_Date__c){
               draftReasonsForReviewCorporateSales += '- Has Net 30 Payment Terms.'+'<br>';
               draftReasonsForReviewCorporateSales += '- Is within 60 Days of Event/Pricebook Start Date.'+'<br>';
            }
            
            // Quote's opportunity has Net 60 payment terms
            if(quote.selected_payment_term__c == 'Net 60'){
                draftReasonsForReviewCorporateSales += '- Has Net 60 Payment Terms.'+'<br>';
            }

            // Quote Line Item related criteria
            for(QuoteLineItem qli : quote.QuoteLineItems) {
                // Product's inventory forecast
                Decimal productInventoryForcast = 0;
                if(qli.Quantity != null && qli.Product2.Current_Inventory__c != null && qli.Product2.RecordType.Name != 'Package' && qli.Product2.RecordType.Name != 'Hotel') {
                    productInventoryForcast = qli.Product2.Current_Inventory__c - qli.Quantity;
                }
                // Product is not Active
                if(!qli.Product2.IsActive || Test.isRunningTest()) {
                    draftReasonsForReviewOperations += '- Inactive Product/Package: '+'<a href="'+salesforceBaseUrl+'/'+qli.Product2.Id+'">'+qli.Product2.Name+'</a>'+'<br>';
                }
                // Product is Allocated
                if(qli.Product2.Allocated__c || Test.isRunningTest()) {
                    draftReasonsForReviewOperations += '- Allocated Product: '+'<a href="'+salesforceBaseUrl+'/'+qli.Product2.Id+'">'+qli.Product2.Name+'</a>'+'<br>';
                }
                // Product requires double approval.
                if(qli.Product2.Requires_Double_Approval__c || Test.isRunningTest()) {
                    draftReasonsForReviewOperations += '- Product Requires Double Approval: '+'<a href="'+salesforceBaseUrl+'/'+qli.Product2.Id+'">'+qli.Product2.Name+'</a>'+'<br>';
                }
                // Product is "Available" and Order quantity is greater than product's quantity per order threshold.
                if(qli.Product2.Available__c && (qli.Quantity > qli.Product2.Quantity_Per_Order_Threshold__c)) {
                    draftReasonsForReviewOperations += '- Quantity Per Order Threshold limit reached: '+'<a href="'+salesforceBaseUrl+'/'+qli.Product2.Id+'">'+qli.Product2.Name+'</a>'+'<br>';
                }
                // Product is Not "Available" and Product's inventory forcast goes below zero.
                if(!qli.Product2.Available__c && productInventoryForcast < 0  && qli.Product2.RecordType.Name != 'Package' && qli.Product2.RecordType.Name != 'Hotel') {
                    draftReasonsForReviewOperations += '- Limited inventory is available: '+'<a href="'+salesforceBaseUrl+'/'+qli.Product2.Id+'">'+qli.Product2.Name+'</a>'+'<br>';
                }
                // Product is Not "Available" and Product's inventory forcast goes below product's threshold.
                if(!qli.Product2.Available__c && productInventoryForcast < qli.Product2.Threshold__c && qli.Product2.RecordType.Name != 'Package' && qli.Product2.RecordType.Name != 'Hotel') {
                    draftReasonsForReviewOperations += '- Threshold limit reached: '+'<a href="'+salesforceBaseUrl+'/'+qli.Product2.Id+'">'+qli.Product2.Name+'</a>'+'<br>';
                }

                //Calculation to check if change order exist
                if(isChangeOrderExist.containsKey(qli.QuoteID)){
                    //Iterate over original line items to check if any product quantity is reduced.
                    if(qli.quantity < qli.Original_Quantity__c){
                        draftReasonsForReviewOperations += '- Product quantity reduced on Change Order for the product which was on original quote, Product Name: '+'<a href="'+salesforceBaseUrl+'/'+qli.Product2.Id+'">'+qli.Product2.Name+'</a>'+'<br>';
                        isOrderChanged = true;
                    }
                    if(mapNewProductIdtoNumberOftimesExist.containsKey(qli.Product2ID)){
                        Integer newProductTimes = mapNewProductIdtoNumberOftimesExist.get(qli.Product2ID) + 1;
                        mapNewProductIdtoNumberOftimesExist.put(qli.Product2ID,newProductTimes);
                    }else{  
                        mapNewProductIdtoNumberOftimesExist.put(qli.Product2ID,1);
                    }
                    if(mapNewQuoteToQLIQuantity != NULL){
                        if(!mapNewQuoteToQLIQuantity.containsKey(qli.quoteID)){
                            map<Id,Decimal> mapProductIDtoQuantity = new map<Id,Decimal>();
                            mapProductIDtoQuantity.put(qli.product2ID,qli.Quantity);
                            mapNewQuoteToQLIQuantity.put(qli.QuoteId,mapProductIDtoQuantity);
                        }else{
                            map<Id,Decimal> mapProductIDtoQuantity = mapNewQuoteToQLIQuantity.get(qli.quoteID);
                            if(mapProductIDtoQuantity.containsKey(qli.Product2ID)){
                                Decimal productQuantity = mapProductIDtoQuantity.get(qli.Product2ID);
                                productQuantity+=qli.quantity;
                                mapProductIDtoQuantity.put(qli.product2ID,productQuantity);
                                mapNewQuoteToQLIQuantity.put(qli.quoteID,mapProductIDtoQuantity);
                            }else{
                                mapProductIDtoQuantity.put(qli.Product2ID,qli.Quantity);
                                mapNewQuoteToQLIQuantity.put(qli.quoteID,mapProductIDtoQuantity);
                            }
                        }
                    }
                }
                //added for Opportunity Discount Product Type 
                if(qli.Product_Types__c == 'Discount' || Test.isRunningTest()){ 
                    Decimal discountedAmount = qli.TotalPrice;
                    discountedAmount = discountedAmount * -1;
                    decimal quoteTotal = qli.quote.GrandTotal;
                    quoteTotal += discountedAmount;
                    quoteTotal = quoteTotal * 0.05;
                    Boolean isTrue = discountedAmount > quoteTotal ? true : false;
                    if(isTrue) {
                        draftReasonsForReviewSales += '- Has Discount line item with Discount Amount '+ qli.TotalPrice + ' | ' + qli.Discount_Description__c + '<br>';
                    }
                }
            }
                     
            //Iterate over original line items to check if any product is missed.
            if(mapOriginalQuotetoOriginalQLI.containsKey(quote.Original_Quote__c)){
                for(QuoteLineItem qli : mapOriginalQuotetoOriginalQLI.get(quote.Original_Quote__c)){
                    if(!mapProductMissingErrorThrown.containsKey(qli.Product2ID) && (!(mapNewQuoteToQLIQuantity.containsKey(quote.ID) && mapNewQuoteToQLIQuantity.get(quote.ID).containsKey(qli.Product2ID)) || 
                    (mapNewProductIdtoNumberOftimesExist.containsKey(qli.Product2ID) && mapOriginalProductIdtoNumberOftimesExist.containsKey(qli.Product2ID) && mapOriginalProductIdtoNumberOftimesExist.get(qli.Product2ID) > mapNewProductIdtoNumberOftimesExist.get(qli.Product2ID)))){
                        draftReasonsForReviewOperations += 'Product which was on original quote has been removed from change order quote, Product Name: '+'<a href="'+salesforceBaseUrl+'/'+qli.Product2.Id+'">'+qli.Product2.Name+'</a>'+'<br>';
                        mapProductMissingErrorThrown.put(qli.Product2ID, true);
                        isOrderChanged = true;
                    }
                }
            }

            List<Payment_Term__c> lstOfPaymentTerms = new List<Payment_Term__c>();
            lstOfPaymentTerms = [select id, Payment_Due_Date__c, Quote__c, Opportunity__r.Pricebook2.LastPaymentDueDate__c FROM Payment_Term__c where Quote__c IN : quoteIds];
            
            if(lstOfPaymentTerms.size() > 0){
                for(Payment_Term__c pt : lstOfPaymentTerms){
                    system.debug('###'+pt);                    
                    if(!String.isBlank(String.valueof(pt.Payment_Due_Date__c)) && !String.isBlank(String.valueof(pt.Opportunity__r.Pricebook2.LastPaymentDueDate__c))){
                        if(pt.Payment_Due_Date__c > pt.Opportunity__r.Pricebook2.LastPaymentDueDate__c){                            
                            Date dt = pt.Opportunity__r.Pricebook2.LastPaymentDueDate__c;  
                            String d = dt.month() + '/' + dt.day() + '/' + dt.year();
                            draftReasonsForReviewOperations = draftReasonsForReviewOperations  + '<br />' + 'Custom payment term has due date further than Last Payment Due Date ' + d + ' for this event.';
                        }
                    }
                }
            }
            //#931 Approval for "Remove Processing Fee" checkbox
            if(quote.Remove_Processing_Fee__c && quote.Payment_Method__c == 'Credit Card') {
                draftReasonsForReviewSales += '- Processing fee was removed.'+'<br>';
            }
            
            // Check if Quote needs reveiw/approval 
            system.debug('###'+draftReasonsForReviewOperations+'###'+draftReasonsForReviewSales+'###'+draftReasonsForReviewCorporateSales);
            if(draftReasonsForReviewOperations != '' || draftReasonsForReviewSales != '' || draftReasonsForReviewCorporateSales != '') {
                //#920 Add text "- Change Order" in Reason for Review - Operations field
                if(isOrderChanged){
                    draftReasonsForReviewOperations = '- Change Order <br/>' + draftReasonsForReviewOperations;
                }
                quote.Draft_Reasons_For_Review_Operations__c = draftReasonsForReviewOperations;
                quote.Draft_Reasons_For_Review_Sales__c = draftReasonsForReviewSales;
                quote.Draft_Reasons_For_Review_Corporate_Sales__c = draftReasonsForReviewCorporateSales;
                quote.Status = 'Draft - Needs Review';
            } else {
                quote.Status = 'Draft - Approved';
            }
            draftQuotesWithCriteriaChecked.add(quote);
        }
        // Update quotes whoes criteria has been checked
        if(draftQuotesWithCriteriaChecked.size() > 0) {
            Utility.processRecords(draftQuotesWithCriteriaChecked, 'update');
            QuoteUtility.quoteApprovalHandling(draftQuotesWithCriteriaChecked);
        }
    }   
}