/**
* @description       : 
* @author            : fsuraitawala@addonblue.com
* @group             : 
* @last modified on  : 03-08-2021
* @last modified by  : fsuraitawala@addonblue.com
* Modifications Log 
* Ver   Date         Author                       Modification
* 1.0   11-05-2020   jagrawal@addonblue.com     Initial Version
* 1.1   10-02-2021   fsuraitawala@addonblue.com #773 Digideck staging changes
* 1.2   08-03-2021   fsuraitawala@addonblue.com #841 Digideck related changes from STG to PROD
* 1.3   04-17-2021   cshah@addonblue.com        #904 Changes to Digideck classes
**/
global class SportsdigitaOpportunityGatherer implements Sportsdigita.IDataCompiler {
    //This function is needed to satisfy the requirements of the IDataCompiler interface, but not actually
    // used in this project. So just return an empty string.
    public string mapDigideckSlides(string pOpportunityId, string pDeckId){
        return '';
    }
    
    //This is the entry point of the APEX code from the Sportsdigita Salesforce app when creating a presentation for an Opportunity
    public List<Map<String, Object>> getRulesetData(String entityId){
        List<Map<String, Object>> returnData = new List<Map<String, Object>>();
        
        //Get the list of columns for each object to get data for
        Map<String, Schema.DisplayType> opportunityColumns = SportsdigitaUtilities.getOpportunityColumns();
        Map<String, Schema.DisplayType> priceBookColumns = SportsdigitaUtilities.getPriceBookColumns();
        
        //Get the Opportunity and Pricebook details.
        Map<String, object> opportunity = SportsdigitaUtilities.getObject('Opportunity', entityId, opportunityColumns, 'PriceBook2', priceBookColumns);
        
        //Get the images from the pricebook
        opportunity.putAll(SportsdigitaUtilities.getOpportunityPriceBookImages((string)opportunity.get('PriceBook2.Id')));
        
        system.debug('@@opportunity1=='+opportunity);
        String priceBookName = (string)opportunity.get('PriceBook2.Name');
        if(priceBookName != null) {
            priceBookName = SportsdigitaUtilities.getFormattedPriceBookId(priceBookName);
            opportunity.put('PriceBook2.Name',priceBookName);
            opportunity.put('PriceBook2.Id',priceBookName);
        }
        system.debug('@@opportunity2=='+opportunity);
        
        returnData.add(opportunity);
        Boolean showPrices = false;
        showPrices = (Boolean)opportunity.get('Opportunity.Display_Package_Price_in_Digideck__c');
        
        //Get all the quote ids on the opportunity that have at least one quote line item
        list<Quote> opportunityQuoteList = SportsdigitaUtilities.getOpportunityQuoteDetails(entityId);
        
        List<Map<String, Object>> rollupData = new List<Map<String, Object>>();
        integer quoteNumber = 0;
        
        //Loop through the quote ids to get the details for each quote.
        for(Quote opportunityQuote: opportunityQuoteList){
            //We need to do our own quote numbering to associate packages/hotels/a la carte items in the Digideck presentation
          // and Salesforce doesn't increment like 1,2,3,4, etc. 
            quoteNumber++;
            
            Map<String, object> quote = SportsdigitaUtilities.convertOpportunityQuoteDetailsToNameValuePair(opportunityQuote);
            
            string currencyCode = 'USD';
            //Use the currency code from the quote if it's there
            if(quote.get('Quote.CurrencyIsoCode') != null){
              currencyCode = (string)quote.get('Quote.CurrencyIsoCode');
          }
            
            quote.put('QuoteNumber', quoteNumber);
            list<QuoteLineItem> quoteLineItems = SportsdigitaUtilities.getQuoteLineItemDetails(opportunityQuote.Id);
            
            for(QuoteLineItem item: quoteLineItems){
                string productHtml = '';
                Map<String, object> quoteProducts = new Map<String, object>();
                quoteProducts.putAll(quote);
                
                //The Digideck only cares about Package, A Al Carte, Package Hotel, and Hotel Transportation record types, so just ignore the rest
              if(item.Record_Type__c <> 'Package' && item.Record_Type__c <> 'A La Carte' && item.Record_Type__c <> 'Package Hotel' && item.Record_Type__c <> 'Hotel Transportation'){
                    continue;
                }
                
                //From here on out we'll work with the QuoteLineItem and Product properties as a name value pair list so convert that here
                Map<String, object> quoteLineItemMap = SportsdigitaUtilities.convertQuoteLineItemDetailsToNameValuePair(item, currencyCode);
                
                //Use display name in the Digideck. If we don't have it, fall back to name.
                if(String.isBlank((string)quoteLineItemMap.get('Product2.Display_Name__c'))){
                    quoteLineItemMap.put('Product2.Display_Name__c', (string)quoteLineItemMap.get('Product2.Name'));
                }
                
                quoteProducts.putAll(quoteLineItemMap);
                
                // Add Checkin/Checkout dates and Room type to the Package Hotel record.
                if(item.Record_Type__c == 'Package Hotel'){
                    SportsdigitaUtilities.addHotelStayDataToPackageHotel(quoteProducts);
                }
                
                string visibilityCssClass = 'dd-hidden';
                string productPrice = '';
                
                //If we shouldn't show prices, don't even send the price to the Digideck
                // Savey users will be able to see the hidden element with the browsers inspector
                if(showPrices){
                    visibilityCssClass = 'dd-show';
                    productPrice = (string)quoteProducts.get('QuoteLineItem.ListPrice_Used__c-formatted');
                }
                
                //Add calculated properties to the QuoteLineItem details
                quoteProducts.put('productHtml', SportsdigitaUtilities.replaceAnchorTags(SportsdigitaUtilities.getProductHtml(quoteProducts)));
                quoteProducts.put('priceVisibility', visibilityCssClass);
                quoteProducts.put('productPrice', productPrice);
                quoteProducts.putAll(SportsdigitaUtilities.getProductImages(item.Product2Id));
                
                returnData.add(quoteProducts);
            }
        }
        //Generate the html for the rollup (aka Summary slide);
        SportsdigitaUtilities.addRollupSlideData(returnData);
        
        return returnData;
    }
}