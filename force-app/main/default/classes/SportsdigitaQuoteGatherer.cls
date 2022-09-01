/**
* @description       : 
* @author            : fsuraitawala@addonblue.com
* @group             : 
* @last modified on  : 03-08-2021
* @last modified by  : fsuraitawala@addonblue.com
* Modifications Log 
* Ver   Date         Author                       Modification
* 1.0   11-19-2020   jagrawal@addonblue.com     Initial Version
* 1.1   10-02-2021   fsuraitawala@addonblue.com #773 Digideck staging changes
* 1.2   04-17-2021   cshah@addonblue.com        #904 Changes to Digideck classes
**/
global class SportsdigitaQuoteGatherer implements Sportsdigita.IDataCompiler {
    //This function is needed to satisfy the requirements of the IDataCompiler interface, but not actually
    // used in this project. So just return an empty string.
    public string mapDigideckSlides(string pOpportunityId, string pDeckId){
        return '';
    }
    
    //This is the entry point of the APEX code from the Sportsdigita Salesforce app when creating a presentation for a Quote
    public List<Map<String, Object>> getRulesetData(String entityId){
        List<Map<String, Object>> returnData = new List<Map<String, Object>>();
        
        //Get the list of columns for each object to get data for
        Map<String, Schema.DisplayType> quoteColumns = SportsdigitaUtilities.getQuoteColumns();
        Map<String, Schema.DisplayType> ownerColumns = SportsdigitaUtilities.getOwnerColumns();
        Map<String, Schema.DisplayType> opportunityColumns = SportsdigitaUtilities.getOpportunityColumns();
        Map<String, Schema.DisplayType> priceBookColumns = SportsdigitaUtilities.getPriceBookColumns();
        
        Boolean showPrices = false;
        String currencyCode = 'USD';
        
        System.debug('entityId@@'+entityId);
        System.debug('quoteColumns@@'+quoteColumns);
        System.debug('ownerColumns@@'+ownerColumns);
        //Get the Quote and Owner details.
        Map<String, object> quote = SportsdigitaUtilities.getObject('Quote', entityId, quoteColumns, 'Owner', ownerColumns);
        System.debug('quote@@'+quote);
        
        
        showPrices = (Boolean)quote.get('Quote.Display_Package_Price_in_Digideck__c');
        string opportunityId = (string)quote.get('Quote.OpportunityId__c');
        
        //Use the currency code from the quote if it's there
        if(quote.get('Quote.CurrencyIsoCode') != null){
            currencyCode = (string)quote.get('Quote.CurrencyIsoCode');
        }
        
        //Get the Opportunity and Pricebook details.
        Map<String, object> opportunity = SportsdigitaUtilities.getObject('Opportunity', opportunityId, opportunityColumns, 'PriceBook2', priceBookColumns);
        system.debug('@@opportunity1=='+opportunity);
        String priceBookName = (string)opportunity.get('PriceBook2.Name');
        if(priceBookName != null) {
            priceBookName = SportsdigitaUtilities.getFormattedPriceBookId(priceBookName);
            opportunity.put('PriceBook2.Name',priceBookName);
            opportunity.put('PriceBook2.Id',priceBookName);
        }
        system.debug('@@opportunity2=='+opportunity);
        quote.putAll(opportunity);
        
        Map<String, Object> priceBookImages = new Map<String, Object>();
        //Get the images from the pricebook
        priceBookImages = SportsdigitaUtilities.getOpportunityPriceBookImages((string)opportunity.get('PriceBook2.Id'));
        
        if(priceBookImages.size() > 0){
            quote.putAll(priceBookImages);
        }
        
        //We need to do our own quote numbering to associate packages/hotels/a la carte items in the Digideck presentation
        // and Salesforce doesn't increment like 1,2,3,4, etc. Since we're generating for a single quote here, we'll just set the quoteNumber to 1
        integer quoteNumber = 1;
        quote.put('QuoteNumber', quoteNumber);
        
        returnData.add(quote);
        
        //Get QuoteLineItem and Product details.
        list<QuoteLineItem> qliList = SportsdigitaUtilities.getQuoteLineItemDetails(entityId);
        
        list<string> productIdList = new list<string>();
        for(QuoteLineItem item: qliList){
            productIdList.add(item.Product2Id);
        }
        
        for(QuoteLineItem item: qliList){
            
            //The Digideck only cares about Package, A Al Carte, Package Hotel, and Hotel Transportation record types, so just ignore the rest
            if(item.Record_Type__c <> 'Package' && item.Record_Type__c <> 'A La Carte' && item.Record_Type__c <> 'Package Hotel' && item.Record_Type__c <> 'Hotel Transportation'){
                continue;
            }
            
            //From here on out we'll work with the QuoteLineItem and Product properties as a name value pair list so convert that here
            Map<String, object> quoteLineItemProduct = SportsdigitaUtilities.convertQuoteLineItemDetailsToNameValuePair(item, currencyCode);
            
            //Add quote fields to the individual line items because we need to display this on the Package/Hotel/A La Carte slides.
            quoteLineItemProduct.put('QuoteNumber', quoteNumber);
            quoteLineItemProduct.put('Quote.Digideck_Comments__c', quote.get('Quote.Digideck_Comments__c'));
            quoteLineItemProduct.put('Quote.Id', quote.get('Quote.Id'));
            
            //Use display name in the Digideck. If we don't have it, fall back to name.
            if(String.isBlank((string)quoteLineItemProduct.get('Product2.Display_Name__c'))){
                quoteLineItemProduct.put('Product2.Display_Name__c', (string)quoteLineItemProduct.get('Product2.Name'));
            }
            
            // Add Checkin/Checkout dates and Room type to the Package Hotel record.
            if(item.Record_Type__c == 'Package Hotel') {
                SportsdigitaUtilities.addHotelStayDataToPackageHotel(quoteLineItemProduct);
            }
            
            string visibilityCssClass = 'dd-hidden';
            string productPrice = '';
            
            //If we shouldn't show prices, don't even send the price to the Digideck
            // Savey users will be able to see the hidden element with the browsers inspector
            if(showPrices){
                visibilityCssClass = 'dd-show';
                productPrice = (string)quoteLineItemProduct.get('QuoteLineItem.ListPrice_Used__c-formatted');
            }
            
            //Add calculated properties to the QuoteLineItem details
            quoteLineItemProduct.put('productHtml', SportsdigitaUtilities.replaceAnchorTags(SportsdigitaUtilities.getProductHtml(quoteLineItemProduct)));
            quoteLineItemProduct.put('priceVisibility', visibilityCssClass);
            quoteLineItemProduct.put('productPrice', productPrice);
            quoteLineItemProduct.putAll(SportsdigitaUtilities.getProductImages(item.Product2Id));
            
            //Add the QuoteLineItem details to the return list. 
            returnData.add(quoteLineItemProduct); 
        }
        
        //Generate the html for the rollup (aka Summary slide);
        SportsdigitaUtilities.addRollupSlideData(returnData);
        
        return returnData;
    }
}