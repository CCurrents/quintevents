/**
* @File Name          : IntacctInvoiceSyncBatch.cls
* @Description        : Batch class to make a callout to Intacct and sync Salseforce records on Order Creation.
* @Author             : Lovel Panchal
* @Group              : QE360V3
* @Last Modified By   : fsuraitawala@addonblue.com
* @Last Modified On   : 04-05-2022
* @Modification Log   : 
* Ver       Date            Author                  Modification
* 1.0       1/17/2020       Lovel Panchal          Initial Version
* 1.1       3/4/2020        jagrawal@addonblue.com Updated Class Name and the referenced class name
* 1.2       2/17/2021       kchavda@addonblue.com  #756 YayPay - Create custom fields on Sales Invoice in Intacct and map fields from SF to Intacct for this fields.
* 1.3       2/23/2021       kchavda@addonblue.com  #820 Map Billing and Shipping address fields in Intacct from Order
* 1.4       05/06/2021      kchavda@addonblue.com  #777 Intacct Credit Memo naming convention change and Avoid creating 0 amount Sales Invoices
**/
public class IntacctInvoiceSyncBatch implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful{ 
    // Collections
    List<String> lstKeys = new List<String>(); // List will be temp holder for setKeys
    Map<string,sObject> mapObj = new Map<string,sObject>(); // Map will hold all the key value of SF Object Fields and to Intacct Object and Fields
    Map<Id,Map<String,MAP<String,String>>> mapPTIntacctSFData =  new Map<Id,Map<String, MAP<String, String>>>(); // Map to store Intacct Field Nodes with SF Data
    // Primitive Data 
    String OrderID = '';
    String query = '';
    public boolean  lastRunFlag = null;
    public String accountId = null; 
    String nodeValue = null; 
    //Order objOrder; 
    String PaymentTermId;
    // Constructor will be invoked when Intacct Table is Sales Invoice
    public IntacctInvoiceSyncBatch(String OrderID,List<String> lstKeys){
        this.lstKeys = lstKeys;
        this.OrderID = OrderID;
        //this.objOrder = [Select Id,QuoteId from Order where id=: OrderID];
    }
    
    // Constructor will be invoked when Intacct Table is Sales Invoice
    public IntacctInvoiceSyncBatch(String OrderID,String PaymentTermId, List<String> lstKeys){
        this.lstKeys = lstKeys; this.OrderID = OrderID; this.PaymentTermId = PaymentTermId; //this.objOrder = [Select Id,QuoteId from Order where id=: OrderID];
    }
    
    // Start method will always Query Top most Table name of from lstKeys   
    public Database.QueryLocator start(Database.BatchableContext BC){
        //String QuoteId = objOrder.QuoteId;
        string query = '';
        if(Test.isrunningTest()) query += 'SELECT Id FROM Payment_Term__c WHERE Order__c =:OrderID limit 1';
        else query += 'SELECT Id FROM Payment_Term__c WHERE Amount__c > 0 and Order__c =:OrderID';
        if(PaymentTermId != null && !Test.isrunningTest()) query+= ' and id=:PaymentTermId ';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        try{
            system.debug('scope----'+scope );
            Payment_Term__c objPT = (Payment_Term__c)scope[0];
            IntacctOrderSyncBatchHelper helper = new IntacctOrderSyncBatchHelper(OrderID,lstKeys[0].toLowerCase(),objPT.Id);
            mapObj = helper.createXMLDataForRequest();
            System.debug('mapObj@@@'+mapObj);
            if(mapObj != null){
                Map<String,MAP<String,String>> mapIntacctSFData = new Map<String,MAP<String,String>>();
                for(SFDCToIntacctMap__c obj : [Select Id, Active__c, Constant_Value__c, Custom_Logic__c, Custom_Setting_Name__c,Description__c, Intacct_Node_Name__c, Intacct_Object__c, Intacct_Table__c, Line_Item__c, Operation__c, SF_Field_API_Name__c,SF_Object__c, Sequence__c, Type__c from SFDCToIntacctMap__c where Active__c = true and  Intacct_Object__c =:lstKeys[0].toLowerCase()]){
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
                            if(obj.SF_Field_API_Name__c == 'Quote_Company_Name__c' && (mapObj.get(obj.SF_Object__c).get('Is_Business_Account__c') == false || mapObj.get(obj.SF_Object__c).get('Quote_Company_Name__c') == null)){
                                dataValue = '-';
                            }
                            
                            if(obj.Intacct_Node_Name__c == 'sotransitems#sotransitem#price'){                                
                                datavalue = String.valueOf(Decimal.valueOf(datavalue).setScale(2));
                                   
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
                                    if(date.valueof(dataValue)<system.today()){
                                        datavalue = String.valueof(mapObj.get(obj.SF_Object__c).get('Opportunity_CloseDate__c'));
                                        tempMap.put(obj.Intacct_Node_Name__c,dataValue);
                                    }else{
                                        tempMap.put(obj.Intacct_Node_Name__c,dataValue);
                                    }
                                }else{*/
                                    tempMap.put(obj.Intacct_Node_Name__c,dataValue);
                                //}
                            }
                            mapIntacctSFData.put(obj.Intacct_Object__c.toLowerCase(),tempMap);
                        }
                    } 
                    catch(exception ex){
                        system.debug('Exception:'+ex.getlinenumber() +'-->'+ex.getmessage());
                        Log.debug('Exception:'+ex.getlinenumber() +'-->'+ex.getmessage());
                    } 
                }
                mapPTIntacctSFData.put(objPT.Id,mapIntacctSFData);
                System.debug('mapPTIntacctSFData@@'+mapPTIntacctSFData);
            }
            //system.debug('mapIntacctSFData-->'+mapIntacctSFData);
            
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
            IntacctOrderSyncBatchHelper helper = new IntacctOrderSyncBatchHelper(OrderID,lstKeys[0].toLowerCase()); 
            DOM.Document dom = new DOM.Document();
            List<Id> setPTId = new List<Id>();
            dom.XmlNode control = helper.generateControlXML(dom);
            System.debug('control@@'+control);
            //mapPTIntacctSFData = CONTAINS MAPS OF PAYMENTS TERM ID AND DATA FOR CREATING XML
            System.debug('mapPTIntacctSFData@@'+mapPTIntacctSFData);
            List<RequestResponse_Log__c> lstRR = new List<RequestResponse_Log__c>();
            for(Id ptID : mapPTIntacctSFData.keyset()){
                // LOGIC TO ADD
                control = helper.generateXMLBody(control,'sales invoice',mapPTIntacctSFData.get(ptID).get(lstKeys[0].toLowerCase()),mapObj);
                System.debug('control.toXmlString()@@'+dom.toXmlString());
                setPTId.add(ptID);
            }            
            String strxmlrequest = dom.toXmlString();            
            for(integer i = 1; i < 19; i++) {  
                if(strxmlrequest.contains('<customfield'+i+'>')) { strxmlrequest = strxmlrequest.replace('<customfield'+i+'>','<customfield>'); }
                if(strxmlrequest.contains('</customfield'+i+'>')) { strxmlrequest = strxmlrequest.replace('</customfield'+i+'>','</customfield>'); }              
                if(strxmlrequest.contains('<customfieldname'+i+'>')) { strxmlrequest = strxmlrequest.replace('<customfieldname'+i+'>','<customfieldname>'); }
                if(strxmlrequest.contains('<customfieldvalue'+i+'>')){ strxmlrequest = strxmlrequest.replace('<customfieldvalue'+i+'>','<customfieldvalue>'); }
                if(strxmlrequest.contains('</customfieldname'+i+'>')) { strxmlrequest = strxmlrequest.replace('</customfieldname'+i+'>','</customfieldname>'); }
                if(strxmlrequest.contains('</customfieldvalue'+i+'>')){ strxmlrequest = strxmlrequest.replace('</customfieldvalue'+i+'>','</customfieldvalue>');}
            }
            System.debug('###strxmlrequest=='+strxmlrequest );
            RequestResponse_Log__c objRes = Utility.callout('Intacct',strxmlrequest);  
            if(Test.isRunningTest()){
                objRes.Response__c = '<?xml version="1.0" encoding="UTF-8"?><response><control><status>success</status><senderid>QuintEvents</senderid><controlid>a31a52c2-1358-1f00-6137-60a6a64b0461</controlid><uniqueid>false</uniqueid><dtdversion>3.0</dtdversion></control><operation><authentication><status>success</status><userid>jpatel</userid><companyid>QuintEvents-sandbox</companyid><locationid>100</locationid><sessiontimestamp>2020-03-31T04:24:11+00:00</sessiontimestamp><sessiontimeout>2020-03-31T10:24:11+00:00</sessiontimeout></authentication><result><status>failure</status><function>create_sotransaction</function><controlid>1c645157-92e1-f9ea-d828-7d19a6d6cfc2</controlid><errormessage><error><errorno>BL03000023</errorno><description></description><description2>Item ID:01sm0000000BE3h is not found.</description2><correction></correction></error></errormessage></result></operation></response>';
            }
            system.debug('objRes- RES URL---'+objRes);  
            objRes.Order__c = OrderID;
            
            Dom.Document resDoc = new Dom.Document();
            resDoc.load(objRes.Response__c); 
            String successStatus;
            Integer index = 0;
            Order objOrder = [Select Id,Intacct_Failure_Reason__c from Order where Id  = :OrderId];
            String orderFailureReason = '';
            List<Payment_Term__c> lstPT = new List<Payment_Term__c>();
            //successStatus = resdoc.getRootElement().getChildElement('operation', null).getChildElement('result', null).getChildElement('status', null).getText();
            dom.XmlNode operation = resdoc.getRootElement().getChildElement('operation', null);
            if(operation != null){
                lstRR.add(objRes);
                for(Dom.XmlNode childNode : operation.getChildElements()){
                    try{
                        system.debug('childNode---'+childNode);  
                        if(!setPTId.isEmpty() && index <= setPTId.size())
                        objRes.Payment_Terms__c = setPTId[index];
                        String currentNodeName = childNode.getName();
                        system.debug('currentNodeName---'+currentNodeName);
                        if(currentNodeName == 'result'){
                            successStatus = childNode.getChildElement('status', null).getText();
                            system.debug('successStatus---'+successStatus);
                            Payment_Term__c objPaymentTerms = new Payment_Term__c();
                            objPaymentTerms.Id =  setPTId[index];
                            objPaymentTerms.Sent_to_Intacct__c = true;
                            if(successStatus == 'Success'){
                                objPaymentTerms.Intacct_Id__c = childNode.getChildElement('key', null).getText();
                                IntacctOrderSyncBatchHelper.wrapResponse wr= new IntacctOrderSyncBatchHelper.wrapResponse();
                                wr = helper.getRecordIdCallout(objPaymentTerms.Intacct_Id__c,'ARINVOICE');
                                 system.debug('wr--'+wr);
                                if(wr != null){
                                    objPaymentTerms.Record_Id__c = wr.resRecordId;
                                    objPaymentTerms.Intacct_Record_URL__c =  wr.recUrl;
                                }
                                objPaymentTerms.Intacct_Status__c =  'Success';
                                objPaymentTerms.Intacct_Failure_Reason__c = '';
                            } else {
                                objPaymentTerms.Intacct_Failure_Reason__c = childNode.getChildElement('errormessage', null).getChildElement('error', null).getChildElement('description2', null).getText();
                                objPaymentTerms.Intacct_Status__c =  'Failure';
                            }
                            try {
                                system.debug('objPaymentTerms---'+objPaymentTerms);
                                lstPT.add(objPaymentTerms);
                                index = index + 1;
                                
                            } catch(exception ex) {
                                system.debug('Exception:'+ex.getlinenumber() +'-->'+ex.getmessage()+'@@@1'+ex.getStackTraceString());
                            }
                            
                        }
                    }
                    catch(exception ex){
                        system.debug('Exception:'+ex.getlinenumber() +'-->'+ex.getmessage()+'@@@2'+ex.getStackTraceString());
                    }
                }
            }
            system.debug('lstPT:---'+lstPT);
            if(lstPT.size()>0) Utility.processRecords(lstPT, 'update');
            if(lstRR.size()>0) Utility.processRecords(lstRR, 'insert');
        }
        catch(exception ex){
            Log.debug('Exception:'+ex.getlinenumber() +'-->'+ex.getmessage()+'@@@'+ex.getStackTraceString());
            system.debug('Exception:'+ex.getlinenumber() +'-->'+ex.getmessage()+'@@@3'+ex.getStackTraceString());
        }
        
    }
}