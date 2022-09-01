/**
 * @File Name          : GenerateGPTProduct_LEX.cls
 * @Description        : class to create GPT product for the Pricebook
 * @Author             : mpatel@addonblue.com
 * @Group              : 
 * @Last Modified By   : fsuraitawala@addonblue.com
 * @Last Modified On   : 01-13-2022
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    4/23/2020   mpatel@addonblue.com     Initial Version
**/
public with sharing class GenerateGPTProduct_LEX {
    /**
    * @description  : method call from the component and get the detail of the pricebook
    * @author       : mpatel@addonblue.com | 4/23/2020 
    * @param        : Id priceBookId
    * @return       : void 
    **/
    @AuraEnabled
    public static void priceBookObjCallOut(Id priceBookId){
        String getId = priceBookId;
        RequestResponse_Log__c objReqResLog = new RequestResponse_Log__c();
        if(getId != null){
            List<PriceBook2> pricebookObj = [Select Id,GPT_Event_Id__c,GPT_Price_Markup_Percentage__c from PriceBook2 where Id =: getId AND GPE_Event__c =: true];
            if(!pricebookObj.isEmpty()){
                Integration_Setting__mdt objIntegrationSetting =  [Select Content_Type__c,Endpoint__c,Type__c,AccessToken__c from Integration_Setting__mdt 
                                                                where DeveloperName ='GPE_Article' and Is_Active__c = true LIMIT 1];
                String eventmethods =objIntegrationSetting.Type__c;
                String eventEndPoint = objIntegrationSetting.Endpoint__c+pricebookObj[0].GPT_Event_Id__c+'/articles';
                String contentType = objIntegrationSetting.Content_Type__c;
                String Authorization = objIntegrationSetting.AccessToken__c;
                HttpResponse result = httpCallOut(eventmethods, eventEndPoint, contentType, Authorization, objReqResLog);
                
                String jsonString = String.valueOf(result.getBody());
                
                objReqResLog.Price_Book_Event__c = getId;
                objReqResLog.Response__c = jsonString.length() > 131072 ? jsonString.substring(0,131072) : jsonString;
                System.debug('###jsonString=='+jsonString);
                if(!jsonString.contains('Not found')){
                    List<Product2> product = getProductArticle(result.getBody(),pricebookObj,getId,objReqResLog);
                }
            }
        }
    }
    /**
    * @description  : method call from the component and get the detail of the pricebook
    * @author       : mpatel@addonblue.com | 4/23/2020 
    * @param        : String eventmethods
    * @param        : String eventEndPoint
    * @param        : String contentType
    * @param        : String Authorization
    * @return       : HttpResponse 
    **/
    public static HttpResponse httpCallOut(String eventmethods, String eventEndPoint, String contentType, String Authorization, RequestResponse_Log__c objReqResLog){
        HttpRequest req = new HttpRequest();
        req.setMethod(eventmethods);
        req.setEndpoint(eventEndPoint);
        req.setHeader('Content-Type', contentType);
        req.setHeader('Authorization', Authorization); 
        req.setTimeout(120000);
        Http http = new Http();
        HttpResponse res = http.send(req);

        objReqResLog.Request__c = String.valueOf(req);
        objReqResLog.Class_Name__c = 'GenerateGPTProduct_LEX';
        objReqResLog.Status_Code__c =  String.valueOf(res.getStatusCode());
        objReqResLog.Message_Type__c = res.getStatus();

        return res;
    }
    /**
    * @description  : method call from the component and get the detail of the pricebook
    * @author       : mpatel@addonblue.com | 4/23/2020 
    * @param        : String stringResponce
    * @param        : List<Pricebook2> priceBookObj
    * @param        : String getId
    * @return       : HttpResponse 
    **/
    public static List<Product2> getProductArticle(String stringResponce,List<Pricebook2> priceBookObj,String getId, RequestResponse_Log__c objReqResLog){
        List<Product2> productList = New List<Product2>();
        try{
            System.debug('stringResponce-->'+stringResponce);
            stringResponce = stringResponce.replace('currency', 'currency_isoCode');
            List<JSON2Apex> jsonData = (List<JSON2Apex>) JSON2Apex.parse(stringResponce);
            //List<JSON2Apex> jsonData = (List<JSON2Apex>) JSON.deserialize(stringResponce, List<JSON2Apex>.class);
            System.debug('No of product fetched-->'+jsonData.size());
            Map<Integer, Product2> newProductMap = new Map<Integer, Product2>();
            Map<Integer, Inventory_Transaction__c> transactionMap = new Map<Integer, Inventory_Transaction__c>();
            Integer count = 1;
            
      //#510 price conversion query added
            Map<String,Decimal> conversionRateByIsoCode = new Map<String,Decimal>();
            // Query all active currency types
            Map<Id, DatedConversionRate> DatedConversionRateById = new Map<Id, DatedConversionRate>([
                Select Id, IsoCode, ConversionRate, StartDate, NextStartDate From DatedConversionRate where CreatedDate = LAST_N_DAYS:5 Order By StartDate DESC ]);
                
            // Create map of conversation rate by currency iso code
            if(!Test.isrunningTest())
            {
                for(DatedConversionRate dcr : DatedConversionRateById.values()) {
                    if(conversionRateByIsoCode.get(dcr.IsoCode) == null){
                        conversionRateByIsoCode.put(dcr.IsoCode, dcr.ConversionRate);
                    }
                }
            }else{
                conversionRateByIsoCode.put('USD',1);
                conversionRateByIsoCode.put('EUR',1);
            }
        
            if(!jsonData.isEmpty()){
                Set<String> productId = New Set<String>();
                for(JSON2Apex jsonObj : jsonData){
                    productId.add(String.ValueOf(jsonObj.Id));                
                }
                
                List<Product2> listPro = [Select Name,GPT_Article_Id__c from Product2 where GPT_Article_Id__c IN: productId];
                System.debug('No of product found in SF: '+listPro.size());
                Map<String, Product2> productMap = New Map<String, Product2>();
                for(Product2 pp : listPro ){
                    if(!productMap.containsKey(pp.GPT_Article_Id__c)){
                        productMap.put(pp.GPT_Article_Id__c, pp);
                    }
                }
                
                Set<string> setarticleIds = New Set<string>();
                String updateProductInfo = 'GID:Act-Avi, ';
                for(JSON2Apex jsonObj : jsonData){
                        
                    if(!productMap.containsKey(String.valueOf(jsonObj.Id)) && !setarticleIds.contains(String.valueOf(jsonObj.Id))){
                        System.debug('creating product having ID: '+jsonObj.id);
                        Decimal grossPrice = 0.00;
                        grossPrice = jsonObj.price.gross;
                        System.debug('jsonObj.price.gross-->'+jsonObj.price.gross);
                        
                        Product2 product = new Product2();
                        product.Name = jsonObj.title;
                        product.Primary_Price_Book__c = priceBookObj[0].Id;
                        product.GPT_Article_Id__c = String.valueOf(jsonObj.id);
                        if(priceBookObj[0].GPT_Price_Markup_Percentage__c > 0){
                            priceBookObj[0].GPT_Price_Markup_Percentage__c = priceBookObj[0].GPT_Price_Markup_Percentage__c;
                        }
                        else{
                            priceBookObj[0].GPT_Price_Markup_Percentage__c = 0.00;
                        }
                        if(priceBookObj[0].GPT_Price_Markup_Percentage__c == 0 ){
                            product.GPT_Gross_Price__c = grossPrice;
                            product.Price__c = grossPrice;
                        }
                        else{
                            product.GPT_Gross_Price__c = grossPrice;
                            product.Price__c = grossPrice + grossPrice/priceBookObj[0].GPT_Price_Markup_Percentage__c;
                        }
                        //#714
                        Date fromDate = Date.valueOf(jsonObj.order.fromDate);
                        Date toDate = Date.valueOf(jsonObj.order.to);
                        product.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Product').getRecordTypeId();
                        product.Type__c = 'Ticket';
                        product.isActive = jsonObj.order.max > 0 && checkProductActivation(fromDate,toDate) ? true : false;
                        product.A_La_Carte__c = true;
                        product.Available__c = true;
                        product.Quantity_Per_Order_Threshold__c = 20;
                        product.CurrencyIsoCode = jsonObj.price.currency_isoCode;
                        product.GPT_Active_From__c= fromDate;
                        product.GPT_Active_To__c= toDate;
                        System.debug('jsonObj.price.currency_isoCode-->'+jsonObj.price.currency_isoCode);
                        System.debug('product.Price__c-->'+product.Price__c);

                         // Start - To capture the Product's activity and availablity.
                        String act = product.isActive == true ? 'T' : 'F';
                        String avi = product.Available__c == true ? 'T' : 'F';
                        String info = jsonObj.Id+':'+act+'-'+avi+', ';
                        updateProductInfo = updateProductInfo + info;
                        // Stop - To capture the Product's activity and availablity.
                        
      //#510 resolve Too many soql issue
                        if(product.CurrencyIsoCode != 'USD'){
                            if (!String.isEmpty(jsonObj.price.currency_isoCode)) {
                                // get values and then rate
                                Decimal fromRate = conversionRateByIsoCode.get(jsonObj.price.currency_isoCode.toUpperCase());
                                Decimal toRate = 1;    
                                Decimal currencyRate = toRate/fromRate;
                                // calculating the currency
                                Decimal convertedRate = product.Price__c * currencyRate;
                                product.Price__c = convertedRate.setScale(1, System.RoundingMode.HALF_UP);   
                            }
                            product.CurrencyIsoCode = 'USD';
                         }
                        /*if(product.CurrencyIsoCode != 'USD'){
                            DatedConversionRateHelper obj = new DatedConversionRateHelper();
                            product.Price__c = obj.convertCurrencyToUSD(product.Price__c, jsonObj.price.currency_isoCode, 1);
                            product.CurrencyIsoCode = 'USD';
                        }*/
                        setarticleIds.add(String.valueOf(jsonObj.id));
                        productList.add(product);  

                        Inventory_Transaction__c inventoryObj = new Inventory_Transaction__c();
                        inventoryObj.RecordTypeId = Schema.SObjectType.Inventory_Transaction__c.getRecordTypeInfosByName().get('Inventory Load').getRecordTypeId();
                        inventoryObj.Quantity__c = jsonObj.order.max;
                        inventoryObj.Cost_Per_Quantity__c = 0;

                        newProductMap.put(count, product);
                        transactionMap.put(count, inventoryObj);
                        count++;     
                    }
                }
                objReqResLog.UpdateInfo__c =  String.valueOf(updateProductInfo);
                insert objReqResLog;
            }
            if(!productList.isEmpty()){
                System.debug('newProductMap-->'+newProductMap);
                System.debug('transactionMap-->'+transactionMap);
                System.enqueueJob(new CreatePBTwelveHourlyQueueableClass(newProductMap, transactionMap));
            }    
        }catch(Exception ex){
            System.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
            Log.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
        }    
        return productList;
    }

    private static Boolean checkProductActivation(Date fromDate, Date toDate){
        Boolean isActivateProduct = false;
        Date todayDate = System.now().date();
        System.debug('fromDate: '+fromDate);
        System.debug('toDate: '+toDate);
        if(todayDate <= toDate && todayDate >= fromDate){
            isActivateProduct = true;
        }
        return isActivateProduct;
    }
}