@RestResource(urlMapping='/runUpdatePricebookEntryRestBatch')

global with sharing class QE_UpdatePricebookEntryRestResource {
     @HttpPost  
     global static string UpdatePricebookEntryMethod() {
      RestRequest req = RestContext.request;
      //String objectName = req.Headers.get('objectName');
      Date Dat5 = system.today();
      List<DatedConversionRate> conversionRateList = [SELECT Id,ConversionRate,IsoCode,StartDate FROM DatedConversionRate where StartDate =:Dat5];
      Map<string,double>  isoCodeMap = new Map<string,double>();
      Set<String> code = new Set<String>();
      for(DatedConversionRate d : conversionRateList){
        isoCodeMap.put(d.IsoCode, d.ConversionRate);       
        code.add(d.IsoCode);
      }
      String pricebookEntryList;
      //if(!isoCodeMap.isempty()){
        pricebookEntryList = 'select id,UnitPrice,Product2Id,Product2.Price__c,CurrencyIsoCode from PricebookEntry';// where CurrencyIsoCode in:isoCodeMap.keyset()';
      //}

      QE_UpdatePricebookEntryBatch uPBE = new QE_UpdatePricebookEntryBatch(pricebookEntryList, isoCodeMap,code);
      Database.executeBatch(uPBE); 
      return 'Success';
  }
  
}