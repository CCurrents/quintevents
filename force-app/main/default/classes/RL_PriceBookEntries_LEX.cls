/*********************************************************************************
* Controller Class: QE360V3_LeadConvertClass_LEX
----------------------------------------------------------------------------------
* Purpose/Methods: 
----------------------------------------------------------------------------------
* Unit Test: QE360V3_LeadConvertClass_Test
*********************************************************************************/
public class RL_PriceBookEntries_LEX {
    
    /****************************************************************************/
    @AuraEnabled
    public static List<PricebookEntry> getPriceBookEntries(String currentRecordId) {
        
        return [SELECT Id, Name, Pricebook2Id, Pricebook2.Name, Product2Id, UnitPrice, IsActive, UseStandardPrice, ProductCode, CurrencyIsoCode 
                FROM PricebookEntry WHERE Product2Id =:currentRecordId];
    }
}