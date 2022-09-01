trigger UpdateLeadswithTask on Task (after insert) {
    // set up lists you will need
    List<Lead> LeadsToUpdate = new List<Lead>();
    Map<Id, Task> taskMap = new Map<Id, Task>();

    // go through the list of tasks that were inserted
    for (Task t: Trigger.New)
    {
      // if they are related to a Lead, add the Lead id (whoID) and their values to a map
      if (t.WhoId  != null && t.Subject == 'Email: Thank you for contacting Derby Experiences!')
        {
            taskMap.put(t.WhoId, t);
        }
    }
    // if the map isnt empty
    if (taskMap.size() > 0)
    {
        // get all of the Leads related to the tasks
        LeadsToUpdate = [SELECT Id, Email_Sent__c FROM Lead WHERE Id IN: taskMap.keySet()];
        // go through the list for each Lead
        for (Lead l: LeadsToUpdate){ 
            l.Email_Sent__c = TRUE;
        }
        // if the list of Leads isnt empty, update them
        if (LeadsToUpdate.size() > 0)
        {
            update LeadsToUpdate;
        }
    }
}