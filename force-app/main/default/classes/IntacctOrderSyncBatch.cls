/**
* @File Name          : IntacctOrderSyncCalloutBatch.cls
* @Description        : Batch class to make a callout to Intacct and sync Salseforce records on Order Creation.
* @Author             : Lovel Panchal
* @Group              : QE360V3
* @Last Modified By   : jagrawal@addonblue.com
* @Last Modified On   : 01-12-2021
* @Modification Log   : 
* Ver       Date            Author                  Modification
* 1.0       1/17/2020       Lovel Panchal          Initial Version
* 1.1       3/4/2020        jagrawal@addonblue.com Updated Class Name and the referenced class name
**/
public class IntacctOrderSyncBatch implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful{ 
    // Collections
    Map<String,String> MapKeys = new Map<String, String>(); // Set to Contain all the Intacct Objects which are pending to be processed via batch
    List<String> lstKeys = new List<String>(); // List will be temp holder for setKeys
    Map<string,sObject> mapObj = new Map<string,sObject>(); // Map will hold all the key value of SF Object Fields and to Intacct Object and Fields
    MAP<String,MAP<String,String>> mapIntacctSFData =  new MAP<String, MAP<String, String>>(); // Map to store Intacct Field Nodes with SF Data
    // Primitive Data 
    String OrderID = '';
    String query = '';
    //String OPT_Id = '';
    String Contact_Id = '';
    public boolean  lastRunFlag = null;
    public String accountId = null; 
    String nodeValue = null;   
    String Obj_Id = null;
     // Flag to check recusive call's last elment from contact
    // Batch class will be called from Order Trigger After Insert
    // Constructor will invoked first time call to the batch
    public IntacctOrderSyncBatch(String OrderID){
        List<SFDCToIntacctMap__c> sfdcToMapping = [Select Intacct_Object__c, Intacct_Table__c from SFDCToIntacctMap__c where Active__c = true AND Type__c = 'Order' ORDER BY Level__c ];
        for(SFDCToIntacctMap__c obj:sfdcToMapping) {
            if(String.isnotEmpty(obj.Intacct_Object__c) && obj.Intacct_Object__c.toLowerCase() != 'CONTACT'.toLowerCase()) {
                MapKeys.put(obj.Intacct_Object__c.toLowerCase(),obj.Intacct_Table__c);
            }
        }
        lstKeys.addAll(MapKeys.keyset());
        system.debug('lstKeys--->'+lstKeys);
        this.OrderID = OrderID;
    }
    // Constructor will be invoked when Intacct Table is Customer or Contact
    public IntacctOrderSyncBatch(String OrderID,List<String> lstKeys){
        this.lstKeys = lstKeys;
        this.OrderID = OrderID;
    }
    // Constructor will be invoked wehn Intacct Table is Sales Invoice (so_Transaction) or AR Payments
    public IntacctOrderSyncBatch(String OrderID,List<String> lstKeys, String Obj_Id){
        if(lstKeys[0].toLowerCase() == 'arpayment'){
            string ptId;
            if(Obj_Id != null) ptId = Obj_Id.split('###')[0];
            Payment_Term__c opt = [Select Id,Opportunity_Currency__c,Payment_Method__c,Order__r.International_Stripe__c from Payment_Term__c where Id =:ptId];
            accountId = IntacctOrderSyncBatchHelper.getBankAccountId(opt);
            if(opt.Opportunity_Currency__c !=  'USD'){
                nodeValue = 'bankaccountid';
            }
            else
                nodeValue = 'undepfundsacct';
            system.debug('accountId---'+accountId);    
        }
       this.lstKeys = lstKeys;
       this.OrderID = OrderID;
       this.Obj_Id = Obj_Id;
       if(lstKeys[0].toLowerCase() == 'CONTACT'.toLowerCase())
            this.Contact_Id = Obj_Id; 
       /*else{
           OPT_Id = Obj_Id;
       }*/     
    }  
    // Constructor will be invoked wehn Intacct Table is Sales Invoice (so_Transaction) or AR Payments
    public IntacctOrderSyncBatch(String OrderID,List<String> lstKeys, String Obj_Id, boolean lastRunFlag){
        if(lstKeys[0].toLowerCase() == 'arpayment'){
            string ptId;
            if(Obj_Id != null) ptId = Obj_Id.split('###')[0];
            Payment_Term__c opt = [Select Id,Opportunity_Currency__c,Payment_Method__c,Order__r.International_Stripe__c from Payment_Term__c where Id =:ptId];
            accountId = IntacctOrderSyncBatchHelper.getBankAccountId(opt);
             if(opt.Opportunity_Currency__c !=  'USD'){
                nodeValue = 'bankaccountid';
             }
            else
                nodeValue = 'undepfundsacct';
        }
       this.lstKeys = lstKeys;
       System.debug('lstKeys--->'+this.lstKeys);
       this.OrderID = OrderID;
       this.lastRunFlag = lastRunFlag;
       this.Obj_Id = Obj_Id;
       if(lstKeys[0].toLowerCase() == 'CONTACT'.toLowerCase())
            this.Contact_Id = Obj_Id; 
       /*else{
           OPT_Id = Obj_Id;
       }*/     
    }    
    // Start method will always Query Top most Table name of from lstKeys   
    public Database.QueryLocator start(Database.BatchableContext BC){
        String intacctObjName;
        if(lstKeys.size() > 0){
            intacctObjName = lstKeys[0].toLowerCase(); // Object Name
        }
        query = 'Select Id, Active__c, Constant_Value__c, Custom_Logic__c, Custom_Setting_Name__c,Description__c, Intacct_Node_Name__c, Intacct_Object__c, Intacct_Table__c, Line_Item__c, Operation__c, SF_Field_API_Name__c,SF_Object__c, Sequence__c, Type__c from SFDCToIntacctMap__c where Active__c = true and  Intacct_Object__c =:intacctObjName'; // Object Name
        // Method to get all SF Object and its data required to fetch Intacct Table details           
        IntacctOrderSyncBatchHelper helper;
        System.debug('Obj_Id---->'+Obj_Id);
        System.debug('intacctObjName---->'+intacctObjName);
        System.debug('OrderID---->'+OrderID);
        if(String.isNotBlank(Obj_Id)){
            System.debug('Contact_Id---->'+Contact_Id);
            helper = new IntacctOrderSyncBatchHelper(OrderID,intacctObjName,Obj_Id);
        }
        else {
            helper = new IntacctOrderSyncBatchHelper(OrderID,intacctObjName);         
        }
        mapObj = helper.createXMLDataForRequest();
        system.debug('mapObj--->'+mapObj);
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        try{
            system.debug('scope----'+scope );
            if(mapObj != null){
                for(SFDCToIntacctMap__c obj : (List<SFDCToIntacctMap__c>)scope){
                    Map<String, String> tempMap = new Map<String, String>();
                    String dataValue =  '';
                    try{
                        If(String.isnotEmpty(obj.Intacct_Object__c) &&  String.isnotEmpty(obj.Intacct_Node_Name__c) && (( String.isnotEmpty(obj.SF_Object__c)   &&  String.isnotEmpty(obj.SF_Field_API_Name__c) && mapObj.get(obj.SF_Object__c) != null ) || (String.isnotEmpty(obj.Constant_Value__c)))){
                            // If Static Value and not equals to custom setting
                            if(String.isnotEmpty(obj.Constant_Value__c) && obj.Constant_Value__c != 'CUSTOMSETTING'){
                                dataValue = obj.Constant_Value__c;
                            }
                            else If(String.isEmpty(obj.Constant_Value__c) && String.isnotEmpty(obj.SF_Object__c) && String.isnotEmpty(obj.SF_Field_API_Name__c) && mapObj.get(obj.SF_Object__c).get(obj.SF_Field_API_Name__c) != null ){
                                dataValue =  String.valueof(mapObj.get(obj.SF_Object__c).get(obj.SF_Field_API_Name__c));
                            }
                            if(mapIntacctSFData.get(obj.Intacct_Object__c.toLowerCase()) != null)
                                tempMap = mapIntacctSFData.get(obj.Intacct_Object__c.toLowerCase());
                            // Checking Static Values for Bank Account Id for AR Payment    
                            if(obj.Intacct_Object__c.toLowerCase() == 'arpayment' && (obj.Intacct_Node_Name__c.toLowerCase() ==  'undepfundsacct' || obj.Intacct_Node_Name__c.toLowerCase() ==  'bankaccountid')){
                                if(!String.isEmpty(nodeValue)){
                                     tempMap.put(nodeValue ,accountId);
                                }    
                            }
                            else{
                                 /*if(obj.Intacct_Node_Name__c.contains('datedue')){                                    
                                    if(obj.Intacct_Object__c == 'Sales Invoice' && date.valueof(dataValue)<system.today()){
                                        datavalue = String.valueof(mapObj.get(obj.SF_Object__c).get('Opportunity_CloseDate__c'));
                                        tempMap.put(obj.Intacct_Node_Name__c,dataValue);
                                    }else{
                                        tempMap.put(obj.Intacct_Node_Name__c,dataValue);
                                    }
                                }*/
                                
                                if(obj.Intacct_Node_Name__c == 'arpaymentkey' && string.isblank(datavalue)){
                                    datavalue = String.valueof(mapObj.get('Payment_Term__c').get('Intacct_Credit_Memo_Record_Id__c'));
                                    tempMap.put(obj.Intacct_Node_Name__c,dataValue);
                                }
                                else{                                    
                                    tempMap.put(obj.Intacct_Node_Name__c,dataValue);                                   
                                }                                
                            }
                            system.debug('--- MAP---- '+obj.Intacct_Node_Name__c +'='+dataValue);
                            mapIntacctSFData.put(obj.Intacct_Object__c.toLowerCase(),tempMap);
                        }
                    } 
                    catch(exception ex){
                        system.debug('Exception:'+ex.getlinenumber() +'-->'+ex.getmessage());
                        Log.debug('Exception:'+ex.getlinenumber() +'-->'+ex.getmessage());
                    } 
                }
            }
            system.debug('mapIntacctSFData-->'+mapIntacctSFData);
        }
        catch(exception ex){
            system.debug('Exception:'+ex.getlinenumber() +'-->'+ex.getmessage());
            Log.debug('Exception:'+ex.getlinenumber() +'-->'+ex.getmessage());
            //IntacctOrderSyncBatchHelper.AsyncLogException('QE_Intacct_OrdersSyncCallout','EXECUTE',ex.getmessage(),ex.getlinenumber(),OrderId);
        }    
    }
    // On finish we will remove the Intacct Object which has processed and Call batch recursively
    public void finish(Database.BatchableContext BC){
        try{
            System.debug('lstKeys@@'+lstKeys);
         IntacctOrderSyncBatchHelper helper;
        if(String.isNotBlank(Obj_Id)){
            System.debug('Obj_Id@@'+Obj_Id);
              helper = new IntacctOrderSyncBatchHelper(OrderID,lstKeys[0],Obj_Id);
        }else {
             helper = new IntacctOrderSyncBatchHelper(OrderID,lstKeys[0]);
        }if(mapObj != null && mapIntacctSFData.get(lstKeys[0].toLowerCase()) != null){
            helper.doIntacctCallout(mapIntacctSFData.get(lstKeys[0].toLowerCase()),mapObj);
        }
        lstKeys.remove(0); 
        if(lastRunFlag == true){
            IntacctOrderSyncBatch inta = new IntacctOrderSyncBatch(OrderID);
            Database.executebatch(inta); 
        }
        
        if(lstKeys.size() > 0 &&  lstKeys[0].toLowerCase() != 'Sales Invoice'.toLowerCase()){
            IntacctOrderSyncBatch batchId = new IntacctOrderSyncBatch(OrderID,lstKeys);
            Database.executebatch(batchId);
        }
        else if(lstKeys.size() > 0 && lstKeys[0] == 'Sales Invoice'){
            System.debug('Sales Invoice@@@@@@@@@@@@');
            Order objOrder =  [Select QuoteId,Intacct_Id__c from Order where Id =: OrderID]; 
               if(objOrder != null && objOrder.QuoteId != null && objOrder.Intacct_Id__c != null){
                   System.debug('lstKeys[0]@@'+lstKeys[0]);
                    IntacctInvoiceSyncBatch batchId = new IntacctInvoiceSyncBatch(OrderID,new list<String> { 'Sales Invoice'});
                    Database.executebatch(batchId,1);
                }
            }
        }
        catch(exception ex){
            Log.debug('Exception:'+ex.getlinenumber() +'-->'+ex.getmessage());
            system.debug('Exception:'+ex.getlinenumber() +'-->'+ex.getmessage());
        }
        
    }
}