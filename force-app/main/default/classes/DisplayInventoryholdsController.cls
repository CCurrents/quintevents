/**
 * @File Name          : DisplayInventoryholdsController.cls
 * @Description        : This class use for displaying inventory holds.
 * @Author             : sagarj@addonblue.com
 * @Group              : 
 * @Last Modified By   : 
 * @Last Modified On   : 
 * @Modification Log   : 
 * Ver       Date            Author                  Modification
 * 1.0    26/09/2021   sagarj@addonblue.com     Initial Version
**/
public class DisplayInventoryholdsController {
    
    /****************************************************************************/
    @AuraEnabled
    public static List<Inventory_Transaction__c> getInventoryHolds(String productid) {
   
        
        String sQuery = 'SELECT Id';
        List<Schema.FieldSetMember> fieldSetMemberList =  readFieldSet('InventoryHoldDisplayFields','Inventory_Transaction__c');
        for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList)
        {
            system.debug('API Name ====>' + fieldSetMemberObj.getFieldPath()); //api name
           
            sQuery = sQuery+ ','+fieldSetMemberObj.getFieldPath();
        }
        sQuery = sQuery + ' FROM Inventory_Transaction__c where Product__c=:productid AND RecordType.developername = \'Inventory_Hold\'';
      
        system.debug('@@@sQuery 1111:'+sQuery);
        system.debug(Database.query(sQuery));
        return Database.query(sQuery);
    }
    
    /****************************************************************************/
    @AuraEnabled
    public static List<Inventory_Transaction__c> deleteInventoryHolds(String productId,  List<Inventory_Transaction__c> lstinventoryholds) {
        if(lstinventoryholds.size() > 0) {
            delete lstinventoryholds;
        }
        
        return getInventoryHolds(productId);
    }

    @AuraEnabled
    public static List<fieldWrapper> fetchfieldconfiguration(string fieldsetname) {
        List<fieldWrapper> fieldWrapperlist = new List<fieldWrapper> ();
        List<Schema.FieldSetMember> fieldSetMemberList =  readFieldSet(fieldsetname,'Inventory_Transaction__c');
        for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList)
        {
            fieldWrapper fw = new fieldWrapper();
            fw.key = fieldSetMemberObj.getFieldPath();
            fw.label = fieldSetMemberObj.getLabel();
            fieldWrapperlist.add(fw);
        }
        return fieldWrapperlist;
    }

    public class fieldWrapper {
        @AuraEnabled
        public string key {get;set;}
        @AuraEnabled
        public string label {get;set;}

    }

    public static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName)
    {
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();

        //system.debug('====>' + DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName));

        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);

        //List<Schema.FieldSetMember> fieldSetMemberList =  fieldSetObj.getFields();
        //system.debug('fieldSetMemberList ====>' + fieldSetMemberList);  
        return fieldSetObj.getFields(); 
    }  

    @AuraEnabled
    public static id getrecordtypeid(String recordtypedevelopername){
       Recordtype rc = [select id from RecordType where developername=:recordtypedevelopername AND SObjectType='Inventory_Transaction__c'];
       return rc.id;
    }
    
}