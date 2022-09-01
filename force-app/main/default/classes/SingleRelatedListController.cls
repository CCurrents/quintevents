public with sharing class SingleRelatedListController {
    @AuraEnabled
    public static List<Api_Image__c> initData(Id recordId){
        List<Api_Image__c> apiImage =[Select Id,Name,Type__c,URL__c from Api_Image__c where Event__c =: recordId OR Product__c =: recordId ORDER BY Name ASC];
        return apiImage;
    }
    @AuraEnabled
    public static RecordType getRecordType(String recordId){  //get the record type of the Api image object
        String recordTypeName;
        List<RecordType> proRecordType =[SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'api_Image__c'];
        Integer j = 0;
        if(proRecordType.size()>0){
            for(Integer i = 0;i<=proRecordType.size();i++){
                if('01t' == recordId.substring(0,3) && proRecordType[i].Name == 'Image for Product'){//LEFT(recordId, 3)
                    recordTypeName= proRecordType[i].Name;
                    j = i;
                    break;
                }
                if('a0b' == recordId.substring(0,3) && proRecordType[i].Name == 'Image for Event'){//LEFT(recordId, 3)
                    recordTypeName= proRecordType[i].Name;
                    j = i;
                    break;
                }
            }
        }
        return proRecordType[j];
    }
    /*@AuraEnabled
    public static List<String> getPickListValue()
    {
        List<String> options = new List<String>();
            
        Schema.DescribeFieldResult fieldResult = Api_Image__c.Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
        for( Schema.PicklistEntry f : ple)
        {
            options.add(f.getLabel());
        }       
        return options;
    }
    @AuraEnabled
    public static List<CurrencyType> getCurrencytValue()
    {
        list<CurrencyType> currencyList = [SELECT ISOCode, ConversionRate FROM CurrencyType WHERE IsActive=TRUE];
        system.debug(currencyList);
        return currencyList;
    }*/
    @AuraEnabled
    public static List<Api_Image__c> deleteRecord(Id recordId,Id parentId){
        Delete [Select id from Api_Image__c where id=:recordId];
        
        return initData(parentId);
    }
}