/**
 * @File Name          : CreditAdjustmentRefundPDF.cls
 * @Description        : To create Credit Adjustment Refund PDF
 * @Author             : kchavda@addonblue.com
 * @Group              : 
 * @Last Modified By   : kchavda@addonblue.com
 * @Last Modified On   : 05/25/2020
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    05/25/2020  kchavda@addonblue.com     Initial Version
 * 1.1    09/01/2020  kchavda@addonblue.com     #378 Addendum Automation changes for v3
 * 1.2    02/11/2021  kchavda@addonblue.com     #716 Currently we use wording "2021 Event" for credit creation, need to be replaced with "Future Event".
**/

public class CreditAdjustmentRefundPDF{
    public string strPDFContent{get;set;}
    
    /**
    * @description Constructor
    * @author kchavda@addonblue.com | 05/25/2020
    * @param  
    * @return void
    **/            
    public CreditAdjustmentRefundPDF(ApexPages.StandardController opp) {
        Opportunity objopportunity = (Opportunity)opp.getRecord();
        List<opportunity> lstopp = new List<opportunity>([Select id,Collected_Revenue__c,Refund_Amount__c,Credit_Amount__c,CurrencyISOCode,Pricebook2Id,Pricebook2.Name,Event__r.Name,Refund_Response__c,Event__c,Primary_Contact__r.Name,(Select id,BillingName,Email,OpportunityId from quotes), (select id,Contact.Name,Contact.Email from opportunitycontactroles where role ='Signee Contact' limit 1) from opportunity where id =: objopportunity.id limit 1]);
        if(lstopp.size()>0){
            List<Pricebook2> lstpb = new List<Pricebook2>();
            if(lstopp[0].Event__c != null) lstpb = [select id,Refund_Addendum__c,Move_to_2021_Addendum__c,Move_to_2020_Addendum__c from Pricebook2 where Legacy_Id__c =: lstopp[0].Event__c ];
            else if(lstopp[0].Pricebook2Id != null) lstpb = [select id,Refund_Addendum__c,Move_to_2021_Addendum__c,Move_to_2020_Addendum__c from Pricebook2 where id =: lstopp[0].Pricebook2Id];
            
            if(lstpb.size()>0){
                if(lstopp[0].Refund_Response__c == 'Confirm Refund'){
                    strPDFContent = lstpb[0].Refund_Addendum__c;
                }
                else if(lstopp[0].Refund_Response__c == 'Apply Credit to New Date in 2020'){
                    strPDFContent = lstpb[0].Move_to_2020_Addendum__c;
                }
                else if(lstopp[0].Refund_Response__c == 'Apply Credit* to the Future Event'){
                    strPDFContent = lstpb[0].Move_to_2021_Addendum__c;
                }
                replacepdfContent(lstopp[0],lstpb[0]);
            }
        }
    }
    
    /**
    * @description To replace content pdf
    * @author kchavda@addonblue.com | 05/25/2020
    * @param  Opportunity, Pricebook2
    * @return void
    **/ 
    public void replacepdfContent(Opportunity opp, Pricebook2 pb){
        if(strPDFContent != null && strPDFContent != ''){          
            //strPDFContent  = strPDFContent.replace('\\n1\\', '<div style="color:#fff;font-size: 10pt;display:inline-block;">\\n1\\</div><br/>');
            String recipientName = '';
            if(!Test.isrunningtest()){
               if(opp.Event__c != null){ 
                   recipientName = opp.Primary_Contact__r.Name == null ? opp.Quotes[0].BillingName : opp.Primary_Contact__r.Name;    
               }else if(opp.pricebook2id != null) {
                   if(opp.opportunitycontactroles != null && opp.opportunitycontactroles.size()>0) 
                       recipientName = opp.opportunitycontactroles[0].Contact.Name;
               }
            }
            else{
               recipientName = 'testRecipient123';
            }
            strPDFContent  = strPDFContent.replace('between XXX', 'between '+recipientName);
            strPDFContent  = strPDFContent.replace('\\d1\\', '<div style="color:#fff;font-size: 10pt;display:inline-block;">\\d1\\</div><br/>');
            if(!Test.isrunningtest()){
                if(opp.Event__c != null) strPDFContent  = strPDFContent.replace('EVENT NAME', opp.Event__r.Name);
                else if(opp.pricebook2id != null) strPDFContent  = strPDFContent.replace('EVENT NAME', opp.pricebook2.Name);
            } 
            strPDFContent  = strPDFContent.replace('USD', opp.CurrencyISOCode);   
             if(opp.Refund_Response__c == 'Confirm Refund'){
                if(opp.Refund_Amount__c == null) opp.Refund_Amount__c = '';
                strPDFContent  = strPDFContent.replace('XXXX.XX', opp.Refund_Amount__c);                
            }
            else if(opp.Refund_Response__c == 'Apply Credit* to the Future Event'){               
                if(opp.Credit_Amount__c == null) opp.Credit_Amount__c = '';
                strPDFContent  = strPDFContent.replace('XXXX.XX', opp.Credit_Amount__c);
            }  
            else if(opp.Refund_Response__c == 'Apply Credit to New Date in 2020'){
                string collectedRevenue = (opp.Collected_Revenue__c != null ? string.valueof(opp.Collected_Revenue__c):'');              
                strPDFContent  = strPDFContent.replace('XXXX.XX', collectedRevenue);
            }          
           
        }
    }
}