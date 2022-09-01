global class QE_RoomingListGuestBlank implements Database.Batchable<sObject> {
    
    global Database.queryLocator start(Database.batchableContext bc) {
        String query = 'SELECT Id,Opportunity__r.OwnerId, Opportunity__r.Owner.Email,Opportunity__r.Event__r.Event_Manager__r.Email, Opportunity__c,OpportunityLineItem_Id__c from Rooming_List__c where Guest_Name__c = null AND Opportunity__c != null AND Opportunity__r.StageName = \'Closed Won\' AND OpportunityLineItem_Id__c != null AND Opportunity__r.Event__r.Event_Manager__c != null';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.batchableContext bc, list<Rooming_List__c> scope) {
        Set<Id> setOLI = new Set<Id>();
        for(Rooming_List__c roomList : scope) {
            setOLI.add(roomList.OpportunityLineItem_Id__c);
        }
        Date dt = system.today().addDays(7);
        
        Set<Id> setOLINext7DayCheckin = new Map<Id,OpportunityLineItem>([Select Id from OpportunityLineItem where Id In :setOLI AND Check_In_Date__c = :dt]).keySet();
        
        if(setOLINext7DayCheckin.size() > 0) {
            List<Messaging.SingleEmailMessage> singleEmails = new List<Messaging.SingleEmailMessage>();
            for(Rooming_List__c roomList : scope) {
                Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[] {roomList.Opportunity__r.Event__r.Event_Manager__r.Email};
                mail.setToAddresses(toAddresses);
                
                mail.setSubject('Rooming List Guest Name Missing');
                
                mail.setHTMLBody('In order to make reservation, Guest Name and Number of Adults must be added to this rooming list: <a target="_blank" href="https://quintevents.my.salesforce.com/"' + roomList.Id + '>Rooming List</a><br/>After adding this values, Please click on "Create H4H Reservation"');
                
                singleEmails.add(mail);
            }
            Messaging.sendEmail(singleEmails);
        }
    }
    
    global void finish(Database.batchableContext bc) {
    }
}