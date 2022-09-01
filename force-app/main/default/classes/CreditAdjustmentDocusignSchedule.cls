/**
 * @File Name          : CreditAdjustmentDocusignSchedule.cls
 * @Description        : To schedule Credit Adjustment Docusign
 * @Author             : kchavda@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 09-09-2020
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    05/27/2020  kchavda@addonblue.com     Initial Version
 * 1.1    09/01/2020  kchavda@addonblue.com     #378 Addendum Automation changes for v3
 * 1.2    02/11/2021  kchavda@addonblue.com     #716 Currently we use wording "2021 Event" for credit creation, need to be replaced with "Future Event".
**/

global class CreditAdjustmentDocusignSchedule implements schedulable{
   
   
     /**
    * @description create schedule for credit adjustment docusign
    * @author kchavda@addonblue.com | 05/27/2020
    * @param 
    * @return void
    **/    
    global static String scheduleMe() {
        Integer minutes = 60;        
       
        Integer days = minutes / 60 / 24 ;
        Integer hours = (minutes - days * 60 * 24) / 60 ;
        Integer mins = minutes - days * 60 * 24 - hours * 60 ;     
        System.debug('days'+days);
        System.debug('hours'+hours);
        System.debug('mins'+mins);
        DateTime dt = System.now();
        DateTime nextScheduleTime = dt;
    
        if (mins > 0 ){
            nextScheduleTime = nextScheduleTime.addMinutes(mins);
        }
        if (hours > 0 ){
            nextScheduleTime = nextScheduleTime.addHours(hours);
        }
        if (days > 0 ){
            nextScheduleTime = nextScheduleTime.addDays(days);
        }
        String minute = string.valueOf(nextScheduleTime.minute());
        String hour = string.valueOf(nextScheduleTime.hour()); 
        String day = string.valueOf(nextScheduleTime.day());
        String month = string.valueOf(nextScheduleTime.month());
        String second = string.valueOf(nextScheduleTime.second());
        String year = string.valueOf(nextScheduleTime.year());
       
        String strJobName = 'Credit Adjustment Docusign-' + second + '_' + minute + '_' + hour + '_' + day + '_' + month + '_' + year;
        String cronvalue = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
        System.debug('cronvalue'+cronvalue);
        CreditAdjustmentDocusignSchedule SC = new CreditAdjustmentDocusignSchedule(); 
        if (!Test.isRunningTest()){
            return System.schedule(strJobName, cronvalue, SC);
        }
        else{
           return '';
        }
    }
    
      /**
    * @description execute method
    * @author kchavda@addonblue.com | 05/26/2020
    * @param SchedulableContext
    * @return void
    **/  
    global void execute(SchedulableContext sc) {
        String EventId = '';
        set<string> EventIds = new set<string>();
        if(!Test.isrunningtest()){ 
            EventId = system.label.Refund_Docusign_EventIds; 
            EventIds.addall(EventId.split(',')); 
        }else{
            EventId = Test.getStandardPricebookId();
        }             
        //string query = 'Select id,dsfs__Opportunity__c,Proceed_Refund__c from dsfs__DocuSign_Status__c where ((dsfs__Opportunity__r.Refund_Response__c = \'Apply Credit to New Date in 2020\' and dsfs__Opportunity__r.Event__r.Program__r.Name = \'F1E\') or dsfs__Opportunity__r.Refund_Response__c = \'Apply Credit* to the Future Event\') and dsfs__Envelope_Status__c = \'Completed\' and Proceed_Refund__c = false and dsfs__Subject__c in (\'Move to Reschedule Dates Addendum\',\'Transfer to Future Event Addendum\') and dsfs__Opportunity__c not in (select Opportunity__c from charge__c where Is_Credit_Adjustment__c = true and recordtype.developername = \'Account_Credit\')';         
        string query = 'Select id,dsfs__Opportunity__c,Proceed_Refund__c from dsfs__DocuSign_Status__c where ((dsfs__Opportunity__r.Refund_Response__c = \'Apply Credit to New Date in 2020\' and (dsfs__Opportunity__r.Event__r.Program__r.Name = \'F1E\' or (dsfs__Opportunity__r.Event__c = null and dsfs__Opportunity__r.Pricebook2.Program__r.Name = \'F1E\'))) or dsfs__Opportunity__r.Refund_Response__c = \'Apply Credit* to the Future Event\') and dsfs__Envelope_Status__c = \'Completed\' and Proceed_Refund__c = false and dsfs__Subject__c in (\'Move to Reschedule Dates Addendum\',\'Transfer to Future Event Addendum\') and dsfs__Opportunity__c not in (select Opportunity__c from charge__c where Is_Credit_Adjustment__c = true and recordtype.developername = \'Account_Credit\')';
        if(EventId != 'Dummy'){
            if(EventId.startswith('a0b')){
                query += ' and dsfs__Opportunity__r.Event__c IN: EventIds';
            }
            else if(EventId.startswith('01s')){
                query += ' and dsfs__Opportunity__r.pricebook2Id IN: EventIds';
            }
        }
        CreditAdjustmentDocusignBatch objBatch = new CreditAdjustmentDocusignBatch(query,EventIds);
        if (!Test.isRunningTest()){
            ID batchprocessid = Database.executeBatch(objBatch,1);
            Id jobId = sc.getTriggerId(); 
            System.abortJob(jobId); 
        }
        scheduleMe(); 
    }
   
}