/**
 * @File Name          : CreatePriceBookApiImage.cls
 * @Description        : 
 * @Author             : mpatel@addonblue.com
 * @Group              : 
 * @Last Modified By   : mpatel@addonblue.com
 * @Last Modified On   : 4/9/2020, 3:23:57 PM
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    4/13/2020   mpatel@addonblue.com     Initial Version
**/
public class CreatePBAndProductApiImage{
    /**
    * @description  : get data of the api image
    * @author       : mpatel@addonblue.com | 2/28/2020 
    * @param        : Id recordId
    * @return       : List<Api_Image__c>
    **/
    @AuraEnabled
    public static List<Api_Image__c> getApiImageData(Id recordId){
        List<Api_Image__c> apiImage =[Select Id,Name,Type__c,URL__c from Api_Image__c where Price_Book__c =: recordId OR Product__c =: recordId ORDER BY Name ASC];
        return apiImage;
    }
    /**
    * @description  : get recordtype name
    * @author       : mpatel@addonblue.com | 2/28/2020 
    * @param        : String recordId
    * @return       : RecordType
    **/
    @AuraEnabled
    public static RecordType getRecordType(String recordId){  //get the record type of the Api image object
        String recordTypeName;
        List<RecordType> proRecordType =[SELECT Id, Name, SobjectType,DeveloperName FROM RecordType WHERE SobjectType = 'api_Image__c'];
        Integer j = 0;
        if(!proRecordType.isEmpty()){
            for(Integer i = 0;i<=proRecordType.size();i++){
                if('01t' == recordId.substring(0,3) && proRecordType[i].DeveloperName == 'Image_for_Product'){//LEFT(recordId, 3)
                    recordTypeName= proRecordType[i].Name;
                    j = i;
                    break;
                }
                if('01s' == recordId.substring(0,3) && proRecordType[i].DeveloperName == 'Image_for_Pricebook'){//LEFT(recordId, 3)
                    recordTypeName= proRecordType[i].Name;
                    j = i;
                    break;
                }
            }
        }
        return proRecordType[j];
    }
    /**
    * @description  : delete api record
    * @author       : mpatel@addonblue.com | 2/28/2020 
    * @param        : Id recordId
    * @param        : Id parentId
    * @return       : List<Api_Image__c>
    **/
    @AuraEnabled
    public static List<Api_Image__c> deleteRecord(Id recordId, Id parentId){
        Delete [Select id from Api_Image__c where id=:recordId];
        
        return getApiImageData(parentId);
    }
}