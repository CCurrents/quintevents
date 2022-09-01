public class QE_EmailHelper {
    
    public QE_EmailHelper() {}
    
    // Payment Token Emails
    public void sendPaymentTokenEmails(List<Quote> quotes, Map<Id,Quote> oldMap) {        
        // Mails to be sent
        List<Messaging.SingleEmailMessage> emailsToBeSent = new List<Messaging.SingleEmailMessage>();
        // Tasks to be created
        List<Task> tasksToBeCreated = new List<Task>();
        // Create list of quote owner Ids
        /*
        List<Id> quoteIds = new List<Id>();
        for (Quote quote : quotesSet) {
            quoteIds.add(quote.Id);
        }
        */
        // Get quote owner data (Map of quote Owner Id -> Email Address)
        List <Quote> quoteAdditionalData = [Select Id, Payment_Page_Access_Token__c, Opportunity.Owner.Id, Email, Status, Payment_Method__c, Opportunity.Event__r.Name, Opportunity.Send_Payment_Email__c, Opportunity.Owner.Name, Opportunity.OwnerId, Opportunity.Owner.Email, Online_Order__c, (select Id from Quote_Additional_Signees__r) From Quote where Id in :quotes];
        // Dont need to do this for online orders.
        Set<Quote> quotesSet = new Set<Quote>();
        for(Quote qt : quoteAdditionalData) {
            if(qt.Online_Order__c != true) {
                quotesSet.add(qt);
            }
        }
        // Continue if has anything to process.
        if(quotesSet.size() > 0) {
            Map<Id,String> quoteOwnerIdsAndEmails = new Map<Id,String>();
            Map<Id,Quote> quoteIdsAndquoteAdditionalData = new Map<Id,Quote>();
            Set<Id> quotesWithOutSplitAgreement = new Set<Id>();
            // For Each Quote's Additional Data
            for (Quote quote : quoteAdditionalData) {
                quoteOwnerIdsAndEmails.put(quote.Opportunity.OwnerId, quote.Opportunity.Owner.Email);
                quoteIdsAndquoteAdditionalData.put(quote.Id, quote);
                List<QE360_Quote_Additional_Signee__c> quoteAdditionalSignees = new List<QE360_Quote_Additional_Signee__c>();
                quoteAdditionalSignees = quote.getSObjects('Quote_Additional_Signees__r'); // get all additional signes for the current quote
                // Has Additional Signees
                if (quoteAdditionalSignees == null || quoteAdditionalSignees.size() == 0) {
                    quotesWithOutSplitAgreement.add(quote.Id);                
                }
            }
            // Get OrgWideEmailAddress (Map of Email Address -> Org Wide Email Address ID)
            List<OrgWideEmailAddress> orgWideEmailAddress = [select id, Address from OrgWideEmailAddress where Address in :quoteOwnerIdsAndEmails.values()];
            // Create map of Quote Owners ID -> org wide emails ID
            Map<String,Id> orgWideEmailsAndTheirOweIds = getOrgWideEmailAndIds();
            System.debug('orgWideEmailsAndTheirOweIds: '+orgWideEmailsAndTheirOweIds);
            // Get email template
            String[] emailTemplateIds = new String[]{'00Xi0000000O6Cp','00X1Y000001N6vM'}; // old template id: 00Xi0000001J2TR
                List<EmailTemplate> emailTemplates = [select Id, Subject, HtmlValue, Body from EmailTemplate where Id in :emailTemplateIds];
            Map<id,EmailTemplate> emailTemplateData = new Map<id,EmailTemplate>(emailTemplates);
            
            // FOR Each Quotes
            for (Quote quote : quotesSet) {
                List<QE360_Stripe_Charge__c> quoteStripeCharges = new List<QE360_Stripe_Charge__c>();
                if(quote.Status != null){//This Line Added By RelationEdge to avoid null pointer exception
                // Payment Token Emails
                if (((quote.Status).equals('Signed - Approved') && !(((oldMap.get(quote.Id)).Status).equals('Signed - Approved'))) &&
                    (quote.Payment_Method__c).equals('Credit Card') &&
                    quotesWithOutSplitAgreement.contains(quote.Id) &&
                    quoteIdsAndquoteAdditionalData.get(quote.Id).Opportunity.Send_Payment_Email__c) {
                        // Client Email
                        String clientTemplateId = '';
                        if ((quoteIdsAndquoteAdditionalData.get(quote.Id).Opportunity.Event__r.Name).containsIgnoreCase('formula') &&
                            !((quoteIdsAndquoteAdditionalData.get(quote.Id).Opportunity.Event__r.Name).containsIgnoreCase('gpmx') ||
                              (quoteIdsAndquoteAdditionalData.get(quote.Id).Opportunity.Event__r.Name).containsIgnoreCase('cotae'))
                           )
                        {
                            clientTemplateId = '00X1Y000001N6vM';
                        } else {
                            clientTemplateId = '00Xi0000000O6Cp';
                        }
                        String subject = emailTemplateData.get(clientTemplateId).Subject;
                        String htmlBody = (emailTemplateData.get(clientTemplateId).HtmlValue);
                        htmlBody = htmlBody.replace('{!Quote.Payment_Page_Access_Token__c}', quote.Payment_Page_Access_Token__c);
                        htmlBody = htmlBody.replace('{!Quote.Id}', quote.Id);
                        String textBody = (emailTemplateData.get(clientTemplateId).Body);
                        textBody = textBody.replace('{!Quote.Payment_Page_Access_Token__c}', quote.Payment_Page_Access_Token__c);
                        
                        System.debug('quote.Opportunity.Owner.Id: '+quote.Opportunity.Owner.Id);
                        System.debug('quoteOwnerIdsAndEmails.get(quote.Opportunity.Owner.Id): '+quoteOwnerIdsAndEmails.get(quote.Opportunity.Owner.Id));
                        System.debug('orgWideEmailsAndTheirOweIds.get(quoteOwnerIdsAndEmails.get(quote.Opportunity.Owner.Id)): '+orgWideEmailsAndTheirOweIds.get(quoteOwnerIdsAndEmails.get(quote.Opportunity.Owner.Id)));
                        
                        Messaging.SingleEmailMessage emailClient = compileEmail(
                            orgWideEmailsAndTheirOweIds.get(quoteOwnerIdsAndEmails.get(quoteIdsAndquoteAdditionalData.get(quote.Id).Opportunity.OwnerId)), // From
                            // orgWideEmailsAndTheirOweIds.get(quoteOwnerIdsAndEmails.get(quote.Opportunity.Owner.Id)), // From
                            quote.Email, // To
                            subject, // Subject
                            htmlBody, // Html Body
                            textBody // Text Body
                        );
                        emailsToBeSent.add(emailClient);
                        Task taskClient = generateTask(emailClient, quote.Id);
                        tasksToBeCreated.add(taskClient);
                    }
                    }
            }
            // For Each Additional Signees
            
            // Send Emails
            List<Messaging.SendEmailResult> sendEmailResult = new List<Messaging.SendEmailResult>();
            try {
                sendEmailResult = Messaging.sendEmail(emailsToBeSent, false);
            } catch (Exception e) {
                System.debug('Exception: '+e);
            }
            // Create Task and attach it to Quote
            try {
                insert tasksToBeCreated;
            } catch (Exception e) {
                System.debug('Exception: '+e);
            }
        }
    }
    
    // Payment Confirmation Emails
    public void sendPaymentConfirmationEmails(List<QE360_Stripe_Charge__c> qeStripeCharges) {
        // Convert list to set
        Set<QE360_Stripe_Charge__c> qeStripeChargesSet = new Set<QE360_Stripe_Charge__c>();
        qeStripeChargesSet.addAll(qeStripeCharges);
        Set<Id> qeStripeChargeIds = (new Map<Id,SObject>(qeStripeCharges)).keySet();
        // Charge addtional data
        Map<Id,QE360_Stripe_Charge__c> qeStripeChargeAdditionalData = new Map<Id,QE360_Stripe_Charge__c>([Select Id, Last4__c, Quote__r.Account.Name, Quote__c, Quote__r.Email, Quote_Additional_Signee__r.Email__c, Quote__r.Payment_Terms__c, Quote__r.Opportunity.Event__r.Name, Quote__r.Opportunity.Send_Payment_Email__c, Quote__r.Opportunity.Owner.Name, Quote__r.Opportunity.OwnerId, Quote__r.Opportunity.Owner.Email From QE360_Stripe_Charge__c where Id in :qeStripeChargeIds]);
        // Get email template
        String[] emailTemplateIds = new String[]{'00Xi0000000O6Co','00Xi0000000O6Cn','00Xi0000000O6Cm','00Xi0000000O6Cl'}; // old template ids: {'00Xi0000001J3in','00Xi0000001J2iM','00Xi0000001J2hx','00Xi0000001J2iv'}
            List<EmailTemplate> emailTemplates = [select Id, Subject, HtmlValue, Body from EmailTemplate where Id in :emailTemplateIds];
        Map<id,EmailTemplate> emailTemplateData = new Map<id,EmailTemplate>(emailTemplates);
        // Get org wide email data
        Map<String,Id> orgWideEmailsAndTheirOweIds = getOrgWideEmailAndIds();
        // Mails to be sent
        List<Messaging.SingleEmailMessage> emailsToBeSent = new List<Messaging.SingleEmailMessage>();
        // Tasks to be created
        List<Task> tasksToBeCreated = new List<Task>();
        // Processed stripe charges for emails
        Set<String> processedStripeChargeCardIds = new Set<String>();
        // For each Charge
        for (QE360_Stripe_Charge__c qeStripeCharge : qeStripeCharges) {
            // To prevent duplicate emails being sent for NON 100% payment temrs
            if (!(processedStripeChargeCardIds.contains(qeStripeCharge.Stripe_Card_Id__c))) {
                processedStripeChargeCardIds.add(qeStripeCharge.Stripe_Card_Id__c);
                String clientToEmail = '';
                // Quote
                if (qeStripeCharge.Quote_Additional_Signee__c == null) {
                    clientToEmail = (qeStripeChargeAdditionalData.get(qeStripeCharge.Id)).Quote__r.Email;
                } else {
                    // Additional Signee
                    clientToEmail = (qeStripeChargeAdditionalData.get(qeStripeCharge.Id)).Quote_Additional_Signee__r.Email__c;
                }
                //// Client Email
                // Payment Temrs - 100%
                if (((qeStripeChargeAdditionalData.get(qeStripeCharge.Id)).Quote__r.Payment_Terms__c).equals('100%')) {
                    String clientTemplateId = '00Xi0000000O6Cn';
                    String clientSubject = emailTemplateData.get(clientTemplateId).Subject;
                    String clientHtmlBody = emailTemplateData.get(clientTemplateId).HtmlValue;
                    String clientTextBody = emailTemplateData.get(clientTemplateId).Body;
                    Messaging.SingleEmailMessage emailClient = compileEmail(
                        orgWideEmailsAndTheirOweIds.get((qeStripeChargeAdditionalData.get(qeStripeCharge.Id)).Quote__r.Opportunity.Owner.Email), // From
                        clientToEmail, // To
                        clientSubject, // Subject
                        clientHtmlBody, // Html Body
                        clientTextBody // Text Body
                    );
                    emailsToBeSent.add(emailClient);
                    Task taskClient = generateTask(emailClient, (qeStripeChargeAdditionalData.get(qeStripeCharge.Id)).Quote__c);
                    tasksToBeCreated.add(taskClient);
                    System.debug('Client Email: Payment Temrs - 100%: '+emailClient);
                }
                // Payment Temrs - NOT 100%
                if (!(((qeStripeChargeAdditionalData.get(qeStripeCharge.Id)).Quote__r.Payment_Terms__c).equals('100%'))) {
                    String clientTemplateId = '00Xi0000000O6Cm';
                    String clientSubject = emailTemplateData.get(clientTemplateId).Subject;
                    String clientHtmlBody = emailTemplateData.get(clientTemplateId).HtmlValue;
                    String clientTextBody = emailTemplateData.get(clientTemplateId).Body;
                    Messaging.SingleEmailMessage emailClient = compileEmail(
                        orgWideEmailsAndTheirOweIds.get((qeStripeChargeAdditionalData.get(qeStripeCharge.Id)).Quote__r.Opportunity.Owner.Email), // From
                        clientToEmail, // To
                        clientSubject, // Subject
                        clientHtmlBody, // Html Body
                        clientTextBody // Text Body
                    );
                    emailsToBeSent.add(emailClient);
                    Task taskClient = generateTask(emailClient, (qeStripeChargeAdditionalData.get(qeStripeCharge.Id)).Quote__c);
                    tasksToBeCreated.add(taskClient);
                }
                //// Sales Rep Email
                String salesRepTemplateId = '00Xi0000000O6Co';
                String salesRepSubject = emailTemplateData.get(salesRepTemplateId).Subject;
                String salesRepHtmlBody = emailTemplateData.get(salesRepTemplateId).HtmlValue;
                salesRepHtmlBody = salesRepHtmlBody.replace('{!Quote.Account__c}', (qeStripeChargeAdditionalData.get(qeStripeCharge.Id)).Quote__r.Account.Name);
                salesRepHtmlBody = salesRepHtmlBody.replace('{!Quote.Link}', 'https://' + ApexPages.currentPage().getHeaders().get('X-Salesforce-Forwarded-To') + '/' + (qeStripeChargeAdditionalData.get(qeStripeCharge.Id)).Quote__c);
                String salesRepTextBody = emailTemplateData.get(salesRepTemplateId).Body;
                salesRepTextBody = salesRepTextBody.replace('{!Quote.Account__c}', (qeStripeChargeAdditionalData.get(qeStripeCharge.Id)).Quote__r.Account.Name);
                salesRepTextBody = salesRepTextBody.replace('{!Quote.Link}', 'https://' + ApexPages.currentPage().getHeaders().get('X-Salesforce-Forwarded-To') + '/' + (qeStripeChargeAdditionalData.get(qeStripeCharge.Id)).Quote__c);
                Messaging.SingleEmailMessage emailSalesRep = compileEmail(
                    orgWideEmailsAndTheirOweIds.get((qeStripeChargeAdditionalData.get(qeStripeCharge.Id)).Quote__r.Opportunity.Owner.Email), // From
                    (qeStripeChargeAdditionalData.get(qeStripeCharge.Id)).Quote__r.Opportunity.Owner.Email, // To
                    salesRepSubject, // Subject
                    salesRepHtmlBody, // Html Body
                    salesRepTextBody // Text Body
                );
                emailsToBeSent.add(emailSalesRep);
                Task taskSalesRep = generateTask(emailSalesRep, (qeStripeChargeAdditionalData.get(qeStripeCharge.Id)).Quote__c);
                tasksToBeCreated.add(taskSalesRep);
                //// Accounting Email
                String accountingTemplateId = '00Xi0000000O6Cl';
                String accountingSubject = emailTemplateData.get(accountingTemplateId).Subject;
                String accountingHtmlBody = emailTemplateData.get(accountingTemplateId).HtmlValue;
                accountingHtmlBody = accountingHtmlBody.replace('{!Quote.Account__c}', (qeStripeChargeAdditionalData.get(qeStripeCharge.Id)).Quote__r.Account.Name);
                accountingHtmlBody = accountingHtmlBody.replace('{!Quote.Link}', 'https://' + ApexPages.currentPage().getHeaders().get('X-Salesforce-Forwarded-To') + '/' + (qeStripeChargeAdditionalData.get(qeStripeCharge.Id)).Quote__c);
                accountingHtmlBody = accountingHtmlBody.replace('{!QE360_Stripe_Charge__c.Last4__c}', (qeStripeChargeAdditionalData.get(qeStripeCharge.Id)).Last4__c);
                String accountingTextBody = emailTemplateData.get(accountingTemplateId).Body;
                accountingTextBody = accountingTextBody.replace('{!Quote.Account__c}', (qeStripeChargeAdditionalData.get(qeStripeCharge.Id)).Quote__r.Account.Name);
                accountingTextBody = accountingTextBody.replace('{!Quote.Link}', 'https://' + ApexPages.currentPage().getHeaders().get('X-Salesforce-Forwarded-To') + '/' + (qeStripeChargeAdditionalData.get(qeStripeCharge.Id)).Quote__c);
                accountingTextBody = accountingTextBody.replace('{!QE360_Stripe_Charge__c.Last4__c}', (qeStripeChargeAdditionalData.get(qeStripeCharge.Id)).Last4__c);
                Messaging.SingleEmailMessage emailAccounting = compileEmail(
                    orgWideEmailsAndTheirOweIds.get((qeStripeChargeAdditionalData.get(qeStripeCharge.Id)).Quote__r.Opportunity.Owner.Email), // From
                    'accounting@quintevents.com', // To
                    accountingSubject, // Subject
                    accountingHtmlBody, // Html Body
                    accountingTextBody // Text Body
                );
                emailsToBeSent.add(emailAccounting);
                Task taskAccounting = generateTask(emailAccounting, (qeStripeChargeAdditionalData.get(qeStripeCharge.Id)).Quote__c);
                tasksToBeCreated.add(taskAccounting);
            }
        }
        // Send Emails
        List<Messaging.SendEmailResult> sendEmailResult = new List<Messaging.SendEmailResult>();
        try {
            sendEmailResult = Messaging.sendEmail(emailsToBeSent, false);
        } catch (Exception e) {
            System.debug('Exception: '+e);
        }
        // Create Task and attach it to Quote
        try {
            System.debug('tasksToBeCreated: '+tasksToBeCreated);
            insert tasksToBeCreated;
        } catch (Exception e) {
            System.debug('Exception: '+e);
        }
    }
    
    // Get Org Wide Email and Ids
    public Map<String,Id> getOrgWideEmailAndIds() {
        // Get OrgWideEmailAddress (Map of Email Address -> Org Wide Email Address ID)
        List<OrgWideEmailAddress> orgWideEmailAddress = [select id, Address from OrgWideEmailAddress];
        // Create map of Quote Owners ID -> org wide emails ID
        Map<String,Id> orgWideEmailsAndTheirOweIds = new Map<String,Id>();
        for (OrgWideEmailAddress owe : orgWideEmailAddress) {
            orgWideEmailsAndTheirOweIds.put(owe.Address, owe.Id);
        }
        return orgWideEmailsAndTheirOweIds;
    }
    
    // Compile Email
    public Messaging.SingleEmailMessage compileEmail(Id fromEmail, String toAddress, String subject, String htmlBody, String textBody) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setOrgWideEmailAddressId(fromEmail); // From
        email.setToAddresses(new List<String>{toAddress}); // To
        email.setSubject(subject); // Subject
        email.setHtmlBody(htmlBody); // Html Body
        email.setPlainTextBody(textBody); // Text Body
        return email;
    }
    
    // Generate Task
    public Task generateTask(Messaging.SingleEmailMessage email, Id whatId) {
        Task task = new Task();
        task.WhatId = whatId;
        task.TaskSubtype = 'Email';
        task.Subject = email.getSubject();
        task.Status = 'Completed';
        task.Description = generateTaskDescription(email);
        task.ActivityDate = Date.today();
        return task;
    }
    
    // Generate Task Description
    private static String generateTaskDescription(Messaging.SingleEmailMessage email){
        return 'From Org Wide Id: '+ email.getOrgWideEmailAddressId()
            + '\n\nTo: '+ email.getToAddresses()
            + '\n\nSubject: ' + email.getSubject()
            + '\n\nBody:\n' + email.getPlainTextBody();
    } 
    
}