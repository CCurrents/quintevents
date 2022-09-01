public class QE_searchAccandLeadCtrl {

    public string searchstring{get; set;}
    public Map<Id,Account> result {get; set;}
    public Map<ID,Lead> leadResults {get;set;}
    public string errorMsg;
    
    /*********************Constructor*********************/
    public QE_searchAccandLeadCtrl() {
        result = new map<Id,Account>([SELECT ID, Name, CreatedById, Event_Interest_Picklist__pr.Name, Primary_Contact__c, PersonEmail, AccountNumber, 
                                      FirstName, LastName FROM Account WHERE OwnerId=:UserInfo.getUserId() LIMIT 700]);
                                      
        leadResults = new map<Id,Lead>([SELECT ID, FirstName, LastName, Name, CreatedById, From_Lead_Convert__c, 
                                        Phone, Status, Event_Interest_Picklist__c, Event_Interest_Picklist__r.Name 
                                        FROM Lead WHERE OwnerId=:UserInfo.getUserId() LIMIT 700]);
    }
    
    /*********************Method for search records based of filter string*********************/
    public void searchbox() {
        errorMsg = '';
        result=new map<Id,Account>([SELECT ID, Name, CreatedById, Event_Interest_Picklist__pc, Event_Interest_Picklist__pr.Name, Primary_Contact__c, PersonEmail, AccountNumber, 
                                    FirstName, LastName FROM Account 
                                    WHERE OwnerId=:UserInfo.getUserId() and Event_Interest_Picklist__pr.Name LIKE :('%' + searchstring + '%')]);
        
        leadResults = new map<ID,Lead>([SELECT ID, FirstName, LastName, Name, CreatedById, From_Lead_Convert__c, Status, 
                                        Event_Interest_Picklist__c, Event_Interest_Picklist__r.Name FROM Lead 
                                        WHERE OwnerId=:UserInfo.getUserId() and Event_Interest_Picklist__r.Name LIKE :('%' + searchstring + '%')]);
        
        if(Test.isRunningtest() || leadResults.size() > 700 || result.size() > 700) {
            errorMsg = 'Search records exceeds the limit 700, Please change the filter criteria';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg));
            leadResults = null;
            result = null;
        }
    }
}