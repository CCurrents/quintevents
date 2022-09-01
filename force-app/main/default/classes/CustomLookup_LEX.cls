/**
 * @File Name          : CustomLookup_LEX.cls
 * @Description        : 
 * @Author             : fsuraitawala@addonblue.com
 * @Group              : 
 * @Last Modified By   : fsuraitawala@addonblue.com
 * @Last Modified On   : 2/20/2020, 3:11:00 AM
 * @Modification Log   : 
 * @Unit Test          : Quote_Contact_Tab_LEX_Test
 * Ver       Date            Author                     Modification
 * 1.0     06/29/2020     fsuraitawala@addonblue.com    Initial Version
**/
public with sharing class CustomLookup_LEX {
    @AuraEnabled
    public static List<sObject> GetRecentRecords(String ObjectName, List<String> ReturnFields, Integer MaxResults) {
        List<Id> recentIds = new List<Id>();
        for(RecentlyViewed recent : [SELECT Id FROM RecentlyViewed WHERE Type = :ObjectName ORDER BY LastViewedDate DESC LIMIT :MaxResults]) {
            recentIds.add(recent.Id);
        }
        String sQUERY = 'SELECT Id, ';
        if (ReturnFields != null && ReturnFields.Size() > 0) {
            sQuery += String.join(ReturnFields, ',');
        } else {
            sQuery += 'Name';   
        }
        if(ObjectName == 'Account') {
            sQuery += ' FROM Contact WHERE AccountId IN :recentIds';
        } else {
            sQuery += ' FROM ' + ObjectName + ' WHERE Id IN :recentIds';
        }
        List<sObject> searchResult = Database.query(sQuery);
        
        return searchResult;
    }
    @AuraEnabled
    public static String createACRelationShip(String AccountId, Contact newCreatedContact) {
        try {
            AccountContactRelation objACR = new AccountContactRelation();
            objACR.AccountId = AccountId;
            objACR.ContactId = newCreatedContact.Id;
            insert objACR;
            return objACR.Id;
        } catch(Exception ex) {
            System.debug(ex.getMessage());
            return ex.getMessage();
        }
    }
}