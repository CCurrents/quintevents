@isTest
public class QE_Utility_class_test{
    public static testMethod void testMethod1(){
        QE_ExceptionHandling_Email__c QEExceptionHandlingEmailObj = new QE_ExceptionHandling_Email__c();
        QEExceptionHandlingEmailObj.To_Address__c = 'test1@test.com';
        QEExceptionHandlingEmailObj.CC_Address__c = 'test2@test.com';
        QEExceptionHandlingEmailObj.BCC_Address__c = 'test3@test.com';
        insert QEExceptionHandlingEmailObj;
        
        SFDCToIntacctMap_Old__c SFDCToIntacctMapObj = new SFDCToIntacctMap_Old__c();
        SFDCToIntacctMapObj.Active__c = true;
        SFDCToIntacctMapObj.Constant_Value__c = 'each';
        SFDCToIntacctMapObj.Description__c = 'true';
        SFDCToIntacctMapObj.Intacct_Node_Name__c = 'customerid';
        SFDCToIntacctMapObj.Intacct_Table__c = 'create_sotransaction';
        SFDCToIntacctMapObj.Operation__c = 'create';
        SFDCToIntacctMapObj.Sequence__c = 2.0;
        SFDCToIntacctMapObj.Type__c = 'true';
        SFDCToIntacctMapObj.SF_Field_API_Name__c = 'Name';
        SFDCToIntacctMapObj.SF_Object__c = 'Contact';
        SFDCToIntacctMapObj.Intacct_Object__c = 'Sales Order';
        insert SFDCToIntacctMapObj;
        
        List<SFDCToIntacctMap_Old__c> SFDCToIntacctMapList = new List<SFDCToIntacctMap_Old__c>();
        SFDCToIntacctMapList.add(SFDCToIntacctMapObj);
        
        string clsName = 'test class';
        string mthName = 'test Method';
        string msg = 'test Message';
        Integer lineNo = 14;
        string type = 'type';
        Id OppId = '07MW00000043i1A';
        Id relatedId = '07MW00000043i1A';
        String req = '<?xml version="1.0" encoding="UTF-8"?><request><control><senderid>QuintEvents</senderid><password>8_64!JO4bA</password>';
        req += '<controlid>3296b819-6c79-2979-3656-9ce5da913a88</controlid><uniqueid>false</uniqueid><dtdversion>3.0</dtdversion><includewhitespace>false';
        req += '</includewhitespace></control><operation><authentication><login><userid>jpatel</userid><companyid>QuintEvents-imp</companyid><password>QuinT.5667!</password>';
        req += '</login></authentication><content><function controlid="3296b819-6c79-2979-3656-9ce5da913a88"><create /></function></content></operation></request>';
        
        String res = '<?xml version="1.0" encoding="UTF-8"?><response><control><status>success</status><senderid>QuintEvents</senderid><controlid>bd03212b-9b94-80f8-631f-2a485dc3f739</controlid><uniqueid>false</uniqueid>';
        res += '<dtdversion>3.0</dtdversion></control><operation><authentication><status>success</status><userid>jpatel</userid><companyid>QuintEvents-imp</companyid><locationid /><sessiontimestamp>2019-02-04T23:30:44-08:00</sessiontimestamp>';
        res += '</authentication><result><status>success</status><function>create</function><controlid>bd03212b-9b94-80f8-631f-2a485dc3f739</controlid><data listtype="objects" count="1"><customer>';
        res += '<RECORDNO>1132</RECORDNO><CUSTOMERID>C0049871</CUSTOMERID></customer></data></result></operation></response>';
        String url = 'www.test.com';
        String code = 'code';
        String qryStr = '';
        String objStr = 'Account';
        string BodyMsg = 'test method for QE_Utility_class';
        String addField = 'name';
        QE_Utility_class.sendExceptionEmail(BodyMsg);
        
        QE_Utility_class.errorExceptionLog(clsName,mthName,msg,lineNo,type,OppId,relatedId);    
        
        QE_Utility_class.reqResLog(clsName,mthName,req,res,url,code,msg,OppId,relatedId);
        
        QE_Utility_class.genDynQuery(qryStr,SFDCToIntacctMapList,objStr,null);
        
        QE_Utility_class.genDynQuery(qryStr,SFDCToIntacctMapList,objStr,addField);
    }   

}