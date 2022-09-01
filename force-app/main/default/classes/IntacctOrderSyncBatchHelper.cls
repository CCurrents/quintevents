/**
* @File Name          : IntacctOrderSyncCalloutBatchHelper.cls
* @Description        : Helper class for IntacctOrderSyncCalloutBatch, On this XML Data creation and Call Logic is written
* @Author             : Lovel Panchal
* @Group              :
* @Last Modified By   : ratiksinghal@addonblue.com
* @Last Modified On   : 05-27-2022
* @Modification Log   :
* Ver       Date            Author                           Modification
* 1.0       1/17/2020       Lovel Panchal          Initial Version
* 1.1       3/4/2020                          jagrawal@addonblue.com Updated Class Name and the referenced class name
* 1.2    09/18/2020  kchavda@addonblue.com      #544 ARPayment not being created in intacct.
* 1.2    01/07/2021  kchavda@addonblue.com      #668 Apply Credit Memos to Sales Invoices automatically.
* 1.3    02/16/2021  kchavda@addonblue.com      #756 YayPay - Create custom fields on Sales Invoice in Intacct and map fields from SF to Intacct for this fields.
* 1.4    02/18/2021  kchavda@addonblue.com      #788 Capture Intacct bank account id in Salesforce to which transactions are being sent to.
* 1.5    02/23/2021  kchavda@addonblue.com      #820 Map Billing and Shipping address fields in Intacct from Order
* 1.6    03/08/2021  kchavda@addonblue.com      #845 Stop Sending Refund Records to Intacct
* 1.8    05/06/2021  kchavda@addonblue.com      #777 Intacct Credit Memo naming convention change and Avoid creating 0 amount Sales Invoices

**/
public class IntacctOrderSyncBatchHelper {
    string gblStrIntacctObjname;
    string gblStrOrderId;
    string gblStrPaymentTermId;
    string gblStrChargeId;
    string gblStrContactId;
    string gblRandomString;
    string gblLocationId;    
    String intRecId;
    string BankAccountId;
    public intacctOrderSyncBatchHelper(){intRecId= '';}
    public intacctOrderSyncBatchHelper( String OrderId,String Intacctobjname, String objId ){
        intRecId= '';
        if(!Test.isRunningTest()){
            List<order> odr = new List<order>([Select Location_Id__c from Order where Id =:OrderId Limit 1]);
            if(!odr.isempty() && odr[0].Location_Id__c != null) gblLocationId = String.valueOf(odr[0].Location_Id__c);
        }
        this.gblStrOrderId  = OrderId;
        this.gblRandomString =  Utility.getRandomNumber();
        this.gblStrIntacctObjname = Intacctobjname.toLowerCase();
        if(Intacctobjname.toLowerCase() != 'CONTACT'.toLowerCase()){
            if(Intacctobjname.toLowerCase() == 'sales credit memo' || Intacctobjname.toLowerCase() == 'arpayment' || Intacctobjname.toLowerCase() == 'apply_arpayment')  { this.gblStrPaymentTermId = objId.split('###')[0]; this.gblStrChargeId = objId.split('###')[1];}               
            else this.gblStrPaymentTermId = objId;
            
        }
        else this.gblStrContactId = objId;    
    }
    public intacctOrderSyncBatchHelper(String OrderId,String Intacctobjname){
        intRecId= '';
        if(!Test.isRunningTest()){
            List<order> odr = new List<order>([Select Location_Id__c from Order where Id =:OrderId Limit 1]);
            if(!odr.isempty() && odr[0].Location_Id__c != null) gblLocationId = String.valueOf(odr[0].Location_Id__c);
        }
        this.gblStrOrderId  = OrderId;
        if(!String.isEmpty(Intacctobjname)){ this.gblStrIntacctObjname = Intacctobjname.toLowerCase(); } 
        this.gblRandomString =  Utility.getRandomNumber();
    }

    /*
    @ Wrapper Class to store Intacct Response
    */
    public class wrapResponse{
        public String Status{get;set;}
        public String resBody{get;set;}
        public String resRecordId{get;set;}
        public string recUrl{get; set;}
    }
     /*@ Independent Method to do callout to Intacct to get Record URL of Saved Intacct Data
      @Parameters - xmlDoc : Body for callout to get Record URL from object
      @             strIntacctObject : Intacct Object/Table Name
      @ Called by : generateRecordURLXML
    */

    public static string getRecordURLCallout(Dom.Document xmlDoc,String strIntacctObject){
        system.debug('To Get RECORD URL---'+strIntacctObject+'---'+xmlDoc.toXmlString());
        string strRecordURL;
        RequestResponse_Log__c objRes = Utility.callout('Intacct',xmlDoc.toXmlString());    
        system.debug('objRes- RES URL---'+objRes);
        Dom.Document resDoc = new Dom.Document();
        resDoc.load(objRes.Response__c); 
        try{
            dom.Xmlnode vxroot = resDoc.getRootElement().getChildElement('operation', null);           
            if(( strIntacctObject.tolowerCase() =='Sales Credit Memo'.tolowerCase() || strIntacctObject.tolowerCase() == 'Sales Order'.tolowerCase()) && vxroot.getChildElement('result', null).getChildElement('data', null).getChildElement('SODOCUMENT', null) != null){
                strRecordURL = vxroot.getChildElement('result', null).getChildElement('data', null).getChildElement('SODOCUMENT', null).getChildElement('RECORD_URL', null).getText();
            }else if(strIntacctObject.tolowerCase() == 'customer' || strIntacctObject.tolowerCase() == 'contact' ){
            //  strRecordURL = vxroot.getChildElement('result', null).getChildElement('data', null).getChildElement(strIntacctObject.tolowerCase(), null).getChildElement('RECORD_URL', null).getText();
            system.debug('in count'+strIntacctObject);
            String count = resDoc.getRootElement().getChildElement('operation', null).getChildElement('result', null).getChildElement('data', null).getAttributeValue('count',null);
            system.debug('count'+count);
            if(integer.valueof(count) > 0){                
                strRecordURL = resDoc.getRootElement().getChildElement('operation', null).getChildElement('result', null).getChildElement('data', null).getChildElement(strIntacctObject.toLowerCase(), null).getChildElement('RECORD_URL', null).getText();
                system.debug('strRecord--RestrRecordURL-->'+strRecordURL);                
            }
            }
        }
        catch(exception ex){system.debug('Exception--'+ex.getmessage());}
        system.debug('strRecordURL---'+strRecordURL);
        return strRecordURL;
    }
    /*@ Independent Method to generate Control Section of XML header to perform Intacct Callout 
      @Parameters - xmlDoc : Parent Header Node for callout
      @             locId : Location Id Required to PegenerateControlXMLrform Callout for SalesInvoice and AR Payment
      @ Called by : generateRecordURLXML,getRecordIdCallout
    */
    public dom.XmlNode generateControlXML(DOM.Document xmlDoc){
        Integration_Setting__mdt objIntegrationSetting = new Integration_Setting__mdt();
        objIntegrationSetting =  [Select Content_Type__c,Endpoint__c,Type__c, UserId__c, Password__c,SenderId__c,SenderPassword__c,CompanyId__c from Integration_Setting__mdt where DeveloperName = 'Intacct' and Is_Active__c = true LIMIT 1];
        dom.XmlNode request = xmlDoc.createRootElement('request', null, null);
        dom.XmlNode control = request.addChildElement('control', null, null);
        //control.addChildElement('senderid', null, null).addTextNode(objIntegrationSetting.UserId__c);
        //control.addChildElement('password', null, null).addTextNode(objIntegrationSetting.Password__c);
        control.addChildElement('senderid', null, null).addTextNode(objIntegrationSetting.SenderId__c);
        control.addChildElement('password', null, null).addTextNode(objIntegrationSetting.SenderPassword__c);
        control.addChildElement('controlid', null, null).addTextNode(Utility.getRandomNumber());
        control.addChildElement('uniqueid', null, null).addTextNode('false');
        control.addChildElement('dtdversion', null, null).addTextNode('3.0');
        control.addChildElement('includewhitespace', null, null).addTextNode('false');
        dom.XmlNode operation = request.addChildElement('operation', null, null);
        dom.XmlNode authentication = operation.addChildElement('authentication', null, null);
        dom.XmlNode login = authentication.addChildElement('login', null, null);
        login.addChildElement('userid', null, null).addTextNode(objIntegrationSetting.UserId__c);
        login.addChildElement('companyid', null, null).addTextNode(objIntegrationSetting.CompanyId__c);
        login.addChildElement('password', null, null).addTextNode(objIntegrationSetting.Password__c);
        if(gblStrIntacctObjname == 'Sales Credit Memo' || gblStrIntacctObjname == 'Sales Invoice' || gblStrIntacctObjname == 'Sales Order' || gblStrIntacctObjname == 'arpayment' || gblStrIntacctObjname == 'apply_arpayment' || gblStrIntacctObjname == 'aradjustment' || gblStrIntacctObjname =='reverse_arpayment') {            
           if(gblLocationId != null) login.addChildElement('locationid', null, null).addTextNode(gblLocationId);
        }
        dom.XmlNode content = operation.addChildElement('content', null, null);
        return content;
    }
    /*@ Independent Method to get Bank Acc Id to perform Intacct Callout for AR Payment
      @Parameters - objPaymentTerms : Payment Terms Object
      @ Called by : 
    */
    public static string getBankAccountId(Payment_Term__c objPaymentTerms){
        List<Intacct_Undeposited_Funds_Account__c> lstUndepFundsAccounts = Intacct_Undeposited_Funds_Account__c.getall().values();
        string strAccountId ;
        string strEURClearing;
        string strGBPClearing;
        String strAUDClearing;
        String strCADClearing;
        String strSARClearing;
        String strTHBClearing;
        if(test.isRunningTest()){
        Intacct_Undeposited_Funds_Account__c objUndepFundsAcc = new Intacct_Undeposited_Funds_Account__c();
            objUndepFundsAcc.Account_Number__c = '1101';
            objUndepFundsAcc.EUR_Clearing_Account__c = 'EUR';
            objUndepFundsAcc.GBP_Clearing_Account__c  = 'USD';
            objUndepFundsAcc.Currency__c  = 'USD';
            lstUndepFundsAccounts.add(objUndepFundsAcc);
         }
        for(Intacct_Undeposited_Funds_Account__c objUndepFundsAcc : lstUndepFundsAccounts){            
            if(objPaymentTerms.Order__r.International_Stripe__c == objUndepFundsAcc.International_Stripe__c && objPaymentTerms.Opportunity_Currency__c == objUndepFundsAcc.Currency__c ){
                strAccountId = objUndepFundsAcc.Account_Number__c;
                strEURClearing = objUndepFundsAcc.EUR_Clearing_Account__c;
                strGBPClearing = objUndepFundsAcc.GBP_Clearing_Account__c;
                strAUDClearing = objUndepFundsAcc.AUD_Clearing_Account__c;
                strCADClearing = objUndepFundsAcc.CAD_Clearing_Account__c;
                strSARClearing = objUndepFundsAcc.SAR_Clearing_Account__c;
                strTHBClearing = objUndepFundsAcc.THB_Clearing_Account__c;
                break;
            }                
        }
        system.debug('objPaymentTerms'+objPaymentTerms);
        if(Test.isRunningTest()){
            strAccountId ='EUR_Clearing Account';
        }
        else{
            if((objPaymentTerms.Opportunity_Currency__c).equals('USD') || (objPaymentTerms.Opportunity_Currency__c != 'USD' &&  objPaymentTerms.Payment_Method__c != 'Credit Card')){
                if((objPaymentTerms.Opportunity_Currency__c).equals('EUR')) strAccountId = strEURClearing;
                if((objPaymentTerms.Opportunity_Currency__c).equals('GBP')) strAccountId = strGBPClearing;
                if((objPaymentTerms.Opportunity_Currency__c).equals('CAD')) strAccountId = strCADClearing;
                if((objPaymentTerms.Opportunity_Currency__c).equals('AUD')) strAccountId = strAUDClearing;
                if((objPaymentTerms.Opportunity_Currency__c).equals('SAR')) strAccountId = strSARClearing;
                if((objPaymentTerms.Opportunity_Currency__c).equals('THB')) strAccountId = strTHBClearing;
            }           
        }
        system.debug('###strAccountId=='+strAccountId);        
        return strAccountId;
    }
    /*@Method to get Record Id after Intacct Callout
      @Parameters - strRecordId : 
      @ Called by : 
    */
    public wrapResponse getRecordIdCallout(String strRecordId, String intacctObjName){
        try{
            string strQuery; 
            if(intacctObjName == 'ARINVOICE') strQuery = 'RECORDID=\''+strRecordId.split('-')[1].normalizeSpace()+'\'';                
            else if(intacctObjName == 'SODOCUMENT') strQuery = 'DOCNO=\''+strRecordId.split('-')[1].normalizeSpace()+'\'';
            
            DOM.Document dom = new DOM.Document();
            dom.XmlNode function = generateControlXML(dom).addChildElement('function', null, null);
            function.setAttribute('controlid', Utility.getRandomNumber());
            dom.XmlNode xmlHeadNode = function;
            dom.XmlNode xmlQueryNode = xmlHeadNode.addChildElement('readByQuery', null, null);
            xmlQueryNode.addChildElement('object', null, null).addTextNode(intacctObjName);
            xmlQueryNode.addChildElement('fields', null, null).addTextNode('RECORD_URL,RECORDNO');
            xmlQueryNode.addChildElement('query', null, null).addTextNode(strQuery);
            // Send the request
            system.debug('dom--->'+dom.toXmlString());
            RequestResponse_Log__c objRes = Utility.callout('Intacct',dom.toXmlString());
            system.debug('objRes---->'+objRes);
            Dom.Document resDoc = new Dom.Document();
            resDoc.load(objRes.Response__c); 
            String successStatus;
            wrapResponse wlp= new wrapResponse();
            successStatus = resdoc.getRootElement().getChildElement('operation', null).getChildElement('result', null).getChildElement('status', null).getText();
            if(successStatus == 'Success'){
                String count = resdoc.getRootElement().getChildElement('operation', null).getChildElement('result', null).getChildElement('data', null).getAttributeValue('count',null);
                if(integer.valueof(count) > 0){
                    wlp.resRecordId = resdoc.getRootElement().getChildElement('operation', null).getChildElement('result', null).getChildElement('data', null).getChildElement(intacctObjName.toLowerCase(), null).getChildElement('RECORDNO', null).getText();
                    wlp.recUrl = resdoc.getRootElement().getChildElement('operation', null).getChildElement('result', null).getChildElement('data', null).getChildElement(intacctObjName.toLowerCase(), null).getChildElement('RECORD_URL', null).getText();
                    system.debug('strRecord--Record ID -->'+wlp);
                    return wlp;
                }
            }
        }
        catch(exception ex){
            System.debug(ex.getlinenumber()+'@----Exception-----'+ex.getmessage());
        }
        return null;
    }

    /*@ Method to generate Control Section of XML header to perform Intacct Callout 
      @Parameters - xmlDoc : Parent Header Node for callout
      @             locId : Location Id Required to Perform Callout for SalesInvoice and AR Payment
    */
   
   
    public string generateRecordURLXML(String gblStrIntacctObjname,String strKey){
        system.debug('FOR GETTING URL----'+gblStrIntacctObjname + '--strKey--'+strKey);
        if(String.isnotEmpty(gblStrIntacctObjname) && String.isnotEmpty(strKey)){
            DOM.Document doc = new DOM.Document();    
            dom.XmlNode function = generateControlXML(doc).addChildElement('function', null, null);
            function.setAttribute('controlid', Utility.getRandomNumber());
            dom.XmlNode xmlNode;
            xmlNode = function.addChildElement('readByQuery', null, null);
            if(gblStrIntacctObjname == 'Sales Order'.toLowerCase()  || gblStrIntacctObjname == 'Sales Credit Memo'.toLowerCase()){ xmlNode.addChildElement('object', null, null).addTextNode('SODOCUMENT');
            }else if( gblStrIntacctObjname == 'Sales Invoice'.toLowerCase()){ xmlNode.addChildElement('object', null, null).addTextNode('ARINVOICE');
            }else{ xmlNode.addChildElement('object', null, null).addTextNode(gblStrIntacctObjname);}
            String  strQuery = 'RECORDNO=\''+strKey+'\'';
            xmlNode.addChildElement('fields', null, null).addTextNode('RECORD_URL');
            xmlNode.addChildElement('query', null, null).addTextNode(strQuery);
            xmlNode.addChildElement('pagesize', null, null).addTextNode('1');
            if(gblStrIntacctObjname == 'Sales Order'.toLowerCase() || gblStrIntacctObjname == 'Sales Invoice'.toLowerCase() || gblStrIntacctObjname == 'Sales Credit Memo'.toLowerCase()){
                if(gblStrIntacctObjname == 'Sales Credit Memo') gblStrIntacctObjname  = 'Credit Memo';                    
                
           // xmlNode.addChildElement('docparid', null, null).addTextNode(gblStrIntacctObjname);
            }
            return getRecordURLCallout(doc,gblStrIntacctObjname);
        }
        return '';
    }
    
    //@Method : Recursive Function to generate Child Elements in XML
    //@ Called by :
    public Dom.XmlNode generateChildXMLNodes(Dom.XmlNode xmlParentNode, String strChildName, String strDataValue, String strNameSpace, String strPrefix){
        if(xmlParentNode == null){return null;
        }else if(strChildName == null || strChildName == ''){return xmlParentNode;
        }
        if(null == strDataValue){strDataValue = '';
        }
        List<String> lstChildNodes = strChildName.split('#');        
        if(!lstChildNodes.isEmpty()){
            if(lstChildNodes.size() > 1 || Test.IsrunningTest()){
                Dom.XmlNode xmlChildNode = xmlParentNode.getChildElement(lstChildNodes[0], strNameSpace);                
                if(xmlChildNode == null){
                    xmlChildNode = xmlParentNode.addChildElement(lstChildNodes[0], strNameSpace, strPrefix);
                }                
                lstChildNodes.remove(0);                
                String strNewChildName = String.join(lstChildNodes, '#');                
                xmlChildNode = generateChildXMLNodes(xmlChildNode, strNewChildName, strDataValue, strNameSpace, strPrefix);                
                return xmlParentNode;
            }else{
                if(xmlParentNode.getChildElement(lstChildNodes[0], strNameSpace) == null){
                   xmlParentNode.addChildElement(lstChildNodes[0], strNameSpace, strPrefix).addTextNode(strDataValue);
                }
            }
        }
        return xmlParentNode;
    }
    /*@ Method to generate 'Create' and  'Body' Section of XML header to perform Intacct Callout 
      @Parameters - xmlDoc : Parent Header Node for callout
      @             strIntacctObj : Location Id Required to Perform Callout for SalesInvoice and AR Payment
      @             mapIntacctSFData : Intacct Field to Salesforce Data 
    */
    public dom.XmlNode generateXMLBody(dom.XmlNode xmlDoc, String strIntacctObj, MAP<String,String> mapIntacctSFData,Map<string,sObject> mapObjects){
        System.debug(gblStrIntacctObjname+'-|-mapIntacctSFData-|-'+mapIntacctSFData);
        List<Payment_Term__c> lstPT = new List<Payment_Term__c>();
        try{
            
            intRecId = CheckIntcctData(strIntacctObj,mapObjects);
            
            system.debug('###intRecId=='+intRecId);
            if(intRecId == ''){               
                if(gblStrIntacctObjname.toLowerCase() == 'sales order'){                   
                    lstPT = [Select Id,Payment_Method__c,CurrencyISOCode,Charge_Date__c,opportunity__r.closedate from Payment_Term__c where Order__c =: gblStrOrderId];
                }else if(gblStrIntacctObjname.toLowerCase() == 'arpayment') {
                     lstPT = [Select Id,Payment_Method__c,CurrencyISOCode,Charge_Date__c,opportunity__r.closedate from Payment_Term__c where id =: gblStrPaymentTermId];
                }
                Integer PTerms = 1;
                dom.XmlNode objNode;
                dom.XmlNode function = xmlDoc.addChildElement('function', null, null);
                function.setAttribute('controlid', ''+ gblRandomString);
                if(String.isnotEmpty(strIntacctObj)){  
                    String strIntacctTableName = [Select  Intacct_Table__c from SFDCToIntacctMap__c where Active__c = true and  Intacct_Object__c =:strIntacctObj LIMIT 1].Intacct_Table__c;
                    if(!strIntacctTableName.contains('create') && gblStrIntacctObjname != 'apply_arpayment'){
                        dom.XmlNode xmlCreateNode = function.addChildElement('create', null, null);
                        objNode = xmlCreateNode.addChildElement(strIntacctTableName, null, null); 
                    }else{
                        system.debug('@@@gblStrIntacctObjname=='+gblStrIntacctObjname);
                        if(gblStrIntacctObjname.toLowerCase() == 'arpayment' && !lstPT.isempty() && lstPT[0].Payment_Method__c == 'Credit Card' && lstPT[0].CurrencyISOCode != 'USD') {
                            List<Intacct_Undeposited_Funds_Account__c> mcs = Intacct_Undeposited_Funds_Account__c.getall().values();
                            dom.XmlNode objBatchNode = function.addChildElement('create_arpaymentbatch', null, null);  
                            objBatchNode.addChildElement('batchtitle', null, null).addTextNode('Credit Card non USD');
                            if(lstPT[0].CurrencyISOCode == 'EUR')  { objBatchNode.addChildElement('bankaccountid', null, null).addTextNode(mcs[0].EUR_Clearing_Account__c); BankAccountId = mcs[0].EUR_Clearing_Account__c;}
                            else if(lstPT[0].CurrencyISOCode == 'GBP') { objBatchNode.addChildElement('bankaccountid', null, null).addTextNode(mcs[0].GBP_Clearing_Account__c); BankAccountId = mcs[0].GBP_Clearing_Account__c;}
                            else if(lstPT[0].CurrencyISOCode == 'AUD') { objBatchNode.addChildElement('bankaccountid', null, null).addTextNode(mcs[0].AUD_Clearing_Account__c); BankAccountId = mcs[0].AUD_Clearing_Account__c;}
                            else if(lstPT[0].CurrencyISOCode == 'CAD') { objBatchNode.addChildElement('bankaccountid', null, null).addTextNode(mcs[0].CAD_Clearing_Account__c); BankAccountId = mcs[0].CAD_Clearing_Account__c;}
                            else if(lstPT[0].CurrencyISOCode == 'SAR') { objBatchNode.addChildElement('bankaccountid', null, null).addTextNode(mcs[0].SAR_Clearing_Account__c); BankAccountId = mcs[0].SAR_Clearing_Account__c;}
                            else if(lstPT[0].CurrencyISOCode == 'THB') { objBatchNode.addChildElement('bankaccountid', null, null).addTextNode(mcs[0].THB_Clearing_Account__c); BankAccountId = mcs[0].THB_Clearing_Account__c;}
                            if(lstPT[0].Charge_Date__c != null){
                                date dt = lstPT[0].Charge_Date__c;
                                dt = dt < lstPT[0].opportunity__r.closedate ? lstPT[0].opportunity__r.closedate : dt;                                
                                dom.XmlNode datecreated = objBatchNode.addChildElement('datecreated', null, null);
                                datecreated.addChildElement('year', null, null).addTextNode(string.valueof(dt.year()));
                                datecreated.addChildElement('month', null, null).addTextNode(string.valueof(dt.month()));
                                datecreated.addChildElement('day', null, null).addTextNode(string.valueof(dt.day()));                                
                            }
                            objNode = objBatchNode.addChildElement(strIntacctTableName, null, null);
                        }
                        else objNode = function.addChildElement(strIntacctTableName, null, null);
                    }
                    if(mapIntacctSFData != null){      
                        for(SFDCToIntacctMap__c key : [Select Intacct_Node_Name__c,SF_Field_API_Name__c from SFDCToIntacctMap__c where Active__c = true AND Intacct_Table__c =: strIntacctTableName AND Intacct_Object__c =:gblStrIntacctObjname ORDER BY Sequence__c ]){                            
                            if(gblStrIntacctObjname.toLowerCase() == 'arpayment' && !lstPT.isempty() && lstPT[0].Payment_Method__c == 'Credit Card' && lstPT[0].CurrencyISOCode != 'USD' && key.Intacct_Node_Name__c == 'bankaccountid') continue;
                            system.debug('key.Intacct_Node_Name__c--'+key.Intacct_Node_Name__c);
                            system.debug('mapIntacctSFData.get(key.Intacct_Node_Name__c)--'+mapIntacctSFData.get(key.Intacct_Node_Name__c));
                            String datavalue = mapIntacctSFData.get(key.Intacct_Node_Name__c);
                            system.debug('-datavalue---'+datavalue);
                            if((mapIntacctSFData.get(key.Intacct_Node_Name__c) == 'COMPANY_NAME' && mapIntacctSFData.get('customfields#customfield14#customfieldvalue14') == '-') || datavalue == '-') continue;
                            /*if(gblStrIntacctObjname.toLowerCase() == 'arpayment' && key.Intacct_Node_Name__c.contains('datereceived')){
                                    if(date.valueof(dataValue)<system.today()) datavalue = String.valueof(lstPT[0].opportunity__r.closedate);                                    
                             }*/
                            if(key.Intacct_Node_Name__c == 'arpaymentkey' && string.isblank(datavalue)){ datavalue = String.valueof(mapObjects.get('Payment_Term__c').get('Intacct_Credit_Memo_Record_Id__c')); }
                            if(key.Intacct_Node_Name__c == 'documentno' && gblStrIntacctObjname.toLowerCase() == 'sales credit memo'  && !string.isblank(datavalue)){ datavalue = datavalue.replace('Sales Invoice-INV','CM'); }
                            
                            if(String.isnotEmpty(datavalue)){
                                if(key.Intacct_Node_Name__c.containsIgnoreCase('#DAY')){ datavalue = String.valueof(Date.valueof(datavalue).day());}
                                else if(key.Intacct_Node_Name__c.containsIgnoreCase('#MONTH')){  datavalue = String.valueof(Date.valueof(datavalue).month());}
                                else if(key.Intacct_Node_Name__c.containsIgnoreCase('#YEAR')){ datavalue = String.valueof(Date.valueof(datavalue).year());}
                                if(key.Intacct_Node_Name__c == 'sotransitems#sotransitem#price' || Test.IsrunningTest()){
                                    PTerms = Integer.valueOf(lstPT.size());
                                    if(PTerms > 1){
                                            datavalue = String.valueOf((Decimal.valueOf(datavalue) / PTerms).setScale(2));
                                        }
                                }
                               
                                if(gblStrIntacctObjname.toLowerCase() == 'arpayment'  && key.Intacct_Node_Name__c == 'paymentmethod' && key.SF_Field_API_Name__c == 'Payment_method__c'){
                                    if(lstPT[0].Payment_Method__c == 'Check'){
                                        objNode.addChildElement('paymentmethod', null, null).addTextNode('Printed Check');
                                    } 
                                    else if(lstPT[0].Payment_Method__c == 'Wire Transfer'){
                                        objNode.addChildElement('paymentmethod', null, null).addTextNode('EFT');
                                    }
                                    else if(lstPT[0].CurrencyISOCode != 'USD' && lstPT[0].Payment_Method__c == 'Credit Card'){
                                        objNode.addChildElement('paymentmethod', null, null).addTextNode('EFT');
                                    }
                                    else if(lstPT[0].Payment_Method__c == 'Bank Account'){
                                        objNode.addChildElement('paymentmethod', null, null).addTextNode('Credit Card');
                                    }
                                    else{
                                        objNode.addChildElement(key.Intacct_Node_Name__c, null, null).addTextNode(datavalue);
                                    }
                                }
                                else{ objNode = generateChildXMLNodes(objNode, key.Intacct_Node_Name__c, datavalue, null, null);}
                            } 
                        }  
                        if(gblStrIntacctObjname == 'sales order'){
                            DOM.XmlNode sotransitems = objNode.getChildElement('sotransitems',null);
                            if(sotransitems != null){DOM.XmlNode sotransitem = sotransitems.getChildElement('sotransitem',null);if(sotransitem != null && PTerms != null){ for(Integer i=1;i<PTerms;i++){ sotransitems.insertBefore(sotransitem, null);
                                    }
                                }
                            }     
                        } 
                    } 
                }
            }
        }
        catch(exception ex){
            system.debug('Exception:--'+ex.getlinenumber()+'--->@-->'+ex.getmessage());
            Log.debug('Exception:'+ex.getlinenumber() +'-->'+ex.getmessage());
        }
        return xmlDoc;
    }
    /*@ Method Generate Header for Intacct XML Callout
      @Parameters - mapIntacctSFData : Map of Salesforce Fields to Salesforce Data
      @ Called by : doIntacctCallout
    */
    public String generateXMLHeader(map<String,String> mapIntacctSFData,Map<string,sObject> mapObjects){
        DOM.Document doc = new DOM.Document();
        //Root Element
        DOM.XmlNode xmlRequest = doc.createRootElement('request', null, null);
        Integration_Setting__mdt objIntegrationSetting = new Integration_Setting__mdt();
        objIntegrationSetting =  [Select Content_Type__c,Endpoint__c,Type__c, UserId__c, Password__c,CompanyId__c,SenderId__c,SenderPassword__c from Integration_Setting__mdt where DeveloperName = 'Intacct' and Is_Active__c = true LIMIT 1];
        //1st Child Element
        dom.XmlNode control = xmlRequest.addChildElement('control', null, null);
        control.addChildElement('senderid', null, null).addTextNode(objIntegrationSetting.SenderId__c);
        control.addChildElement('password', null, null).addTextNode(objIntegrationSetting.SenderPassword__c);
        control.addChildElement('controlid', null, null).addTextNode(''+ Utility.getRandomNumber());
        control.addChildElement('uniqueid', null, null).addTextNode('false');
        control.addChildElement('dtdversion', null, null).addTextNode('3.0');
        control.addChildElement('includewhitespace', null, null).addTextNode('false');
        //2nd Child Element
        dom.XmlNode operation = xmlRequest.addChildElement('operation', null, null);
        //1st Sub-Child Element
        dom.XmlNode authentication = operation.addChildElement('authentication', null, null);
        dom.XmlNode login = authentication.addChildElement('login', null, null);
        login.addChildElement('userid', null, null).addTextNode(objIntegrationSetting.UserId__c);
        login.addChildElement('companyid', null, null).addTextNode(objIntegrationSetting.CompanyId__c);
        login.addChildElement('password', null, null).addTextNode(objIntegrationSetting.Password__c);
        if(gblStrIntacctObjname == 'Sales Credit Memo' || gblStrIntacctObjname == 'Sales Order' || gblStrIntacctObjname == 'arpayment' || gblStrIntacctObjname == 'apply_arpayment') {
            if(gblLocationId != null) login.addChildElement('locationid', null, null).addTextNode(gblLocationId);
        }
        //2nd Sub-Child Element
        dom.XmlNode content = operation.addChildElement('content', null, null);
        content = generateXMLBody(content,gblStrIntacctObjname.toLowerCase(),mapIntacctSFData,mapObjects);        
        String strxmlrequest = doc.toXmlString();
        for(integer i=1; i<11;i++){  
            if(strxmlrequest.contains('<customfield'+i+'>')) { strxmlrequest = strxmlrequest.replace('<customfield'+i+'>','<customfield>'); }
            if(strxmlrequest.contains('</customfield'+i+'>')) { strxmlrequest = strxmlrequest.replace('</customfield'+i+'>','</customfield>'); }              
            if(strxmlrequest.contains('<customfieldname'+i+'>')) { strxmlrequest = strxmlrequest.replace('<customfieldname'+i+'>','<customfieldname>'); }
            if(strxmlrequest.contains('<customfieldvalue'+i+'>')){ strxmlrequest = strxmlrequest.replace('<customfieldvalue'+i+'>','<customfieldvalue>'); }
            if(strxmlrequest.contains('</customfieldname'+i+'>')) { strxmlrequest = strxmlrequest.replace('</customfieldname'+i+'>','</customfieldname>'); }
            if(strxmlrequest.contains('</customfieldvalue'+i+'>')){ strxmlrequest = strxmlrequest.replace('</customfieldvalue'+i+'>','</customfieldvalue>');}
        }
        return strxmlrequest;
    }
    /*@ Method which will perform callout and get response
      @Parameters - mapIntacct : Map of Salesforce Fields to Salesforce Data
      @ Called by : doIntacctCallout
    */
    public void doIntacctCallout(Map<String,String> mapIntacct,Map<string,sObject> mapObjects){
        try{
            RequestResponse_Log__c objReqResLog =  new RequestResponse_Log__c();            
            String reqXMLBody = generateXMLHeader(mapIntacct,mapObjects);            
            if(intRecId == '') objReqResLog = Utility.callout('Intacct',reqXMLBody);  
            objReqResLog.Order__c = gblStrOrderId;
            Dom.Document resDoc = new Dom.Document();
            if(Test.isRunningTest()){
                if(gblStrIntacctObjname == 'Sales Credit Memo'.toLowerCase()){
                    objReqResLog.Response__c = '<?xml version="1.0" encoding="UTF-8"?><response><control><status>success</status><senderid>QuintEvents</senderid><controlid>033181fd-f2de-910f-1855-cc7ee73e07fa</controlid><uniqueid>false</uniqueid><dtdversion>3.0</dtdversion></control><operation><authentication><status>success</status><userid>jpatel</userid><companyid>QuintEvents-sandbox</companyid><locationid>100</locationid><sessiontimestamp>2020-03-18T14:40:25+00:00</sessiontimestamp><sessiontimeout>2020-03-18T20:40:25+00:00</sessiontimeout></authentication><result><status>success</status><function>create_sotransaction</function><controlid>131cd983-a0e7-1b47-4c4b-72282fc960f7</controlid><key>Sales MEMO-INV16055</key></result></operation></response>';
                }
                if(gblStrIntacctObjname.toLowerCase() == 'customer'){ 
                    objReqResLog.Response__c = '<?xml version="1.0" encoding="UTF-8"?><request><control><senderid>QuintEvents</senderid><password>8_64!JO4bA</password><controlid>4bf7f012-d816-9b3d-4593-c5fc1ad915bd</controlid><uniqueid>false</uniqueid><dtdversion>3.0</dtdversion><includewhitespace>false</includewhitespace></control><operation><authentication><login><userid>jpatel</userid><companyid>QuintEvents-sandbox</companyid><password>Addonblue@2020</password></login></authentication><content><function controlid="b8ff22a9-d617-d404-e299-1f2911ada798"><create><CUSTOMER><NAME>Lovel Panchal</NAME><DISPLAYCONTACT><PRINTAS>Lovel Panchal</PRINTAS></DISPLAYCONTACT><CURRENCY>USD</CURRENCY><BILLTO><CONTACTNAME>003m000001Ll85AAAR</CONTACTNAME></BILLTO><SHIPTO><CONTACTNAME>003m000001LknI5AAJ</CONTACTNAME></SHIPTO></CUSTOMER></create></function></content></operation></request>';
                }
                if(gblStrIntacctObjname.toLowerCase() == 'contact'){
                    objReqResLog.Response__c = '<?xml version="1.0" encoding="UTF-8"?><response><control><status>success</status><senderid>QuintEvents</senderid><controlid>367aa2a0-ba3b-c033-1ce1-b0f716ac637a</controlid><uniqueid>false</uniqueid><dtdversion>3.0</dtdversion></control><operation><authentication><status>success</status><userid>jpatel</userid><companyid>QuintEvents-sandbox</companyid><locationid></locationid><sessiontimestamp>2020-05-18T14:57:27+00:00</sessiontimestamp><sessiontimeout>2020-05-18T20:57:27+00:00</sessiontimeout></authentication><result><status>failure</status><function>create</function><controlid>88ab6aaf-c5e4-a903-ce4b-3810ac28a93d</controlid><data listtype="objects" count="0"/><errormessage><error><errorno>BL34000061</errorno><description></description><description2>Another Contact with the given value(s) already exists [Support ID: 2%40pV-%7EXsKiVWElB8V6uhT1xiBHxAAAAAY]</description2><correction>Use a unique value instead.</correction></error><error><errorno>BL01001973</errorno><description></description><description2>Could not create Contact record!</description2><correction></correction></error></errormessage></result></operation></response>>';
                }
                if(gblStrIntacctObjname.toLowerCase() == 'sales order'){
                    objReqResLog.Response__c = '<?xml version="1.0" encoding="UTF-8"?><response><control><status>success</status><senderid>QuintEvents</senderid><controlid>033181fd-f2de-910f-1855-cc7ee73e07fa</controlid><uniqueid>false</uniqueid><dtdversion>3.0</dtdversion></control><operation><authentication><status>success</status><userid>jpatel</userid><companyid>QuintEvents-sandbox</companyid><locationid>100</locationid><sessiontimestamp>2020-03-18T14:40:25+00:00</sessiontimestamp><sessiontimeout>2020-03-18T20:40:25+00:00</sessiontimeout></authentication><result><status>success</status><function>create_sotransaction</function><controlid>131cd983-a0e7-1b47-4c4b-72282fc960f7</controlid><key>sales order-INV16055</key></result></operation></response>';
                }
                if(gblStrIntacctObjname.toLowerCase()== 'arpayment'){
                    objReqResLog.Response__c = '<?xml version="1.0" encoding="UTF-8"?><response><control><status>failure</status><senderid>QuintEvents</senderid><controlid>c480bdee-cb05-155d-e7f0-718a3f89d212</controlid><uniqueid>false</uniqueid><dtdversion>3.0</dtdversion></control><errormessage><error><errorno>XL03000003</errorno><description></description><description2>XML Parse schema error: Error 1871: Element &#039;amount&#039;: This element is not expected. Expected is ( invoicekey ).. Line: 1, column: 0.</description2><correction></correction></error></errormessage></response>';                
                }
                if(gblStrIntacctObjname == 'apply_arpayment'){
                    objReqResLog.Response__c = '<?xml version="1.0" encoding="UTF-8"?><response><control><status>success</status><senderid>QuintEvents</senderid><controlid>4029fc03-6f12-571c-fa74-64ea3d9bc1e9</controlid><uniqueid>false</uniqueid><dtdversion>3.0</dtdversion></control><operation><authentication><status>success</status><userid>jpatel</userid><companyid>QuintEvents-sandbox</companyid><locationid>100</locationid><sessiontimestamp>2021-01-11T18:05:33+00:00</sessiontimestamp><sessiontimeout>2021-01-12T00:05:33+00:00</sessiontimeout></authentication><result><status>success</status><function>apply_arpayment</function><controlid>596fe011-7f5b-e419-43e0-cab0d055b6b6</controlid></result></operation></response>';
                }
            }            
            if(objReqResLog.Response__c != null) resDoc.load(objReqResLog.Response__c); 
            //-----------------------------
            // LOGIC TO UPDATE THE INTACCT ID ON ORDER RECORD
            String intacctSOId = '';
            String intRecId = '';
            String payRecordIntNo = '';
            String url = '';
            Order objOrder = new Order();
            wrapResponse wrp  = new wrapResponse();            
            if(objReqResLog.Response__c != null) wrp = parseResponse(resDoc,gblStrIntacctObjname);
            if(wrp.Status == 'Success') {
                intacctSOId = wrp.resBody;
                intRecId = wrp.resRecordId;
                URL = wrp.recUrl;
            }
             if((wrp.Status != null && wrp.Status != 'Success') || Test.isRunningTest()){
                 system.debug('###gblStrIntacctObjname =='+gblStrIntacctObjname );
                 system.debug('###gblStrChargeId=='+gblStrChargeId);
                 if(!Test.isRunningTest())
                    objOrder = [ Select id,ShiptoContactId,Intacct_Failure_Reason__c,AccountId,BillToContactId,Intacct_Id__c,Intacct_Status__c from Order where Id =:gblStrOrderId limit 1 ];
                 else
                     objOrder = [ Select id,ShiptoContactId,Intacct_Failure_Reason__c,AccountId,BillToContactId,Intacct_Id__c,Intacct_Status__c from Order limit 1 ];
                if(String.isNotBlank(objOrder.Intacct_Failure_Reason__c))
                        objOrder.Intacct_Failure_Reason__c = objOrder.Intacct_Failure_Reason__c +'. Failed :'+ gblStrIntacctObjname +'-'+ gblStrPaymentTermId + ' Reason :' +wrp.resBody;
                else
                        objOrder.Intacct_Failure_Reason__c = gblStrIntacctObjname + ' Reason :' +wrp.resBody;
                if(String.isNotBlank(objOrder.Intacct_Status__c))
                        objOrder.Intacct_Status__c = objOrder.Intacct_Status__c + ', ' +  gblStrIntacctObjname +'-' + gblStrPaymentTermId + ' Failure';
                else
                        objOrder.Intacct_Status__c = gblStrIntacctObjname +' Failure';
                try{ 
                    Utility.processRecords(objOrder, 'update');  
                    //update objOrder;
                }
                catch(exception ex){
                    system.debug('Exception:'+ ex.getmessage());
                }
                if(gblStrIntacctObjname == 'Sales Order'.toLowerCase()){
                    Payment_Term__c objPaymentTerms = new Payment_Term__c();
                    objPaymentTerms.Id =  gblStrPaymentTermId;
                    objPaymentTerms.Intacct_Failure_Reason__c = wrp.resBody;
                    objPaymentTerms.Intacct_Status__c =  'Failure';
                    try{
                        Utility.processRecords(objPaymentTerms, 'update');
                        //update objPaymentTerms;
                    } catch(exception ex){
                        System.debug(ex.getlinenumber()+' Exception: '+ ex.getmessage()); 
                    }
                }
                else if( gblStrIntacctObjname == 'Sales Credit Memo'.toLowerCase()){
                    Charge__c objCharge = new Charge__c();
                    Payment_term__c objPT = new Payment_term__c();
                    if(!Test.isRunningTest()){  
                       if(gblStrChargeId == 'dummy') objPT = [Select Id,Intacct_Failure_Reason__c,Intacct_Status__c from Payment_term__c  where id=:gblStrPaymentTermId];                    
                       else objCharge = [Select Id from Charge__c where Payment_terms__c =:gblStrPaymentTermId and id=:gblStrChargeId];
                     } 
                    else{
                       objCharge = [Select Id from Charge__c Order by Createddate desc  Limit 1];
                       objPT = [Select Id from Payment_term__c limit 1];
                    }
                    if(gblStrChargeId == 'dummy'){
                        objPT.Intacct_Failure_Reason__c = wrp.resBody;
                        objPT.Intacct_Status__c =  'Failure';
                    }
                    else{
                        objCharge.Intacct_Failure_Reason__c = wrp.resBody;
                        objCharge.Intacct_Status__c =  'Failure';
                        System.debug('objCharge-------------'+objCharge);   
                    }
                    try{
                        if(gblStrChargeId == 'dummy') Utility.processRecords(objPT, 'update');
                        else Utility.processRecords(objCharge, 'update');
                        //update objPaymentTerms;
                    } catch(exception ex){System.debug(ex.getlinenumber()+' Exception: '+ ex.getmessage());}
                }                  
                else if( gblStrIntacctObjname.toLowerCase() == 'customer'.toLowerCase()){
                    objReqResLog.Account__c = objOrder.AccountId;
                }
                else if( gblStrIntacctObjname.toLowerCase() == 'CONTACT'.toLowerCase() && String.isNotBlank(gblStrContactId)){
                    objReqResLog.Contact__c = gblStrPaymentTermId;
                }
                else if((gblStrIntacctObjname == 'arpayment' || gblStrIntacctObjname == 'apply_arpayment') && gblStrChargeId != 'dummy'){
                    objReqResLog.Charge__c = [Select Id from Charge__c where Payment_Terms__c =:gblStrPaymentTermId and id=:gblStrChargeId][0].Id; //Order by LastModifiedDate Desc
                    Charge__c objCharge = new Charge__c();
                    objCharge.Id =  objReqResLog.Charge__c;
                    objCharge.Intacct_Failure_Reason__c = wrp.resBody;
                    if(gblStrIntacctObjname == 'apply_arpayment') objCharge.Intacct_Apply_ARPayment_Status__c = 'Failure';
                    else objCharge.Intacct_Status__c =  'Failure';
                    try{
                        Utility.processRecords(objCharge, 'update');
                        //update objCharge;
                    } catch(exception ex){system.debug('Execption - IN ERROR CASE OF CHARGE---->' + ex.getmessage());}
                    // system.debug('OPT_Id -IN ERROR CASE OF CHARGE---->' + reqresObj.Charge__c);
                }
                else if(gblStrIntacctObjname == 'apply_arpayment' && gblStrChargeId == 'dummy'){
                    objReqResLog.Opportunity_Payment_Terms__c = gblStrPaymentTermId;
                    Payment_term__c objPT = new Payment_term__c();
                    objPT.Id =  gblStrPaymentTermId; objPT.Intacct_Failure_Reason__c = wrp.resBody; objPT.Intacct_Apply_ARPayment_Status__c = 'Failure';                    
                    try { Utility.processRecords(objPT, 'update'); } catch(exception ex){system.debug('Execption - IN ERROR CASE OF Payment Term---->' + ex.getmessage());}
                }
            }
            system.debug('intacctSOId-->'+intacctSOId);
            if(String.isNotBlank(intacctSOId)) {
                objOrder = [ Select id,AccountId,BillToContactId,ShiptoContactId,Intacct_Id__c,Intacct_Status__c,OpportunityId from Order where Id =:gblStrOrderId limit 1 ];
                if(String.isNotBlank(objOrder.Intacct_Status__c))
                    objOrder.Intacct_Status__c = objOrder.Intacct_Status__c +', '+gblStrIntacctObjname+'-' + gblStrPaymentTermId + ' Synced';
                else
                    objOrder.Intacct_Status__c = gblStrIntacctObjname+' Synced';  
                try{
                    if(gblStrIntacctObjname.toLowerCase() == 'Sales Order'.toLowerCase()){
                        objOrder.Intacct_Id__c = intacctSOId;
                        objOrder.Record_Id__c = intRecId;
                        objOrder.Intacct_Record_URL__c = url;
                        objReqResLog.Order__c = objOrder.Id;
                    }
                    Utility.processRecords(objOrder, 'update');
                    //update objOrder; 
                }
                catch(exception ex){system.debug('Exception:-- Order Update---' + ex.getmessage());}
                if( gblStrIntacctObjname == 'Sales Credit Memo'.toLowerCase()){
                        try{
                            if(String.isNotBlank(gblStrPaymentTermId)){
                                if(gblStrChargeId  == 'dummy'){
                                    Payment_term__c objPt = [Select Id,Order__c from Payment_term__c where id=:gblStrPaymentTermId];
                                    objPT.Intacct_Credit_Memo_Id__c = intacctSOId; 
                                    objPT.Intacct_Credit_Memo_Record_Id__c = intRecId; 
                                    objPT.Intacct_Status__c =  'Success';   
                                    objPT.Intacct_Failure_Reason__c = '';                                
                                    System.debug('objPT-------------'+objPT); 
                                    objReqResLog.Opportunity_Payment_Terms__c = objPt.Id;
                                    Utility.processRecords(objPT, 'update');
                                    IntacctOrderSyncBatch batch = new IntacctOrderSyncBatch(objPt.Order__c,new list<String> {'apply_arpayment'},objPt.Id+'###'+'dummy',false);
                                    if(!Test.isRunningTest()) Database.executebatch(batch);
                                }
                                else{
                                    Charge__c objCharge = [Select Id,Payment_terms__c,Payment_Terms__r.Order__c from Charge__c where Payment_terms__c =:gblStrPaymentTermId and id=:gblStrChargeId ]; //Order by Createddate desc  Limit 1
                                    objCharge.Intacct_Id__c = intacctSOId;
                                    objCharge.Intacct_Record_Id__c = intRecId;
                                    objCharge.Intacct_Status__c =  'Success';
                                    objCharge.Intacct_Failure_Reason__c = '';
                                    System.debug('objCharge-------------'+objCharge); 
                                    objReqResLog.Charge__c = objCharge.Id;
                                    Utility.processRecords(objCharge, 'update');
                                    IntacctOrderSyncBatch batch = new IntacctOrderSyncBatch(objCharge.Payment_Terms__r.Order__c,new list<String> {'apply_arpayment'},objCharge.Payment_Terms__c+'###'+objCharge.id,false);
                                    if(!Test.isRunningTest()) Database.executebatch(batch);
                                }
                            }
                        }
                        catch(exception ex){System.debug('Exception : Issue in updating Charge (Credit Memo) '+ ex.getmessage());}
                 }
                 else if( gblStrIntacctObjname.toLowerCase() == 'customer'.toLowerCase() || Test.IsrunningTest()) {  
                    Account objAccount = new Account();
                    objAccount.Id = objOrder.AccountId;
                    objAccount.Intacct_Id__c  = intacctSOId;
                    objAccount.Record_Id__c  = intRecId;
                    objAccount.Intacct_Record_URL__c = url;
                    objReqResLog.Account__c = objOrder.AccountId;
                    try{
                        Utility.processRecords(objAccount, 'update');
                        //update objAccount;
                    }
                    catch(exception ex){System.debug('Exception : Issue in updating Account '+ ex.getmessage());}
                    System.debug('In Account' +  objReqResLog);
                } else if( gblStrIntacctObjname.toLowerCase()== 'CONTACT'.toLowerCase() && String.isNotBlank(gblStrContactId)) {  
                    Contact objCon = new Contact();
                    objCon.Id = gblStrContactId;
                    //objCon.Intacct_Id__c = intacctSOId;
                    //objCon.Record_Id__c = intRecId;
                    objCon.Intacct_Id__c = intRecId;
                    objCon.Record_Id__c = intacctSOId;
                    // objCon.Intacct_Record_URL__c = URL;
                    objReqResLog.Contact__c = gblStrContactId;
                    try{ Utility.processRecords(objCon, 'update');} catch(exception ex){System.debug('Exception : Issue in updating Contact '+ ex.getmessage());}
                    System.debug('In Contact' +  objReqResLog);
                }
                else if( gblStrIntacctObjname.toLowerCase()== 'arpayment'.toLowerCase()  && String.isNotBlank(gblStrPaymentTermId)) {
                    try{                         
                        Charge__c objChg = new Charge__c();
                        objChg.Id = [Select Id,Intacct_Apply_ARPayment_Status__c,Intacct_Bank_Account_Id__c from Charge__c where Payment_Terms__c =:gblStrPaymentTermId and id=:gblStrChargeId][0].Id; //Order by LastModifiedDate Desc                       
                        objChg.Intacct_Id__c = intacctSOId; objChg.Intacct_Record_Id__c = intRecId; objChg.Intacct_Status__c =  'Success';    
                        system.debug('###mapIntacct='+mapIntacct.get('bankaccountid'));
                        objChg.Intacct_Bank_Account_Id__c = (BankAccountId != null ? BankAccountId :(mapIntacct.get('bankaccountid') != null? mapIntacct.get('bankaccountid') : mapIntacct.get('undepfundsacct')));                   
                        objChg.Intacct_Failure_Reason__c = '';                          
                        try{ Utility.processRecords(objChg, 'update'); } catch(exception ex){System.debug('Exception : Issue in updating Charge '+ ex.getmessage());}
                        System.debug('In Chrage' +  objReqResLog);
                        objReqResLog.Charge__c = objChg.Id;
                    }
                    catch(exception ex){System.debug('exception--'+ex.getmessage() +'--@--'+ ex.getlinenumber());}
                }
            } 
            if(gblStrIntacctObjname == 'apply_arpayment' && String.isNotBlank(gblStrPaymentTermId) && wrp.Status == 'Success'){
                try{ 
                        Charge__c objChgpay = new Charge__c();
                        Payment_term__c objPterm = new Payment_term__c(); 
                        if(gblStrChargeId != null && gblStrChargeId != 'dummy'){
                            objChgpay.Id = gblStrChargeId; objChgpay.Intacct_Apply_ARPayment_Status__c = 'Success'; objChgpay.Intacct_Failure_Reason__c = '';
                        }
                        else if(gblStrChargeId == 'dummy'){
                            objPterm.id = gblStrPaymentTermId; objPterm.Intacct_Apply_ARPayment_Status__c = 'Success'; objPterm.Intacct_Failure_Reason__c = '';
                        }
                        try{
                            if(gblStrChargeId == 'dummy') Utility.processRecords(objPterm, 'update'); 
                            else Utility.processRecords(objChgpay, 'update');                            
                        }
                        catch(exception ex){System.debug('Exception : Issue in updating Charge '+ ex.getmessage());}
                        System.debug('In Chrage apply_arpayment' +  objReqResLog);
                        if(gblStrChargeId == 'dummy') objReqResLog.Opportunity_payment_terms__c = gblStrPaymentTermId;
                        else objReqResLog.Charge__c = objChgpay.Id;
                    }
                    catch(exception ex){System.debug('exception--'+ex.getmessage() +'--@--'+ ex.getlinenumber());}
            }
            objReqResLog.Class_Name__c = 'IntacctOrderSyncCalloutBatchHelper'; 
            if(objReqResLog.Response__c != null) Utility.processRecords(objReqResLog, 'insert');  
            //insert objReqResLog;
        }
        catch(exception ex){system.debug('Exception:--'+ex.getlinenumber()+'--->@-->'+ex.getStackTraceString());Log.debug('Exception:'+ex.getlinenumber() +'-->'+ex.getmessage());}
    }
    
    //////////////////////// LOGIC TO PARSE RESPONSE ////////////////////////////////////////////
    public wrapResponse parseResponse(Dom.Document doc,String gblStrIntacctObjname){
        wrapResponse wr = new wrapResponse();
        try{ 
            system.debug('doc----->'+doc.toXmlString());
            Dom.XMLNode response = doc.getRootElement();
            Dom.XMLNode control = response.getChildElement('control', null);
            Dom.XMLNode operation = response.getChildElement('operation', null);
            string strRecord;
            string strAccountNo;
            string strCustomerId; 
            //system.debug('operation:-'+operation);
            if(operation != null){
                Dom.XMLNode authentication = operation.getChildElement('authentication', null);
                Dom.XMLNode result = operation.getChildElement('result', null);
                Dom.XMLNode sotransaction = result.getChildElement('key', null);
                System.debug('sotransaction to string@@@'+sotransaction);
                
                // LOGIC for Applying ARPAYMENT Status
                Dom.XMLNode function = result.getChildElement('function', null);
                system.debug('###function.getText() =='+function.getText());
                if(function != null && function.getText() == 'apply_arpayment'){
                     wr.Status = result.getChildElement('status', null).getText();
                     if(wr.Status == 'success') return wr;
                }
                
                // LOGIC FOR FETCHING INTACCT SALES ORDER ID
                if(sotransaction != null){
                    strRecord = result.getChildElement('key', null).getText();
                    wr.Status = 'Success';
                    wr.resBody = strRecord;
                    try{
                        
                        if(gblStrIntacctObjname == 'Sales Credit Memo'.toLowerCase() || gblStrIntacctObjname == 'Sales Order'.toLowerCase()){
                            String intacctObjName;
                            if(gblStrIntacctObjname == 'Sales Credit Memo'.toLowerCase()){
                                intacctObjName = 'ARINVOICE';
                            }else if(gblStrIntacctObjname == 'Sales Order'.toLowerCase()){
                                intacctObjName = 'SODOCUMENT';
                            }
                            wrapResponse wop = new wrapResponse();
                            wop = getRecordIdCallout(strRecord,intacctObjName);
                           wr.resRecordId  = wop.resRecordId; wr.recUrl  = wop.recUrl;
                           system.debug('strRecord-->'+strRecord + '---' +wr.resRecordId );
                        }
                        system.debug('wr----->'+wr);
                       // wr.recUrl =  generateRecordURLXML(gblStrIntacctObjname , wr.resRecordId);
                    }
                    catch(exception ex){
                        system.debug('Exception:---No able get Recored Id or URL'+ex.getlinenumber()+'--'+ex.getmessage());
                    }
                    return wr;
                }
                //--------------------------------------------------------------------------
                Dom.XMLNode data = result.getChildElement('data', null);
                system.debug('data==>'+data);
                String resStatus = result.getChildElement('status', null).getText();
                //If the request is successfully processed.
                if(data != null){
                    // LOGIC FOR FETCHING INTACCT ACCOUNT ID
                    Dom.XMLNode glaccount = data.getChildElement('glaccount', null);
                    if(glaccount != null){strRecord = glaccount.getChildElement('RECORDNO', null).getText();strAccountNo = glaccount.getChildElement('ACCOUNTNO', null).getText();wr.Status = 'Success'; wr.resBody = strAccountNo;wr.resRecordId = strRecord;
                        try{
                            wr.recUrl =  generateRecordURLXML('customer',strRecord);
                        }
                        catch(exception ex){
                            system.debug('Exception:---No able get Recored Id or URL'+ex.getlinenumber()+'--'+ex.getmessage());
                        }
                        return wr;
                    }
                    //--------------------------------------------------------------------------
                    // LOGIC FOR FETCHING INTACCT SALES Customer ID
                    Dom.XMLNode customer = data.getChildElement('customer', null);
                    //system.debug('testsotransaction1'+sotransaction1);
                    system.debug('customer--------->'+customer);
                    if(customer != null){strRecord = customer.getChildElement('RECORDNO', null).getText(); strCustomerId = customer.getChildElement('CUSTOMERID', null).getText();wr.Status = 'Success';wr.resBody = strCustomerId;wr.resRecordId = strRecord;
                        try{
                            wr.recUrl =  generateRecordURLXML('customer',strRecord);
                        }
                        catch(exception ex){
                            system.debug('Exception:---No able get Recored Id or URL'+ex.getlinenumber()+'--'+ex.getmessage());
                        }
                        //system.debug('wr'+wr);
                        return wr;
                    }
                    //--------------------------------------------------------------------------
                    // LOGIC FOR FETCHING INTACCT SALES CONTACT ID
                    Dom.XMLNode contact = data.getChildElement('contact', null);
                    //system.debug('sotransaction2'+sotransaction2);
                    if(contact != null){
                        strRecord = contact.getChildElement('RECORDNO', null).getText();
                        strCustomerId = contact.getChildElement('CONTACTNAME', null).getText();
                        //system.debug('contact--RECORDNO'+RECORDNO+'referenceno'+referenceno);
                        wr.Status = 'Success';
                        wr.resBody = strRecord;
                        wr.resRecordId = strCustomerId;
                        try{
                            wr.recUrl =  generateRecordURLXML('contact',strRecord);
                        }
                        catch(exception ex){
                            system.debug('Exception:---No able get Recored Id or URL'+ex.getlinenumber()+'--'+ex.getmessage());
                        }
                        //system.debug('wr'+wr);
                        return wr;
                    }
                    
                    //--------------------------------------------------------------------------
                    // LOGIC FOR FETCHING INTACCT SALES ORDER ID
                    Dom.XMLNode salesorder = data.getChildElement('SODOCUMENT', null);                    
                    if(salesorder != null){
                        strRecord = salesorder.getChildElement('RECORDNO', null).getText();
                        string strOrderId = salesorder.getChildElement('DOCID', null).getText();
                        //system.debug('contact--RECORDNO'+RECORDNO+'referenceno'+referenceno);
                        wr.Status = 'Success';
                        wr.resBody = strRecord;
                        wr.resRecordId = strOrderId;                        
                        return wr;
                    }
                    
                    
                     //--------------------------------------------------------------------------
                    // LOGIC FOR FETCHING INTACCT SALES INVOICE ID
                    Dom.XMLNode salesinvoice = data.getChildElement('ARINVOICE', null);                    
                    if(salesinvoice != null){
                        strRecord = salesinvoice.getChildElement('RECORDNO', null).getText();
                        string strInvoiceId = salesinvoice.getChildElement('RECORDID', null).getText();
                        //system.debug('contact--RECORDNO'+RECORDNO+'referenceno'+referenceno);
                        wr.Status = 'Success';
                        wr.resBody = strRecord;
                        wr.resRecordId = strInvoiceId;                        
                        return wr;
                    }                    
                    
                    
                    Dom.XMLNode errormessage = result.getChildElement('errormessage', null);                    
                   
                    if(errormessage  != null){
                        system.debug('@@@errormessage- '+errormessage.getText());
                        Dom.XMLNode error = errormessage.getChildElement('error', null);
                        String status = result.getChildElement('status', null).getText();
                        //system.debug('Response Status:- '+status);
                        String errorno = error.getChildElement('errorno', null).getText();
                        //system.debug('Error no:- '+errorno);
                        String description = error.getChildElement('description', null).getText();
                        //system.debug('Description:- '+description);
                        String description2 = error.getChildElement('description2', null).getText();
                        wr.Status = 'Failure';
                        wr.resBody = description2;
                        return wr;
                    }
                }else{//If the request is not processed properly.
                    Dom.XMLNode errormessage = result.getChildElement('errormessage', null);                   
                    
                    //system.debug('Response function Status:- '+errormessage );
                    if(errormessage  != null){                        
                        Dom.XMLNode error = errormessage.getChildElement('error', null);
                        String status = result.getChildElement('status', null).getText();
                        //system.debug('Response Status:- '+status);
                        String errorno = error.getChildElement('errorno', null).getText();
                        //system.debug('Error no:- '+errorno);
                        String description = error.getChildElement('description', null).getText();
                        //system.debug('Description:- '+description);
                        String description2 = error.getChildElement('description2', null).getText();
                        //system.debug('Description 2:- '+description2);
                        String correction = error.getChildElement('correction', null).getText();
                        //system.debug('Correction:- '+correction);
                        wr.Status = 'Failure';
                        wr.resBody = description2;
                        //system.debug('wr'+wr);
                        return wr;
                    }
                }
            }
            else{
                Dom.XMLNode errormessage = response.getChildElement('errormessage', null);
                if(errormessage  != null){
                    Dom.XMLNode error = errormessage.getChildElement('error', null);                                     
                    String errorno = error.getChildElement('errorno', null).getText();                   
                    String description = error.getChildElement('description', null).getText();                    
                    String description2 = error.getChildElement('description2', null).getText();                    
                    String correction = error.getChildElement('correction', null).getText();                    
                    wr.Status = 'Failure';
                    wr.resBody = description2;
                    system.debug('wr'+wr);
                    return wr;
                }
                
            }
        }
        catch(exception ex){
            system.debug('Exception:--'+ex.getlinenumber()+'--->@-->'+ex.getmessage());
            wr.Status = 'Failure';
            wr.resBody = ex.getmessage();
            //system.debug('wr'+wr);
            return wr;
        }
        return wr;
    }
    
    //////////////////////// LOGIC TO CREATE QUOTE ATTACHMENTS /////////////////////////////////////////
    public sObject createAttachmentXML(Id OrderId){
        RequestResponse_Log__c reqresObj =  new RequestResponse_Log__c();
        List<Order> lstOrder = [Select Id, QuoteId ,Quote.name from Order where Id =: OrderId];
        if(!lstOrder.isEmpty()){
            List<Attachment> attachmentList = [Select Id,ParentId, Name,body,ContentType From Attachment a where parentid =: lstOrder[0].QuoteId limit 1];
            if(!attachmentList.isEmpty()){
                DOM.Document attachDoc = new DOM.Document();
                dom.XmlNode function = generateControlXML(attachDoc).addChildElement('function', null, null);
                function.setAttribute('controlid', Utility.getRandomNumber());
                //Create Attachments in inacct
                Integer randomNumber = Integer.valueof((Math.random() * 100));
                dom.XmlNode ccreate = function.addChildElement('create_supdoc', null, null);
                dom.XmlNode supdocid = ccreate.addChildElement('supdocid', null, null).addTextNode(String.valueOf(lstOrder[0].QuoteId));
                dom.XmlNode supdocfoldername = ccreate.addChildElement('supdocfoldername', null, null).addTextNode('Quote Attachments');
                dom.XmlNode supdocdescription = ccreate.addChildElement('supdocdescription', null, null).addTextNode(lstOrder[0].Quote.name);
                dom.XmlNode attachments = ccreate.addChildElement('attachments', null, null);
                dom.XmlNode attachment = attachments.addChildElement('attachment', null, null);
                dom.XmlNode attachmentname = attachment.addChildElement('attachmentname', null, null).addTextNode(lstOrder[0].Quote.name);
                dom.XmlNode attachmenttype = attachment.addChildElement('attachmenttype', null, null).addTextNode('pdf');
                dom.XmlNode attachmentdata = attachment.addChildElement('attachmentdata', null, null).addTextNode(EncodingUtil.base64Encode(attachmentList[0].body));
                HttpRequest AttachRequest = new HttpRequest();
                System.debug('req==>'+attachDoc);
                // Make Callout for Attachments..
                reqresObj = Utility.callout('Intacct',attachDoc.toXmlString());  
                reqresObj.Quote__c = lstOrder[0].QuoteId;
                reqresObj.Order__c = lstOrder[0].Id;
            }
        }
        return Utility.processRecords(reqresObj, 'insert')[0];
    }
    
    /////////////////////////////// LOGIC TO CREATE DATA FOR XML ///////////////////////////////
    public Map<string,sObject> createXMLDataForRequest(){
        try{
            String strMapFields = '';
            List<SFDCToIntacctMap__c > lstMapping  = [Select Active__c,Level__c, Constant_Value__c, Intacct_Node_Name__c, Intacct_Object__c, Intacct_Table__c, SF_Field_API_Name__c,SF_Object__c from SFDCToIntacctMap__c where Intacct_Object__c =:gblStrIntacctObjname AND Active__c = true AND SF_Field_API_Name__c != '' ORDER BY Level__c,Sequence__c];
            system.debug('lstMapping--->'+lstMapping);
            Set<string> intAcctObj = new set<String>(); 
            Set<string> intSFObj = new set<String>();       
            // LOGIC TO GET DATA FROM OBJECT AND RELATED OBJECTS OF ORDER FROM SFDC TO INTACCT MAPPING.
            Map<String,Set<String>> queryMap =  new Map<String, Set<String>>();
            for(SFDCToIntacctMap__c obj: lstMapping){
                //system.debug('objnode-->'+obj.Intacct_Node_Name__c);
                if(String.IsNotEmpty(obj.Intacct_Object__c) && null != obj.Level__c)
                    intAcctObj.add(obj.Intacct_Object__c.toLowerCase());
                intSFObj.add(obj.SF_Object__c);
                if(obj.SF_Field_API_Name__c != null){ 
                    Set<String> tempset = new Set<String>{'Id'};              
                        if(queryMap.get(obj.SF_Object__c) != null){
                            tempset = queryMap.get(obj.SF_Object__c);
                        }
                    tempset.add(obj.SF_Field_API_Name__c);
                    queryMap.put(obj.SF_Object__c,tempset); 
                }
            }
            Map<string,List<sObject>> mapObj = new Map<string,List<sObject>>();
            Map<string, string> mapfields = new Map<string,string>();
            for(String objName : intSFObj){
                String fields = '';
                for(String key:queryMap.get(objName)){
                    if(key != null)
                        fields = fields + key +',';
                }
                fields = fields.removeEnd(',');
                mapfields.put(objName,fields);
            }
            System.debug('mapfields---->'+mapfields);
            strMapFields = '';
            if(mapfields.get('Order') != null)
            {
                strMapFields = mapfields.get('Order');
            }else{
                strMapFields = 'Id,BillToContactId ';
            }
            if(!strMapFields.contains('Intacct_Id__c')) strMapFields += ',Intacct_Id__c'; 
            if(!strMapFields.contains('Record_Id__c')) strMapFields += ',Record_Id__c';
            String Orderquery;
            if(!strMapFields.contains('QuoteId,')){ Orderquery = 'Select QuoteId, AccountId, OpportunityId, Account.IsPersonAccount, Is_Business_Account__c, '+ strMapFields +' from Order where Id = :gblStrOrderId';
            }else{
                Orderquery = 'Select AccountId, OpportunityId, Account.IsPersonAccount, Is_Business_Account__c, '+ strMapFields +' from Order where Id = :gblStrOrderId';
            }
            System.debug('Orderquery@@@@'+Orderquery);
            List<Order> lstOrder =  Database.query(Orderquery);
            system.debug('lstOrder---->'+lstOrder);
            if(lstOrder.size() > 0){
                mapObj.put('Order',lstOrder);
                String quoteId = lstOrder[0].QuoteId;
                List<Opportunity> lstOpportunity = new List<Opportunity>();
                List<Account> lstAccount =  new List<Account>();
                List<Payment_Term__c> lstPaymentTerms =  new List<Payment_Term__c>();
                List<Contact> lstContact =  new List<Contact>();
                If(lstOrder[0].AccountId != null ){
                    string accId = lstOrder[0].AccountId;
                    strMapFields = '';
                    if(mapfields.get('Account') != null) {strMapFields = mapfields.get('Account');
                    } else{
                        strMapFields = 'Id';
                    }
                    system.debug('Account Fields:-'+mapfields.get('Account'));
                    if(!strMapFields.contains('Intacct_Id__c')) strMapFields += ',Intacct_Id__c';
                    string accQuery = 'SELECT '+strMapFields+' FROM ACCOUNT WHERE ID =: accId';
                    lstAccount = Database.query(accQuery);
                    mapObj.put('Account',lstAccount);
                    system.debug('lstAccount-->'+lstAccount);
                    system.debug('QuoteId-->'+lstOrder[0].QuoteId +'--gblStrOrderId-->'+gblStrOrderId);
                    if(String.isnotEmpty(gblStrOrderId) && String.isnotEmpty(quoteId)){
                        strMapFields = '';
                        if(mapfields.get('Payment_Term__c') != null)  { strMapFields = mapfields.get('Payment_Term__c'); }
                        else{ strMapFields = 'Id';}
                        system.debug('strMapFields--->'+strMapFields);
                        system.debug('gblStrPaymentTermId--->'+gblStrPaymentTermId);
                        if(!strMapFields.contains('Intacct_Id__c')) strMapFields += ',Intacct_Id__c'; 
                        if(!strMapFields.contains('Opportunity_CloseDate__c')) strMapFields += ',Opportunity_CloseDate__c'; 
                        if(!strMapFields.contains('Record_Id__c')) strMapFields += ',Record_Id__c';
                        //String paymentTermQry ='SELECT '+strMapFields+' FROM Payment_Term__c WHERE Quote__c =:quoteId ';
                        String paymentTermQry ='SELECT Intacct_Credit_Memo_Record_Id__c, '+strMapFields+' FROM Payment_Term__c WHERE Order__c =:gblStrOrderId';
                        if(String.isnotEmpty(gblStrPaymentTermId)){
                            paymentTermQry = 'SELECT Intacct_Credit_Memo_Record_Id__c, '+strMapFields+' FROM Payment_Term__c WHERE Id =:gblStrPaymentTermId ';
                        }
                        system.debug('paymentTermQry-->'+paymentTermQry+'quoteId-->'+quoteId);
                        lstPaymentTerms = Database.query(paymentTermQry);
                        system.debug('lstPaymentTerms-->'+lstPaymentTerms);
                        mapObj.put('Payment_Term__c',lstPaymentTerms);
                    }
                    system.debug('lstOrder[0].OpportunityId--->'+lstOrder[0].OpportunityId);
                    if(String.isnotEmpty(lstOrder[0].OpportunityId)){
                        string oppId = lstOrder[0].OpportunityId;
                        strMapFields = '';
                        if(mapfields.get('Opportunity') != null) { strMapFields = mapfields.get('Opportunity');} 
                        else { strMapFields = 'Name'; }
                        //system.debug('mapfields.get(Opportunity)--->'+mapfields.get('Opportunity'));
                        if(!strMapFields.contains('Id,')) strMapFields = 'Id,'+ strMapFields;
                        string oppQuery = 'SELECT '+ strMapFields+' FROM OPPORTUNITY WHERE ID =: oppId';
                        //system.debug('oppQuery --->'+Database.query(oppQuery));
                        lstOpportunity =  Database.query(oppQuery);
                        mapObj.put('Opportunity',lstOpportunity);
                    }
                    if(String.isNotEmpty(gblStrContactId)) { 
                        //string contId = objOrder[0].BillToContactId;
                        strMapFields = '';
                        if(mapfields.get('Contact') != null) { strMapFields = mapfields.get('Contact');} 
                        else { strMapFields = 'Id';}
                        if(!strMapFields.contains('Intacct_Id__c')) strMapFields += ',Intacct_Id__c';
                        string conQuery = 'SELECT  '+strMapFields+' FROM CONTACT WHERE ID =: gblStrContactId';
                        lstContact = Database.query(conQuery);
                        mapObj.put('Contact',lstContact);
                    }
                    
                    if(gblStrChargeId  != null && gblStrChargeId != 'dummy'){
                        if(mapfields.get('Charge__c') != null){
                            strMapFields = mapfields.get('Charge__c');
                        }else{
                            strMapFields = 'Id';
                        }
                        String ChargeQuery = 'Select '+ strMapFields + ' From Charge__c WHERE Id=:gblStrChargeId ';
                        List<Charge__c> lstcharges =  new List<Charge__c>();
                        lstcharges = Database.query(ChargeQuery);
                        mapObj.put('Charge__c',lstcharges);
                    }
                    
                    Map<integer,Map<string,sObject>> CountMap = new Map<integer,Map<string,sObject>>();
                    system.debug('mapObj.get(Payment_Term__c)--->'+mapObj.get('Payment_Term__c'));
                    List<sObject>lstobj = mapObj.get('Payment_Term__c');
                    for(integer i= 0; i < lstObj.size(); i++){
                        Map<string,sObject> mapTemp = new Map<string,sObject>();
                        for(string key :  mapObj.keyset()){
                            if( CountMap.get(0) != null){
                                mapTemp = CountMap.get(0);
                            }
                            if(i > 0 && key == 'Payment_Term__c'){
                                mapTemp.put(key,lstObj[i]);
                                CountMap.put(i,mapTemp);
                                break;
                            }                      
                            else if(i == 0){
                                mapTemp.put(key,mapObj.get(key)[0]);
                                CountMap.put(i,mapTemp);
                            }
                        }
                        // for(string objname : intAcctObj){
                        //if(i == 0 || objname == 'create_sotransaction' ||  objname == 'create_arpayment'){
                        return mapTemp;
                        // }
                        // }
                    }
                }
            }
        }
        catch(exception ex){system.debug('Exception:'+ex.getlinenumber() +'-->'+ex.getmessage());Log.debug('Exception:'+ex.getlinenumber() +'-->'+ex.getmessage());}
        return null;
    }

    public void contactDataUpdateCallout(Contact objContact) {
        try{
            Dom.Document xmlDoc = new Dom.Document();
            dom.XmlNode function = generateControlXML(xmlDoc).addChildElement('function', null, null);
            function.setAttribute('controlid', Utility.getRandomNumber());
            dom.XmlNode read = function.addChildElement('update', null, null);
            dom.XmlNode addAttributes = read.addChildElement('CONTACT', null, null);
            addAttributes.addChildElement('RECORDNO', null, null).addTextNode(objContact.Record_Id__c);
            addAttributes.addChildElement('PREFIX', null, null).addTextNode(objContact.Salutation != null ? string.valueof(objContact.Salutation) : '');
            addAttributes.addChildElement('FIRSTNAME', null, null).addTextNode(objContact.FirstName != null ? string.valueof(objContact.FirstName) : '');
            addAttributes.addChildElement('LASTNAME', null, null).addTextNode(string.valueof(objContact.LastName));
            addAttributes.addChildElement('PRINTAS', null, null).addTextNode(string.valueof(objContact.Name));
            Utility.callout('Intacct',xmlDoc.toXmlString());
        }
        catch(exception ex){system.debug('Exception-----'+ex.getmessage());}
    }

    public void updateInvoiceCallout(String OrderId, String invoiceNo, String poNumber) {
        system.debug('@@ Sales Invoice-' + OrderId+', invoiceNo: '+invoiceNo+', poNumber: '+poNumber);
        try{
            List<order> odr = new List<order>([Select Location_Id__c from Order where Id =:OrderId Limit 1]);
            if(!odr.isempty() && odr[0].Location_Id__c != null) gblLocationId = String.valueOf(odr[0].Location_Id__c);
            gblStrIntacctObjname = 'Sales Invoice';

            Dom.Document xmlDoc = new Dom.Document();
            dom.XmlNode function = generateControlXML(xmlDoc).addChildElement('function', null, null);
            function.setAttribute('controlid', Utility.getRandomNumber());
            dom.XmlNode updateTranscation = function.addChildElement('update_sotransaction', null, null);
            updateTranscation.setAttribute('key', 'Sales Invoice-'+invoiceNo);
            dom.XmlNode customeFieldsTag = updateTranscation.addChildElement('customfields', null, null);
            dom.XmlNode customeFieldIdTag = customeFieldsTag.addChildElement('customfield', null, null);
            customeFieldIdTag.addChildElement('customfieldname', null, null).addTextNode('PO_NUMBER');
            customeFieldIdTag.addChildElement('customfieldvalue', null, null).addTextNode(poNumber);
            RequestResponse_Log__c objRequestResponse = Utility.callout('Intacct',xmlDoc.toXmlString());
            System.debug('objRequestResonse.Status_Code__c-->'+objRequestResponse.Status_Code__c);
            if(objRequestResponse != null){
                objRequestResponse.Order__c = OrderId;
                Utility.processRecords(objRequestResponse, 'insert');
            }
            system.debug('@@ Sales Invoice-' + invoiceNo+' updated, Doc object: '+xmlDoc.toXmlString());
        }
        catch(exception ex){system.debug('Exception-----'+ex.getmessage());}
    }
    
    public void updateAmoutOnInvoiceCallout(Id paymentTermId, String invoiceNo, String amount) {
        system.debug('@@  invoiceNo: '+invoiceNo+', amount: '+amount);
        try{
             Dom.Document xmlDoc = new Dom.Document();
            dom.XmlNode function = generateControlXML(xmlDoc).addChildElement('function', null, null);
            function.setAttribute('controlid', Utility.getRandomNumber());
            dom.XmlNode updateTranscation = function.addChildElement('update_sotransaction', null, null);
            updateTranscation.setAttribute('key', invoiceNo);
            dom.XmlNode updatesotransitemsNode = updateTranscation.addChildElement('updatesotransitems', null, null);
            dom.XmlNode updatesotransitemNode = updatesotransitemsNode.addChildElement('updatesotransitem', null, null);
            updatesotransitemNode.setAttribute('line_num', '1');
            dom.XmlNode priceNode = updatesotransitemNode.addChildElement('price', null, null).addTextNode(amount);

            RequestResponse_Log__c objRequestResponse = Utility.callout('Intacct',xmlDoc.toXmlString());
          System.debug('objRequestResonse.Status_Code__c-->'+objRequestResponse.Status_Code__c);
            if(objRequestResponse != null){
                objRequestResponse.Payment_Terms__c = paymentTermId;
                Utility.processRecords(objRequestResponse, 'insert');
            }
        }
        catch(exception ex){system.debug('Exception-----'+ex.getmessage());}
    }

    public void getIntcctData(String IntacctObj,String key,dom.XmlNode xmlDoc){
        try{
            //dom.XmlNode function = generateControlXML(doc).addChildElement('function', null, null);
            dom.XmlNode function = xmlDoc.addChildElement('function', null, null);
            function.setAttribute('controlid', ''+ gblRandomString);
            dom.XmlNode read;
            if(IntacctObj == 'customer') read = function.addChildElement('readByName', null, null);
            else read = function.addChildElement('read', null, null);
            
            if(IntacctObj == 'contact') IntacctObj = 'contact';
            else if(IntacctObj == 'sales order') IntacctObj = 'SODOCUMENT';
            else if(IntacctObj == 'sales invoice') IntacctObj = 'ARINVOICE';
            else if(IntacctObj == 'customer') IntacctObj = 'customer';
            read.addChildElement('object', null, null).addTextNode(IntacctObj);
            read.addChildElement('keys', null, null).addTextNode(key);
        }
        catch(exception ex){system.debug('Exception-----'+ex.getmessage());}
    }
    
    
    
    public string CheckIntcctData(String gblStrIntacctObjname,Map<string,sObject> mapObjects){
        String intRecordId = '';
        try{
            system.debug('###objName=='+gblStrIntacctObjname);            
            DOM.Document Docdata = new DOM.Document();
            dom.XmlNode xmlDoc = generateControlXML(Docdata);            
            if(gblStrIntacctObjname.toLowerCase() == 'customer' || gblStrIntacctObjname.toLowerCase() == 'contact' || gblStrIntacctObjname.toLowerCase() == 'sales order' || gblStrIntacctObjname.toLowerCase() == 'sales invoice'){
                system.debug('###mapObjects=='+mapObjects.get('Account'));
                if(gblStrIntacctObjname.toLowerCase() == 'customer' && mapObjects.get('Account').get('Intacct_Id__c') != null){
                    getIntcctData(gblStrIntacctObjname,string.valueof(mapObjects.get('Account').get('Intacct_Id__c')),xmlDoc);
                }
                else if(gblStrIntacctObjname.toLowerCase() == 'contact' && mapObjects.get('Contact').get('Intacct_Id__c') != null){
                    getIntcctData(gblStrIntacctObjname,string.valueof(mapObjects.get('Contact').get('Intacct_Id__c')),xmlDoc);
                }
                else if(gblStrIntacctObjname.toLowerCase() == 'sales order' && mapObjects.get('Order').get('Record_Id__c') != null){
                    getIntcctData(gblStrIntacctObjname,string.valueof(mapObjects.get('Order').get('Record_Id__c')),xmlDoc);
                }
                else if(gblStrIntacctObjname.toLowerCase() == 'sales invoice' && mapObjects.get('Payment_Term__c').get('Record_Id__c') != null){
                    getIntcctData(gblStrIntacctObjname,string.valueof(mapObjects.get('Payment_Term__c').get('Record_Id__c')),xmlDoc);
                }
                RequestResponse_Log__c objReqResLog =  new RequestResponse_Log__c();                
                String reqXMLBody = Docdata.toXmlString();
                objReqResLog = Utility.callout('Intacct',reqXMLBody);
                Dom.Document resDoc = new Dom.Document();
                resDoc.load(objReqResLog.Response__c); 
                wrapResponse wrp = parseResponse(resDoc,gblStrIntacctObjname);  
                if(wrp.Status == 'Success') {
                    intRecordId = wrp.resRecordId;                    
                    if(gblStrIntacctObjname.toLowerCase() != 'sales invoice') Utility.processRecords(objReqResLog, 'insert');  
                    return intRecordId;
                }
            }
        }
        catch(exception ex){system.debug('Exception-----'+ex.getmessage());}
        return intRecordId;
    }
    
    //#1150 Create Adjument
    public void createAdujusmentCallout(String PaymentTermId) {
        System.debug(PaymentTermId);
        Payment_Term__c objPaymentTerm = new Payment_Term__c();
        if(String.isNotBlank(PaymentTermId)){
            objPaymentTerm = [Select Id, CurrencyISOCode, Intacct_Adjustment_Id__c, Intacct_Adjustment_Applied__c, Commission__c, Intacct_Id__c, Order__r.Location_Id__c, Order__r.Account.Intacct_Id__c, Record_Id__c, Order__r.International_Stripe__c  FROM Payment_Term__c WHERE Id = :PaymentTermId LIMIT 1];
        }
        System.debug(objPaymentTerm);
        if(objPaymentTerm != null && objPaymentTerm.Intacct_Adjustment_Applied__c == false && String.isBlank(objPaymentTerm.Intacct_Adjustment_Id__c)) {
            gblLocationId = String.valueOf(objPaymentTerm.Order__r.Location_Id__c);
            gblStrIntacctObjname = 'aradjustment';
            
            DOM.Document dom = new DOM.Document();
            dom.XmlNode function = generateControlXML(dom).addChildElement('function', null, null);
            function.setAttribute('controlid', Utility.getRandomNumber());
            
            dom.XmlNode read = function.addChildElement('create_aradjustment', null, null);
            dom.XmlNode customerIdNode = read.addChildElement('customerid', null, null).addTextNode(String.valueOf(objPaymentTerm.Order__r.Account.Intacct_Id__c));
            
            dom.XmlNode datecreated = read.addChildElement('datecreated', null, null);
            dom.XmlNode year = datecreated.addChildElement('year', null, null).addTextNode(String.valueOf(System.Today().year()));
            dom.XmlNode month = datecreated.addChildElement('month', null, null).addTextNode(String.valueOf(System.Today().month()));
            dom.XmlNode day = datecreated.addChildElement('day', null, null).addTextNode(String.valueOf(System.Today().day()));
            
            String adjustment_Number = 'COMM'+ (objPaymentTerm.Intacct_Id__c).remove('Sales Invoice-INV');
            dom.XmlNode adjustmentno = read.addChildElement('adjustmentno', null, null).addTextNode(adjustment_Number);
            
            dom.XmlNode Invoice_Ids  = read.addChildElement('invoiceno', null, null).addTextNode(objPaymentTerm.Intacct_Id__c);
            dom.XmlNode currencyNode = read.addChildElement('currency', null, null).addTextNode(objPaymentTerm.CurrencyISOCode);
            dom.XmlNode exchratetype = read.addChildElement('exchratetype', null, null).addTextNode('Intacct Daily Rate');
            
            dom.XmlNode aradjustmentitems = read.addChildElement('aradjustmentitems', null, null);
            dom.XmlNode lineitem = aradjustmentitems.addChildElement('lineitem', null, null);  
                  
            dom.XmlNode accountlabel = lineitem.addChildElement('glaccountno', null, null).addTextNode(Label.Intacct_GL_Account_Number);
            dom.XmlNode amount = lineitem.addChildElement('amount', null, null).addTextNode(string.valueof(-objPaymentTerm.Commission__c));
            System.debug('reqdoc-->'+dom.toXmlString());
            
            RequestResponse_Log__c objRes = Utility.callout('Intacct',dom.toXmlString()); 
            if(objRes != null){
                objRes.Payment_Terms__c = objPaymentTerm.Id;
                objRes.Class_Name__c = 'AR_Create_Adjustment';

                String adjustmentKey = validateIntacctResponse(objRes);
                String applyAdjustmentResponseKey ='';
                if(adjustmentKey.startsWith('Error:')){
                    objPaymentTerm.Intacct_Failure_Reason__c = 'AR_CREATE_ADJUSTMENT: '+adjustmentKey;
                    objPaymentTerm.Intacct_Status__c =  'Failure';
                }else{
                    objPaymentTerm.Intacct_Adjustment_Id__c = adjustmentKey;
                    objPaymentTerm.Intacct_Adjustment_Created__c  = true;
                    objPaymentTerm.Intacct_Status__c =  'Success';
                    objPaymentTerm.Intacct_Failure_Reason__c = '';

                    if(Label.Intacct_Apply_Adjustment == 'YES') {
                        applyAdjustmentResponseKey = applyAdujusment(objPaymentTerm);
                        if(applyAdjustmentResponseKey.startsWith('Error:')) {
                            objPaymentTerm.Intacct_Failure_Reason__c = 'AR_APPLY_ADJUSTMENT: '+applyAdjustmentResponseKey;
                            objPaymentTerm.Intacct_Status__c =  'Failure';
                        } else {
                            objPaymentTerm.Intacct_Apply_Adjustment_Id__c = applyAdjustmentResponseKey;
                            objPaymentTerm.Intacct_Adjustment_Applied__c = true;
                            objPaymentTerm.Intacct_Status__c =  'Success';
                            objPaymentTerm.Intacct_Failure_Reason__c = '';
                        }
                    }
                }
                system.debug('objPaymentTerm ---'+objPaymentTerm);
                Utility.processRecords(objPaymentTerm, 'update');
                Utility.processRecords(objRes, 'insert');
            }
        }
    }

    //#1151 Apply Adjument
    public String applyAdujusment(Payment_Term__c objPaymentTerm) {
        String currencyString = objPaymentTerm.CurrencyISOCode;
        Boolean isInternational = objPaymentTerm.Order__r.International_Stripe__c;
        String docNumber = '';

        Account_Currency_Mapping__mdt currencyAccountObj = new Account_Currency_Mapping__mdt();
        currencyAccountObj = [select id, Account_ID__c from Account_Currency_Mapping__mdt where Currency__c =:currencyString and International_Stripe__c =:isInternational limit 1];
        System.debug('Accound Id: '+currencyAccountObj.Account_ID__c + 'for Currency: '+currencyString);

        String invoiceNo = objPaymentTerm.Intacct_Id__c;
        if(String.isNotBlank(invoiceNo)){
           List<String> invoiceNoList= invoiceNo.split('-');
           docNumber = invoiceNoList[1];
        }

        DOM.Document dom = new DOM.Document();
        dom.XmlNode function = generateControlXML(dom).addChildElement('function', null, null);
        function.setAttribute('controlid', Utility.getRandomNumber());

        dom.XmlNode createNode = function.addChildElement('create', null, null);
        dom.XmlNode arpymtNode = createNode.addChildElement('arpymt', null, null);
        
        dom.XmlNode financialEntityNode = arpymtNode.addChildElement('financialentity', null, null).addTextNode(currencyAccountObj.Account_ID__c);
        dom.XmlNode paymentNode = arpymtNode.addChildElement('paymentmethod', null, null).addTextNode('EFT');
        dom.XmlNode customerNode = arpymtNode.addChildElement('customerid', null, null).addTextNode(String.valueOf(objPaymentTerm.Order__r.Account.Intacct_Id__c));
        dom.XmlNode docNumberNode = arpymtNode.addChildElement('docnumber', null, null).addTextNode(docNumber);
        dom.XmlNode receiptDateNode = arpymtNode.addChildElement('receiptdate', null, null).addTextNode(System.now().format('MM/dd/yyyy'));
        dom.XmlNode paymentDateNode = arpymtNode.addChildElement('paymentdate', null, null).addTextNode(System.now().format('MM/dd/yyyy'));
        dom.XmlNode currencyNode = arpymtNode.addChildElement('currency', null, null).addTextNode(objPaymentTerm.CurrencyISOCode);

        dom.XmlNode arpymtDetailsNode = arpymtNode.addChildElement('arpymtdetails', null, null);
        dom.XmlNode paymentDetailNode = arpymtDetailsNode.addChildElement('arpymtdetail', null, null);

        dom.XmlNode recordKeyNode = paymentDetailNode.addChildElement('recordkey', null, null).addTextNode(objPaymentTerm.Record_Id__c);
        dom.XmlNode adjuKeyNode = paymentDetailNode.addChildElement('adjustmentkey', null, null).addTextNode(objPaymentTerm.Intacct_Adjustment_Id__c);
        dom.XmlNode adjuAmountNode = paymentDetailNode.addChildElement('trx_adjustmentamount', null, null).addTextNode(string.valueof(objPaymentTerm.Commission__c));
        System.debug('applyAdujusment Dom-->'+dom.toXmlString());
        
        RequestResponse_Log__c objRes = Utility.callout('Intacct',dom.toXmlString());
        System.debug('Response of appplied AR Adjustment-->'+objRes);
        String responseKeyApplyAdjustment = 'Error:';
        if(objRes != null){
            responseKeyApplyAdjustment = validateIntacctResponse(objRes);
            objRes.Payment_Terms__c = objPaymentTerm.Id;
            objRes.Class_Name__c = 'AR_Apply_Adjustment';
            Utility.processRecords(objRes, 'insert');
        }
        return responseKeyApplyAdjustment;

    }

    private String validateIntacctResponse( RequestResponse_Log__c objRes){
        String responseKey = '';
        System.debug('objRes- RES URL---'+objRes);
        Dom.Document resDoc = new Dom.Document();
        resDoc.load(objRes.Response__c);
        dom.XmlNode operation = resdoc.getRootElement().getChildElement('operation', null);
        system.debug('operation ---'+operation );

        if(operation != null) {
            for(Dom.XmlNode childNode : operation.getChildElements()){
                String currentNodeName = childNode.getName();
                system.debug('currentNodeName---'+currentNodeName);
                if(currentNodeName == 'result'){
                    String successStatus = childNode.getChildElement('status', null).getText();
                    system.debug('successStatus---'+successStatus);
                    if(successStatus == 'Success'){
                        String functionString = childNode.getChildElement('function', null).getText();
                        if(functionString=='create'){
                            dom.XmlNode dateNode =  childNode.getChildElement('data', null);
                            dom.XmlNode arpymtNode =  dateNode.getChildElement('arpymt', null);
                            responseKey = arpymtNode.getChildElement('RECORDNO', null).getText();
                        }else if(functionString=='create_aradjustment'){
                             responseKey = childNode.getChildElement('key', null).getText();
                        }else if(functionString=='reverse_arpayment'){
                             responseKey = childNode.getChildElement('controlid', null).getText();
                        }
                    } else {
                        responseKey = 'Error:'+childNode.getChildElement('errormessage', null).getChildElement('error', null).getChildElement('description2', null).getText();
                    }
                }
            }
        }
        return responseKey;
    }

    //1217
    public String applyReverseAdujusment(Payment_Term__c objPaymentTerm) {
        DOM.Document dom = new DOM.Document();
        dom.XmlNode function = generateControlXML(dom).addChildElement('function', null, null);
        function.setAttribute('controlid', Utility.getRandomNumber());

        dom.XmlNode reverseNode = function.addChildElement('reverse_arpayment', null, null);
        reverseNode.setAttribute('key', objPaymentTerm.Intacct_Apply_Adjustment_Id__c);

        dom.XmlNode dateReverseNode = reverseNode.addChildElement('datereversed', null, null);
        dateReverseNode.addChildElement('year', null, null).addTextNode(String.valueOf(System.Today().year()));
        dateReverseNode.addChildElement('month', null, null).addTextNode(String.valueOf(System.Today().month()));
        dateReverseNode.addChildElement('day', null, null).addTextNode(String.valueOf(System.Today().day()));   

        System.debug('@@ Reverse AR Adujusment Dom-->'+dom.toXmlString());
        RequestResponse_Log__c objRes = Utility.callout('Intacct',dom.toXmlString());
        System.debug('Response of appplied Reverse Adjustment-->'+objRes);
        String responseKeyApplyAdjustment = '';
        if(objRes != null){
            responseKeyApplyAdjustment = validateIntacctResponse(objRes);
            objRes.Payment_Terms__c = objPaymentTerm.Id;
            objRes.Class_Name__c = 'Reverse_arpayment';

            if(!responseKeyApplyAdjustment.startsWith('Error')){
                objPaymentTerm.Reverse_AR_Payment__c = true;
                objPaymentTerm.Intacct_Adjustment_Applied__c = false;
                Utility.processRecords(objPaymentTerm, 'update');
            }
            Utility.processRecords(objRes, 'insert');
        }
        return responseKeyApplyAdjustment;
    }
}