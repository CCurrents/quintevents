/**
 * @description       : 
 * @author            : Jheel Agrawal
 * @group             : 
 * @last modified on  : 11-25-2020
 * @last modified by  : Jheel Agrawal
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   11-25-2020   Jheel Agrawal   Initial Version
**/
global class MaskCustomerEmailsAndPhoneBatch implements Database.Batchable<sObject>{
    
    global final String query;
    global final string EmailFields;
    global final string PhoneFields;

    global MaskCustomerEmailsAndPhoneBatch(String e, String p, String o, String w){
        EmailFields=e;
        PhoneFields=p;
        String strQuery='Select Id';
        if(e != null && e != ''){
            strQuery+=','+e.replaceAll(';',',');
        }
        if(p != null && p != ''){
            strQuery+=','+p.replaceAll(';',',');
        }
        if(o != null && o != ''){
            strQuery+=' from '+o;
        }
        if(w != null && w != ''){
            strQuery+=' where '+w;
        }
        if(strQuery.contains('from')){
            query = strQuery;
        }
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<sObject> sObjectListForUpdate = new List<sObject>();
        for(sObject s : scope){
            sObject newSObject = (sObject)s;
            if(EmailFields != null && EmailFields != ''){
                for (String emailFld : EmailFields.split(';')) {
                    if (newSObject.get(emailFld.trim()) != null) {
                        string updatedEmail = 'test'+getRandomNumber()+'@addonblue.com';
                        newSObject.put(EmailFld.trim(), updatedEmail);
                    }
                }
            }
            if(PhoneFields != null && PhoneFields != ''){
                for (String phone : PhoneFields.split(';')) {
                    if (newSObject.get(phone.trim()) != null) {
                        String updatedPhone = '111-111-1111';
                        newSObject.put(phone.trim(), updatedPhone);
                    }
                }
            }
            sObjectListForUPdate.add(newSObject);
        }
        System.debug('SOBJECT :' +sObjectListForUpdate);
        database.update(sObjectListForUpdate, true);
    }
    global void finish(Database.BatchableContext BC){
    }
    
    global string getRandomNumber(){
        string hexKey = EncodingUtil.ConvertTohex(Crypto.GenerateAESKey(128));
        return(hexKey.SubString(0,8)+ '-' + hexKey.SubString(8,12) + '-' + hexKey.SubString(12,16) + '-' + hexKey.SubString(16,20) + '-' + hexKey.substring(20));
    }
}