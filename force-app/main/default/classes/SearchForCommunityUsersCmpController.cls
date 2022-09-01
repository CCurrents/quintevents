/**
 * @File Name          : SearchForCommunityUsersCmpController.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 4/11/2020, 2:56:09 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/11/2020   jagrawal@addonblue.com     Initial Version
**/
public with sharing class SearchForCommunityUsersCmpController {
    
    @AuraEnabled
    public static List < SObject > fetchAccount(String searchKeyWord) {
        String searchKey = searchKeyWord + '%';
        List < SObject > returnAccList = new List < SObject > ();
        List < Account > lstOfAccount = [select id, Name, PersonEmail, OwnerId, Owner.Name from account
                                        where Name LIKE: searchKey LIMIT 500];

        for (Account acc: lstOfAccount) {
            returnAccList.add(acc);
        }
        System.debug('returnListAcc-->'+returnAccList);
        return returnAccList;
    }

    @AuraEnabled
    public static List < SObject > fetchLead(String searchKeyWord) {
        String searchKey = searchKeyWord + '%';
        List < SObject > returnLeadList = new List < SObject > ();
        List<Lead> lstOfLead = [SELECT Id,Name,Email,OwnerId,Owner.Name FROM Lead where Name LIKE: searchKey LIMIT 500];
        for(Lead led : lstOfLead){
            returnLeadList.add(led);
        }
        System.debug('returnLeadList-->'+ returnLeadList);
        return returnLeadList;
    }

    @AuraEnabled
    public static List < SObject > fetchContact(String searchKeyWord) {
        String searchKey = searchKeyWord + '%';
        List < SObject > returnConList = new List < SObject > ();
        List<Contact> lstOfContact = [SELECT Id,Name,Email,OwnerId,Owner.Name FROM Contact where Name LIKE: searchKey LIMIT 500];
        for(Contact con : lstOfContact){
            returnConList.add(con);
        }
        System.debug('returnConList-->'+returnConList);
        return returnConList;
    }
}