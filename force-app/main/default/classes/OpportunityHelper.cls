public class OpportunityHelper {
    
    public void createOpportunityContactRole (List<Opportunity> newOpportunities) {
        try {
            // Get Account and Opportunity ids
            Set<Id> accountIds = new Set<Id>();
            Set<Id> opportunityIds = new Set<Id>();
            for(Opportunity oppt : newOpportunities){
                accountIds.add(oppt.AccountId);
                opportunityIds.add(oppt.Id);
            }
            // Get
            List<Account> accountsWithContacts = [select id, (select id from Contacts) from Account where id in :accountIds];
            Map<Id,Contact> accountIdsAndContacts = new Map<Id,Contact>();
            // List<Contact> contactsToBeCreated = new List<Contact>();
            for (Account account : accountsWithContacts) {
                // Account Has Contact
                if (account.Contacts.size() > 0) {
                	accountIdsAndContacts.put(account.Id, account.Contacts.get(0));
                } else {
                // Account Dont have Contacts (Create New Contact)
                    /*
                	Contact contact = new Contact(
                    	AccountId = account.Id
                    );
                    contactsToBeCreated.add(contact);
				    */
                }
            }
            /*
            System.debug('contactsToBeCreated Before Insert => '+contactsToBeCreated);
            insert contactsToBeCreated;
            System.debug('contactsToBeCreated After Insert => '+contactsToBeCreated);
            */
			System.debug('accountIdsAndContacts => '+accountIdsAndContacts);
            // Get Opportunity Contact Roles for current oppts, to check if current oppt already has contact role or not.
            List<OpportunityContactRole> opptContactRoles = [select Id, OpportunityId from OpportunityContactRole where OpportunityId in :opportunityIds];
            // Create map of opportunity ids and existing OpportunityContactRoles
            Map<Id,OpportunityContactRole> opportunityIdsAndOpportunityContactRoles = new Map<Id,OpportunityContactRole>();
            for (OpportunityContactRole opptContactRole : opptContactRoles) {
                opportunityIdsAndOpportunityContactRoles.put(opptContactRole.OpportunityId, opptContactRole);
            }
            // Create Opportunitiy contact role
            List<OpportunityContactRole> opptContactRolesToInsert = new List<OpportunityContactRole>();
            for(Opportunity oppt : newOpportunities){
                // If oppt already have contact role then skip this oppt
                if (!opportunityIdsAndOpportunityContactRoles.containsKey(oppt.Id)) {
                    // Create contact role for this opportunity
                    OpportunityContactRole currentOpptContactRole = new OpportunityContactRole();
                    currentOpptContactRole.OpportunityId = oppt.Id;
                    currentOpptContactRole.ContactId = accountIdsAndContacts.get(oppt.AccountId).Id;
                    currentOpptContactRole.IsPrimary = true;
                    currentOpptContactRole.Role = 'Other';
                    opptContactRolesToInsert.add(currentOpptContactRole);
                }
            }
            insert opptContactRolesToInsert;
        } catch (Exception e) {
            System.debug('Exception Line => '+e.getLineNumber());
            System.debug('Exception Cause => '+e.getCause());
            System.debug('Exception Message => '+e.getMessage());
            ExceptionEmailHelper exEmailHelper = new ExceptionEmailHelper();
            exEmailHelper.compileAndSend(e, OpportunityHelper.class.getName());
        }
    }
    
}