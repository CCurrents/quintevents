@RestResource(urlMapping='/OnlineSalesQuote/*')
global with sharing class QE_OnlineSaleQuoteCtrl {

    global class OnlineSaleQuote {
        public String opportunity_id;
    }
    
    /* static public Pricebook2 pricebook {
        get {
            if (pricebook == null) {
                pricebook = [SELECT Id FROM Pricebook2 WHERE isStandard = true LIMIT 1];
            }
            
            return pricebook;
        }
    }
    */
    
    @Httppost
    global static Quote createQuote(onlineSaleQuote onlinesalequote){
        Quote salesQuote = crtQuote(onlinesalequote);
        salesQuote.Status = 'Signed - Approved';
        update salesQuote;
        return salesQuote;
    }
    
    
    // Create Quote
    private static Quote crtQuote(onlineSaleQuote onlinesalequote) {
        pricebook2 pricebook = [SELECT Id FROM Pricebook2 WHERE isStandard = true LIMIT 1];  
        List<Opportunity> oppList = [SELECT Id, (Select Id, PriceBookEntry.Product2Id, PricebookEntryId, Opportunity_Product_Package_Hotel__c, Package__c,
                    Quantity, UnitPrice, ApexHotelTotalPrice__c, Transportation_As_Part_Of_Hotel__c
                    From OpportunityLineItems) FROM Opportunity WHERE id = :onlinesalequote.opportunity_id];
        Quote newQuote = new Quote();
        if( oppList != null){
            try{
                newQuote.Name = 'Online Sale';
                newQuote.OpportunityId = onlinesalequote.opportunity_id;
                newQuote.pricebook2Id = pricebook.id;
                newQuote.Online_Order__c = true;
                Insert newQuote;
                newQuote.Status = 'Draft';
                update newQuote;
                System.debug('newQuote==>'+newQuote);
                // Opportunity line items
              
                List<QuoteLineItem> quoteLineItemList = new List<QuoteLineItem>();
                for(OpportunityLineItem oli : oppList[0].OpportunityLineItems){

                    QuoteLineItem qli = new QuoteLineItem();
                    qli.Product2Id = oli.PriceBookEntry.Product2Id;
                    qli.PriceBookEntryId = oli.PricebookEntryId;
                    qli.QuoteId = newQuote.Id;
                    qli.OpportunityLineItemId = oli.Id;
                    qli.Quote_Product_Package_Hotel__c = oli.Opportunity_Product_Package_Hotel__c;
                    qli.Package__c = oli.Package__c;
                    qli.Quantity = oli.Quantity;
                    qli.UnitPrice = oli.UnitPrice;
                    qli.ApexHotelTotalPrice__c = oli.ApexHotelTotalPrice__c;
                    if (oli.Transportation_As_Part_Of_Hotel__c != null) {
                        qli.Transportation_As_Part_Of_Hotel__c = oli.Transportation_As_Part_Of_Hotel__c;
                    }
                    quoteLineItemList.add(qli);
                }
                if(quoteLineItemList.size() > 0){
                    Insert quoteLineItemList;
                }
                system.debug('quoteLineItemList'+quoteLineItemList);
            }catch(exception e){
                System.debug('exception=>'+e+'=LineNumber=>'+e.getLineNumber());
            }
        }
        return newQuote;
    }
}