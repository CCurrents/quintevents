public class QE_contactTriggerHandler{
    
    public void OnBeforeInsert(List<Contact> newObjects){

    }
    
    public void OnAfterInsert(List<Contact> newObjects){
        Set<Id> conIdSet = new Set<Id>();
        Set<Id> conIdNewSet = new Set<Id>();
        Set<Id> accIdSet = new Set<Id>();
        Set<Id> accIdNewSet = new Set<Id>();
        Map<Id,Id> accMap = new Map<Id,Id>();
        List<Contact> conUpdate = new List<Contact>();
        List<Account> accUpdate = new List<Account>();
        
        try{
            for(Contact con: newObjects){
            System.debug('con=>'+con.Primary_Contact__c);
                if(con.Primary_Contact__c == TRUE){
                    conIdSet.add(con.Id);
                    
                    if(con.AccountId != null){
                        accIdSet.add(con.AccountId);
                        accMap.put(con.AccountId,con.Id);
                    }
                }
                
                accIdNewSet.add(con.AccountId);
                conIdNewSet.add(con.Id);
            }
            
            System.debug('accIdNewSet=>'+accIdNewSet);
            System.debug('conIdNewSet=>'+conIdNewSet);
            System.debug('accMap=>'+accMap);
            if(accIdSet.size() > 0 && conIdSet.size() > 0){
                for(Contact conRec: [SELECT Id, Name, AccountId,Primary_Contact__c  FROM Contact WHERE AccountId IN: accIdSet AND Id NOT IN: conIdSet]){
                    if(conRec.Primary_Contact__c == TRUE){
                        conRec.Primary_Contact__c = FALSE;
                        conUpdate.add(conRec);                   
                    }
                }
            }
            
            if(accIdNewSet.size() > 0 && conIdNewSet.size() > 0){
             List<contact> lstContact=new List<Contact>();
             Map<string,List<contact>> newAccountMap =new Map<string,List<contact>>();
             for(Account item:[SELECT Id,(SELECT Id, Name, AccountId,Primary_Contact__c,Account.RecordTypeID  FROM Contacts order by createddate asc limit 1 ) From Account WHERE ID IN : accIdNewSet]){
                 newAccountMap.put(item.Id,item.Contacts) ;
                 }
                    for(Id item:newAccountMap.keyset())
                    {  
                        List<Contact> ls=newAccountMap.get(item);
                        system.debug('ls==>'+ls);
                        if(ls.size()>0 && ls[0].Account.RecordTypeID==Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId())
                        {
                            ls[0].Primary_Contact__c=true;
                            conUpdate.add(ls[0]);
                        }
                    }
             }
            
            if(accIdSet.size() > 0){
                for(Account acc: [SELECT Id, Name, Primary_Contact__c FROM Account WHERE Id IN: accIdSet]){
                    acc.Primary_Contact__c = accMap.get(acc.Id);    
                    accUpdate.add(acc);
                }
            }
            
            System.debug('conUpdate=>'+accUpdate);
            if(conUpdate.size() > 0){
                update conUpdate;
            }
            
            if(accUpdate.size() > 0){
                update accUpdate;
            }
            
        }catch(Exception ex){
             system.debug('Error==>'+ex.getMessage()+' Line Number==>'+ex.getLineNumber());
        }  
    }
    
    public void OnBeforeUpdate(List<Contact> oldObjects, List<Contact> updatedObjects,Map<Id,Contact> MapNewObject, Map<Id,Contact> MapOldObject){
        
    }
    
    public void OnAfterUpdate(List<Contact> oldObjects, List<Contact> updatedObjects,Map<Id,Contact> MapNewObject, Map<Id,Contact> MapOldObject){
        Set<Id> conIdSet = new Set<Id>();
        Set<Id> accIdSet = new Set<Id>();
        Map<Id,Id> accMap = new Map<Id,Id>();
        List<Contact> conUpdate = new List<Contact>();
        List<Account> accUpdate = new List<Account>();
        
        try{
            for(Contact con: updatedObjects){
            System.debug('con=>'+con.Primary_Contact__c+'MapOldObject.get(con.Id).Primary_Contact__c=>'+MapOldObject.get(con.Id).Primary_Contact__c);
                if(MapOldObject.get(con.Id).Primary_Contact__c == FALSE && con.Primary_Contact__c == TRUE){
                    conIdSet.add(con.Id);
                    
                    if(con.AccountId != null){
                        accIdSet.add(con.AccountId);
                        accMap.put(con.AccountId,con.Id);
                    }
                }
            }
            System.debug('accIdSet=>'+accIdSet);
            System.debug('conIdSet=>'+conIdSet);
            if(accIdSet.size() > 0 && conIdSet.size() > 0){
                for(Contact conRec: [SELECT Id, Name, AccountId,Primary_Contact__c  FROM Contact WHERE AccountId IN: accIdSet AND Id NOT IN: conIdSet]){
                    if(conRec.Primary_Contact__c == TRUE){
                        conRec.Primary_Contact__c = FALSE;
                        conUpdate.add(conRec);                   
                    }
                }
            }
            if(accIdSet.size() > 0){
                for(Account acc: [SELECT Id, Name, Primary_Contact__c FROM Account WHERE Id IN: accIdSet]){
                    acc.Primary_Contact__c = accMap.get(acc.Id);    
                    accUpdate.add(acc);
                }
            } 
            
            if(conUpdate.size() > 0){
                update conUpdate;
            }
            
            if(accUpdate.size() > 0){
                update accUpdate;
            }
            
        }catch(Exception ex){
             system.debug('Error==>'+ex.getMessage()+' Line Number==>'+ex.getLineNumber());
        }
    }   

    //added by manan patel---***---
    public static void updateContactNameToIntacct(List<contact> newContact, Map<Id,contact> oldOPTMap){
       set<Id> setcontactIds = new set<Id>();
       for(contact con : newContact){
           String newContactName = con.Salutation+' '+con.FirstName+' '+con.LastName;
           String oldContactName = oldOPTMap.get(con.Id).Salutation+' '+oldOPTMap.get(con.Id).FirstName+' '+oldOPTMap.get(con.Id).LastName;
           
            if(newContactName != null && newContactName != oldContactName){
               setcontactIds.add(con.Id);
            }
       }
       if(setcontactIds.size()>0){
           calloutToupdateIntacctContact(setcontactIds);
       }
   }
   
   @future(callout=true)
   public static void calloutToupdateIntacctContact(Set<Id> setcontactIds){
       List<contact> contactList = New List<contact>([Select id,Name,Salutation,FirstName,LastName,Record_Id__c,Intacct_Id__c,Sandbox_Intacct_Id__c,Sandbox_Record_Id__c from contact where id in: setcontactIds]);
       Intacct_API_Details__c cs = Intacct_API_Details__c.getOrgDefaults();
       if(contactList.size()>0){
           for(contact con: contactList){
               createIntacctInvoiceDateRequest(cs,con);
           }
       }
   }
   
   private static void createIntacctInvoiceDateRequest(Intacct_API_Details__c cs, contact opt){
    
        if((cs.Production__c == true  && opt.Record_Id__c != null) || (cs.Production__c == false && opt.Sandbox_Record_Id__c != null)){
            Dom.Document xmlDoc = new Dom.Document();
            dom.XmlNode function = QE_Intacct_FutureCallout.controlAuthXML(cs, xmlDoc,null);
            dom.XmlNode read = function.addChildElement('update', null, null);
            dom.XmlNode addAttributes = read.addChildElement('CONTACT', null, null);
            addAttributes.addChildElement('RECORDNO', null, null).addTextNode(string.valueof(cs.Production__c ? opt.Record_Id__c : opt.Sandbox_Record_Id__c));
            addAttributes.addChildElement('PREFIX', null, null).addTextNode(opt.Salutation != null ? string.valueof(opt.Salutation) : '');
            addAttributes.addChildElement('FIRSTNAME', null, null).addTextNode(opt.FirstName != null ? string.valueof(opt.FirstName) : '');
            addAttributes.addChildElement('LASTNAME', null, null).addTextNode(string.valueof(opt.LastName));
            addAttributes.addChildElement('PRINTAS', null, null).addTextNode(string.valueof(opt.Name));

            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setEndpoint(cs.Production__c? cs.EndpointURL__c: cs.Sandbox_EndpointURL__c);
            req.setHeader('Content-Type', 'text/xml');
            req.setBodyDocument(xmlDoc);
            System.debug('Request-->'+xmlDoc.toXmlString());        
            Http http = new Http();
            if(!Test.Isrunningtest()){
                HttpResponse res = http.send(req);
                Dom.Document resDoc = res.getBodyDocument();
                System.debug('Responce: '+resDoc.toXmlString());
            }
        }
   } 
}