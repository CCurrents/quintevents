public class OpportunityAddendumPDF{
    public string strPDFContent{get;set;}
    
    public OpportunityAddendumPDF(ApexPages.StandardController opp) {
        Opportunity objopportunity = (Opportunity)opp.getRecord();
        List<opportunity> lstopp = new List<opportunity>([Select id,Event__r.Addendum__c from opportunity where id =: objopportunity.id limit 1]);
        if(lstopp.size()>0){
            strPDFContent = lstopp[0].Event__r.Addendum__c;  
            replacepdfContent();
        }
    }
    
    public void replacepdfContent(){
        if(strPDFContent != null && strPDFContent != ''){          
            strPDFContent  = strPDFContent.replace('\\n1\\', '<div style="color:#fff;font-size: 10pt;display:inline-block;">\\n1\\</div><br/>');
            strPDFContent  = strPDFContent.replace('\\d1\\', '<div style="color:#fff;font-size: 10pt;display:inline-block;">\\d1\\</div><br/>');
        }
    }
}