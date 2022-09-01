public class QE_QuoteMessageDisplayCtlr {

  public Boolean quoteMessageDisplay { get;set; }
  public Quote quoteRecd { get;set; }
  public String draftVariable = 'Draft';
  private ApexPages.StandardController controller;
  public Id quoteId ;
  
   public QE_QuoteMessageDisplayCtlr(ApexPages.StandardController controller){
       quoteMessageDisplay = false;
       quoteId = controller.getId();
       quoteRecd = [Select Id,status from Quote Where Id=:quoteId];
       if(quoteRecd.status == draftVariable){
           quoteMessageDisplay = true;
       }
   }
}