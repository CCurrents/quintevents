global class GPT_ProductUpdateBatchClass implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    global final Map<String, Product2> productMap;
        
    global GPT_ProductUpdateBatchClass(Map<String, Product2> q){
        productMap = q;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('Select Id,GPT_Article_Id__c,Event__r.GPT_Event_Id__c,Event__r.GPT_Price_Markup_Percentage__c,GPT_Gross_Price__c,Price__c,Name from Product2 where Event__r.GPT_Event_Id__c != null and GPT_Article_Id__c != null');
    }

    global void execute(Database.BatchableContext BC, List<Product2> scope){
     
    List<Product2> productList = new List<Product2>();
    Set<String> eventIdSet = new Set<String>();
    
    for(Product2 product : scope){
        //if(product.Event__r.GPT_Event_Id__c=='3897')
        eventIdSet.add(product.Event__r.GPT_Event_Id__c);
    }
    System.debug('eventIdSet.size()-->'+eventIdSet.size());
    try{
    for(String str : eventIdSet){
      
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint('https://www.gpt-worldwide.com/api/v1.1/gpe/en/event/'+str+'/articles');
        req.setHeader('Content-Type', 'text/xml');
        req.setHeader('Authorization', 'Bearer Qe1v0yrj9XTDwJHkWNF3Mu2lLQzlvz6swblTQJleHHncpMdqL7v6S3bmzAxu'); 
        Http http = new Http();
        HttpResponse res = http.send(req);

        String jsonString = String.valueOf(res.getBody());
        System.debug('str-->'+str);
        System.debug('jsonString1-->'+jsonString);
        jsonString = jsonString.replace('currency', 'currency_isoCode');
        if(!jsonString.contains('Not found') && !jsonString.contains('[]')){
            System.debug('jsonString2-->'+jsonString);
            List<JSON2Apex> jsonData = (List<JSON2Apex>) JSON.deserialize(jsonString , List<JSON2Apex>.class);
            if(!jsonData.isEmpty()){                
                List<DatedConversionRate> datedConversionRateList = [SELECT Id,ConversionRate,IsoCode,StartDate FROM DatedConversionRate where IsoCode = 'USD'  order by StartDate DESC limit 1];
                for(JSON2Apex jsonObj : jsonData){
                    System.debug('jsonObj max-->'+jsonObj.Price);
                    if(productMap.containsKey(String.valueOf(jsonObj.Id))){
                    
                        Decimal price = 0.00;
                        Decimal grossPrice = 0.00;
                        
                        //Check GPT_Price_Markup_Percentage__c is not null or have some value more then 0
                        if(productMap.get(String.valueOf(jsonObj.Id)).Event__r.GPT_Price_Markup_Percentage__c > 0){
                            productMap.get(String.valueOf(jsonObj.Id)).Event__r.GPT_Price_Markup_Percentage__c = productMap.get(String.valueOf(jsonObj.Id)).Event__r.GPT_Price_Markup_Percentage__c;
                        }
                        else{
                            productMap.get(String.valueOf(jsonObj.Id)).Event__r.GPT_Price_Markup_Percentage__c = 0.00;
                        }
                        
                        //gross price and price calculation if GPT_Price_Markup_Percentage__c is 0 or not
                        if(productMap.get(String.valueOf(jsonObj.Id)).Event__r.GPT_Price_Markup_Percentage__c == 0 ){    
                            if(jsonObj.price.currency_isoCode != 'USD'){
                                grossPrice = GPT_EventCallOut_LEX.convertProductPricetoUSD(jsonObj.price.gross,datedConversionRateList);
                                price = grossPrice;
                            }
                            else{                        
                                grossPrice = jsonObj.price.gross;
                                price = jsonObj.price.gross;
                            }
                        }
                        else{
                            if(jsonObj.price.currency_isoCode != 'USD'){
                                grossPrice = GPT_EventCallOut_LEX.convertProductPricetoUSD(jsonObj.price.gross,datedConversionRateList);
                                price = grossPrice + grossPrice/productMap.get(String.valueOf(jsonObj.Id)).Event__r.GPT_Price_Markup_Percentage__c;
                            }
                            else{
                                grossPrice = jsonObj.price.gross;
                                price = jsonObj.price.gross + jsonObj.price.gross/productMap.get(String.valueOf(jsonObj.Id)).Event__r.GPT_Price_Markup_Percentage__c;
                            }
                        }
                       // QE_DatedConversionRateHelper datedConversionRateHelper = new QE_DatedConversionRateHelper();
                        if(productMap.get(String.valueOf(jsonObj.Id)).Name != jsonObj.title ||
                            productMap.get(String.valueOf(jsonObj.Id)).GPT_Gross_Price__c != grossPrice || 
                            productMap.get(String.valueOf(jsonObj.Id)).Price__c != price ||
                            jsonObj.order.max == 0){
                                                       
                            Product2 productObj = New Product2();
                            productObj.Id = productMap.get(String.valueOf(jsonObj.Id)).Id;
                            productObj.Name = jsonObj.title;
                            productObj.GPT_Gross_Price__c = grossPrice.setScale(2);
                            productObj.Price__c = price.setScale(2);
                            productObj.isActive = jsonObj.order.max == 0 ? false : true ;
                            //productObj.CurrencyIsoCode = jsonObj.price.currency_isoCode;
                            productObj.CurrencyIsoCode = 'USD';
                            productList.add(productObj);
                            System.debug('productList-->'+productList);
                        }
                    }
                }
            }
        }
        break;
       }
       if(!productList.isEmpty()){
           update productList;
       }
       }
       catch(Exception e){
           System.debug('Exception-->'+e.getMessage());
       }
   }

   global void finish(Database.BatchableContext BC){
   }
}