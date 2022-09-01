/**
 * @File Name          : SearchAccountLeadController.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 4/13/2020, 4:18:39 PM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    4/13/2020   jagrawal@addonblue.com     Initial Version
**/
public with sharing class SearchAccountLeadController {

  @AuraEnabled
  public static list<Account> fetchAccounts() {
     List<Account> lstAccount = new List<Account>([SELECT ID, Name, CreatedById, Event_Interest_Picklist_PB__pr.Name, Primary_Contact__c, PersonEmail, AccountNumber, 
                                                  FirstName, LastName FROM Account WHERE OwnerId=:UserInfo.getUserId() LIMIT 700]);
     Return lstAccount;
   }

  @AuraEnabled
  public static list<Lead> fetchLead() {
      List<Lead> lstLead = [SELECT ID, FirstName, LastName, Name, CreatedById, From_Lead_Convert__c, 
                            Phone, Status, Event_Interest_Picklist_PB__c, Event_Interest_Picklist__r.Name 
                            FROM Lead WHERE OwnerId=:UserInfo.getUserId() LIMIT 700];
      Return lstLead;
   }

   @AuraEnabled
    public static List < Account > serchAccounts(String searchKeyWord) {
        String searchKey = searchKeyWord + '%';
        List < Account > returnAccList = new List < Account > ();
        List < Account > lstOfAccount = [SELECT ID, Name, CreatedById, Event_Interest_Picklist_PB__pr.Name, Primary_Contact__c, PersonEmail, AccountNumber, 
        FirstName, LastName FROM Account WHERE OwnerId=:UserInfo.getUserId() AND Event_Interest_Picklist_PB__pr.Name LIKE: searchKey LIMIT 700];

        for (Account acc: lstOfAccount) {
            returnAccList.add(acc);
        }
        System.debug('returnListAcc-->'+returnAccList);
        if(returnAccList.size() > 0){
          return returnAccList;
        }
        else{
          return null;
        }
        
    }

    @AuraEnabled
    public static List < Lead > searchLead(String searchKeyWord) {
        String searchKey = searchKeyWord + '%';
        List < Lead > returnLeadList = new List < Lead > ();
        List<Lead> lstOfLead = [SELECT ID, FirstName, LastName, Name, CreatedById, From_Lead_Convert__c, 
                                Phone, Status, Event_Interest_Picklist_PB__c, Event_Interest_Picklist_PB__r.Name 
                                FROM Lead WHERE OwnerId=:UserInfo.getUserId() AND Event_Interest_Picklist_PB__r.Name LIKE: searchKey LIMIT 700];
        for(Lead led : lstOfLead){
            returnLeadList.add(led);
        }
        System.debug('returnLeadList-->'+ returnLeadList);
        if(returnLeadList.size() > 0){
          return returnLeadList;
        }
        else{
          return null;
        }
    }

}