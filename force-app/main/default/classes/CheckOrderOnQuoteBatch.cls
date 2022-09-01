/**
* @description       : 
* @author            : Jheel Agrawal
* @group             : 
* @last modified on  : 11-03-2020
* @last modified by  : jagrawal@addonblue.com
* Modifications Log 
* Ver   Date         Author          Modification
* 1.0   10-29-2020   Jheel Agrawal   Initial Version
**/
public class CheckOrderOnQuoteBatch implements Database.Batchable<sObject>, Schedulable {
    
    public String query;
    
    public CheckOrderOnQuoteBatch(){
        this.query = 'Select Id, Name, QuoteNumber from Quote where Status = \'Signed - Approved\' AND LastModifiedDate = LAST_N_DAYS:2';
    }
    
    public CheckOrderOnQuoteBatch(String p_query){
        this.query = p_query;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Quote> scope){
        Set<Id> setQuoteIds = new Set<Id>();        
        for(Quote objQuote: scope){
            setQuoteIds.add(objQuote.Id);
        }
        
        Map<Id, Order> mapQuoteIdNOrder = new Map<Id, Order>();
        List<Order> lstOrders = [Select Id, QuoteId from Order where QuoteId IN :setQuoteIds];
        for(Order objOrder: lstOrders){
            mapQuoteIdNOrder.put(objOrder.QuoteId, objOrder);
        }
        
        Set<Quote> setErroneousQuotes = new Set<Quote>();
        for(Quote objQuote: scope){
            if(!mapQuoteIdNOrder.containsKey(objQuote.Id)){ setErroneousQuotes.add(objQuote); }
        }
        
        if(setErroneousQuotes.size() > 0){
            String body = 'Hi there,<br/><br/>Here is the list of Quotes which didn\'t had Orders created. Please have a look at them.<br/>|     Quote Id     |     Quote Number     |<br/>';
            for(Quote objQuote: setErroneousQuotes){
                body += '| ' + objQuote.Id + ' | <a href="' + System.URL.getSalesforceBaseURL().toExternalForm() + '/' + objQuote.Id + '">' + objQuote.QuoteNumber + '</a> |<br/>';
            }
            body += '<br/><br/>Regards,<br/>Quintevents Admin';
            String strEmails = System.Label.CheckOrderOnQuoteBatch_Emails;
            if(String.isNotBlank(strEmails))
            {
                List<String> lstEmails = strEmails.split(',');
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { Utility.createSingleEmailMessage(lstEmails, 'Quotes Created without Order in Production', 'Quintevents Admin', body, true, false) });
            }
            
        }
    }
    
    public void finish(Database.BatchableContext BC){}
    
    public void execute(SchedulableContext sc){
        Database.executeBatch(new CheckOrderOnQuoteBatch());
    }
    
}