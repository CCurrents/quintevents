public class GPT_EventCallOut_LEX{
   @AuraEnabled
    public static void eventObjCallOut(Id eventId){
        String getId = eventId;//ApexPages.currentPage().getParameters().get('id');
        if(getId != null){
            List<QE360_Event__c> eventObj = [Select Id,GPT_Event_Id__c,GPT_Price_Markup_Percentage__c from QE360_Event__c where Id =: getId AND GPE_Event__c =: true];
            if(!eventObj.isEmpty()){
                String eventmethods ='GET';
                String eventEndPoint = 'https://www.gpt-worldwide.com/api/v1.1/gpe/en/event/'+eventObj[0].GPT_Event_Id__c+'/articles';
                HttpResponse result = httpCallOut(eventmethods,eventEndPoint);
                
                String jsonString = String.valueOf(result.getBody());
                System.debug('###jsonString=='+jsonString);
                if(!jsonString.contains('Not found')){
                    List<Product2> product = eventGetArticle(result.getBody(),eventObj,getId);
                }
                /*
                PageReference pagess = New PageReference('/'+getId);
                pagess.setRedirect(true);
                return pagess;*/
            }
        }
       //return null;       
    }
    
    public static HttpResponse httpCallOut(String eventmethods, String eventEndPoint){
        HttpRequest req = new HttpRequest();
        req.setMethod(eventmethods);
        req.setEndpoint(eventEndPoint);
        req.setHeader('Content-Type', 'text/xml');
        req.setHeader('Authorization', 'Bearer Qe1v0yrj9XTDwJHkWNF3Mu2lLQzlvz6swblTQJleHHncpMdqL7v6S3bmzAxu'); 
        req.setTimeout(120000);
        Http http = new Http();
        HttpResponse res = http.send(req);
        return res;
    }
    
    public static List<Product2> eventGetArticle(String stringResponce,List<QE360_Event__c> eventObj,String getId){
        List<Product2> productList = New List<Product2>();
        try{
        stringResponce = stringResponce.replace('currency', 'currency_isoCode');
        List<JSON2Apex> jsonData = (List<JSON2Apex>) JSON.deserialize(stringResponce, List<JSON2Apex>.class);
        
        
        if(!jsonData.isEmpty()){
            Set<String> productId = New Set<String>();
            for(JSON2Apex jsonObj : jsonData){
                productId.add(String.ValueOf(jsonObj.Id));                
            }

            List<Product2> listPro = [Select Name,GPT_Article_Id__c from Product2 where GPT_Article_Id__c IN: productId];

            Map<String, Product2> productMap = New Map<String, Product2>();
            for(Product2 pp : listPro ){
                if(!productMap.containsKey(pp.GPT_Article_Id__c)){
                    productMap.put(pp.GPT_Article_Id__c, pp);
                }
            }
                        
            Set<string> setarticleIds = New Set<string>();
            List<DatedConversionRate> datedConversionRateList = [SELECT Id,ConversionRate,IsoCode,StartDate FROM DatedConversionRate where IsoCode = 'USD'  order by StartDate DESC limit 1];
            
            for(JSON2Apex jsonObj : jsonData){
            
                if(!productMap.containsKey(String.valueOf(jsonObj.Id)) && !setarticleIds.contains(String.valueOf(jsonObj.Id))){
                    System.debug('jsonObj-->'+jsonObj);
                    Decimal grossPrice = 0.00;
                    if(jsonObj.price.currency_isoCode != 'USD'){
                        grossPrice = convertProductPricetoUSD(jsonObj.price.gross,datedConversionRateList);
                    }else{
                        grossPrice = jsonObj.price.gross;
                    }
                    
                    Product2 product = new Product2();
                    product.Name = jsonObj.title;
                    System.debug('jsonObj.title-->'+jsonObj.title);
                    product.Event__c = eventObj[0].Id;
                    product.GPT_Article_Id__c = String.valueOf(jsonObj.id);
                    if(eventObj[0].GPT_Price_Markup_Percentage__c > 0){
                        eventObj[0].GPT_Price_Markup_Percentage__c = eventObj[0].GPT_Price_Markup_Percentage__c;
                    }
                    else{
                        eventObj[0].GPT_Price_Markup_Percentage__c = 0.00;
                    }
                    if(eventObj[0].GPT_Price_Markup_Percentage__c == 0 ){
                        product.GPT_Gross_Price__c = grossPrice;
                        product.Price__c = grossPrice;
                    }
                    else{
                        product.GPT_Gross_Price__c = grossPrice;
                        product.Price__c = grossPrice + grossPrice/eventObj[0].GPT_Price_Markup_Percentage__c;
                    }
                    product.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Products').getRecordTypeId();
                    product.Type__c = 'Ticket';
                    product.isActive = jsonObj.order.max == 0 ? false : true;
                    product.A_La_Carte__c = true;
                    product.Available__c = true;
                    product.Quantity_Per_Order_Threshold__c = 20;
                    //product.CurrencyIsoCode = jsonObj.price.currency_isoCode;
                    product.CurrencyIsoCode = 'USD';
                    setarticleIds.add(String.valueOf(jsonObj.id));
                    productList.add(product);   
                                   
                }
                //break;
            }
        }
        if(!productList.isEmpty()){
            System.enqueueJob(new GPT_CreateEventSixHourlyQueueableClass(productList, productList));
           
        }    
        }catch(Exception e){
            System.debug('Exception-->'+e.getMessage()+'-->'+e.getLineNumber());
        }    
        return productList;
    }
    
    public static Decimal convertProductPricetoUSD(Decimal decprice, List<DatedConversionRate> datedConversionRateList){         
        Decimal finalprice = 0.00;
        if(!datedConversionRateList.isEmpty()){
            finalprice = datedConversionRateList[0].ConversionRate * decprice;
        }
        return finalprice;
    }
}