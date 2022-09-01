/**
 * @File Name          : QE_OpportunityPaymentTermsHelper.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/11/2020, 3:32:00 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/11/2020   jagrawal@addonblue.com     Initial Version
**/
public class QE_OpportunityPaymentTermsHelper {
    public QE_OpportunityPaymentTermsHelper(){}
    public void updateOpptPaymentTerms(Set<Id> opptIds) {
        // // Get opportunities with payment terms
        // List<Opportunity> lstOpportunitiesWithPaymentTerms = new List<Opportunity>([
        //     Select Id, Amount, Grand_Total__c, Package_Sub_Total__c, Hotel_Sub_Total__c, A_La_Carte_Sub_Total__c, Discount__c,CurrencyIsoCode,
        //         (Select Id, Opportunity__c, Payment_Term__c, Amount__c, Percentage_Of_Payment__c,CurrencyIsoCode 
        //          From Opportunity_Payment_Terms__r)
        //     From Opportunity
        //     Where Id in : opptIds
        // ]);
        // // Do the math for each payment terms.
        // List<Opportunity_Payment_Terms__c> opptPaymentTersmToUpdate = new List<Opportunity_Payment_Terms__c>(); 
        // for(Opportunity oppt : lstOpportunitiesWithPaymentTerms) {
        //     Decimal totalAmount = 0;
        //     Decimal totalPercentage = 0;
        //     //Decimal opptGrandTotal = ((oppt.Package_Sub_Total__c).setScale(2) + oppt.Hotel_Sub_Total__c + oppt.A_La_Carte_Sub_Total__c ) - oppt.Discount__c;
        //    // System.debug('oppt.Opportunity_Payment_Terms__r:'+oppt.Opportunity_Payment_Terms__r);
        //     // Only if oppt has existing payment terms
        //     if(oppt.Opportunity_Payment_Terms__r.size() > 0) {
        //         for(Opportunity_Payment_Terms__c paymentTerm : oppt.Opportunity_Payment_Terms__r){
        //             system.debug('####paymentTerm.Percentage_Of_Payment__c=='+paymentTerm.Percentage_Of_Payment__c); 
        //             system.debug('####oppt.Amount=='+oppt.Amount);
        //             paymentTerm.Amount__c = oppt.Amount * ((paymentTerm.Percentage_Of_Payment__c != null ? paymentTerm.Percentage_Of_Payment__c : 0)/100);
        //             system.debug('####paymentTerm.Amount__c =='+paymentTerm.Amount__c);
        //             paymentTerm.CurrencyIsoCode = oppt.CurrencyIsoCode;
        //             system.debug('####paymentTerm.CurrencyIsoCode =='+paymentTerm.CurrencyIsoCode);  
        //             totalPercentage = totalPercentage + (paymentTerm.Percentage_Of_Payment__c != null ? paymentTerm.Percentage_Of_Payment__c : 0);
        //             system.debug('####totalPercentage =='+totalPercentage);
        //             totalAmount = totalAmount + (paymentTerm.Amount__c != null ? paymentTerm.Amount__c : 0);
        //             system.debug('####totalAmount =='+totalAmount);
        //         }
        //         if(totalPercentage != 100) {
        //             if(oppt.Opportunity_Payment_Terms__r != null){
        //                 oppt.Opportunity_Payment_Terms__r[oppt.Opportunity_Payment_Terms__r.size() - 1].Percentage_Of_Payment__c = (oppt.Opportunity_Payment_Terms__r[oppt.Opportunity_Payment_Terms__r.size() - 1].Percentage_Of_Payment__c != null ? oppt.Opportunity_Payment_Terms__r[oppt.Opportunity_Payment_Terms__r.size() - 1].Percentage_Of_Payment__c : 0) + (100 - totalPercentage);
        //                 system.debug('####Percentage_Of_Payment__c  1 =='+oppt.Opportunity_Payment_Terms__r[oppt.Opportunity_Payment_Terms__r.size() - 1].Percentage_Of_Payment__c);
        //             }
        //         }
        //         if(totalAmount != oppt.Amount) {
        //            // system.debug('Test*1******'+oppt.Opportunity_Payment_Terms__r[oppt.Opportunity_Payment_Terms__r.size() - 1].Amount__c + (oppt.Amount - totalAmount));
        //            if(oppt.Opportunity_Payment_Terms__r != null){
        //             oppt.Opportunity_Payment_Terms__r[oppt.Opportunity_Payment_Terms__r.size() - 1].Amount__c = (oppt.Opportunity_Payment_Terms__r[oppt.Opportunity_Payment_Terms__r.size() - 1].Amount__c != null ? oppt.Opportunity_Payment_Terms__r[oppt.Opportunity_Payment_Terms__r.size() - 1].Amount__c : 0) + ((oppt.Amount != null?oppt.Amount:0) - totalAmount); // Error amounts not matching for 1/3
        //             system.debug(' ####Test********'+ oppt.Opportunity_Payment_Terms__r[oppt.Opportunity_Payment_Terms__r.size() - 1].Amount__c);
        //            }
        //         }
        //     }
        //     opptPaymentTersmToUpdate.addAll(oppt.Opportunity_Payment_Terms__r);
        // }
        // update opptPaymentTersmToUpdate;
    }
    // Capture deleted Opportunity Payment Terms
    // public void captureDeletedOpportunityPaymentTerms(List<Opportunity_Payment_Terms__c> oldList) {
    //     // Capture deleted product 
    //     List<QE_Deleted_Record__c> recordsBeingDeleted = new List<QE_Deleted_Record__c>();
    //     for (Opportunity_Payment_Terms__c opt : oldList) {
    //         QE_Deleted_Record__c deletedRecord = new QE_Deleted_Record__c();
    //         deletedRecord.Name = opt.Name;
    //         deletedRecord.DeletedId__c = opt.Id;
    //         recordsBeingDeleted.add(deletedRecord);
    //     }
    //     try {
    //         insert recordsBeingDeleted;
    //     } catch (Exception e) {
    //         System.debug('Exception: '+e);
    //     }
    // }
    /*
    public static void updatePaidInFullinOpportunity(Set<Id> opptIds){
        List<Opportunity> lstOpportunitiesToUpdate = new List<Opportunity>();
        System.debug('**opps**' +opptIds.size() + '***opp id**8' +opptIds);
        List<Opportunity> lstOpportunitiesWithPaymentTerms = new List<Opportunity>([Select Id,Paid_in_Full__c,
                (Select Id, Opportunity__c,Status__c From Opportunity_Payment_Terms__r WHERE Status__c !='Passed') From Opportunity Where Id in : opptIds]);
         system.debug('****lstOpportunitiesWithPaymentTerms**********'+lstOpportunitiesWithPaymentTerms);
             for(Opportunity opp :lstOpportunitiesWithPaymentTerms){
                 system.debug('**opp.Opportunity_Payment_Terms__r *****'+opp.Opportunity_Payment_Terms__r.size());
                 System.debug('***payment terms pay**' +opp.opportunity_payment_terms__r);
                  if(opp.Opportunity_Payment_Terms__r != null && opp.Opportunity_Payment_Terms__r.size() > 0){
                  System.debug('***payment terms pay not passed**' +opp.opportunity_payment_terms__r);
                        opp.Paid_in_Full__c = false;
                    lstOpportunitiesToUpdate.add(opp);
                  }
                  else{
                  System.debug('***payment terms pay all passed**' +opp.opportunity_payment_terms__r);
                      opp.Paid_in_Full__c = true;
                    lstOpportunitiesToUpdate.add(opp);
                    System.debug('****opp paid in full&&*'+opp.paid_in_full__C);
                  }
             }
         if(!lstOpportunitiesToUpdate.isEmpty()){
             update lstOpportunitiesToUpdate;
             System.debug('****opp updated***' +lstOpportunitiesToUpdate);
         }
    }
    */
    Public static void updateOrderpayStatus(Set<id> opprtIds) {
    //     List<Opportunity> oppOrderPayStatusLst = new List<Opportunity>();
    //     List<Opportunity> oppPayTermsLst = new List<Opportunity>([Select Id,Order_Payment_Status__c,Subject_to_Cancellation__c, 
    //             (Select Id, Opportunity__c,Status__c From Opportunity_Payment_Terms__r) From Opportunity Where Id in : opprtIds]);
    //      System.debug('****opp pay terms list**********'+oppPayTermsLst);
    //      for(Opportunity opp :oppPayTermsLst){
    //          integer i = 0;
    //          integer passSize = 0;
    //          integer Size = opp.Opportunity_Payment_Terms__r.size();
    //      System.debug('**terms list**'+Size);
              
    //           if(opp.Opportunity_Payment_Terms__r != null && opp.Opportunity_Payment_Terms__r.size() >0){                                      
    //                for(Opportunity_Payment_Terms__c oppTerms: opp.Opportunity_Payment_Terms__r){
    //                     if(oppTerms.Status__c != null && oppTerms.status__c == 'Passed') {
    //                         passSize++;
    //                         System.debug('***passed count**'+passSize);
    //                     }
    //                     else if(oppTerms.status__c == null || oppTerms.status__C != 'Passed')
    //                     {
    //                         i++;
    //                         System.debug('***i count**'+i);
    //                     }
    //                 }
    //               System.debug('***i count final**'+i);
    //               System.debug('***passed count final**'+passSize);
    //                     }
                        
    //               if(passSize > 0 && passSize < size) {                
    //                 opp.Order_Payment_Status__c = 'Partially Paid';
    //                  if(opp.Subject_to_Cancellation__c == true) {
    //                     opp.Subject_to_Cancellation__c = false;
    //                   }
    //                 oppOrderPayStatusLst.add(opp);
    //               }

    //               else if(passSize == size) {
    //                 opp.Order_Payment_Status__c = 'Fully Paid';
    //                 opp.Paid_in_Full__c = true;
    //                  if(opp.Subject_to_Cancellation__c == true) {
    //                     opp.Subject_to_Cancellation__c = false;
    //                  }
    //                 oppOrderPayStatusLst.add(opp);
    //               }

    //               else if(passSize == 0) {
    //                 opp.Order_Payment_Status__c = 'Not Paid';
    //                 oppOrderPayStatusLst.add(opp);
    //                 }
    
    // }
    // if(!oppOrderPayStatusLst.isEmpty()){
    //     update oppOrderPayStatusLst;   
    // }
   } 
   
//    public static void updateInvoiceDatetoIntacct(List<Opportunity_Payment_Terms__c> newOppPaymentTerm, Map<Id,Opportunity_Payment_Terms__c> oldOPTMap){
//        set<Id> setOPTIds = new set<Id>();
//        for(Opportunity_Payment_Terms__c opt: newOppPaymentTerm){
//            if(opt.Payment_Due_Date__c != null && opt.Payment_Due_Date__c != oldOPTMap.get(opt.Id).Payment_Due_Date__c){
//                setOPTIds.add(opt.Id);
//            }
//        }
//        if(setOPTIds.size()>0){
//            calloutToupdateIntacctDate(setOPTIds);
//        }
//    }
   
   @future(callout=true)
   public static void calloutToupdateIntacctDate(Set<Id> setOptIds){
    //    List<Opportunity_Payment_Terms__c> lstOPT = New List<Opportunity_Payment_Terms__c>([Select id,Payment_Due_Date__c,Record_Id__c,Intacct_Id__c,Sandbox_Intacct_Id__c,Location_Id__c,Sandbox_Record_Id__c from Opportunity_Payment_Terms__c where id in: setOptIds and (Record_Id__c != null or Sandbox_Record_Id__c != null)]);
    //    Intacct_API_Details__c cs = Intacct_API_Details__c.getOrgDefaults();
    //    List<Opportunity_Payment_Terms__c> lstupdatepaymentTerms = New List<Opportunity_Payment_Terms__c>();
    //    if(lstOPT.size()>0 || Test.IsrunningTest()){
    //        for(Opportunity_Payment_Terms__c op: lstOPT){
    //            Opportunity_Payment_Terms__c opt = new Opportunity_Payment_Terms__c();
    //            opt = createIntacctInvoiceDateRequest(cs,op);
    //            lstupdatepaymentTerms.add(opt);
    //        }
    //    }
    //    if(lstupdatepaymentTerms.size()>0){
    //        Update lstupdatepaymentTerms;
    //    }
       
   }
   
//    @testvisible private static Opportunity_Payment_Terms__c createIntacctInvoiceDateRequest(Intacct_API_Details__c cs, Opportunity_Payment_Terms__c opt){
//         Dom.Document xmlDoc = new Dom.Document();
//         dom.XmlNode function = QE_Intacct_FutureCallout.controlAuthXML(cs, xmlDoc,string.valueof(opt.Location_Id__c));
//         //dom.XmlNode read = function.addChildElement('update_invoice', null, null);
//         dom.XmlNode read = function.addChildElement('update_sotransaction', null, null);
//         //read.setAttribute('key',cs.Production__c? opt.Record_Id__c: opt.Sandbox_Record_Id__c);
//         read.setAttribute('key',cs.Production__c? 'Sales Invoice-'+opt.Intacct_Id__c: 'Sales Invoice-'+opt.Sandbox_Intacct_Id__c);
//         dom.XmlNode read1 = read.addChildElement('datedue', null, null);
//         read1.addChildElement('year', null, null).addTextNode(string.valueof(opt.Payment_Due_Date__c.year()));
//         read1.addChildElement('month', null, null).addTextNode(string.valueof(opt.Payment_Due_Date__c.month()));
//         read1.addChildElement('day', null, null).addTextNode(string.valueof(opt.Payment_Due_Date__c.day()));
       
//         HttpRequest req = new HttpRequest();
//         req.setMethod('POST');
//         req.setEndpoint(cs.Production__c? cs.EndpointURL__c: cs.Sandbox_EndpointURL__c);
//         req.setHeader('Content-Type', 'text/xml');
//         req.setBodyDocument(xmlDoc);
//         System.debug('Request: '+xmlDoc.toXmlString());        
//         Http http = new Http();
//         if(!Test.Isrunningtest()){
//             HttpResponse res = http.send(req);
//             Dom.Document resDoc = res.getBodyDocument();
//             System.debug('Responce: '+resDoc.toXmlString());
//             String successStatus = resdoc.getRootElement().getChildElement('operation', null).getChildElement('result', null).getChildElement('status', null).getText();            
//             if(successStatus == 'Success'){
//                 String strRECORDNO = QE_Intacct_FutureCallout.getInvoiceRecordId(cs.Production__c?opt.Intacct_Id__c:opt.Sandbox_Intacct_Id__c, cs);
//                 opt.put(cs.Production__c? 'Record_Id__c' : 'Sandbox_Record_Id__c' ,strRECORDNO);                
//             }           
//         }
        
//         return opt;
//    }
   
  
}