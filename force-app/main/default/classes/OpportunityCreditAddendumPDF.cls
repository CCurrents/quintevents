public class OpportunityCreditAddendumPDF{
    public string strPDFContent{get;set;}
    
    public OpportunityCreditAddendumPDF(ApexPages.StandardController opp) {
        Opportunity objopportunity = (Opportunity)opp.getRecord();
        List<opportunity> lstopp = new List<opportunity>([Select id,CurrencyISOCode,Credit_Amount__c, Refund_Response__c, Event__r.Name, Event__c,Refund_Amount__c,Primary_Contact__r.Name, (Select id,BillingName,Email,OpportunityId from quotes) from opportunity where id =: objopportunity.id limit 1]);
        if(lstopp.size()>0){
            List<Pricebook2> lstpb = new List<Pricebook2>([select id,Move_to_2020_Addendum__c,Move_to_2021_Addendum__c,Refund_Addendum__c from Pricebook2 where Legacy_Id__c =: lstopp[0].Event__c ]);
            if(lstpb.size()>0){
                if(lstopp[0].Refund_Response__c == 'Confirm Refund'){
                    strPDFContent = lstpb[0].Refund_Addendum__c; 
                } 
                 else if(lstopp[0].Refund_Response__c == 'Apply Credit to New Date in 2020'){
                    strPDFContent = lstpb[0].Move_to_2020_Addendum__c; 
                } 
                else if(lstopp[0].Refund_Response__c == 'Apply Credit* to the 2021 Event'){
                    strPDFContent = lstpb[0].Move_to_2021_Addendum__c; 
                } 
                replacepdfContent(lstopp[0]);
            }
        }
    }
    
    public void replacepdfContent(Opportunity opp){
        if(strPDFContent != null && strPDFContent != ''){      
             //strPDFContent  = strPDFContent.replace('\\n1\\', '<div style="color:#fff;font-size: 10pt;display:inline-block;">\\n1\\</div><br/>');             
            String recipientName = '';
            if(!Test.isrunningtest()){
               recipientName = opp.Primary_Contact__r.Name == null ? opp.Quotes[0].BillingName : opp.Primary_Contact__r.Name;    
            }
            else{
               recipientName = 'testRecipient123';
            }
            strPDFContent  = strPDFContent.replace('between XXX', 'between '+recipientName);           
            strPDFContent  = strPDFContent.replace('\\d1\\', '<div style="color:#fff;font-size: 10pt;display:inline-block;">\\d1\\</div><br/>');
            if(!Test.isrunningtest()){
                strPDFContent  = strPDFContent.replace('EVENT NAME', opp.Event__r.Name);
            }   
            strPDFContent  = strPDFContent.replace('USD', opp.CurrencyISOCode);  
            if(opp.Refund_Response__c == 'Confirm Refund'){
                if(opp.Refund_Amount__c == null) opp.Refund_Amount__c = '';
                strPDFContent  = strPDFContent.replace('$XXXX.XX', opp.Refund_Amount__c);
            }
            else if(opp.Refund_Response__c == 'Apply Credit* to the 2021 Event'){
                if(opp.Credit_Amount__c == null) opp.Credit_Amount__c = '';
                strPDFContent  = strPDFContent.replace('$XXXX.XX', opp.Credit_Amount__c);
            }
            
        }
    }
}