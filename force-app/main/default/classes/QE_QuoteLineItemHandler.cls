public class QE_QuoteLineItemHandler {
 
    // Constructor 
    public QE_QuoteLineItemHandler() {
    }
    
    // Update fields before inserting
    public void onBeforeInsert(Quotelineitem[] newListQuotelineitems) {
        try {
            Map<QuoteLineItem, Id> quotesAndOpportunitylineItemIds = new Map<QuoteLineItem, Id>();
            
            for (QuoteLineItem currentQuoteLineItem : newListQuotelineitems) {
                quotesAndOpportunitylineItemIds.put(currentQuoteLineItem , currentQuoteLineItem.OpportunityLineItemId);
            }
                
            //Related OpportunityLineItems
            Map<Id, OpportunityLineItem> relatedOpportunityLineItems = new Map<Id, OpportunityLineItem>([
                select id, Cost__c, ListPrice_Used__c, ListPrice_With_Discount__c, Tax_Percentage_Used__c, Tax_Amount__c,Discount_Description__c,
                    Total_Tax_Amount__c, VAT_Tax_Amount__c, Total_VAT_Tax__c, Record_Type__c, ProductType__c, Opportunity_Package__c, Room_Type__c,
                    Processing_Fee_Percentage_Used__c, Processing_Fee_Amount__c, Total_Processing_Fee_Amount__c,Discount_Type__c
                from OpportunityLineItem
                where id in :quotesAndOpportunitylineItemIds.values()
            ]);
            
            //QuoteLineItem
            for (Quotelineitem currentQuoteLineItem : quotesAndOpportunitylineItemIds.keySet()) {
                // Current QuoteLineItem
                currentQuoteLineItem.Record_Type__c = relatedOpportunityLineItems.get(currentQuoteLineItem.OpportunityLineItemId).Record_Type__c;     
                currentQuoteLineItem.ProductType__c = relatedOpportunityLineItems.get(currentQuoteLineItem.OpportunityLineItemId).ProductType__c;
                currentQuoteLineItem.Cost__c = relatedOpportunityLineItems.get(currentQuoteLineItem.OpportunityLineItemId).Cost__c;
                currentQuoteLineItem.ListPrice_Used__c = relatedOpportunityLineItems.get(currentQuoteLineItem.OpportunityLineItemId).ListPrice_Used__c;
                currentQuoteLineItem.ListPrice_With_Discount__c = relatedOpportunityLineItems.get(currentQuoteLineItem.OpportunityLineItemId).ListPrice_With_Discount__c;
                currentQuoteLineItem.Tax_Percentage_Used__c = relatedOpportunityLineItems.get(currentQuoteLineItem.OpportunityLineItemId).Tax_Percentage_Used__c;
                currentQuoteLineItem.Tax_Amount__c = relatedOpportunityLineItems.get(currentQuoteLineItem.OpportunityLineItemId).Tax_Amount__c;
                currentQuoteLineItem.Total_Tax_Amount__c = relatedOpportunityLineItems.get(currentQuoteLineItem.OpportunityLineItemId).Total_Tax_Amount__c;
                currentQuoteLineItem.VAT_Tax_Amount__c = relatedOpportunityLineItems.get(currentQuoteLineItem.OpportunityLineItemId).VAT_Tax_Amount__c;
                currentQuoteLineItem.Total_VAT_Tax__c = relatedOpportunityLineItems.get(currentQuoteLineItem.OpportunityLineItemId).Total_VAT_Tax__c;
                currentQuoteLineItem.Processing_Fee_Percentage_Used__c = relatedOpportunityLineItems.get(currentQuoteLineItem.OpportunityLineItemId).Processing_Fee_Percentage_Used__c;
                currentQuoteLineItem.Processing_Fee_Amount__c = relatedOpportunityLineItems.get(currentQuoteLineItem.OpportunityLineItemId).Processing_Fee_Amount__c;
                currentQuoteLineItem.Total_Processing_Fee_Amount__c = relatedOpportunityLineItems.get(currentQuoteLineItem.OpportunityLineItemId).Total_Processing_Fee_Amount__c;
                currentQuoteLineItem.Quote_Package__c = relatedOpportunityLineItems.get(currentQuoteLineItem.OpportunityLineItemId).Opportunity_Package__c;                                
                currentQuoteLineItem.Room_Type__c = relatedOpportunityLineItems.get(currentQuoteLineItem.OpportunityLineItemId).Room_Type__c;
                currentQuoteLineItem.Discount_Description__c = relatedOpportunityLineItems.get(currentQuoteLineItem.OpportunityLineItemId).Discount_Description__c;
                currentQuoteLineItem.Discount_Type__c = relatedOpportunityLineItems.get(currentQuoteLineItem.OpportunityLineItemId).Discount_Type__c;
            }
        } catch(exception ex) {
            system.debug('Error==>'+ex.getMessage()+' Line Number==>'+ex.getLineNumber());
        } 
    }    
   
}