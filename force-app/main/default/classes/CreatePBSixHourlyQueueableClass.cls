/**
 * @File Name          : CreatePBSixHourlyQueueableClass.cls
 * @Description        : checking and Creating event on every six hour
 * @Author             : mpatel@addonblue.com
 * @Group              : 
 * @Last Modified By   : mpatel@addonblue.com
 * @Last Modified On   : 4/22/2020, 3:11:00 AM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    4/22/2020    maptel@addonblue.com      Initial Version
**/
public with sharing class CreatePBSixHourlyQueueableClass implements Queueable, Database.AllowsCallouts{

    public final Set<String> pricebookIdSet;
    public List<Product2> ProductIdSet = new List<Product2>();
    public List<Product2> ProductIdSet1 = new List<Product2>();

    public CreatePBSixHourlyQueueableClass(Set<String> pricebookIdSet){
        this.pricebookIdSet = pricebookIdSet;
    }
    public CreatePBSixHourlyQueueableClass(List<Product2> ProductIdSet, List<Product2> ProductIdSet1){
        this.ProductIdSet = ProductIdSet;
        this.ProductIdSet1 = ProductIdSet1;
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
            if(!ProductIdSet.isEmpty()){
                Database.SaveResult[] InsertProductList = Database.insert(ProductIdSet, false);
            }
            else{
                Map<String, CreatePBApextoJson> apexJsonMap = new Map<String, CreatePBApextoJson>();
                List<PriceBook2> pricebookList = new List<PriceBook2>();
                Integration_Setting__mdt objIntegrationSetting =  [Select Content_Type__c,Endpoint__c,Type__c,AccessToken__c from Integration_Setting__mdt where DeveloperName ='GPE_Events' and
                                                                 Is_Active__c = true LIMIT 1];
                for(Integer years : YearList){
                    HttpRequest req = new HttpRequest();
                    req.setMethod(objIntegrationSetting.Type__c);
                    req.setEndpoint(objIntegrationSetting.Endpoint__c+years);
                    req.setHeader('Content-Type', objIntegrationSetting.Content_Type__c);
                    req.setHeader('Authorization', objIntegrationSetting.AccessToken__c); 
                    req.setTimeout(120000);
                    Http http = new Http();
                    HttpResponse res = http.send(req);

                    List<CreatePBApextoJson> ApextoJsonList = (List<CreatePBApextoJson>) JSON.deserialize(res.getBody(), List<CreatePBApextoJson>.class);
                    
                    if(!ApextoJsonList.isEmpty()){
                        for(CreatePBApextoJson apexJsonObj : ApextoJsonList){
                            if(!apexJsonMap.containsKey(String.valueOf(apexJsonObj.Id)) && !pricebookIdSet.contains(String.valueOf(apexJsonObj.Id))){
                                apexJsonMap.put(String.valueOf(apexJsonObj.Id), apexJsonObj);
                            }
                        }
                    }
                }

                for(String pricebookIdSet : apexJsonMap.keyset()){
                    
                    PriceBook2 pricebookObj = new PriceBook2();
                    pricebookObj.Name = 'GPE - '+apexJsonMap.get(pricebookIdSet).title;
                    pricebookObj.GPE_Event__c = true;
                    pricebookObj.GPT_Event_Id__c = pricebookIdSet;
                    pricebookObj.isActive = true;
                    pricebookObj.Start_Date__c = Date.valueof(apexJsonMap.get(pricebookIdSet).fromdate);
                    pricebookObj.End_Date__c = Date.valueof(apexJsonMap.get(pricebookIdSet).todate);
                    pricebookList.add(pricebookObj);
                }
                if(!pricebookList.isEmpty()){
                    Utility.processRecords(pricebookList, 'insert');
                }
            }
        }
        catch(Exception ex){
            System.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
            Log.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
        }
    }
}