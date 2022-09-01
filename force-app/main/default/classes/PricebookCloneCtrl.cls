/**
* @File Name          : PricebookCloneCtrl.cls
* @Description        : 
* @Author             : jthakkar@addonblue.com
* @Group              : 
* @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
* @Last Modified On   : 9/6/2020, 2:56:59 pm
* @Modification Log   : 
* Ver       Date            Author              Modification
* 1.0    4/10/2020   jthakkar@addonblue.com     Initial Version
**/
public class PricebookCloneCtrl{
    
    /**
    * @description  : Method for returning the base Url of the environment
    * @author       : jthakkar@addonblue.com
    * @param        : 
    * @return       : String
    **/  
    @AuraEnabled
    public static String fetchBaseUrl(){
        String sfurl = String.valueof(URL.getSalesforceBaseUrl().toExternalForm());
        system.debug('###'+sfurl);
        return sfurl;
    }
    
    /**
    * @description  : Method for cloning the Pricebook
    * @author       : jthakkar@addonblue.com
    * @param        : Pricebook Id
    * @return       : String
    **/
    @AuraEnabled
    public static String fetchPricebookValues(Id recordId){
        Pricebook2 oldPricebookRecord;
        Pricebook2 newPricebookRecord;
        String errorMessage='This Event name already exists. Please choose a unique name.';
        String displayMsg;
        system.debug('###pricebookId=='+recordId);        
        // Create a savepoint
        Savepoint sp = Database.setSavepoint();
        
        try {
            //PriceBook(Event) Clone            
            Map<String, Schema.SObjectField> fieldMap = Pricebook2.sObjectType.getDescribe().fields.getMap();
            // Get all of the fields on the object
            Set<String> fieldNames = fieldMap.keySet();
            String soqlQuery = 'SELECT ' + String.join(new List<String>(fieldNames), ',') + ' FROM Pricebook2 Where Id =: recordId Limit 1';
            oldPricebookRecord = Database.query(soqlQuery);
            system.debug('###'+oldPricebookRecord.Id);
            
            newPricebookRecord = new Pricebook2(); 
            newPricebookRecord = oldPricebookRecord.clone(false,true);
            
            newPricebookRecord.Name = 'Copy-'+oldPricebookRecord.Name;
            
            insert newPricebookRecord;
            
            //Clone Event Payment Terms
            List<Event_Payment_Terms__c> evePayTIn = new List<Event_Payment_Terms__c>();
            if(oldPricebookRecord != null) {
                List<Event_Payment_Terms__c> evePayTermList = new List<Event_Payment_Terms__c>([SELECT Id, Name, Event__c, Payment_Due_Date__c, Payment_Term__c FROM Event_Payment_Terms__c WHERE Price_Book__c =: oldPricebookRecord.Id]);
                if(evePayTermList.size() > 0) {
                    for(Event_Payment_Terms__c ePayTerm: evePayTermList){
                        Event_Payment_Terms__c payCopy = ePayTerm.clone(false,true);
                        payCopy.Price_Book__c = newPricebookRecord.Id;
                        evePayTIn.add(payCopy);
                    }
                    Utility.processRecords(evePayTIn, 'insert');
                }
            }
            
            //Clone Products
            List<Product2> lstNewProduct = new List<Product2>();
            if(oldPricebookRecord != null) {
                List<Product2> lstOldProduct = new List<Product2>([SELECT Id, Family, RecordTypeId, Primary_Price_Book__c, Name, Long_Description__c, Shipping_And_Handling__c, Shipping_And_Handling_Outside_US__c,
                                                                   Short_Description__c, Tax_Percentage__c, Threshold__c, IsActive, Apply_SAndH_Per_Quantity__c, Cost__c, Price__c, Margin__c, Margin_Percentage__c, Display_on_Website__c, 
                                                                   Legacy_ID__c, Type__c, Allocated__c, Do_Not_Display_Quantity_On_Contract__c, Current_Inventory__c, 
                                                                   Requires_Double_Approval__c, SKU__c, Room_Type__c, Product_Type__c, A_La_Carte__c, Threshold_for_Website__c FROM Product2 WHERE 
                                                                   Primary_Price_Book__c =: oldPricebookRecord.Id AND Auto_Generated_Product__c = false]);
                system.debug('###lstOldProduct== '+lstOldProduct);
                if(lstOldProduct.size() > 0) {
                    for(Product2 eProRec: lstOldProduct) {
                        Product2 eProCopy = eProRec.clone(false, true);
                        eProCopy.Primary_Price_Book__c = newPricebookRecord.Id;
                        eProCopy.ApexOldCloneProductId__c = eProRec.Id;
                        eProCopy.Legacy_ID__c = '';
                        lstNewProduct.add(eProCopy);
                    }
                    lstNewProduct = Utility.processRecords(lstNewProduct, 'insert');
                }
                
                Map<Id,Id> MapProOldNewId = new Map<Id, Id>();
                List<Products_Bundle__c> newPackProdRecords = new List<Products_Bundle__c>();
                
                if(lstNewProduct.size() > 0) {
                    for(Product2 eProRec: lstNewProduct) {
                        if(eProRec.ApexOldCloneProductId__c != null) {
                            MapProOldNewId.put(eProRec.ApexOldCloneProductId__c, eProRec.Id);
                        }
                    }
                }
                
                if(MapProOldNewId != null && MapProOldNewId.size() > 0) {
                    //Clone Products Bundle
                    List<Products_Bundle__c> lstProductBundle = [SELECT Id, Name, Child_Product_Record_Type__c, Child_product__c, Parent_Product__c, Type__c
                                                                 FROM Products_Bundle__c WHERE Parent_Product__c =: lstOldProduct];
                    System.debug('###lstProductBundle=='+lstProductBundle);
                    if(lstProductBundle.size() > 0) {
                        for(Products_Bundle__c obj : lstProductBundle) {
                            if(MapProOldNewId.containskey(obj.Parent_Product__c)) {
                                Products_Bundle__c objClone = obj.clone(false, true);
                                objClone.Parent_Product__c = MapProOldNewId.get(obj.Parent_Product__c);
                                newPackProdRecords.add(objClone);
                            }
                        }
                        Utility.processRecords(newPackProdRecords, 'insert');
                    }
                }
            }
            
            return newPricebookRecord.Id;
            
        } catch(DMLException e) {
            Database.rollback(sp);
            if(e.getMessage().contains(errorMessage))
                displayMsg = errorMessage;
            else
                displayMsg = e.getMessage();
            return displayMsg;            
        }
    }
}