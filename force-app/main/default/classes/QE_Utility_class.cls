/*************************************
    Developer:- Sundar Subramaniam
    Created Date:- 11/28/2017
    Modified Date:- 11/28/2017

Modification History - 
1.) 
*************************************/
public class QE_Utility_class {

    public static void sendExceptionEmail(String BodyMsg){
        QE_ExceptionHandling_Email__c cs = QE_ExceptionHandling_Email__c.getOrgDefaults();
        
        String[] toAddresses = new String[] {cs.To_Address__c};
        String[] ccAddresses = new String[] {cs.CC_Address__c};
        String[] bccAddresses = new String[] {cs.BCC_Address__c};
        system.debug('toAddresses=>'+toAddresses);
        system.debug('ccAddresses=>'+ccAddresses);
        system.debug('bccAddresses=>'+bccAddresses);
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setToAddresses(toAddresses);
        if(ccAddresses.size() > 0 || ccAddresses != null)
        message.setCcAddresses(ccAddresses);
        if(bccAddresses.size() > 0 || bccAddresses != null)
        message.setBccAddresses(bccAddresses);
        message.subject = 'MSTS REST API Exception';
        message.plainTextBody = BodyMsg;
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

    }
    
    public static Exception_Log__c errorExceptionLog(String clsName,String mthName, String msg, Integer lineNo, String type,Id OppId,Id relatedId){
        
        Exception_Log__c exce=new Exception_Log__c();
        exce.Class_Name__c=clsName;
        exce.Method_Name__c=mthName;
        exce.Exception_Message__c=msg;
        exce.LineNumber__c=lineNo;
        exce.Type_Name__c=type;
        exce.Opportunity__c = OppId;
        if(relatedId != null){
            String sObjName = relatedId.getSObjectType().getDescribe().getName();
            if(sObjName == 'Account'){
                exce.Account__c = relatedId;
            }else if(sObjName == 'Contact'){
                exce.Contact__c = relatedId;
            }else if(sObjName == 'Payment_Term__c'){
                exce.Opportunity_Payment_Terms__c  = relatedId;
            }
        }
        return exce;
        
    } 
    
    public static RequestResponse_Log__c reqResLog(String clsName,String mthName, String req, String res, String url,String code,String message,Id OppId,Id relatedId){
        
        RequestResponse_Log__c ReqResObj = new RequestResponse_Log__c();
        ReqResObj.Class_Name__c = clsName;
        ReqResObj.Method_Name__c = mthName;
        ReqResObj.Message_Type__c = message;
        ReqResObj.Opportunity__c = OppId;
        if(relatedId != null){
            String sObjName = relatedId.getSObjectType().getDescribe().getName();
            if(sObjName == 'Account'){
                ReqResObj.Account__c = relatedId;
            }else if(sObjName == 'Contact'){
                ReqResObj.Contact__c = relatedId;
            }else if(sObjName == 'Payment_Terms__c'){
                ReqResObj.Payment_Terms__c = relatedId;
            }
        }

        //hidding the username and password
        Dom.Document xmlDocument = new Dom.Document();
        xmlDocument.load(req);
        Dom.XMLNode request = xmlDocument.getRootElement();
        Dom.XMLNode[] loginArray =request.getChildElement('operation',null).getChildElement('authentication',null).getChildElement('login',null).getChildren();
        Dom.XMLNode loginObject =request.getChildElement('operation',null).getChildElement('authentication',null).getChildElement('login',null);
        Dom.XMLNode[] controlArray =request.getChildElement('control',null).getChildren();
        Dom.XMLNode controlObject =request.getChildElement('control',null);
        integer firstCounter = 1;
        for(Dom.XMLNode nodebject : loginArray){
            if(firstCounter == 1){
                nodebject.getParent().removeChild(nodebject);
                loginObject.addChildElement('userid', null, null).addTextNode('USERNAME');
            }
            if(firstCounter == 3){
                nodebject.getParent().removeChild(nodebject);
                loginObject.addChildElement('password', null, null).addTextNode('PASSWORD');
            }
            firstCounter++;
        }
        integer secondCounter = 1;
        for(Dom.XMLNode nodebject : controlArray)
        {
            if(secondCounter == 1){
                nodebject.getParent().removeChild(nodebject);
                loginObject.addChildElement('senderid', null, null).addTextNode('SENDERNAME');
            }
            if(secondCounter == 2){
                nodebject.getParent().removeChild(nodebject);
                controlObject.addChildElement('password', null, null).addTextNode('PASSWORD');
            }
            secondCounter++;
        }

        String restponceDataProcess = String.valueOf(xmlDocument.toXmlString());
         //String restponceDataProcess = req;
        Integer Intlength = restponceDataProcess.length();
        String subjectInput;
        if(Intlength >131060 ){
            subjectInput = restponceDataProcess.substring(0,131060);
        }else if(Intlength < 131060){
            subjectInput = restponceDataProcess.substring(0,Intlength);
        }       

        ReqResObj.Request__c=subjectInput;
        if(res.length() > 131071){
            res = res.subString(0,131071);
        }

        //hidding the username and password
        Dom.Document xmlResponce = new Dom.Document();
        xmlResponce.load(res);
        Dom.XMLNode responce = xmlResponce.getRootElement();
        Dom.XMLNode[] controlsArray = responce.getChildElement('control',null).getChildren();
        Dom.XMLNode controlsObject = responce.getChildElement('control',null);
        Dom.XMLNode[] loginsArray = responce.getChildElement('operation',null).getChildElement('authentication',null).getChildren();
        Dom.XMLNode loginsObject = responce.getChildElement('operation',null).getChildElement('authentication',null);
        integer thiredCounter = 1;
        for(Dom.XMLNode node : controlsArray){
            if(thiredCounter == 2){
                node.getParent().removeChild(node);
                controlsObject.addChildElement('senderid', null, null).addTextNode('SENDERNAME');
            }
            thiredCounter++;
        }
        integer fourCounter = 1;
        for(Dom.XMLNode node : loginsArray){
            if(fourCounter == 2){
                node.getParent().removeChild(node);
                loginsObject.addChildElement('userid', null, null).addTextNode('USERNAME');
            }
            fourCounter++;
        }
        System.debug('Responce-->'+String.valueOf(xmlResponce.toXmlString()));
        ReqResObj.Response__c = String.valueOf(xmlResponce.toXmlString());
        //ReqResObj.Response__c=res;
        ReqResObj.API_URL__c=url;
        ReqResObj.Status_Code__c=code;
        return ReqResObj;
        
    }  
    
    public static string genDynQuery(String qryStr,List<SFDCToIntacctMap_Old__c> accMapList,String objStr, String addField){
        set<String> uniqField = new Set<String>();
        qryStr = 'SELECT Id';
        for(SFDCToIntacctMap_Old__c sti: accMapList){
            if(!uniqField.contains(sti.SF_Field_API_Name__c) && sti.SF_Field_API_Name__c != null){
                qryStr = qryStr +','+ sti.SF_Field_API_Name__c;
                uniqField.add(sti.SF_Field_API_Name__c);
            }
        }
        if(addField == null){
            qryStr = qryStr + ' FROM '+ objStr;
        }else{
            qryStr = qryStr + ' ' + addField + ' '+ ' FROM '+ objStr;
        }
        return qryStr;
    }
    
}