public class QE_Add_Packages_and_Products_btn_Class{
public Id opp_ID;
public boolean displayPopup {get;set;}
public string page_URL{get;set;}
public QE_Add_Packages_and_Products_btn_Class(ApexPages.StandardController stdController)
{
//RedirectMethod();
}
   public pageReference closePopup()
   {
       displayPopup=false;
       pageReference ref=new pageReference('/'+opp_ID);
       ref.setRedirect(true);
       return ref;
   }
   public pageReference RedirectMethod()
   {
       List<Opportunity> lstOpportunity=new List<Opportunity>();
        opp_ID=ApexPages.currentPage().getParameters().get('Oppid');
        lstOpportunity=[select Id from Opportunity where id=: opp_ID and (StageName='Closed Won' OR StageName='Closed Lost')];
        if(lstOpportunity.size()>0)
        {
             displayPopup=true;
            return null;
        }
        else
        {
           pageReference ref=new pageReference('/apex/QE_productSelectionPage?id='+opp_ID);
           ref.setRedirect(true);
           return ref;
         }
   }
}