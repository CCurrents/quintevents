public class ReverseOrderController_LEX {
    
    @AuraEnabled
    public static Boolean checkOrderEligible(string orderId){
          List<Order> objorder = [Select id from Order where  Id=:orderId  and Record_Id__c!=null and Intacct_Id__c!=null];
         
        return objorder.isEmpty()?true:False;
    }
    
    @AuraEnabled
    Public static void createReverseOrder(string orderId){
        string orderQuery = 'Select '+fetchObjectFields('Order')+' from Order where  Id=:orderId  and Record_Id__c!=null and Intacct_Id__c!=null';
        List<Order> orderWithterms = Database.query(orderQuery);
        string ptermQuery = 'Select '+fetchObjectFields('Payment_Term__c')+' from Payment_Term__c where  order__c=:orderId and Record_Id__c!=null and Intacct_Id__c!=null';
        List<Payment_Term__c> orderpaymentTerms = Database.query(ptermQuery);
        if(!orderWithterms.isEmpty()){
            List<Payment_Term__c> paymentTerms = new List<Payment_Term__c>();
            // List<Charge__c> orderCharges = orderWithterms[0].Charges__r;
            // List<Charge__c> charges = [Select id,Intacct_Id__c,Intacct_Record_Id__c from Charge__c where ]
            Order actualOrder = orderWithterms[0];
            Order reverseOrder =  actualOrder.clone(false,true,false,false);
            reverseOrder.Original_Order__c = actualorder.Id;
            reverseOrder.status = 'Reverse - Sales Adjustment';            
            insert reverseOrder;
            for(Payment_Term__c pterm: orderpaymentTerms){
                Payment_Term__c reverseterm = pterm.clone(false,true,false,false);
                reverseterm.Order__c = reverseOrder.id;
                paymentTerms.add(reverseterm);
            } 
            insert paymentTerms;                
            List<Payment_Term__c> updateTerms = new List<Payment_Term__c>();
            for(Payment_Term__c pterm: orderpaymentTerms){
                pterm.Intacct_Adjustment_Applied__c=false;
                pterm.Intacct_Adjustment_Created__c = false;
                pterm.Intacct_Adjustment_Id__c ='';
                pterm.Intacct_Apply_Adjustment_Id__c ='';
                pterm.Intacct_Apply_ARPayment_Status__c='';
                pterm.Intacct_Credit_Memo_Id__c='';
                pterm.Intacct_Credit_Memo_Record_Id__c='';
                pterm.Intacct_Id__c='';
                pterm.Intacct_Failure_Reason__c='';
                pterm.Intacct_Line_Number__c='';
                pterm.Intacct_Record_URL__c='';
                pterm.Intacct_Status__c='';
                pterm.Record_Id__c='';
                pterm.Sent_to_Intacct__c=false;
                updateTerms.add(pterm);
            }
            
            update updateTerms;
            updateOrder( actualOrder);
        }        
    }
    
    public static void updateOrder(Order actualOrder){
        actualOrder.Intacct_Id__c='';
        actualOrder.Intacct_Failure_Reason__c='';
        actualOrder.Intacct_Record_URL__c='';
        actualOrder.Intacct_Status__c='';
        actualOrder.Record_Id__c ='';
        actualOrder.Sent_to_Intacct__c = false;
        update actualOrder;        
    }
    
    public static string fetchObjectFields(String ObjectAPIName){
         String FiedNames = '';
        SObjectType objectType = Schema.getGlobalDescribe().get(ObjectAPIName);
        Schema.DescribeSObjectResult obj = objectType.getDescribe();
         if(obj!=Null)
         {
           
         Map<String , Schema.SObjectField> mapFieldList = obj.fields.getMap();  

         for(Schema.SObjectField field : mapFieldList.values())  
         {  
            Schema.DescribeFieldResult fieldResult = field.getDescribe();  
          // if(fieldResult.accessible){
                FiedNames+= field +',';
             }
        // }
         if(FiedNames.endsWith(','))
         {
           
            FiedNames= FiedNames.removeEnd(',');
         }
        }
         return FiedNames;
    }
}