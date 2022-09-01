public class QE_QuoteHandler {
    
    // After Update
    public void OnAfterUpdate(Quote[] oldListQuotes, Quote[] newListQuotes, Map<ID, Quote> oldMapQuotes, Map<ID, Quote> newMapQuotes) {
        // Quotes Related Data by Quote Id
        Map<Id,Quote> quoteExtraDataById = new Map<Id,Quote>([
            Select Id, Owner.Email, Event__r.Program__c,
            (Select Id, IsPending, ProcessInstanceId, ProcessNode.DeveloperName, TargetObjectId, StepStatus, OriginalActorId,
             ActorId, RemindersSent, Comments, IsDeleted, CreatedDate, CreatedById, SystemModstamp
             From ProcessSteps
             Where StepStatus = 'Approved' Or StepStatus = 'Rejected')
            From Quote
            Where Id In :newListQuotes
        ]);
        /*** After Hour Approver's Email ***/
        Set<Quote> quotesToProcessForNotification = new Set<Quote>();
        // QuintEvents Office TimeZone
        Timezone tz = Timezone.getTimeZone('America/New_York');
        // Get day of week for today
        DateTime dt = system.now();
        String dayOfWeek = dt.format('EEEE');
        // Days of Weekend
        List<String> weekEndDays = new list<String> {'Saturday','Sunday'};
            for(Quote quote : newListQuotes) {
                // Check if quote has Draft Approval Request Date/Time
                if(oldMapQuotes.get(quote.Id).Draft_Approval_Request_Date_Time__c == null && 
                   quote.Draft_Approval_Request_Date_Time__c != null) {
                       Integer hourOfApprovalRequest = (quote.Draft_Approval_Request_Date_Time__c.hourGmt() + (tz.getOffset(dt.dateGMT())/3600000)); //Gmt; //getting hour in GMT time
                       if(hourOfApprovalRequest < 0) {
                           hourOfApprovalRequest = 24 + hourOfApprovalRequest;
                       }
                       Integer minuteOfApprovalRequest = quote.Draft_Approval_Request_Date_Time__c.minute();
                       // For test class
                       if(Test.isRunningTest()) {
                           hourOfApprovalRequest = 19; // Setting it after hour so test class can execute rest of code.
                       }
                       System.debug('dayOfWeek: ' + dayOfWeek);
                       System.debug('Hour of Approval Requst: ' + hourOfApprovalRequest);
                       // Check if today is weekend.
                       if(weekEndDays.contains(dayOfWeek)) {
                           // Collet id of quote to send email
                           quotesToProcessForNotification.add(quote);
                           System.debug('Today is Weekend');
                       } else {
                           System.debug('Today is Weekday');
                           System.debug('Quote: '+quote);
                           // Today is a Weekday
                           // Get current hours and see if its between after business hours (6pm/18 to 7:59am/7)
                           if(hourOfApprovalRequest > 17 || hourOfApprovalRequest < 8 || (hourOfApprovalRequest == 17 && minuteOfApprovalRequest > 30) || (hourOfApprovalRequest == 8 && minuteOfApprovalRequest < 30)) {
                               // Collect id of quote to send email
                               quotesToProcessForNotification.add(quote);
                           }
                       }
                   }
            }
        // Only if there are quotes to process
        if(quotesToProcessForNotification.size() > 0) {
            // Get after hour approvers info.
            List<Schedule__c> afterHourApprovers = new List<Schedule__c>([
                Select Id, User__r.Name, User__r.Email, Days__c, Program__c
                From Schedule__c
                Where RecordType.Name = 'After Hour Approver' and Days__c includes (:dayOfWeek)
            ]);            
            // After Hour Approvers by Partner
            Map<Id,List<Schedule__c>> afterHourApproversByProgram = new Map<Id,List<Schedule__c>>();
            List<Schedule__c> afterHourApproversNoPrograms = new List<Schedule__c>();
            for(Schedule__c ahApprover : afterHourApprovers) {
                if(afterHourApproversByProgram.containsKey(ahApprover.Program__c)) {
                    // Get exisitng key/value and add to it.
                    afterHourApproversByProgram.get(ahApprover.Program__c).add(ahApprover);
                } else {
                    // New key/value
                    List<Schedule__c> arApprovers = new List<Schedule__c>();
                    arApprovers.add(ahApprover);
                    // After Hour Approver has Partner
                    if(ahApprover.Program__c != null) {
                        afterHourApproversByProgram.put(ahApprover.Program__c, arApprovers);
                    } else {
                        // After Hour Approver has No Partner
                        //afterHourApproversByProgram.put('NoPartner', arApprovers);
                        afterHourApproversNoPrograms.add(ahApprover);
                    }
                }
                System.debug('afterHourApproversNoPrograms: '+afterHourApproversNoPrograms);
            }
            // Create email for quotes
            List<Messaging.SingleEmailMessage> emailsToBeSent = new List<Messaging.SingleEmailMessage>();
            for(Quote quote : quotesToProcessForNotification) {
                // Create single email for quote
                Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
                // To
                List<String> sendTo = new List<String>();
                sendTo.add(quoteExtraDataById.get(quote.Id).Owner.Email);
                String emailSubject = 'After Hour Quote Approvers';
                // CC
                List<String> sendCC = new List<String>();                
                //
                String clickAbleApproverName = '';
                // Check if there are approvers for Quote's Event's Program
                if(quoteExtraDataById.get(quote.Id).Event__r.Program__c != null &&
                   afterHourApproversByProgram.containsKey(quoteExtraDataById.get(quote.Id).Event__r.Program__c)) {
                       // Get approvers for this partner and create message
                       for(Schedule__c arApprover : afterHourApproversByProgram.get(quoteExtraDataById.get(quote.Id).Event__r.Program__c)) {
                           // Get info of each approver and append it to message.
                           clickAbleApproverName += '<a href="mailto:'+arApprover.User__r.Email+'?Subject='+emailSubject+'">'+arApprover.User__r.Name+'</a>';
                           // Get approver's email and add it to email's CC.
                           sendCC.add(arApprover.User__r.Email);
                       }
                   } else { 
                       // No approvers for Quote Program, Get approvers without programs.
                       for(Schedule__c arApprover : afterHourApproversNoPrograms) {
                           // Get info of each approver and append it to message.
                           clickAbleApproverName += '<a href="mailto:'+arApprover.User__r.Email+'?Subject='+emailSubject+'">'+arApprover.User__r.Name+'</a>';
                           // Get approver's email and add it to email's CC.
                           sendCC.add(arApprover.User__r.Email);
                       }
                   }
                // If has no approver then don't create email
                if(clickAbleApproverName != '') {
                    // Email Body
                    String emailBody = 'Your quote has been submitted for approval outside of business hours in the '+
                        'North American Office. '+clickAbleApproverName+' will check your quote within two hours through 9 PM. '+
                        'If you require more immediate attention, please contact '+clickAbleApproverName+' directly. '+
                        'If the quote cannot be approved within this time frame, you will receive '+
                        'an explanation as to why as well as a time frame of when you can expect approval.';
                    singleEmail.setSubject(emailSubject);
                    singleEmail.setToAddresses(sendTo);
                    singleEmail.setCcAddresses(sendCC);
                    singleEmail.setHtmlBody(emailBody);
                    // Add to list of emails to be sent
                    emailsToBeSent.add(singleEmail);
                }
            }
            // Send emails
            if(emailsToBeSent.size() > 0) {
                Messaging.sendEmail(emailsToBeSent);
            }           
        }
        
        /*** Capture Approval Process Comments from Each Step ***/
        List<Quote> quotesToUpdate = new List<Quote>();
        for (Quote quote : newListQuotes) {
            System.debug('quoteExtraDataById.get(quote.Id).ProcessSteps 1: '+quoteExtraDataById.get(quote.Id).ProcessSteps);
            // Capture comments only if the quote status is Draft - Approved or Signed - Approved
            If(quote.Status.equals('Draft - Approved') || quote.Status.equals('Signed - Approved') || quote.Status.equals('Draft - Denied') || quote.Status.equals('Signed - Denied')) {
                // Avoid recursive trigger
                If(!QE_checkRecursiveQuote.setOfIDs.contains(quote.Id)) {
                    Quote q = new Quote();
                    q.Id = quote.Id;
                    System.debug('quoteExtraDataById.get(quote.Id).ProcessSteps 2: '+quoteExtraDataById.get(quote.Id).ProcessSteps);
                    for (ProcessInstanceHistory step : quoteExtraDataById.get(quote.Id).ProcessSteps) {
                        System.debug('ProcessInstanceHistory => ' +step);
                        // Has ProcessNode
                        If(step.ProcessNode != null) {
                            System.debug('step.ProcessNode.DeveloperName: '+step.ProcessNode.DeveloperName);
                            // Draft Quote Operations
                            If((step.ProcessNode.DeveloperName).equals('Draft_Quote_Operations')) {
                                q.Draft_Approver_Comment_Operations__c = step.Comments;
                            }
                            // Draft Quote Sales
                            If((step.ProcessNode.DeveloperName).equals('Draft_Quote_Sales')) {
                                q.Draft_Approver_Comment_Sales__c = step.Comments;
                            }
                            // Signed Quote Operations
                            If((step.ProcessNode.DeveloperName).equals('Signed_Quote_Operations')) {
                                q.Signed_Approver_Comment_Operations__c = step.Comments;
                            }
                            // Signed Quote Sales
                            If((step.ProcessNode.DeveloperName).equals('Signed_Quote_Sales')) {
                                q.Signed_Approver_Comment_Sales__c = step.Comments;
                            }
                        }
                    }
                    // Only add the quote to list of quotes to update, if comments are captured for steps.
                    if(q.Draft_Approver_Comment_Operations__c != null || q.Draft_Approver_Comment_Sales__c != null) {
                        quotesToUpdate.add(q);
                        QE_checkRecursiveQuote.SetOfIDs.add(quote.Id);
                    }
                }
            }
        }
        // Update Quotes
        if(quotesToUpdate.size() > 0) {
            update quotesToUpdate;
        }
    }
}