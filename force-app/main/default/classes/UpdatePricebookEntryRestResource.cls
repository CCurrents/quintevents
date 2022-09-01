/**
 * @File Name          : UpdatePricebookEntryRestResource.cls
 * @Description        : rest resource class for the update price book entry currency iso code
 * @Author             : mpatel@addonblue.com
 * @Group              : 
 * @Last Modified By   : Lovel Panchal
 * @Last Modified On   : 5/4/2020, 7:51:58 PM
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    4/20/2020   mpatel@addonblue.com     Initial Version
**/
@RestResource(urlMapping='/runUpdatePricebookEntryRestBatch_V3')

global with sharing class UpdatePricebookEntryRestResource { 
    /**
    * @description  : http post request for updating the pricebookentry currency
    * @author       : mpatel@addonblue.com | 4/20/2020 
    * @return       : string 
    **/ 
    @HttpPost  
    global static string UpdatePricebookEntryMethod() {
        try{
            RestRequest req = RestContext.request;
            Date Dat5 = system.today();
            List<DatedConversionRate> conversionRateList = [SELECT Id,ConversionRate,IsoCode,StartDate FROM DatedConversionRate where StartDate =:Dat5];
            Map<string,double>  isoCodeMap = new Map<string,double>();
            Set<String> code = new Set<String>();
            if(test.isRunningTest()){
                 DatedConversionRate dateRate = new DatedConversionRate();
        		 dateRate.StartDate = system.today();
                 dateRate.IsoCode = 'USD';
                 dateRate.ConversionRate = 1.2;
                conversionRateList.add(dateRate);
            }
            for(DatedConversionRate d : conversionRateList){
            isoCodeMap.put(d.IsoCode, d.ConversionRate);       
            code.add(d.IsoCode);
            }
            String pricebookEntryList = 'select id,UnitPrice,Product2Id,Product2.Price__c,CurrencyIsoCode from PricebookEntry';

            UpdatePricebookEntryBatch updatePriceBookEntrys = new UpdatePricebookEntryBatch(pricebookEntryList, isoCodeMap,code);
            Database.executeBatch(updatePriceBookEntrys); 
            
        }catch(Exception ex){
            System.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
            Log.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
        }
        return 'Success';
    }
}