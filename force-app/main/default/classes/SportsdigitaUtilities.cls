/**
 * @description       : 
 * @author            : jagrawal@addonblue.com
 * @group             : 
 * @last modified on  : 10-08-2021
 * @last modified by  : fsuraitawala@addonblue.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   10-27-2020   Unknown                   Initial Version
 * 1.1   11-20-2020   jagrawal@addonblue.com    #625 Added code changes as requested
 * 1.2   12-22-2020   jagrawal@addonblue.com    #675 Digideck changes SportsdigitaUtilities class for moving a button position.
 * 1.3   01-21-2021   jagrawal@addonblue.com    #719 code changes line numbers 503 and 525.
 * 1.4   26-01-2021   jagrawal@addonblue.com    #738 Digideck remove this line from code, this is two remove second button.
 * 1.5   17-04-2021   cshah@addonblue.com       #904 Changes to Digideck classes
 * 1.6   18-04-2021   fsuraitawala@addonblue.com #1001 Digideck File Update - Unconfirmed Dates
 * 1.6   18-04-2021   fsuraitawala@addonblue.com #1035 Digideck add Venue and Location
**/
public class SportsdigitaUtilities {
    
     //Gets the list of columns needed from the Opportunity object
     public static Map<String, Schema.DisplayType> getOpportunityColumns(){
          Map<String, Schema.DisplayType> opportunityMap = new Map<String, Schema.DisplayType>();
          
          opportunityMap.put('Name', Schema.DisplayType.STRING);
          opportunityMap.put('Display_Package_Price_in_Digideck__c', Schema.DisplayType.BOOLEAN);
          
          return opportunityMap;
      }
      
      //Gets the list of columns needed from the PriceBook object
      public static Map<String, Schema.DisplayType> getPriceBookColumns(){
          
          Map<String, Schema.DisplayType> priceBookMap = new Map<String, Schema.DisplayType>();
          
          priceBookMap.put('Name', Schema.DisplayType.STRING);
          priceBookMap.put('Display_Name__c', Schema.DisplayType.STRING);
          priceBookMap.put('Description', Schema.DisplayType.STRING);
          priceBookMap.put('Start_Date__c', Schema.DisplayType.DATE);
          priceBookMap.put('End_Date__c', Schema.DisplayType.DATE);
          priceBookMap.put('Event_Year__c', Schema.DisplayType.INTEGER);
          priceBookMap.put('Outreach_Event_Name__c', Schema.DisplayType.STRING);
          priceBookMap.put('Unconfirmed_Dates__c', Schema.DisplayType.BOOLEAN);
          priceBookMap.put('Location__c', Schema.DisplayType.STRING);
          priceBookMap.put('Venue__c', Schema.DisplayType.STRING);
          priceBookMap.put('International_Stripe__c', Schema.DisplayType.BOOLEAN);
                    
          return priceBookMap;
      }
      
      //Gets the list of columns needed from the Quote object
      public static Map<String, Schema.DisplayType> getQuoteColumns(){
          Map<String, Schema.DisplayType> quoteMap = new Map<String, Schema.DisplayType>();
          
          quoteMap.put('CurrencyIsoCode', Schema.DisplayType.STRING);
          quoteMap.put('Digideck_Comments__c', Schema.DisplayType.STRING);
          quoteMap.put('TotalPrice', Schema.DisplayType.CURRENCY);
          quoteMap.put('Id', Schema.DisplayType.STRING);
          quoteMap.put('Display_Package_Price_in_Digideck__c', Schema.DisplayType.BOOLEAN);
          quoteMap.put('OpportunityId__c', Schema.DisplayType.STRING);
          return quoteMap;
      }
      
      //Gets the list of columns needed from the Owner object
      public static Map<String, Schema.DisplayType> getOwnerColumns(){
          Map<String, Schema.DisplayType> ownerMap = new Map<String, Schema.DisplayType>();
          
          ownerMap.put('Name', Schema.DisplayType.STRING);
          ownerMap.put('Email', Schema.DisplayType.Email);
          // #625 Added code changes as requested
          ownerMap.put('Phone', Schema.DisplayType.Phone);
          return ownerMap;
      }
      
      //Gets the list of columns needed from the OpportunityLineItem object
      public static Map<String, Schema.DisplayType> getQuoteLineItemColumns(){
          Map<String, Schema.DisplayType> quoteLineItemMap = new Map<String, Schema.DisplayType>();
          
          quoteLineItemMap.put('Record_Type__c', Schema.DisplayType.STRING);
          quoteLineItemMap.put('Quantity', Schema.DisplayType.INTEGER);
          quoteLineItemMap.put('Quote_Package__c', Schema.DisplayType.STRING);
          quoteLineItemMap.put('Id', Schema.DisplayType.STRING);
          quoteLineItemMap.put('Product_Type__c', Schema.DisplayType.STRING);
          quoteLineItemMap.put('ListPrice_Used__c', Schema.DisplayType.CURRENCY);
          quoteLineItemMap.put('Product2Id', Schema.DisplayType.STRING);
          
          return quoteLineItemMap;
      }
      
      //Gets the list of columns needed from the Product2 object
      public static Map<String, Schema.DisplayType> getProduct2Columns(){
          Map<String, Schema.DisplayType> quoteLineItemMap = new Map<String, Schema.DisplayType>();
          
          quoteLineItemMap.put('Room_Type__c', Schema.DisplayType.STRING);
          quoteLineItemMap.put('Check_In_Date__c', Schema.DisplayType.DATE);
          quoteLineItemMap.put('Check_Out_Date__c', Schema.DisplayType.DATE);
          quoteLineItemMap.put('Id', Schema.DisplayType.STRING);
          quoteLineItemMap.put('Display_Name__c', Schema.DisplayType.STRING);
          quoteLineItemMap.put('Name', Schema.DisplayType.STRING);
          quoteLineItemMap.put('DisplayinDigideck__c', Schema.DisplayType.BOOLEAN);
          quoteLineItemMap.put('DigideckContent__c', Schema.DisplayType.STRING);
          return quoteLineItemMap;
      }
      
      //Get's data from a single object based on the object id
      // objectName: The name of the object to query
      // objectId: The id of the record to get
      // objectFieldMap: The columns to retrieve.
      public static Map<String, object> getObject(string objectName, string objectId, Map<String, Schema.DisplayType> objectFieldMap){
          return SportsdigitaUtilities.getObject(objectName, objectId, objectFieldMap, null, null);
      }
    
      //Get's data from a parent object and one of it's children based on the id of the parent object.
      // objectName: The name of the object to query
      // objectId: The id of the record to get
      // objectFieldMap: The parent object columns to retrieve.
      // childObjectName: The name of the child object to query
      // childObjectFieldMap: The child object columns to retrieve.
      public static Map<String, object> getObject(string objectName, string objectId, Map<String, Schema.DisplayType> objectFieldMap, 
                                                  string childObjectName, Map<String, Schema.DisplayType> childObjectFieldMap) {    
          Map<String, object> mapping = new Map<String, object>(); 
          
          string fieldList = '';
          Integer counter = 0; 
                                                      
          // Make the list of columns to retrieve from the parent object
          for(string key : objectFieldMap.keySet()){
              if(counter > 0){
                  fieldList = fieldList + ', ';
              }
              fieldList = fieldList + key;
              counter = counter + 1;
          }
             
          // Add the child object columns if there is a child object
          if(childObjectName != null && childObjectFieldMap != null){
              fieldList = fieldList + ', ' + childObjectName + '.Id';
              for(string key: childObjectFieldMap.keySet()){
                  if(counter > 0){
                    fieldList = fieldList + ', ';
                  }
                  fieldList = fieldList + childObjectName + '.' + key;
                  counter = counter + 1;
              }  
          }
          
          //Make the SOQL query
          string soql = 'select ';
          soql = soql + fieldList;
          soql = soql + ' FROM '+ objectName + ' where Id = :objectId';
        
          sObject sobj = Database.query(soql);                                      
           System.debug('sobj@@'+sobj);
          
          //Add the parent object id to the return set.
          mapping.put(objectName + '.Id', sobj.get('Id'));
                                                      
          string currencyCode = 'USD';
          
          //Check if there's a currency code in the parent object dataset.
          //We'll need this for formatting currency columns later.
          if(objectFieldMap.keySet().contains('CurrencyIsoCode')){
               currencyCode = (string) sobj.get('CurrencyIsoCode');
          }
                                                      
          for (String f : objectFieldMap.keySet())
          {
            mapping.put(objectName + '.' + f, sobj.get(f));
              
              //Add new formated property for currencys and dates
              string formattedValue = SportsdigitaUtilities.getFormattedValue(sobj.get(f), objectFieldMap.get(f), currencyCode);
              if(!String.isBlank(formattedValue)){
                  //Add a new property called {propertyName}-formatted just in case we need the original for some reason.
                  mapping.put(objectName + '.' + f + '-formatted', formattedValue);
              }
          }
          System.debug('childObjectName@@'+childObjectName);
          System.debug('childObjectFieldMap@@'+childObjectFieldMap);
          System.debug('sobj.getSObject(childObjectName)@@'+sobj.getSObject(childObjectName));
          
          if(childObjectName != null && childObjectFieldMap != null && sobj.getSObject(childObjectName) != null){
             //Check if there's a currency code in the child object dataset.
             //Use that for currency formatting if there is.
             if(childObjectFieldMap.keySet().contains('CurrencyIsoCode')){
               currencyCode = sobj.getSObject(childObjectName).get('CurrencyIsoCode').toString();                                           
             }
             mapping.put(childObjectName + '.Id', sobj.getSObject(childObjectName).get('Id'));
             for (String f : childObjectFieldMap.keySet())
              {
                  string childPropertyName = childObjectName + '.' + f;
                  mapping.put(childPropertyName, sobj.getSObject(childObjectName).get(f));
                  
                  //Add new formated property for currencys and dates
                  string formattedValue = SportsdigitaUtilities.getFormattedValue(sobj.getSObject(childObjectName).get(f), childObjectFieldMap.get(f), currencyCode);
                  if(!String.isBlank(formattedValue)){
                      //Add a new property called {propertyName}-formatted just in case we need the original for some reason.
                      mapping.put(childPropertyName + '-formatted', formattedValue);
                  }
              }
          }
          
          return mapping;
      }
    
    //Gets the quote and owner data fro all quotes on an opportunity
    public static List<Quote> getOpportunityQuoteDetails(string opportunityId){
        
        Map<String, Schema.DisplayType> quoteColumns = SportsdigitaUtilities.getQuoteColumns();
        Map<String, Schema.DisplayType> ownerColumns = SportsdigitaUtilities.getOwnerColumns();
        
        string fieldList = '';
        Integer counter = 0;    
        for(string key : quoteColumns.keySet()){
            if(counter > 0){
                fieldList = fieldList + ', ';
            }
            fieldList = fieldList + key;
            counter = counter + 1;
        }
             
        fieldList = fieldList + ', Owner.Id';
        for(string key: ownerColumns.keySet()){
            if(counter > 0){
                fieldList = fieldList + ', ';
            }
            fieldList = fieldList + 'Owner.' + key;
            counter = counter + 1;
        }  
          
        string soql = 'select ';
        soql = soql + fieldList;
        soql = soql + ' FROM Quote where OpportunityId = :opportunityId AND LineItemCount > 1 Order By QuoteNumber';
                
        List<Quote> quoteList = Database.query(soql);
          
        return quoteList;
    }
    
    // Converts the quote object properties to a name value pair list cause that's how the Digideck presentation flows are expecting the data;
    public static Map<String, object> convertOpportunityQuoteDetailsToNameValuePair(Quote quote){
        System.debug('@@@quote : '+quote);
        Map<String, object> mapping = new Map<String, object>(); 
        
        Map<String, Schema.DisplayType> quoteColumns = SportsdigitaUtilities.getQuoteColumns();
        Map<String, Schema.DisplayType> ownerColumns = SportsdigitaUtilities.getOwnerColumns();
        
        string currencyCode = 'USD';
                                                      
        if(quote.CurrencyIsoCode != null){
          currencyCode = quote.CurrencyIsoCode;                                           
        }
        
        mapping.put('Quote.Id', quote.get('Id'));                                            
        for (String f : quoteColumns.keySet()){
            mapping.put('Quote.' + f, quote.get(f));
              
            //Add new formated property for currencys and dates
            string formattedValue = SportsdigitaUtilities.getFormattedValue(quote.get(f), quoteColumns.get(f), currencyCode);
            if(!String.isBlank(formattedValue)){
                mapping.put('Quote.' + f + '-formatted', formattedValue);
            }
        }
        
        if(quote.getSObject('Owner') != null) {
            mapping.put('Owner.Id', quote.getSObject('Owner').get('Id'));
            for (String f : ownerColumns.keySet()) {
                string ownerPropertyName = 'Owner.' + f;
                mapping.put(ownerPropertyName, quote.getSObject('Owner').get(f));
                      
                //Add new formated property for currencys and dates
                string formattedValue = SportsdigitaUtilities.getFormattedValue(quote.getSObject('Owner').get(f), ownerColumns.get(f), currencyCode);
                if(!String.isBlank(formattedValue)){
                    mapping.put(ownerPropertyName + '-formatted', formattedValue);
                }
            }
        }          
        return mapping;
    }
    
    //Gets the QuoteLineItem and Product data for a quote
    public static List<QuoteLineItem> getQuoteLineItemDetails(string quoteId){
                
        Map<String, Schema.DisplayType> quoteLineItemColumns = SportsdigitaUtilities.getQuoteLineItemColumns();
        Map<String, Schema.DisplayType> productColumns = SportsdigitaUtilities.getProduct2Columns();
        
        string fieldList = '';
        Integer counter = 0;    
        for(string key : quoteLineItemColumns.keySet()){
            if(counter > 0){
                fieldList = fieldList + ', ';
            }
            fieldList = fieldList + key;
            counter = counter + 1;
        }
        
        for(string key: productColumns.keySet()){
            if(counter > 0){
                fieldList = fieldList + ', ';
            }
            fieldList = fieldList + 'Product2.' + key;
            counter = counter + 1;
        }  
          
        string soql = 'select ';
        soql = soql + fieldList;
        soql = soql + ' FROM QuoteLineItem WHERE QuoteId = :quoteId Order By LineNumber';
        
        List<QuoteLineItem> quoteLineItemList = Database.query(soql);                                      
        
        return quoteLineItemList;
    }
    
    // Converts the quoteLineItem object properties to a name value pair list cause that's how the Digideck presentation flows are expecting the data;
    public static Map<String, object> convertQuoteLineItemDetailsToNameValuePair(QuoteLineItem quoteLineItem, String currencyCode){
        Map<String, object> mapping = new Map<String, object>(); 
        
        Map<String, Schema.DisplayType> quoteLineItemColumns = SportsdigitaUtilities.getQuoteLineItemColumns();
        Map<String, Schema.DisplayType> productColumns = SportsdigitaUtilities.getProduct2Columns();
        
        mapping.put('QuoteLineItem.Id', quoteLineItem.get('Id'));                                            
        for (String f : quoteLineItemColumns.keySet()){
            mapping.put('QuoteLineItem.' + f, quoteLineItem.get(f));
              
            //Add new formated property for currencys and dates
            string formattedValue = SportsdigitaUtilities.getFormattedValue(quoteLineItem.get(f), quoteLineItemColumns.get(f), currencyCode);
            if(!String.isBlank(formattedValue)){
                mapping.put('QuoteLineItem.' + f + '-formatted', formattedValue);
            }
        }
             
        mapping.put('Owner.Id', quoteLineItem.getSObject('Product2').get('Id'));
        
        for (String f : productColumns.keySet())
        {
            string ownerPropertyName = 'Product2.' + f;
            mapping.put(ownerPropertyName, quoteLineItem.getSObject('Product2').get(f));
                  
            //Add new formated property for currencys and dates
            string formattedValue = SportsdigitaUtilities.getFormattedValue(quoteLineItem.getSObject('Product2').get(f), productColumns.get(f), currencyCode);
            if(!String.isBlank(formattedValue)){
                mapping.put(ownerPropertyName + '-formatted', formattedValue);
            }
        }
                  
        return mapping;
    }
      
      //Formats dates and currency data types
      public static string getFormattedValue(object value, Schema.DisplayType displayType, string currencyCode){
          if(displayType == Schema.DisplayType.CURRENCY)
          {
              return SportsdigitaUtilities.formatCurrency(Integer.valueOf(value), currencyCode);
          } else 
          if(displayType == Schema.DisplayType.DATE){
              if (value <> null) {
                  DateTime d = (Date)value;
                  // #625 Added code changes as requested
                  return d.formatGMT('MM/dd/yyyy');
              }
          } else if (displayType == Schema.DisplayType.DATETIME)
          {
              if (value <> null) {
                  DateTime d = (DateTime)value;
                  // #625 Added code changes as requested
                  return d.formatGMT('MM/dd/yyyy');
              }
          }
        return null;
      }
      
      //Prepends the currency symbol based on the currencyCode and formats the decimal as 999.00
      public static String formatCurrency(Decimal i, string currencyCode) {
          string currencySymbol = '$';
  
          if(currencyCode == 'EUR'){ currencySymbol = '€';
          } else if(currencyCode == 'GBP'){ currencySymbol = '£'; }
            
          if (i == null || Math.abs(i) < 0.005) return currencySymbol + '0';
          String s = i.setScale(0).format();
          return currencySymbol + s;
      }
      
      //Gets the images associated to the product
      public static Map<String, Object> getProductImages(String productId){
          Map<String, Object> imageMap = new Map<String, Object>();
          
          list<API_Image__c> imageList = [SELECT Id, Type__c, url__c FROM API_Image__c where Product__c = :productId];
          
          integer photoImageCount = 0;
          integer seatingChartImageCount = 0;
          list<string> photoImageList = new list<string>();
          list<string> imageRotatorPhotoList = new list<string>();
          list<string> seatingChartImageList = new list<string>();
          list<string> imageRotatorSeatingChartList = new list<string>();
          
          for(API_Image__c image: imageList){
              //Split up Photo and Seating Chart images into two separate lists because they will be used differently in the Digideck
              if(image.Type__c == 'Photo'){
                  photoImageCount++;
                  //Make each image a separate variable, but also add it to the image list for maximum Digideck flexiblility.
                  // For example slides with an image rotator need images in an array, but slides with an image collage need a separate property for each image.
                  imageMap.put('photoUrl' + photoImageCount, image.URL__c);
                  photoImageList.add(image.URL__c);
                  //Image rotator needs a seed value in one property and the image list in another.
                  // Use photoUrl1 as the seed value, so don't include it in the image list. 
                  if(photoImageCount > 1){
                      imageRotatorPhotoList.add(image.URL__c);
                  }
              } else if(image.Type__c == 'Seating Chart'){
                  seatingChartImageCount++;
                  imageMap.put('seatingChartUrl' + seatingChartImageCount, image.URL__c);
                  seatingChartImageList.add(image.URL__c);
                  if(seatingChartImageCount > 1){
                      imageRotatorSeatingChartList.add(image.URL__c);
                  }
              }
          }
          
          imageMap.put('photoUrls', photoImageList);
          imageMap.put('seatingChartUrls', seatingChartImageList);
          imageMap.put('imageRotatorPhotoUrls', imageRotatorPhotoList);
          imageMap.put('imageRotatorSeatingChartUrls', imageRotatorSeatingChartList);
          //If there's no seating chart the Digideck should hide the seating chart button. 
          //Create a new property here to indicate to the Digideck should show or hide the seating chart button.
          if(seatingChartImageList.size() < 1){
              imageMap.put('displaySeatingChart', 'dd-hidden');
          } else { imageMap.put('displaySeatingChart', 'dd-show'); }
          
          return imageMap;
      }
      
      //Get images associated with the pricebook
      public static Map<String, Object> getOpportunityPriceBookImages(String pricebookId){
          Map<String, Object> imageMap = new Map<String, Object>();
          
          list<API_Image__c> imageList = [SELECT Id, Type__c, url__c FROM API_Image__c where Price_Book__c = :pricebookId];
          
          integer photoImageCount = 0;
          integer seatingChartImageCount = 0;
          list<string> photoImageList = new list<string>();
          list<string> seatingChartImageList = new list<string>();
          
          for(API_Image__c image: imageList){
              //Split up Photo and Seating Chart images into two separate lists because they will be used differently in the Digideck
              if(image.Type__c == 'Photo'){
                  photoImageCount++;
                  //Make each image a separate variable, but also add it to the image list for maximum Digideck flexiblility.
                  imageMap.put('priceBookPhotoUrl' + photoImageCount, image.URL__c);
                  photoImageList.add(image.URL__c);
              } else if(image.Type__c == 'Seating Chart'){
                  seatingChartImageCount++;
                  imageMap.put('priceBookSeatingChartUrl' + seatingChartImageCount, image.URL__c);
                  seatingChartImageList.add(image.URL__c);
              }
          }
          
          imageMap.put('priceBookPhotoUrls', photoImageList);
          imageMap.put('priceBookSeatingChartUrls', seatingChartImageList);
                  
          return imageMap;
      }
      
      //Determine when and when not to include DigideckContent
      public static string getProductHtml(Map<String, object> quoteLineItemMap){
          string productHtml = ' ';
          if((string)quoteLineItemMap.get('QuoteLineItem.Record_Type__c') == 'Package') {
              productHtml = (string)quoteLineItemMap.get('Product2.DigideckContent__c');
          } else if((boolean)quoteLineItemMap.get('Product2.DisplayinDigideck__c') == true && 
                    (string)quoteLineItemMap.get('QuoteLineItem.Product_Type__c') != 'Shipping and Handling' &&
                    (string)quoteLineItemMap.get('QuoteLineItem.Record_Type__c') == 'A La Carte'
          ){
            productHtml = (string)quoteLineItemMap.get('Product2.DigideckContent__c');
          } else if((string)quoteLineItemMap.get('QuoteLineItem.Record_Type__c') == 'Package Hotel'){
              productHtml = (string)quoteLineItemMap.get('Product2.DigideckContent__c');
          }
          
          if(!String.isBlank(productHtml)) { productHtml = productHtml.unescapeHtml4(); }
          
          return productHtml;
      }
      
      //Replace <a href='image/video url'>text</a> tags in html with <a href="#" data-popup-media-url="image/video url" class="tinymce-popup-image/video">text</a>
      //So images/vidoes open in a lightbox in the presenation
      public static string replaceAnchorTags(string html){
          
          if(String.isBlank(html)){
              return html;
          }
                              
          string newHtml = '';
          string[] anchorBeginningSplit = html.split('<a');
          
          integer beginningAnchorTagCount = 0;
          
          for(string stringPart: anchorBeginningSplit){
              beginningAnchorTagCount ++;
              if(beginningAnchorTagCount != anchorBeginningSplit.size()){ stringPart += '<a'; }
              
              if(!stringPart.contains('href=')){
                  newHtml += stringPart;
                continue;
              }
              
              string[] anchorEndSplit = stringPart.split('>');
              
              integer endAnchorTagCount = 0;
              for(string anchor: anchorEndSplit){
                  endAnchorTagCount++;
                  if(endAnchorTagCount != anchorEndSplit.size()){
                      anchor += '>';
                  }
                  
                  if(!anchor.contains('href=')){
                      newHtml += anchor;
                      continue;
                  }
                  integer hrefPosition = anchor.indexOf('href="') + 6;
                 
                  string contentUrl = anchor.substring(hrefPosition, anchor.indexOf('"', hrefPosition + 1));
                  
                  string id = '';
                  
                  if(anchor.contains('id=')){
                      integer idPosition = anchor.indexOf('id="') + 4;
                      id = anchor.substring(idPosition, anchor.indexOf('"', idPosition + 1));
                      id = 'id="' + id + '"';
                  }
                  
                  if(contentUrl.endsWithIgnoreCase('.svg') || contentUrl.endsWithIgnoreCase('.bmp') || 
                     contentUrl.endsWithIgnoreCase('.png') || contentUrl.endsWithIgnoreCase('.jpg') ||
                     contentUrl.endsWithIgnoreCase('.jpeg')){
                     newHtml += ' href="#" data-popup-media-url="' + contentUrl + '" class="tinymce-popup-image"' + id + '>';      
                  } else if (contentUrl.endsWithIgnoreCase('.mp4')){
                      newHtml += ' href="#" data-popup-media-url="' + contentUrl + '" class="tinymce-popup-video"' + id + '>';
                  } else{
                      newHtml += anchor;
                  }
              } 
          }
          
          //If there are anchor tags, the split removes the last > and it never gets added back
          if(!newHtml.endsWith('>')){
              newHtml += '>';
          }
         
          return newHtml;
      }
      
      //Overrides the DisplayName, DigideckContent, CheckIn and CheckOut date properties on the Hotel Stay record with Package Hotel data
      public static void addHotelStayDataToPackageHotel(Map<String, object> packageHotel){
          string quoteLineItemId = (string)packageHotel.get('QuoteLineItem.Id');
          string currencyCode = (string)packageHotel.get('Quote.CurrencyIsoCode');
          sObject[] hotelDetails = [SELECT Record_Type__c, ListPrice_Used__c, Product2.Room_Type__c, Product2.Check_In_Date__c, Product2.Check_Out_Date__c, Quantity FROM QuoteLineItem WHERE Hotel_package_id__c = :quoteLineItemId];
          
          packageHotel.put('hasHotelTransportation', false);
          packageHotel.put('hotelTransportationText', ' ');
          
          for(sObject hotelDetail: hotelDetails){
              if((string)hotelDetail.get('Record_Type__c') == 'Hotel Stay'){
                  packageHotel.put('Product2.Room_Type__c', hotelDetail.getSObject('Product2').get('Room_Type__c'));
                  packageHotel.put('QuoteLineItem.ListPrice_Used__c-formatted', SportsdigitaUtilities.formatCurrency(Integer.valueOf(hotelDetail.get('ListPrice_Used__c')), currencyCode));
                  packageHotel.put('QuoteLineItem.ListPrice_Used__c', hotelDetail.get('ListPrice_Used__c'));
                  if(packageHotel.get('HotelStayQty') == null){
                      packageHotel.put('HotelStayQty', 0);
                  }
                  
                  packageHotel.put('HotelStayQty', (integer)packageHotel.get('HotelStayQty') + ((decimal)hotelDetail.get('Quantity')).intValue());
                  
                  //There could be multiple hotel stay records. The checkout date in the Digideck should be the lowest date.
                  if(!String.isBlank(String.valueOf(hotelDetail.getSObject('Product2').get('Check_In_Date__c')))){
                      DateTime d = (Date)hotelDetail.getSObject('Product2').get('Check_In_Date__c');
                      if(packageHotel.get('Product2.Check_In_Date__c') != null && (DateTime)packageHotel.get('Product2.Check_In_Date__c') > d){ 
                          packageHotel.put('Product2.Check_In_Date__c', d); 
                          packageHotel.put('Product2.Check_In_Date__c-formatted', d.format('MM/dd/yyyy')); 
                      }
                  }
                  //There could be multiple hotel stay records. The checkin date in the Digideck should be the greatest date.
                  if(!String.isBlank(string.valueOf(hotelDetail.getSObject('Product2').get('Check_Out_Date__c')))){
                      DateTime d = (Date)hotelDetail.getSObject('Product2').get('Check_Out_Date__c');
                      if(packageHotel.get('Product2.Check_Out_Date__c') != null && (DateTime)packageHotel.get('Product2.Check_Out_Date__c') < d){
                        packageHotel.put('Product2.Check_Out_Date__c', d);
                        packageHotel.put('Product2.Check_Out_Date__c-formatted', d.format('MM/dd/yyyy'));
                      }
                  }
                  
              } else if((string)hotelDetail.get('Record_Type__c') == 'Hotel Transportation'){
                  //All the Digideck cares about is if there is a hotel transportation record.
                  //If there is, just add some custom properties to the package hotel data set.
                  packageHotel.put('hasHotelTransportation', true);
                  packageHotel.put('hotelTransportationText', 'Includes Transportation');
              }
          }
          
          return;
      }
      
      //Creates the html for the summary slides and adds it to the quoteData list.
      public static void addRollupSlideData(List<Map<String, Object>> quoteData){
          Map<String, Object> rollupData = new Map<String, Object>();
          Map<String, Map<String, object>> packageData = new Map<String, Map<String, object>>();
          String quoteTitle = '';
          String quotePrice = '';
          String salespersonEmail = '';
          // #625 Added code changes as requested
          String SalespersonName = '';
          String quoteDataString = JSON.serialize(quoteData);
          
          //Merge individual quote line items into packages
          for(Map<String, Object> item: quoteData){
                          
              quoteTitle = 'Option ' + item.get('QuoteNumber');
              
              String digideckComments = '';
              if(item.get('Quote.Digideck_Comments__c') != null){ digideckComments = (string)item.get('Quote.Digideck_Comments__c'); }
              
              if(!string.isBlank( (string)item.get('Owner.Email'))){ salespersonEmail = (string) item.get('Owner.Email'); }
  
              // #625 Added code changes as requested
              if(!string.isBlank( (string)item.get('Owner.Name'))){ SalespersonName = (string) item.get('Owner.Name'); }
                     
              if(item.get('Quote.TotalPrice') != null){
                  quotePrice = SportsdigitaUtilities.formatCurrency((Decimal)item.get('Quote.TotalPrice'), (string)item.get('Quote.CurrencyIsoCode'));
              }
              
              if((string)item.get('QuoteLineItem.Record_Type__c') == 'Package'){
                  Map<String, object> packageDataMap = packageData.get((string)item.get('QuoteLineItem.Id'));
                  if(packageDataMap == null) {
                      packageDataMap = new Map<String, object>();
                      packageData.put((string)item.get('QuoteLineItem.Id'), packageDataMap);
                  }
                  
                  string name = (string)item.get('Product2.Display_Name__c');
                  if(String.isBlank(name)){ name = (string)item.get('Product2.Name'); }
                  
                  packageDataMap.put('RecordType', 'Package');
                  packageDataMap.put('PackageQuantity', item.get('QuoteLineItem.Quantity'));
                  packageDataMap.put('PackageName', name);
                  packageDataMap.put('QuoteId', item.get('Quote.Id'));
                  packageDataMap.put('QuotePrice', quotePrice);
                  packageDataMap.put('QuoteTitle', quoteTitle);
                  packageDataMap.put('DigideckComments', digideckComments);
                  packageDataMap.put('SalespersonEmail', salespersonEmail);
                  // #625 Added code changes as requested
                  packageDataMap.put('SalespersonName', SalespersonName);
                  
              } else if((string)item.get('QuoteLineItem.Record_Type__c') == 'Package Hotel'){
                  Map<String, object> packageDataMap = packageData.get((string)item.get('QuoteLineItem.Quote_Package__c'));
                  if(packageDataMap == null) {
                      packageDataMap = new Map<String, object>();
                      packageData.put((string)item.get('QuoteLineItem.Quote_Package__c'), packageDataMap);
                  }
                  
                  string name = (string)item.get('Product2.Display_Name__c');
                  if(String.isBlank(name)){ name = (string)item.get('Product2.Name'); }
                  
                  packageDataMap.put('HotelQuantity', (integer)item.get('HotelStayQty'));
                  
                  packageDataMap.put('HotelName', name);
                  packageDataMap.put('HotelRoomType', item.get('Product2.Room_Type__c'));
              }
              else if((string)item.get('QuoteLineItem.Record_Type__c') == 'Hotel Transportation'){
                  Map<String, object> packageDataMap = packageData.get((string)item.get('QuoteLineItem.Quote_Package__c'));
                  if(packageDataMap == null) {
                      packageDataMap = new Map<String, object>();
                      packageData.put((string)item.get('QuoteLineItem.Quote_Package__c'), packageDataMap);
                  }
                  
                  string name = (string)item.get('Product2.Display_Name__c');
                  if(String.isBlank(name)){ name = (string)item.get('Product2.Name'); }
                  
                  packageDataMap.put('HotelTransportationQuantity', item.get('QuoteLineItem.Quantity'));
                  packageDataMap.put('HotelTransportationName', name);
            } else if((string)item.get('QuoteLineItem.Record_Type__c') == 'A La Carte' && 
                        (string)item.get('QuoteLineItem.Product_Type__c') != 'Shipping and Handling' &&
                        (boolean)item.get('Product2.DisplayinDigideck__c')){
                  Map<String, object> packageDataMap = packageData.get((string)item.get('QuoteLineItem.Id'));
                  if(packageDataMap == null) {
                      packageDataMap = new Map<String, object>();
                      packageData.put((string)item.get('QuoteLineItem.Id'), packageDataMap);
                  }
                  
                  string name = (string)item.get('Product2.Display_Name__c');
                  if(String.isBlank(name)){
                      name = (string)item.get('Product2.Name');
                  }
                  
                  packageDataMap.put('RecordType', 'A La Carte');
                  packageDataMap.put('PackageQuantity', item.get('QuoteLineItem.Quantity'));
                  packageDataMap.put('PackageName', name);
                  packageDataMap.put('QuoteId', item.get('Quote.Id'));
                  packageDataMap.put('QuotePrice', quotePrice);
                  packageDataMap.put('QuoteTitle', quoteTitle);
                  packageDataMap.put('DigideckComments', digideckComments);
                  packageDataMap.put('SalespersonEmail', salespersonEmail);
                  // #625 Added code changes as requested
                  packageDataMap.put('SalespersonName', SalespersonName);
              }
          }
          
          Map<String, Map<string, string>> htmlMap = new Map<String, Map<string, string>>();
          List<String> quotesWithChooseThisPackageButtonAdded = new List<String>();
          //Merge packages into quotes
          for(Map<String, Object> quotePackage: packageData.values()){
              string quoteId = (string) quotePackage.get('QuoteId');
              Map<String, String> quoteHtmlMap = htmlMap.get(quoteId);
              
              if(quoteHtmlMap == null){
                  quoteHtmlMap = new Map<string, string>();
              }
              
              string html = quoteHtmlMap.get('ProductsHtml');
              
              if(String.isBlank(html)){
                  // #625 Added code changes as requested -- START
                  String emailSubjectText = EncodingUtil.urlEncode('I want this Option: ', 'UTF-8');
                  String emailBodyText = EncodingUtil.urlEncode(',\n\nI would like to book my package!', 'UTF-8');
                  // #657 Digideck changes SportsdigitaUtilities class for moving a button position.
                  html = '<h2>' + (string) quotePackage.get('QuoteTitle') + '</h2>';
                      
                  if(!quotesWithChooseThisPackageButtonAdded.contains(quoteId))
                  { 
                    html += '<div class="quote-rollup-price">' + (string) quotePackage.get('QuotePrice') + '</div><a class="quote-rollup-quote-selection" href="mailto:' + quotePackage.get('SalespersonEmail') + '?subject=' + quotePackage.get('QuoteId') + '">Choose This Package</a>'; 
                    quotesWithChooseThisPackageButtonAdded.add(quoteId); 
                  }
                  html += '<p class="quote-rollup-comments">' + (string) quotePackage.get('DigideckComments') + '</p>';
                  // #625 Added code changes as requested -- END
              }
              if(quotePackage.get('PackageQuantity') != null)
              { 
                  html += '<div class="quote-rollup-package">' + ((decimal)quotePackage.get('PackageQuantity')).intValue() + ' — <p class="quote-rollup-package-details">' + quotePackage.get('PackageName') + '</p></div>'; 
              }
              if(!String.isBlank((string) quotePackage.get('HotelName')) && quotePackage.get('HotelQuantity') != null)
              { 
                  html += '<div class="quote-rollup-package">' + ((decimal)quotePackage.get('HotelQuantity')).intValue() + ' — <p class="quote-rollup-package-details">' + quotePackage.get('HotelName') + ': ' + quotePackage.get('HotelRoomType') + '</p></div>'; 
              }
              
              
              if(!String.isBlank((string) quotePackage.get('HotelTransportationName'))){
                  html += '<div class="quote-rollup-package">' + ((decimal)quotePackage.get('HotelTransportationQuantity')).intValue() + ' — <p class="quote-rollup-package-details">' + quotePackage.get('HotelTransportationName') + '</p></div>'; 
              }
              // #675 Digideck changes SportsdigitaUtilities class for moving a button position.
              // #738 Digideck remove this line from code, this is two remove second button.
              // string quotePriceHtml = '<div class="quote-rollup-price">' + (string) quotePackage.get('QuotePrice') + '</div><a class="quote-rollup-quote-selection" href="mailto:' + quotePackage.get('SalespersonEmail') + '?subject=' + quotePackage.get('QuoteId') + '">Choose This Package</a>';
              
              quoteHtmlMap.put('ProductsHtml', html);
              // quoteHtmlMap.put('PriceHtml', quotePriceHtml);
              htmlMap.put(quoteId, quoteHtmlMap);
          }
          
          string finalHtml = '';
          
          for(Map<String, String> quoteHtml : htmlMap.values()){
              finalHtml += '<div class="quote-rollup-details">' + quoteHtml.get('ProductsHtml') + /*quoteHtml.get('PriceHtml') +*/ '</div>';
          }
          
          Map<String, object> rollupDataMap = new Map<String, object>();
          
          rollupDataMap.put('slideType', 'OpportunityRollup');
          rollupDataMap.put('rollupHtml', finalHtml);
          
          quoteData.add(rollupDataMap);
          
      }
      
      //Get the formatted price book Id
      public static String getFormattedPriceBookId(String pricebookName) { //#904
        String strpbId = 'pb-' + pricebookName;
        if(!pricebookName.startsWith('01s')) {
            strpbId = strpbId.tolowercase();
        }
        strpbId = strpbId.trim();
        strpbId = strpbId.replaceAll( '\\s+', '-');
        return strpbId;
      }
  }