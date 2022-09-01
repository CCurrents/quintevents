/**
 * @File Name          : ProductUpdateBatchClass.cls
 * @Description        : batch class to update gpt product
 * @Author             : mpatel@addonblue.com
 * @Group              : 
 * @Last Modified By   : fsuraitawala@addonblue.com
 * @Last Modified On   : 02-22-2022
 * @Modification Log   : 
 * Ver       Date            Author              			Modification
 * 1.0    4/30/2020     mpatel@addonblue.com     			Initial Version
 * 1.1    8/28/2020     mpatel@addonblue.com     			added some logic
 * 1.2    2/15/2022     vaibhav.khopade@addonblue.com     	for issue 1156
**/
global class ProductUpdateBatchClass implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    global String query;
    Map<Id, Product2> productUpdateMap = new Map<Id, Product2>();
    List<Inventory_Transaction__c> inventoryList = new List<Inventory_Transaction__c>();
    
    global ProductUpdateBatchClass(String query){
        this.query = query;
    }
    /**
    * @description  : start method
    * @author       : mpatel@addonblue.com | 4/30/2020 
    * @param        : Database.BatchableContext BC
    * @return       : Database.QueryLocator 
    **/
    global Database.QueryLocator start(Database.BatchableContext BC){
        Date toDate = System.today();
        return Database.getQueryLocator(query);
    }
    /**
    * @description  : execute method
    * @author       : mpatel@addonblue.com | 4/30/2020 
    * @param        : Database.BatchableContext BC
    * @param        : List<Product2> scope
    * @return       : void 
    **/
    global void execute(Database.BatchableContext BC, List<PriceBook2> scope){
        System.debug('scope-->'+scope.size());
        Set<String> eventIdSet = new Set<String>();
        Map<String, Id> mapEvent = new  Map<String, Id>();
        List<RequestResponse_Log__c> listReqRespLogs = new List<RequestResponse_Log__c>();
        for(PriceBook2 pb : scope) {
            mapEvent.put(pb.GPT_Event_Id__c, pb.Id);       
            eventIdSet.add(pb.GPT_Event_Id__c);
        }
        system.debug('eventIdSet = ' + eventIdSet);
        
        List<Product2> productList = [Select Id,  Name, isActive,Available__c, GPT_Article_Id__c, Primary_Price_Book__r.GPT_Event_Id__c, Primary_Price_Book__r.GPT_Price_Markup_Percentage__c, 
                                      GPT_Gross_Price__c, Total_Inventory__c, Current_Inventory__c, Primary_Price_Book__r.End_Date__c, Price__c, Auto_Generated_Product__c,
                                      (Select Id, Product__c, Quantity__c, Cost_Per_Quantity__c, RecordTypeId FROM Inventory_Transactions__r) 
                                       FROM Product2 WHERE Primary_Price_Book__r.GPT_Event_Id__c != null and GPT_Article_Id__c != null 
                                       AND Primary_Price_Book__c IN : scope];
        system.debug('productList = ' + productList);
        
        Map<String, Product2> productMap = new Map<String, Product2>();
        for(Product2 product : productList){
            if(!productMap.containsKey(product.GPT_Article_Id__c)){
                productMap.put(product.GPT_Article_Id__c, product);
            }
        }
        
        //#510 resolve price convert issue
        Map<String,Decimal> conversionRateByIsoCode = new Map<String,Decimal>();
        // Query all active currency types
        Map<Id, DatedConversionRate> DatedConversionRateById = new Map<Id, DatedConversionRate>([
            Select Id, IsoCode, ConversionRate, StartDate, NextStartDate From DatedConversionRate where CreatedDate = LAST_N_DAYS:5 Order By StartDate DESC ]);
            
        // Create map of conversation rate by currency iso code
        if(!Test.isrunningTest()) {
            for(DatedConversionRate dcr : DatedConversionRateById.values()) {
                if(conversionRateByIsoCode.get(dcr.IsoCode) == null){
                    conversionRateByIsoCode.put(dcr.IsoCode, dcr.ConversionRate);
                }
            }
        } else {
            conversionRateByIsoCode.put('USD',1);
            conversionRateByIsoCode.put('EUR',1);
        }
        
        try {
            Integration_Setting__mdt objIntegrationSetting =  [Select Content_Type__c,Endpoint__c,Type__c,AccessToken__c from Integration_Setting__mdt
                                                                     where DeveloperName ='GPE_Article' and Is_Active__c = true LIMIT 1];
            for(String str : eventIdSet) {
                
                HttpRequest req = new HttpRequest();
                req.setMethod(objIntegrationSetting.Type__c);
                req.setEndpoint(objIntegrationSetting.Endpoint__c+str+'/articles');
                req.setHeader('Content-Type', objIntegrationSetting.Content_Type__c);
                req.setHeader('Authorization', objIntegrationSetting.AccessToken__c); 
                Http http = new Http();
                HttpResponse res = http.send(req);

                String jsonString = String.valueOf(res.getBody());

                RequestResponse_Log__c objReqResLog = new RequestResponse_Log__c();
                ID priceBook2ID = mapEvent.get(str);
                objReqResLog.Price_Book_Event__c = priceBook2ID;
                objReqResLog.Request__c = String.valueOf(req);
                objReqResLog.Class_Name__c = 'ProductUpdateBatchClass';
                objReqResLog.Status_Code__c =  String.valueOf(res.getStatusCode());
                objReqResLog.Response__c = jsonString;
                objReqResLog.Message_Type__c = res.getStatus();
                
                System.debug('str-->'+str);
                System.debug('jsonString1-->'+jsonString);
                jsonString = jsonString.replace('currency', 'currency_isoCode');
                if(!jsonString.contains('Not found') && !jsonString.contains('[]')){
                    System.debug('jsonString2-->'+jsonString);
                    List<String> lstInfo = new List<String>();
                    //List<JSON2Apex> jsonData = (List<JSON2Apex>) JSON.deserialize(jsonString , List<JSON2Apex>.class);
                    List<JSON2Apex> jsonData = (List<JSON2Apex>) JSON2Apex.parse(jsonString);
                    if(!jsonData.isEmpty()){
                        String updateProductInfo = 'GID:Act-Avi, '; // To capture the info of active and availablity while updating product.
                        for(JSON2Apex jsonObj : jsonData){
                        //need to remove after testing
                            //jsonObj.order.max = 0;
                            if(productMap.containsKey(String.valueOf(jsonObj.Id))){
                                Decimal price = 0.00;
                                Decimal grossPrice = 0.00;
                                //1070
                                Date fromDate = Date.valueOf(jsonObj.order.fromDate);
                                Date toDate = Date.valueOf(jsonObj.order.to);
                                
                                system.debug('fromDate & Todate = ' + fromDate + ' ::: ' + toDate);
                                
                                //Check GPT_Price_Markup_Percentage__c is not null or have some value more then 0
                                if(productMap.get(String.valueOf(jsonObj.Id)).Primary_Price_Book__r.GPT_Price_Markup_Percentage__c > 0){
                                    productMap.get(String.valueOf(jsonObj.Id)).Primary_Price_Book__r.GPT_Price_Markup_Percentage__c = productMap.get(String.valueOf(jsonObj.Id)).Primary_Price_Book__r.GPT_Price_Markup_Percentage__c;
                                }
                                else{
                                    productMap.get(String.valueOf(jsonObj.Id)).Primary_Price_Book__r.GPT_Price_Markup_Percentage__c = 0.00;
                                }
                                //gross price and price calculation if GPT_Price_Markup_Percentage__c is 0 or not
                                if(productMap.get(String.valueOf(jsonObj.Id)).Primary_Price_Book__r.GPT_Price_Markup_Percentage__c == 0 ){
                                    grossPrice = jsonObj.price.gross;
                                    price = jsonObj.price.gross;
                                }
                                else{
                                    grossPrice = jsonObj.price.gross;
                                    price = jsonObj.price.gross + jsonObj.price.gross/productMap.get(String.valueOf(jsonObj.Id)).Primary_Price_Book__r.GPT_Price_Markup_Percentage__c;
                                }
                                grossPrice = grossPrice.setScale(2);
                                price = price.setScale(2);
                                
                                boolean productIsActive = jsonObj.order.max > 0 && checkProductActivation(fromDate,toDate) ? true : false; //VKHOPADE - issue 1156
                                
                                if(productMap.containsKey(String.valueOf(jsonObj.Id))){
                                if(productMap.get(String.valueOf(jsonObj.Id)).Name != jsonObj.title ||
                                 productMap.get(String.valueOf(jsonObj.Id)).GPT_Gross_Price__c != grossPrice ||
                                  productMap.get(String.valueOf(jsonObj.Id)).Price__c != price ||
                                   (productMap.get(String.valueOf(jsonObj.Id)).Current_Inventory__c != jsonObj.order.max) ||
                                   (productMap.get(String.valueOf(jsonObj.Id)).isActive != productIsActive)){ ////VKHOPADE - issue 1156
                                    
                                    system.debug('inside the loop to update Product Name/price/isActive/isAvailable');
                                    Product2 productObj = New Product2();
                                    productObj.Id = productMap.get(String.valueOf(jsonObj.Id)).Id;
                                    productObj.Name = jsonObj.title;
                                    productObj.GPT_Gross_Price__c = grossPrice.setScale(2);
                                    productObj.Price__c = price.setScale(2);
                                    //productObj.isActive = jsonObj.order.max <= 0 ? false : true ;
                                    productObj.isActive = productIsActive;
                                    //added for 1072
                                   /* if(system.today() > date.valueOf(jsonObj.order.fromDate)
                                     && system.today() < date.valueOf(jsonObj.order.to) && jsonObj.order.max > 0 ) {
                                        productObj.isActive = true;    
                                    } else {
                                        productObj.isActive = false;   
                                    } */
                                    
                                    productObj.CurrencyIsoCode = jsonObj.price.currency_isoCode;
                                    //if(jsonObj.order.max <= 10){
                                    productObj.Available__c = jsonObj.order.max <= 10 ? false : true;
                                    productObj.GPT_Active_From__c= fromDate;
                                    productObj.GPT_Active_To__c= toDate;
                                    //}

                                    // Start - To capture the Product's activity and availablity.
                                    String act = productObj.isActive == true ? 'T' : 'F';
                                    String avi = productObj.Available__c == true ? 'T' : 'F';
                                    String info = jsonObj.Id+':'+act+'-'+avi+', ';
                                    updateProductInfo = updateProductInfo + info;
                                    // Stop - To capture the Product's activity and availablity.
                                    
                                    //System.debug('productObj.CurrencyIsoCode-->'+productObj.CurrencyIsoCode);
                                    //System.debug('jsonObj.price.currency_isoCode-->'+jsonObj.price.currency_isoCode);
                                    //#510 resolve to many query issue
                                    if(productObj.CurrencyIsoCode != 'USD'){
                                        if (!String.isEmpty(jsonObj.price.currency_isoCode)) {
                                            // get values and then rate
                                            Decimal fromRate = conversionRateByIsoCode.get(jsonObj.price.currency_isoCode.toUpperCase());
                                            Decimal toRate = 1;    
                                            Decimal currencyRate = toRate/fromRate;
                                            // calculating the currency
                                            Decimal convertedRate = productObj.Price__c * currencyRate;
                                            productObj.Price__c = convertedRate.setScale(1, System.RoundingMode.HALF_UP);   
                                        }
                                        //productObj.Price__c = obj.convertCurrencyToUSD(productObj.Price__c, jsonObj.price.currency_isoCode, 1);
                                        productObj.CurrencyIsoCode = 'USD';
                                    }
                                    
                                    if(!productUpdateMap.containsKey(productObj.Id)){                                        
                                        productUpdateMap.put(productObj.Id, productObj);
                                    }
                                    /*if(productObj.CurrencyIsoCode != 'USD'){
                                        
                                        productObj.Price__c = obj.convertCurrencyToUSD(productObj.Price__c, jsonObj.price.currency_isoCode, 1);
                                        productObj.CurrencyIsoCode = 'USD';
                                    }*/
                                    /*for(Inventory_Transaction__c Itr : productMap.get(String.valueOf(jsonObj.Id)).Inventory_Transactions__r){
                                        Inventory_Transaction__c inventoryObj = new Inventory_Transaction__c();
                                        //inventoryObj = Itr;
                                        System.debug('Itr.Quantity__c-->'+Itr.Quantity__c);
                                        System.debug('jsonObj.order.max-->'+jsonObj.order.max);
                                        if(Itr.Quantity__c > jsonObj.order.max){
                                           Decimal transQut = Itr.Quantity__c - jsonObj.order.max;
                                           inventoryObj.Quantity__c = transQut * -1;
                                           inventoryObj.Product__c = Itr.Product__c;
                                           inventoryObj.RecordTypeId = Schema.SObjectType.Inventory_Transaction__c.getRecordTypeInfosByName().get('Inventory Load').getRecordTypeId();
                                           inventoryList.add(inventoryObj);
                                           System.debug('inventoryObj-->'+inventoryObj);
                                        }                                     
                                    }*/
                                    Product2 proObj = productMap.get(String.valueOf(jsonObj.Id));
                                    Inventory_Transaction__c inventoryObj = new Inventory_Transaction__c();
                                    System.debug('Itr.Quantity__c-->'+proObj.Current_Inventory__c);
                                    System.debug('jsonObj.order.max-->'+jsonObj.order.max);
                                    
                                    if(proObj.Current_Inventory__c > jsonObj.order.max){
                                       Decimal transQut = proObj.Current_Inventory__c - jsonObj.order.max;
                                       inventoryObj.Quantity__c = transQut * -1;
                                       inventoryObj.Product__c = proObj.Id;
                                       inventoryObj.RecordTypeId = Schema.SObjectType.Inventory_Transaction__c.getRecordTypeInfosByName().get('Inventory Load').getRecordTypeId();
                                       inventoryList.add(inventoryObj);
                                       System.debug('inventoryObj minus section-->'+inventoryObj);
                                    } else if(proObj.Current_Inventory__c < jsonObj.order.max){
                                       inventoryObj.Quantity__c = jsonObj.order.max - proObj.Current_Inventory__c;
                                       inventoryObj.Product__c = proObj.Id;
                                       inventoryObj.RecordTypeId = Schema.SObjectType.Inventory_Transaction__c.getRecordTypeInfosByName().get('Inventory Load').getRecordTypeId();
                                       inventoryList.add(inventoryObj);
                                       System.debug('inventoryObj plus section-->'+inventoryObj);
                                    }
                                    //System.debug('productList-->');
                                }
                                }
                                //22-Sep-21 -> Added by sagar  - start - #1062
                                productMap.remove(String.valueOf(jsonObj.Id));
                                //Added by sagar - end - #1062
                            }
                        }
                        objReqResLog.UpdateInfo__c =  String.valueOf(updateProductInfo);
                    }
                }
                listReqRespLogs.add(objReqResLog);
            }
            if(productMap != null && !productMap.values().isEmpty()) {
                for(product2 prodObj : productMap.values()) {
                    if(!prodObj.Auto_Generated_Product__c) {
                        prodObj.Available__c = false;
                        prodObj.isactive = false;
                        productUpdateMap.put(prodObj.id,prodObj);
                    }
                }
            }
            if(listReqRespLogs.size() > 0){
                System.debug('logsList-->'+listReqRespLogs);
                Utility.processRecords(listReqRespLogs, 'insert');  
            }   
        }
        catch(Exception e){
            System.debug('Exception-->'+e.getMessage()+'<--Line Number-->'+e.getLineNumber());
        }
    }
    /**
    * @description  : execute method
    * @author       : mpatel@addonblue.com | 4/30/2020 
    * @param        : Database.BatchableContext BC
    * @return       : void 
    **/
    global void finish(Database.BatchableContext BC){
        if(!productUpdateMap.Values().isEmpty()){
            GPTProductUpdateBatch batch = new GPTProductUpdateBatch(productUpdateMap);
            database.executebatch(batch,100);
        }
        if(!inventoryList.isEmpty()){
            Utility.processRecords(inventoryList, 'insert');
        }
    }

    private static Boolean checkProductActivation(Date fromDate, Date toDate){
        Boolean isActivateProduct = false;
        Date todayDate = System.now().date();
        system.debug('System.now() = ' + System.now());
        system.debug('system.today() = ' + system.today());
        system.debug('todayDate = ' + todayDate);
        system.debug('from date = ' + fromDate);
        
        if(todayDate <= toDate && todayDate >= fromDate){
            isActivateProduct = true;
        }
        return isActivateProduct;
    }
}