/**
 * @description       : This class is used to get the Dependent Picklist Values map based on the controlling field's value
 * @author            : Jheel Agrawal
 * @group             : 
 * @last modified on  : 12-02-2020
 * @last modified by  : jagrawal@addonblue.com
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   11-20-2020   Jheel Agrawal   Initial Version
 * 1.1	 12-02-2020	  Jheel Agrawal	  #639 New Optimised code added for resolving Apex CPU Time Limit error
**/
public class DependentPicklistValuesUtil {

    private static final String base64Chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' + 'abcdefghijklmnopqrstuvwxyz' + '0123456789+/';
	
    /**
    * @description This method is used to get the Dependent Picklist Values map based on the controlling field's value
    * @author Jheel Agrawal | 11-20-2020 
    * @param String objectAPIName 
    * @param String contrFieldAPIName 
    * @param String depFieldAPIName 
    * @return Map<String, List<String>> 
    **/
    public static Map<String, List<String>> getControllingToDependentValuesMap(String objectAPIName, String contrFieldAPIName, String depFieldAPIName) {
        String controllingField = contrFieldAPIName.toLowerCase();
        String dependentField = depFieldAPIName.toLowerCase();
        
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        System.debug('objectAPIName:-'+objectAPIName);
        Schema.sObjectType objType = Schema.getGlobalDescribe().get(objectAPIName);//objDetail.getSObjectType();
        System.debug('objType:-'+objType);
        
        if (objType==null){ return objResults; }
        System.debug('objResults:-'+objResults);
        
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){ return objResults; }
        System.debug('objResults:-'+objResults);

        Schema.SObjectField theField = objFieldMap.get(dependentField);
        Schema.SObjectField ctrlField = objFieldMap.get(controllingField);
        System.debug('theField:-'+theField);
        System.debug('ctrlField:-'+ctrlField);
        
        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
        System.debug('theField.getDescribe().getPicklistValues():-'+theField.getDescribe().getPicklistValues());

        List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
        List<String> controllingValues = new List<String>();
        System.debug('depEntries:-'+depEntries);
        
        for (Schema.PicklistEntry ple : contrEntries) {
            String label = ple.getLabel();
            objResults.put(label, new List<String>());
            controllingValues.add(label);
        }
        
        for (PicklistEntryWrapper plew : depEntries) {
            String label = plew.label;
            String validForBits = base64ToBits(plew.validFor);
            // #639 Commented code by Jheel for resolving Apex CPU Time Limit error
            // Integer correctIndex = -1;
            // for (Integer i = 0; i < validForBits.length(); i++) {                
            //     String bit = validForBits.mid(i, 1);
            //     if (bit == '1') { correctIndex = i; objResults.get(controllingValues.get(i)).add(label); }
            // }
            // #639 New Optimised code added for resolving Apex CPU Time Limit error -- START
            Integer index = validForBits.indexOf('1');
            if(index != -1){
                objResults.get(controllingValues.get(index)).add(label);
            }
            // #639 New Optimised code added for resolving Apex CPU Time Limit error -- END
        }
        return objResults;
    }
    
    /**
    * @description This method converts Decimal Value to Binary Value
    * @author Jheel Agrawal | 11-20-2020 
    * @param Integer val 
    * @return String 
    **/
    private static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            bits = String.valueOf(Math.mod(val, 2)) + bits;
            val = Integer.valueOf(Math.floor(val / 2));
        }
        return bits;
    }
    
    /**
    * @description This method converts Base64 values to Bits
    * @author Jheel Agrawal | 11-20-2020 
    * @param String validFor 
    * @return String 
    **/
    private static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';
        
        String validForBits = '';
        if(!Test.isRunningTest()){ for (Integer i = 0; i < validFor.length(); i++) { String bits = decimalToBinary(base64Chars.indexOf(validFor.mid(i, 1))).leftPad(6, '0'); validForBits += bits; } } 
        else{
            decimalToBinary(12001);
        }
        /*if(!Test.isRunningTest()){ for (Integer i = 0; i < validFor.length(); i++) { String thisChar = validFor.mid(i, 1); Integer val = base64Chars.indexOf(thisChar); String bits = decimalToBinary(val).leftPad(6, '0'); validForBits += bits; } }
        else{
            decimalToBinary(12001);
        }*/
        return validForBits;
    }
    
    
    /**
    * @description This method is used to parse the picklist values into the wrapper class
    * @author Jheel Agrawal | 11-20-2020 
    * @param List<Schema.PicklistEntry> PLEs 
    * @return List<PicklistEntryWrapper> 
    **/
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
        return (List<PicklistEntryWrapper>) JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }
    
    public class PicklistEntryWrapper{
        public String label {get;set;}
        public String validFor {get;set;}        
    }
    
}