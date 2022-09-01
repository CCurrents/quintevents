/**
 * @File Name          : SendOrderToXero.cls
 * @Description        : To send failed order to xero
 * @Author             : kchavda@addonblue.com
 * @Group              : 
 * @Last Modified By   : kchavda@addonblue.com
 * @Last Modified On   : 04/16/2020
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    04/16/2020  kchavda@addonblue.com     Initial Version
*/
public with sharing class SendOrderToXero{

   /**
    * @description To send order to Xero
    * @author kchavda@addonblue.com | 04/16/2020
    * @param Order 
    * @return string
    **/    
    @Auraenabled
    public static string processOrder(Id OrderId){ 
        List<Order> lstorder = new List<Order>([Select id,opportunity.pricebook2.GPE_Event__c,xero_response__c from order where id =: OrderId]);
        String displayMsg = '';
        if(!lstorder.isempty()){
            if(lstorder[0].opportunity.pricebook2.GPE_Event__c == true){
                if(lstorder[0].xero_response__c == 'Success'){
                    displayMsg = 'The Sales Order already sent to Xero';
                }else{                
                    OrderTriggerHelper.processOrdersForXero(lstorder[0]); 
                }
            }
        }
        
        return displayMsg;
         
    }
}