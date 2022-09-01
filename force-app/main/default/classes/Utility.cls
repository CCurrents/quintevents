/**
 * @File Name          : Utility.cls
 * @Description        : Generic Class which will contain all the reuseable methods 
 * Wiki Link           : https://gitlab.com/addonblue/quintevents/qe360/-/wikis/Test-Data-Factory-and-Utility-Class
 * @Author             : Lovel Panchal - lpanchal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/8/2020, 4:08:04 AM
 * @Modification Log   : 
 * Ver       Date            Author             Modification
 * 1.0    3/2/2020   lpanchal@addonblue.com     Initial Version
 * 1.1    4/8/2020   jagrawal@addonblue.com     Added methods getSOQLCount & getTrigger Size        
**/
public with sharing class Utility {
    
    static Map<Id, DatedConversionRate> DatedConversionRateById = null;
    static Map<String,Decimal> conversionRateByIsoCode = new Map<String,Decimal>();
    static Map<Date, Map<String,Decimal>> conversionRateByDate = new Map<Date, Map<String,Decimal>>();

    // Constructor
    public static  void DatedConversionRate() {
        // Query all active currency types
        DatedConversionRateById = new Map<Id, DatedConversionRate>([
            Select Id, IsoCode, ConversionRate, StartDate, NextStartDate
            From DatedConversionRate Order By StartDate DESC
        ]);
        // Create map of conversation rate by currency iso code
        for(DatedConversionRate dcr : DatedConversionRateById.values()) {
            if(!conversionRateByDate.Containskey(dcr.startDate)){
                conversionRateByDate.put(dcr.startDate, new Map<String,Decimal>{dcr.IsoCode => dcr.ConversionRate});                
            }else{
                conversionRateByDate.get(dcr.startDate).put(dcr.IsoCode, dcr.ConversionRate);
            }
            
            if(conversionRateByIsoCode.get(dcr.IsoCode) == null){
                conversionRateByIsoCode.put(dcr.IsoCode, dcr.ConversionRate);
            }
        }
    }
    
    // Convert
    public static  Decimal convert(Decimal amount, String toIsoCode,Date exchangerateDate) {
        DatedConversionRate();
        System.debug('conversionRateByIsoCode:'+conversionRateByIsoCode);
        System.debug('conversionRateByDate:'+conversionRateByDate);
        // Get conversion rate        
        Decimal toRate;
        if(exchangerateDate != null && conversionRateByDate.containskey(exchangerateDate) && conversionRateByDate.get(exchangerateDate) != null){
            toRate = conversionRateByDate.get(exchangerateDate).get(toIsoCode.toUpperCase());
        }
        else{
            toRate = conversionRateByIsoCode.get(toIsoCode.toUpperCase());        
        }
        // Calculate
        Decimal convertedAmount = amount * toRate;
        // Return
        return convertedAmount;
    }
    
    /**************************************************************************
       Purpose: Convert the Currency
       Parameters: Decimal amount, String fromIsoCode, String toIsoCode
       Returns: Decimal 
       Throws [Exceptions]: 
    ****************************************************************************/
    public static  Decimal convertCurrencyFromIsoToIso(Decimal amount, String fromIsoCode, String toIsoCode){
        DatedConversionRate();
        if (String.isEmpty(fromIsoCode) || String.isEmpty(toIsoCode)) {
            return amount;
        }
        
        // get values and then rate
        Decimal fromRate = conversionRateByIsoCode.get(fromIsoCode.toUpperCase());
        Decimal toRate = conversionRateByIsoCode.get(toIsoCode.toUpperCase());
        Decimal currencyRate = toRate/fromRate;
        
        // calculating the currency
        Decimal convertedRate = amount * currencyRate;
        Decimal convertedRateRounded = convertedRate.setScale(1, System.RoundingMode.HALF_UP);
        
        return convertedRateRounded;
    }
      
    // @Description : Generic Callout HTTP method
    // @Parmeters : type - it will have the integration name eg. Intacct, Xero, GPE 
    // @Parmeters : body - The req body which needs to send 
    // @Return type : RequestResponse_Log__c which will contains partial parmerter and instertion should be handled by calling method.
    public static RequestResponse_Log__c callout(string type, string body){
        RequestResponse_Log__c objRequestResponse_Log =  new RequestResponse_Log__c();
        try{
            Integration_Setting__mdt objIntegrationSetting = new Integration_Setting__mdt();
            system.debug('body-->'+body);
            objIntegrationSetting =  [Select Content_Type__c,Endpoint__c,Type__c from Integration_Setting__mdt where DeveloperName =:type and Is_Active__c = true LIMIT 1];
            String reqXMLBody = body;
            HttpRequest req = new HttpRequest();
            req.setTimeout(120000);
            req.setEndpoint(objIntegrationSetting.Endpoint__c);
            req.setMethod(objIntegrationSetting.Type__c);
            req.setHeader('Content-Type', objIntegrationSetting.Content_Type__c);
            req.setBody(body);
            Http http = new Http();
            if(!Test.isRunningTest()){
                HTTPResponse res = http.send(req);
                objRequestResponse_Log.Request__c = body;
                objRequestResponse_Log.Response__c = String.valueof(res.getBody());
                objRequestResponse_Log.Status_Code__c =  res.getStatusCode()+'';
                objRequestResponse_Log.Message_Type__c = res.getStatus();
                objRequestResponse_Log.API_URL__c = objIntegrationSetting.Endpoint__c;
                system.debug('res'+res);
            }else{
                objRequestResponse_Log.Request__c = body;
                objRequestResponse_Log.Response__c = String.valueof('<?xml version="1.0" encoding="UTF-8"?><response><control><status>success</status><senderid>QuintEvents</senderid><controlid>982c9fd7-b86f-ab0e-df1b-1419629343fe</controlid><uniqueid>false</uniqueid><dtdversion>3.0</dtdversion></control><operation><authentication><status>success</status><userid>jpatel</userid><companyid>QuintEvents-sandbox</companyid><locationid>100</locationid><sessiontimestamp>2020-03-19T14:00:57+00:00</sessiontimestamp><sessiontimeout>2020-03-19T20:00:57+00:00</sessiontimeout></authentication><result><status>success</status><function>create_sotransaction</function><controlid>e5d2d1de-b5a7-fe17-6ff6-20c6408a86f7</controlid><key>Sales Order-SO9353</key></result></operation></response>');
                objRequestResponse_Log.Status_Code__c =  '200';
                objRequestResponse_Log.Message_Type__c = 'Success';
                objRequestResponse_Log.API_URL__c = 'Test.com';
            }
            
        }
        catch(exception ex){
            // Error logging need to done
            Log.debug('Exception:'+ex.getlinenumber() +'-->'+ex.getmessage());
            system.debug('Exception:'+ex.getlinenumber() +'-->'+ex.getmessage());
        }
        return objRequestResponse_Log;
    }
    // @Description : Generic Callout HTTP method
    // @Parmeters : type - it will have the integration name eg. BrandFuel 
    // @Parmeters : body - The req body which needs to send 
    // @Parmeters : brandFuelEmail - The req email which needs to check user exisy or not 
    // @Return type : RequestResponse_Log__c which will contains partial parmerter and instertion should be handled by calling method.
    public static RequestResponse_Log__c callout(String type, String body, String endPointString){
        //under construction by manan patel
        RequestResponse_Log__c objRequestResponse_Log =  new RequestResponse_Log__c();
        try{
            Integration_Setting__mdt objIntegrationSetting = new Integration_Setting__mdt();
            objIntegrationSetting =  [Select Content_Type__c,Endpoint__c,Type__c,UserId__c,Password__c from Integration_Setting__mdt where DeveloperName =:type and Is_Active__c = true LIMIT 1];
            //String reqXMLBody = body;
            HttpRequest req = new HttpRequest();
            req.setEndpoint(objIntegrationSetting.Endpoint__c+endPointString);
            req.setMethod(objIntegrationSetting.Type__c);
            req.setHeader('Content-Type', objIntegrationSetting.Content_Type__c);
            req.setHeader('User-Agent', 'Fulcrum');
            Blob headerValue = Blob.valueOf(objIntegrationSetting.UserId__c + ':' + objIntegrationSetting.Password__c);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            req.setHeader('Accept', 'application/json');
            req.setHeader('Authorization', authorizationHeader);
            if(body != null){
                req.setBody(body);
            }
            Http http = new Http();
            HTTPResponse res = http.send(req);
            objRequestResponse_Log.Request__c = body;
            objRequestResponse_Log.Response__c = String.valueof(res.getBody());
            objRequestResponse_Log.Status_Code__c =  res.getStatusCode()+'';
            objRequestResponse_Log.Message_Type__c = res.getStatus();
            objRequestResponse_Log.API_URL__c = objIntegrationSetting.Endpoint__c;
           
        }
        catch(exception ex){
            // Error logging need to done
            Log.debug('Exception:'+ex.getlinenumber() +'-->'+ex.getmessage());
            system.debug('Exception:'+ex.getlinenumber() +'-->'+ex.getmessage());
        }
        return objRequestResponse_Log;
    }
    // @Description : Generic Method to perform DML Operations (Overloaded)
    // @Parmeters : obj - object to be inserted
    // @Parmeters : operation - DML Operation
    // @Return type : List<sObject> List of Sucessfully inserted records.
    public static List<sObject> processRecords(sObject obj, string operation){
        List<sObject> lstObject = new List<sObject>();
        lstObject.add(obj);
        return processRecords(lstObject,operation,false);
    }
    
    // @Description : Generic Method to perform DML Operations (Overloaded)
    // @Parmeters : lstObject - list of object to be inserted
    // @Parmeters : operation - operation - DML Operation 
    // @Return type : List<sObject> List of Sucessfully inserted records.
    public static List<sObject> processRecords(List<sObject> lstObject,string operation){
        return processRecords(lstObject,operation,false);
    }
    
    // @Description : Generic Method to perform DML Operations (Overloaded)
    // @Parameter : obj - object to be inserted
    // @Parameter : operation - DML Operation
    // @Parameter : flag - All or none on DML operation False for Partial
    // @Return type : List<sObject> List of Sucessfully inserted records.
    public static List<sObject> processRecords(sObject obj, string operation, Boolean flag){
        List<sObject> lstObject = new List<sObject>();
        lstObject.add(obj);
        return processRecords(lstObject,operation,flag);
    }
    
    // @Description : Main Method for processRecords
    // @Parameter : lstObject - list of object to be inserted
    // @Parameter : operation - DML Operation
    // @Parameter : flag - All or none on DML operation False for Partial
    // @Return type : List<sObject> List of Sucessfully inserted records.
    public static List<sObject> processRecords(List<sObject> lstObject, String operation, Boolean flag){
        Database.SaveResult[] srList;
        Database.UpsertResult[] upsrtList;
        Database.DeleteResult[] drList;  
        List<sObject> lstResult = new List<sObject>();   
        Set<Id> successIds = new Set<Id>();  
        operation = operation.toLowerCase();
        switch on operation {
            when 'insert' { 
                srList = Database.insert(lstObject, flag);
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        successIds.add(sr.getId());
                    } else {
                        // Operation failed, so get all errors
                        for(Database.Error err : sr.getErrors()) { 
                            System.debug('Insert Failed: fields that affected this error: ' + err.getFields()+'--'+err.getStatusCode() + ': ' + err.getMessage());
                            Log.debug('Insert Failed: fields that affected this error: ' + err.getFields()+'--'+err.getStatusCode() + ': ' + err.getMessage());
                        }
                    }
                }
                for (sObject obj : lstObject) {
                    if (successIds.contains(string.valueof(obj.get('Id')))) {
                        lstResult.add(obj);
                    } 
                }
            }   
            when 'update' {
                srList = Database.update(lstObject, flag);
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        successIds.add(sr.getId());
                    } else {
                        // Operation failed, so get all errors
                        for(Database.Error err : sr.getErrors()) {                           
                            Log.debug('Update Failed: fields that affected this error: ' + err.getFields()+'--'+err.getStatusCode() + ': ' + err.getMessage());
                        }
                    }
                }
                for (sObject obj : lstObject) {
                    if (successIds.contains(string.valueof(obj.get('Id')))) {
                        lstResult.add(obj);
                    } 
                }
            }
            when 'upsert' { 
                upsrtList = Database.upsert(lstObject, flag);
                for (Database.UpsertResult sr : upsrtList) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed                   
                        successIds.add(sr.getId());
                    } else {
                        // Operation failed, so get all errors
                        for(Database.Error err : sr.getErrors()) {
                            Log.debug('Upsert Failed: fields that affected this error: ' + err.getFields()+'--'+err.getStatusCode() + ': ' + err.getMessage());
                        }
                    }
                }
                for (sObject obj : lstObject) {
                    if (successIds.contains(string.valueof(obj.get('Id')))) {
                        lstResult.add(obj);
                    } 
                }
            }
            when 'delete' { 
                drList = Database.delete(lstObject, flag);
                for (Database.DeleteResult sr : drList) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed                   
                        successIds.add(sr.getId());
                    } else {
                        // Operation failed, so get all errors
                        for(Database.Error err : sr.getErrors()) {
                            Log.debug('Delete Failed: fields that affected this error: ' + err.getFields()+'--'+err.getStatusCode() + ': ' + err.getMessage());
                        }
                    }
                }
                for (sObject obj : lstObject) {
                    if (successIds.contains(string.valueof(obj.get('Id')))) {
                        lstResult.add(obj);
                    } 
                }
            }           
            when else {       // default block, optional
                Log.debug('DML Failed: Incorret Operation '+operation);
            }
        }   
        return lstResult;     
    } 
    
    // @Description : Generic Method for merging Records (Overloaded)
    // @Parameter : masterRecord - Master object in which data will be merged
    // @Parameter : duplicateRecord - Duplicate record will get merged into master and get deleted
    // @Parameter : flag - All or none on DML operation False for Partial
    // @Return type : List<sObject> List of Sucessfully inserted records.
    public static void mergeRecords(sObject masterRecord, sObject duplicateRecord, Boolean flag){
        List<sObject> duplicateRecords = new List<sObject>();
        duplicateRecords.add(duplicateRecord);
        mergeRecords(masterRecord, duplicateRecords, flag);
    }
    
    // @Description : Main Method for mergeRecords
    // @Parameter : masterRecord - Master object in which data will be merged
    // @Parameter : duplicateRecords - Duplicate records will get merged into master and get deleted
    // @Parameter : flag - All or none on DML operation False for Partial
    // @Return type : List<sObject> List of Sucessfully inserted records.
    public static void mergeRecords(sObject masterRecord,List<sObject> duplicateRecords, Boolean flag){
           Database.MergeResult[] mrgList = Database.merge(masterRecord,duplicateRecords, flag);
           for (Database.MergeResult sr : mrgList) {
            if (sr.isSuccess()) {
            // Operation was successful, so get the ID of the record that was processed           
            } else {
                // Operation failed, so get all errors
                for(Database.Error err : sr.getErrors()) {                   
                    Log.debug('Insert Failed: fields that affected this error: ' + err.getFields()+'--'+err.getStatusCode() + ': ' + err.getMessage());
                }
            }
        }
    }
    
    // @Description : Method to create Single Mail Messages with some generic parameters required.
    // @Parameter : toAddresses - List of email addresses to whom this email will be sent
    // @Parameter : subject - Subject of the email
    // @Parameter : senderName - Name to be set as the Sender of the email
    // @Parameter : body - Body content of the email
    // @Parameter : bccToSender - whether or not to send the mail back to sender as well
    // @Parameter : saveAsActivity - whether or not to set as activity on the record object
    // @Return type : Messaging.SingleEmailMessage object of SignleEmailMessage
    public static Messaging.SingleEmailMessage createSingleEmailMessage(List<String> toAddresses, String subject, String senderName, String body, Boolean bccToSender, Boolean saveAsActivity){
        Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        mail.setBccSender(bccToSender);
        mail.setSubject(subject);
        mail.setSenderDisplayName(senderName);
        mail.setSaveAsActivity(saveAsActivity);
        mail.setHtmlBody(body);
        return mail;
    }
    // @Description : Method to create Single Mail Messages with some generic parameters required.
    // @Parameter : toAddresses - List of email addresses to whom this email will be sent
    // @Parameter : ccAddresses - List of email addresses to whom this cc email will be sent
    // @Parameter : subject - Subject of the email
    // @Parameter : senderName - Name to be set as the Sender of the email
    // @Parameter : body - Body content of the email
    // @Parameter : bccToSender - whether or not to send the mail back to sender as well
    // @Parameter : saveAsActivity - whether or not to set as activity on the record object
    // @Return type : Messaging.SingleEmailMessage object of SignleEmailMessage
    public static Messaging.SingleEmailMessage createSingleEmailMessage(List<String> toAddresses,List<String> ccAddresses, String subject, String senderName, String body, Boolean bccToSender, Boolean saveAsActivity){
        Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        mail.setCCAddresses(ccAddresses);
        mail.setBccSender(bccToSender);
        mail.setSubject(subject);
        mail.setSenderDisplayName(senderName);
        mail.setSaveAsActivity(saveAsActivity);
        mail.setHtmlBody(body);
        return mail;
    }
    // @Description : Method to stored deleted records on QE_Deleted_Record__c to make an outbound on delete.
    // @Parameter : lstObject - List of sObject to insert in QE_Deleted_Record__c.    
    public static void processDeletedRecords(List<sObject> lstObject){
        List<QE_Deleted_Record__c> listOfRecordsBeingDeleted = new List<QE_Deleted_Record__c>();
        for (sObject obj : lstObject) {
            QE_Deleted_Record__c objOfDeletedRecord = new QE_Deleted_Record__c();
            objOfDeletedRecord.Name = String.valueof(obj.get('Name'));
            objOfDeletedRecord.DeletedId__c = String.valueof(obj.get('Id'));
            listOfRecordsBeingDeleted.add(objOfDeletedRecord);
        }
        try {
            processRecords(listOfRecordsBeingDeleted, 'insert');
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
            Log.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
        }
    }
    
    public static string getRandomNumber(){
        string hexKey = EncodingUtil.ConvertTohex(Crypto.GenerateAESKey(128));
        return(hexKey.SubString(0,8)+ '-' + hexKey.SubString(8,12) + '-' + hexKey.SubString(12,16) + '-' + hexKey.SubString(16,20) + '-' + hexKey.substring(20));
    }
    // @Description : Method to call approval process.
    // @Parameter : Object Id : RecordId, strMessage : Comment for Approval Proces, ProcessName : Approval ProcessName;   
    public static void submitForApproval(Id objId, String strMessage, String ProcessName)
    {
        // Create an approval request for the Opportunity
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setProcessDefinitionNameOrId(ProcessName);
        req.setComments(strMessage);
        req.setObjectId(objId);
        //List<String> setId = new List<String>();
        //for(User objUser : [Select Id,Profile.Name, Username  from User where Profile.Name = 'QE360 - Sales Admin' and IsActive  = true])
        //    setId.add(objUser.Id);
        //req.setNextApproverIds(setId);

        // Submit the approval request for the Opportunity
        Approval.ProcessResult result = Approval.process(req);

    }
    
    public static void TestingAccount(){
        try {
           Account Acc = [Select Id From Account limit 1];
            String Name =  Acc.Name;
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
            Log.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
        }        
    }

    /**
    * @description method to get SOQL Count in current transaction
    * @author jagrawal@addonblue.com | 4/8/2020 
    * @return Integer 
    **/
    public static Integer getSOQLCount(){
        Integer soqlCount = Limits.getQueries();
        System.debug('SOQL Count: ' + soqlCount);
        return soqlCount;
    }

    /**
    * @description 
    * @author jagrawal@addonblue.com | 4/8/2020 
    * @return Integer 
    **/
    public static Integer getTriggerSize(){
        Integer triggerSize = Trigger.size;
        System.debug('Trigger Size: '+triggerSize);
        return triggerSize;
    }

    /**
    * @description  : Method for storing request and response of the API Callouts made
    * @author       : jagrawal@addonblue.com | 28/1/2020 
    * @param-1      : clsName 
    * @param-2      : mthName 
    * @param-3      : req 
    * @param-4      : res 
    * @param-5      : url 
    * @param-6      : code 
    * @param-7      : primaryObjId 
    * @param-8      : relatedObjId 
    * @param-9      : msgType 
    * @return       : RequestResponse_Log__c 
    **/
    public static RequestResponse_Log__c reqResLog(String clsName,String mthName, String req, String res, String url,Integer code,Id primaryObjId,Id relatedObjId,String msgType){
        RequestResponse_Log__c ReqResObj = new RequestResponse_Log__c();
        ReqResObj.Class_Name__c = clsName;
        ReqResObj.Method_Name__c = mthName;
        if(primaryObjId != null) {
            String sObjName = primaryObjId.getSObjectType().getDescribe().getName();
            if(sObjName == 'Product2') {
                ReqResObj.Product__c = primaryObjId;
            } else if(sObjName == 'QuoteLineItem') {
                ReqResObj.Quote_Product_Id__c = primaryObjId;
            }
            else if(sObjName == 'Order') {
                ReqResObj.Order__c = primaryObjId;
            }
            else if(sObjName == 'Quote') {
                ReqResObj.Quote__c = primaryObjId;
            }
            else if(sObjName == 'Rooming_List__c') {
                ReqResObj.Rooming_List__c = primaryObjId;
            }
            else if(sObjName == 'Opportunity') {
                ReqResObj.Opportunity__c = primaryObjId;
            }
            else if(sObjName == 'Account') {
                ReqResObj.Account__c = primaryObjId;
            }
            else if(sObjName == 'Charge__c') {
                ReqResObj.Charge__c = primaryObjId;
            }
            else if(sObjName == 'Contact') {
                ReqResObj.Contact__c = primaryObjId;
            }
            else if(sObjName == 'Payment_Terms__c') {
                ReqResObj.Payment_Terms__c = primaryObjId;
            }
        }
        ReqResObj.H4H_End_Point__c = url;
        ReqResObj.Status_Code__c = String.valueOf(code);
        ReqResObj.Request__c = req;
        ReqResObj.Response__c = res;
        ReqResObj.Message_Type__c = msgType;
        
        if(relatedObjId != null) {
            String sObjName = relatedObjId.getSObjectType().getDescribe().getName();
            if(sObjName == 'Product2') {
                ReqResObj.Product__c = relatedObjId;
            } else if(sObjName == 'QuoteLineItem') {
                ReqResObj.Quote_Product_Id__c = relatedObjId;
            }
            else if(sObjName == 'Order') {
                ReqResObj.Order__c = relatedObjId;
            }
            else if(sObjName == 'Quote') {
                ReqResObj.Quote__c = relatedObjId;
            }
            else if(sObjName == 'Rooming_List__c') {
                ReqResObj.Rooming_List__c = relatedObjId;
            }
            else if(sObjName == 'Opportunity') {
                ReqResObj.Opportunity__c = relatedObjId;
            }
            else if(sObjName == 'Account') {
                ReqResObj.Account__c = relatedObjId;
            }
            else if(sObjName == 'Charge__c') {
                ReqResObj.Charge__c = relatedObjId;
            }
            else if(sObjName == 'Contact') {
                ReqResObj.Contact__c = relatedObjId;
            }
            else if(sObjName == 'Payment_Terms__c') {
                ReqResObj.Payment_Terms__c = relatedObjId;
            }
        }
        return ReqResObj;
    }
}