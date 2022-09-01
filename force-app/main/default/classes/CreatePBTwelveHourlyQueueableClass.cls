/**
 * @File Name          : CreatePBTwelveHourlyQueueableClass.cls
 * @Description        : checking and Creating event on every six hour
 * @Author             : mpatel@addonblue.com
 * @Group              : 
 * @Last Modified By   : fsuraitawala@addonblue.com
 * @Last Modified On   : 12-21-2021
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    4/22/2020    maptel@addonblue.com      Initial Version
**/ 
public with sharing class CreatePBTwelveHourlyQueueableClass implements Queueable, Database.AllowsCallouts{

    public Set<String> pricebookIdSet = new Set<String>();
    Public Map<string,Pricebook2> pbookMap = new Map<string,Pricebook2>();
    public Map<Integer, Product2> newProductMap = new Map<Integer, Product2>();
    public Map<Integer, Inventory_Transaction__c> transactionMap = new Map<Integer, Inventory_Transaction__c>();

    public CreatePBTwelveHourlyQueueableClass(){
        
       for(PriceBook2 priccebookObj : [Select Id,GPT_Event_Id__c,isactive,Start_Date__c,End_Date__c   from PriceBook2 where GPT_Event_Id__c !=null AND GPE_Event__c = true]){
            pricebookIdSet.add(priccebookObj.GPT_Event_Id__c);
            pbookMap.put(priccebookObj.GPT_Event_Id__c,priccebookObj );
        }
    }
    public CreatePBTwelveHourlyQueueableClass(Map<Integer, Product2> newProductMap, Map<Integer, Inventory_Transaction__c> transactionMap){
        this.newProductMap = newProductMap;
        this.transactionMap = transactionMap;
    }
    List<Integer> YearList = new List<Integer> { System.Today().Year(), System.Today().Year()+1};
    /**
    * @description  : execute method for the gpe call out
    * @author       : mpatel@addonblue.com | 4/22/2020 
    * @param        : QueueableContext context
    * @return       : void 
    **/
    public void execute(QueueableContext context) {
        try{
            if(!newProductMap.isEmpty()){
                Utility.processRecords(newProductMap.values(), 'insert');
                for(Integer keys : newProductMap.keyset()){
                    if(newProductMap.get(keys).Id != null){
                        if(transactionMap.containsKey(keys)){
                            transactionMap.get(keys).Product__c = newProductMap.get(keys).Id;
                        }
                    }
                }
                if(!transactionMap.isEmpty()){
                    Utility.processRecords(transactionMap.values(), 'insert');
                }
            }
            else{
                Map<String, CreatePBApextoJson> apexJsonMap = new Map<String, CreatePBApextoJson>();
                List<PriceBook2> pricebookList = new List<PriceBook2>();
                List<PriceBook2> UpdatepricebookList = new List<PriceBook2>();
               // List<PriceBook2> pbList = [Select Id,GPT_Event_Id__c,Start_Date__C,End_Date__C from PriceBook2 where GPT_Event_Id__c !=null AND GPE_Event__c = true];
                Integration_Setting__mdt objIntegrationSetting =  [Select Content_Type__c,Endpoint__c,Type__c,AccessToken__c from Integration_Setting__mdt where DeveloperName ='GPE_Events' and
                                                                 Is_Active__c = true LIMIT 1];
                for(Integer years : YearList){
                    System.debug('years-->'+years);
                    HttpRequest req = new HttpRequest();
                    req.setMethod(objIntegrationSetting.Type__c);
                    req.setEndpoint(objIntegrationSetting.Endpoint__c+years);
                    req.setHeader('Content-Type', objIntegrationSetting.Content_Type__c);
                    req.setHeader('Authorization', objIntegrationSetting.AccessToken__c); 
                    req.setTimeout(120000);
                    Http http = new Http();
                    HttpResponse res = http.send(req);
                    System.debug('res-->'+req);
                    System.debug('res-->'+res.getBody());
                    List<CreatePBApextoJson> ApextoJsonList = (List<CreatePBApextoJson>) JSON.deserialize(res.getBody(), List<CreatePBApextoJson>.class);
                    System.debug('ApextoJsonList-->'+ApextoJsonList);
                    if(!ApextoJsonList.isEmpty()){
                        for(CreatePBApextoJson apexJsonObj : ApextoJsonList){
                            System.debug('apexJsonObj.Id-->'+apexJsonObj.Id);
                           if(!apexJsonMap.containsKey(String.valueOf(apexJsonObj.Id)) && !pricebookIdSet.contains(String.valueOf(apexJsonObj.Id))){
                                apexJsonMap.put(String.valueOf(apexJsonObj.Id), apexJsonObj);
                                
                            }
                            else  if(pbookMap.containsKey(String.valueOf(apexJsonObj.Id))){
                            
                                 Pricebook2 pb = pbookMap.get(String.valueOf(apexJsonObj.Id));
                                 Date fromDate =  Date.valueOf(apexJsonObj.fromdate) ;
                                 Date toDate  =  Date.valueof(apexJsonObj.todate) ;
                                 boolean isupdated=false;
                                 if(pb.Start_Date__c !=fromDate){
                                    pb.Start_Date__c = fromDate; isupdated=true;
                                 }
                                 if(pb.End_Date__c !=toDate){
                                    pb.End_Date__c = toDate; isupdated=true;
                                 }
                                 if(pb.End_Date__c < Date.today() && pb.isactive == true){
                                    pb.isactive=false; isupdated=true;
                                 }
                                 else if(pb.End_Date__c > Date.today() && pb.isactive ==false){
                                  pb.isactive=true; isupdated=true;
                                 }
                                 if(isupdated){
                                     UpdatepricebookList.add(pb);
                                 }
                            }
                        }
                    }
                }
                System.debug('apexJsonMap-->'+apexJsonMap);
                for(String pricebookIdSet : apexJsonMap.keyset()){
                    system.debug('Testtt --- '+pricebookIdSet );
                    PriceBook2 pricebookObj = new PriceBook2();
                    pricebookObj.Name = 'GPE - '+apexJsonMap.get(pricebookIdSet).title;
                    pricebookObj.GPE_Event__c = true;
                    pricebookObj.GPT_Event_Id__c = pricebookIdSet;
                    pricebookObj.isActive = true;
                    if(!Test.isRunningTest()){
                        pricebookObj.Start_Date__c = Date.valueof(apexJsonMap.get(pricebookIdSet).fromdate);
                        pricebookObj.End_Date__c = Date.valueof(apexJsonMap.get(pricebookIdSet).todate);
                    }
                    pricebookObj.International_Stripe__c = true;
                    pricebookObj.Chargeable_Currencies__c = 'AUD;CAD;EUR;GBP;USD;SAR;THB';
                    pricebookList.add(pricebookObj);
                   
               
            }
                if(!pricebookList.isEmpty()){
                    System.debug('pricebookList-->'+pricebookList.size());
                    Utility.processRecords(pricebookList, 'insert');
                }
                if(!UpdatepricebookList.isEmpty()){
                    System.debug('UpdatepricebookList-->'+UpdatepricebookList.size());
                    Utility.processRecords(UpdatepricebookList, 'update');
                }
            }
        }
        catch(Exception ex){
            System.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
            Log.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
        }
    }
}