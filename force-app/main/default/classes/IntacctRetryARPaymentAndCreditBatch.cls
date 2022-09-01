/**
 * @description       : 
 * @author            : ratiksinghal@addonblue.com
 * @group             : 
 * @last modified on  : 03-22-2022
 * @last modified by  : ratiksinghal@addonblue.com
**/
global class IntacctRetryARPaymentAndCreditBatch implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful {
    String orderId = null;
    String intacctObjectName = 'arpayment';
    String query = null;
    String nodeValue = null; 
    String accountId = null;
    String objId = null;

    public IntacctRetryARPaymentAndCreditBatch(){
        this.query = 'Select Id, Payment_Terms__c, Payment_Terms__r.Order__c, Payment_Terms__r.Order__r.International_Stripe__c, Payment_Terms__r.Opportunity_Currency__c, CurrencyIsoCode, RecordType.Name FROM charge__c where Order__r.EffectiveDate = THIS_FISCAL_YEAR AND Order__r.Status = \'Active\' AND Order__r.Pricebook2.GPE_Event__c = false AND Amount__c > 0 AND Intacct_Id__c = null AND Payment_Terms__r.Intacct_Id__c != null AND Sent_to_Intacct__c = false';
    }
    public IntacctRetryARPaymentAndCreditBatch(String strQuery){
         this.query = strQuery;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        List<charge__c> lstOfChargeRecords = scope;
        String query = 'Select Id, Active__c, Constant_Value__c, Custom_Logic__c, Custom_Setting_Name__c,Description__c, Intacct_Node_Name__c, Intacct_Object__c, Intacct_Table__c, Line_Item__c, Operation__c, SF_Field_API_Name__c,SF_Object__c, Sequence__c, Type__c from SFDCToIntacctMap__c where Active__c = true and  Intacct_Object__c =:intacctObjectName'; 
        List<SFDCToIntacctMap__c> lstOfSFDCMapping = Database.query(query);
        Set<Id> setPTId = new Set<Id>();
        for(charge__c chg:lstOfChargeRecords){
            setPTId.add(chg.Payment_Terms__c); 
        }
        Map<Id, Payment_Term__c> listOfPT = new Map<Id, Payment_Term__c>([Select Id, Order__r.International_Stripe__c,Opportunity_Currency__c from Payment_Term__c where id IN : setPTId]);
        System.debug('IntacctRetryARPaymentAndCreditBatch: listOfPT ==='+listOfPT);
        for(charge__c chg:lstOfChargeRecords){
            System.debug('IntacctRetryARPaymentAndCreditBatch: Charge ID ==='+chg.Id);
            String objId = chg.Payment_Terms__c+'###'+chg.Id;
            String orderId = chg.Payment_Terms__r.Order__c;
            String ptId = chg.Payment_Terms__c;
            String currenyCode = chg.CurrencyIsoCode;
            Payment_Term__c opt = listOfPT.get(chg.Payment_Terms__c);
            System.debug('IntacctRetryARPaymentAndCreditBatch: PaymentTerm ==='+opt);
            this.accountId = IntacctOrderSyncBatchHelper.getBankAccountId(opt);
            if(currenyCode !=  'USD'){
                nodeValue = 'bankaccountid';
            }
            else{
                nodeValue = 'undepfundsacct';
            } 
            
            try{
                MAP<String,MAP<String,String>> mapIntacctSFData = 	 new MAP<String, MAP<String, String>>();
                IntacctOrderSyncBatchHelper helper = new IntacctOrderSyncBatchHelper(orderId,intacctObjectName,objId);
                Map<string,sObject> mapObj = helper.createXMLDataForRequest();
                System.debug('IntacctRetryARPaymentAndCreditBatch: mapObj ==='+mapObj);
                if(mapObj !=null){
                    for(SFDCToIntacctMap__c obj : lstOfSFDCMapping){
                        Map<String, String> tempMap = new Map<String, String>();
                        String dataValue =  '';
                        if(String.isnotEmpty(obj.Intacct_Object__c) &&  String.isnotEmpty(obj.Intacct_Node_Name__c) && (( String.isnotEmpty(obj.SF_Object__c)   &&  String.isnotEmpty(obj.SF_Field_API_Name__c) && mapObj.get(obj.SF_Object__c) != null ) || (String.isnotEmpty(obj.Constant_Value__c)))){
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
                                if(obj.Intacct_Node_Name__c == 'arpaymentkey' && string.isblank(datavalue)){
                                    datavalue = String.valueof(mapObj.get('Payment_Term__c').get('Intacct_Credit_Memo_Record_Id__c'));
                                    tempMap.put(obj.Intacct_Node_Name__c,dataValue);
                                }
                                else{                                    
                                    tempMap.put(obj.Intacct_Node_Name__c,dataValue);                                   
                                }                                
                            }
                            //System.debug('IntacctRetryARPaymentAndCreditBatch--- MAP---- '+obj.Intacct_Node_Name__c +'='+dataValue);
                            mapIntacctSFData.put(obj.Intacct_Object__c.toLowerCase(),tempMap);
                        }
                    }
                    System.debug('IntacctRetryARPaymentAndCreditBatch:mapIntacctSFData ==='+mapIntacctSFData);
                    if(mapIntacctSFData.get(intacctObjectName) != null){
                        helper.doIntacctCallout(mapIntacctSFData.get(intacctObjectName),mapObj);
                    }                     
                }
            }catch(Exception ex){
                System.debug('IntacctRetryARPaymentAndCreditBatch:Exception:'+ex.getlinenumber() +'-->'+ex.getmessage());
                Log.debug('IntacctRetryARPaymentAndCreditBatch:Exception:'+ex.getlinenumber() +'-->'+ex.getmessage());
            }
        }
    }
    public void finish(Database.BatchableContext BC){
    }

    
}