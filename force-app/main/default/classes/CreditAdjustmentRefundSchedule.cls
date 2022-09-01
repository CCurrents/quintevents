/**
 * @File Name          : CreditAdjustmentRefundSchedule.cls
 * @Description        : To schedule Credit Adjustment Refund
 * @Author             : kchavda@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 6/23/2020, 6:29:10 PM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    05/26/2020  kchavda@addonblue.com     Initial Version
 * 1.1    09/01/2020  kchavda@addonblue.com     #378 Addendum Automation changes for v3
 * 1.2    02/11/2021  kchavda@addonblue.com     #716 Currently we use wording "2021 Event" for credit creation, need to be replaced with "Future Event".
**/

global class CreditAdjustmentRefundSchedule implements schedulable{
      
    
    /**
    * @description execute method
    * @author kchavda@addonblue.com | 05/26/2020
    * @param SchedulableContext
    * @return void
    **/  
    global void execute(SchedulableContext sc) { 
        String EventId = '';
        set<string> EventIds = new set<string>();       
                        
        Set<Id> setparentOppId = new set<Id>();
        for(Attachment att: [select Id, parentId from attachment where name in ('Confirm Refund.pdf','Apply Credit to New Date in 2020.pdf','Apply Credit to the Future Event.pdf') ]){
            if(att.parentId != null && String.valueof(att.parentId).startswith('006')) setparentOppId.add(att.parentId);
        }
        
        
        //string query = 'Select id,primary_contact__c,Email__c,Name,Refund_Response__c,Event__c,Pricebook2Id from opportunity where Refund_Response__c != null and Send_To_Docusign__c = false and id not in (select dsfs__Opportunity__c from dsfs__DocuSign_Status__c where dsfs__Subject__c in (\'Reimbursement Addendum\', \'Move to Reschedule Dates Addendum\', \'Transfer to Future Event Addendum\') ) and ((Refund_Response__c = \'Confirm Refund\' and Refund_Amount__c != null and Refund_Amount__c != \'Not Applicable\') or (Refund_Response__c = \'Apply Credit to New Date in 2020\' and ((Event__r.Program__r.Name = \'F1E\' and Collected_Revenue__c != null) or Event__r.Program__r.Name != \'F1E\')) or (Refund_Response__c = \'Apply Credit* to the Future Event\' and Credit_Amount__c != null and Credit_Amount__c != \'Not Applicable\')) and id not in: setparentOppId ';
        string query = 'Select id,primary_contact__c,Email__c,Name,Refund_Response__c,Event__c,Pricebook2Id from opportunity where Refund_Response__c != null and Send_To_Docusign__c = false and id not in (select dsfs__Opportunity__c from dsfs__DocuSign_Status__c where dsfs__Subject__c in (\'Reimbursement Addendum\', \'Move to Reschedule Dates Addendum\', \'Transfer to Future Event Addendum\') ) and ((Refund_Response__c = \'Confirm Refund\' and Refund_Amount__c != null and Refund_Amount__c != \'Not Applicable\') or (Refund_Response__c = \'Apply Credit to New Date in 2020\' and (((Event__r.Program__r.Name = \'F1E\' or (Event__c = null and Pricebook2.Program__r.Name = \'F1E\')) and Collected_Revenue__c != null) or (Event__r.Program__r.Name != \'F1E\' or (Event__c = null and Pricebook2.Program__r.Name != \'F1E\')))) or (Refund_Response__c = \'Apply Credit* to the Future Event\' and Credit_Amount__c != null and Credit_Amount__c != \'Not Applicable\')) and id not in: setparentOppId and id not in (select opportunityId from order where status = \'Inactive - Credit Issued\')';
        //system.debug(database.query(query));
         
        Map<string,string> mapOppEventIds = new Map<string,string>();
        for(opportunity opp: database.query(query)){
            if(opp.Event__c != null && opp.Refund_Response__c != null) mapOppEventIds.put(opp.Event__c,opp.Refund_Response__c);
            else if(opp.Pricebook2Id != null && opp.Refund_Response__c != null) mapOppEventIds.put(opp.Pricebook2Id,opp.Refund_Response__c);
        }        
        
        if(mapOppEventIds.size()>0 || Test.isrunningtest()){
            for(Pricebook2 pb: [select Id,legacy_Id__c,Refund_Addendum__c,Refund_Addendum_Envelope_Message__c,Move_to_2020_Addendum__c,Move_to_2020_Addendum_Envelope_Message__c,Move_to_2021_Addendum__c,Move_to_2021_Addendum_Envelope_Message__c from pricebook2 where legacy_Id__c in: mapOppEventIds.keyset() or id in: mapOppEventIds.keyset()]){
                if(mapOppEventIds.containskey(pb.legacy_Id__c)  && mapOppEventIds.get(pb.legacy_Id__c) != null){
                    if(mapOppEventIds.get(pb.legacy_Id__c) == 'Confirm Refund' && pb.Refund_Addendum__c != null && pb.Refund_Addendum_Envelope_Message__c != null) 
                        EventIds.add(pb.legacy_Id__c);
                    else if(mapOppEventIds.get(pb.legacy_Id__c) == 'Apply Credit to New Date in 2020' && pb.Move_to_2020_Addendum__c != null && pb.Move_to_2020_Addendum_Envelope_Message__c != null) 
                        EventIds.add(pb.legacy_Id__c);
                    else if(mapOppEventIds.get(pb.legacy_Id__c) == 'Apply Credit* to the Future Event' && pb.Move_to_2021_Addendum__c != null && pb.Move_to_2021_Addendum_Envelope_Message__c != null) 
                        EventIds.add(pb.legacy_Id__c);
                }
                if(mapOppEventIds.containskey(pb.Id) && mapOppEventIds.get(pb.Id) != null){
                    if(mapOppEventIds.get(pb.Id) == 'Confirm Refund' && pb.Refund_Addendum__c != null && pb.Refund_Addendum_Envelope_Message__c != null) 
                        EventIds.add(pb.Id);
                    else if(mapOppEventIds.get(pb.Id) == 'Apply Credit to New Date in 2020' && pb.Move_to_2020_Addendum__c != null && pb.Move_to_2020_Addendum_Envelope_Message__c != null) 
                        EventIds.add(pb.Id);
                    else if(mapOppEventIds.get(pb.Id) == 'Apply Credit* to the Future Event' && pb.Move_to_2021_Addendum__c != null && pb.Move_to_2021_Addendum_Envelope_Message__c != null) 
                        EventIds.add(pb.Id);
                }
            }
        }
        if(EventIds.size()>0 || Test.isrunningtest()){ query += ' and (Event__c IN: EventIds or Pricebook2Id IN: EventIds)'; }
        
            CreditAdjustmentRefundBatch objBatch = new CreditAdjustmentRefundBatch(query,EventIds,setparentOppId);
            if(!Test.isRunningTest()){ 
                if(query.contains('and (Event__c IN')) ID batchprocessid = Database.executeBatch(objBatch,10);                
                 
            }        
        
    }
   
}