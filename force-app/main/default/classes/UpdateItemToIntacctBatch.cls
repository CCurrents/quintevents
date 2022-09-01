/**
 * @File Name          : UpdateItemToIntacctBatch.cls
 * @Description        : To update Item in Intacct
 * @Author             : kchavda@addonblue.com
 * @Group              : 
 * @Last Modified By   : kchavda@addonblue.com
 * @Last Modified On   : 05/12/2020
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0     05/12/2020  kchavda@addonblue.com     Initial Version
**/
public class UpdateItemToIntacctBatch implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful{    
   
    public string query;   
    public map<Id,string> mapsfdcIdwithRecNo;
    public set<Id> setSFDCId;
    /**
    * @description Constructor
    * @author kchavda@addonblue.com | 05/12/2020
    * @param String, Order 
    * @return
    **/
    public UpdateItemToIntacctBatch (string strquery, map<Id,string> mapsfdcIdwithRecNo,set<Id> setSFDCId){    
        this.query = strquery;                
        this.mapsfdcIdwithRecNo = mapsfdcIdwithRecNo;            
        this.setSFDCId = setSFDCId;      
    }
    
    /**
    * @description Start Method
    * @author kchavda@addonblue.com | 05/12/2020
    * @param Database.BatchableContext 
    * @return Database.QueryLocator
    **/
    public Database.QueryLocator start(Database.BatchableContext BC){        
        return Database.getQueryLocator(query);
    }
    
    /**
    * @description Execute Method
    * @author kchavda@addonblue.com | 05/12/2020
    * @param Database.BatchableContext, List<sObject>
    * @return void 
    **/
    public void execute(Database.BatchableContext BC, List<pricebook2> scope){
        if(!scope.isempty()){
            // To update Event in intacct
           /* Dom.Document xmlDoc = new Dom.Document();
            dom.XmlNode function = IntacctOrderSyncBatchHelper.generateControlXML(xmlDoc);
            dom.XmlNode read = function.addChildElement('update', null, null);
            dom.XmlNode addAttributes = read.addChildElement('CLASS', null, null);
            addAttributes.addChildElement('RECORDNO', null, null).addTextNode(mapsfdcIdwithRecNo.get(scope[0].Legacy_15_Digit_Id__c));
            addAttributes.addChildElement('SFDC_ID', null, null).addTextNode(string.valueof(scope[0].Id).substring(0,15));            
            Utility.callout('Intacct',xmlDoc.toXmlString());*/
            
            //To get Item of related event from Intacct
            DOM.Document docs = new DOM.Document();    
            dom.XmlNode funct = IntacctOrderSyncBatchHelper.generateControlXML(docs);
            dom.XmlNode xmlNode;
            xmlNode = funct.addChildElement('readByQuery', null, null);
            xmlNode.addChildElement('object', null, null).addTextNode('ITEM');
            xmlNode.addChildElement('fields', null, null).addTextNode('*');
            String  strQuery = 'RCLASS=\''+mapsfdcIdwithRecNo.get(string.valueof(scope[0].Id).substring(0,15))+'\'';
            xmlNode.addChildElement('query', null, null).addTextNode(strQuery);
            xmlNode.addChildElement('pagesize', null, null).addTextNode('500');
            RequestResponse_Log__c objRes = Utility.callout('Intacct',docs.toXmlString());
            
            Dom.Document resDoc = new Dom.Document();
            resDoc.load(objRes.Response__c); 
            dom.Xmlnode vxroot = resDoc.getRootElement().getChildElement('operation', null);   
            dom.Xmlnode data = vxroot.getChildElement('result', null).getChildElement('data', null); 
            String PRODUCTLINEID = '';
            String GLGROUP = '';
            if(!Test.isrunningtest()){
                for(dom.xmlnode dn: data.getChildren()){    
                    if(dn.getName() == 'item'){
                        PRODUCTLINEID = dn.getChildElement('PRODUCTLINEID', null).getText();
                        GLGROUP = dn.getChildElement('GLGROUP', null).getText();                    
                    }       
                }
            }
            
            //To created Items for related Pricebook to intacct
            Dom.Document Doc = new Dom.Document();
            dom.XmlNode func = IntacctOrderSyncBatchHelper.generateControlXML(Doc);
            dom.XmlNode readdoc = func.addChildElement('create', null, null);
            dom.XmlNode addobject = readdoc.addChildElement('ITEM', null, null);
            addobject.addChildElement('ITEMID', null, null).addTextNode(string.valueof(scope[0].Id).substring(0,15));
            addobject.addChildElement('Name', null, null).addTextNode(scope[0].Name);
            addobject.addChildElement('ITEMTYPE', null, null).addTextNode('Non-Inventory (Sales only)');
            addobject.addChildElement('PRODUCTLINEID', null, null).addTextNode(PRODUCTLINEID);
            addobject.addChildElement('UOMGRP', null, null).addTextNode('Count');
            addobject.addChildElement('GLGROUP', null, null).addTextNode(GLGROUP);
            addobject.addChildElement('Taxable', null, null).addTextNode('true');
            addobject.addChildElement('RCLASS', null, null).addTextNode(mapsfdcIdwithRecNo.get(string.valueof(scope[0].Id).substring(0,15)));             
            Utility.callout('Intacct',Doc.toXmlString());
            
        }
    }
    
    /**
    * @description Finish Method
    * @author kchavda@addonblue.com | 05/12/2020
    * @param Database.BatchableContext
    * @return void 
    **/
    public void finish(Database.BatchableContext BC){    
        
    }
}