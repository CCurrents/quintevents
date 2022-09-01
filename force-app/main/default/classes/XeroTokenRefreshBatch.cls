/**
 * @File Name          : XeroTokenRefreshBatch.cls
 * @Description        : To get refresh token 
 * @Author             : kchavda@addonblue.com
 * @Group              : 
 * @Last Modified By   : kchavda@addonblue.com
 * @Last Modified On   : 04/02/2020
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    04/02/2020  kchavda@addonblue.com     Initial Version
 * 1.1    09/07/2020   kchavda@addonblue.com      #519 Xero Related Changes
**/
public class XeroTokenRefreshBatch  implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful{    
    String invoiceId;
    Order objOrder = new Order();   
    string type;
    Payment_Term__c PaymentTerm = new Payment_Term__c();
    
    
    /**
    * @description Constructor
    * @author kchavda@addonblue.com | 04/02/2020
    * @param String, Order 
    * @return
    **/
    public XeroTokenRefreshBatch(string type,Order objOrder, string invoiceId, Payment_Term__c PaymentTerm ){                   
        this.objOrder = objOrder;
        this.invoiceId = invoiceId;
        this.type = type;
        this.PaymentTerm = PaymentTerm;       
    }
    
    /**
    * @description Start Method
    * @author kchavda@addonblue.com | 04/02/2020
    * @param Database.BatchableContext 
    * @return Database.QueryLocator
    **/
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('Select Access_Token__c,Tenant_Id__c, Refresh_token__c from Xero_Configuration__c where Active__c = true LIMIT 1');
    }
    
    /**
    * @description Execute Method
    * @author kchavda@addonblue.com | 04/02/2020
    * @param Database.BatchableContext, List<sObject>
    * @return void 
    **/
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        try{
            system.debug('###scope=='+scope);
            if(!scope.isEmpty()){    
                List<Xero_Configuration__c> lstxeroconfig = (List<Xero_Configuration__c>) scope;      
                system.debug('###lstxeroconfig[0].Refresh_Token__c=='+lstxeroconfig[0].Refresh_Token__c);     
                XeroOAuthController.refreshAccessTokenOnFailure(lstxeroconfig[0].Refresh_Token__c);
            }
        }
        catch(exception ex){
            System.debug('Exception :-QE360V3_XeroTokenRefreshBatch-'+ex.getlinenumber()+'--'+ex.getmessage());
            Log.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
        }     
    }
    
    /**
    * @description Finish Method
    * @author kchavda@addonblue.com | 04/02/2020
    * @param Database.BatchableContext
    * @return void 
    **/
    public void finish(Database.BatchableContext BC){    
        try{    
            if(type == 'Contact' && objOrder != null){                
                XeroSFCalloutBatch batch = new XeroSFCalloutBatch(new set<Id>{objOrder.Id}); 
                Database.executeBatch(batch,1); 
            }
            
        }
        catch(exception ex){
            System.debug('Exception :-QE360V3_XeroTokenRefreshBatch-'+ex.getlinenumber()+'--'+ex.getmessage());
            Log.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
        }  
    }
}