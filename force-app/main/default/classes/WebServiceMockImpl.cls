@isTest
global class WebServiceMockImpl implements HttpCalloutMock{
    public String type;
    global WebServiceMockImpl (String type){
             this.type = type;
    }
    
    
  global HttpResponse respond(HTTPRequest req){
    HttpResponse res = new HttpResponse();
    res.setStatus('OK');
    if(type=='type4'){
        res.setStatusCode(401);
    }else{  
        res.setStatusCode(200);
    }   
    String xml = '';
    if(type=='type1'){
        xml = '<soap><operation><result><key>key</key><status>success</status></result></operation></soap>';
    }   else if(type=='type2'){
        xml = '<soap><operation><result><key>key</key><status>success</status><data><customer><RECORDNO>123</RECORDNO><CUSTOMERID>123</CUSTOMERID><CONTACTNAME>ttest</CONTACTNAME></customer></data></result></operation></soap>';
    }else if(type=='type5'){
        xml = '<soap><operation><result><key>key</key><status>success</status><data count="1"><arinvoice><RECORDNO>11</RECORDNO></arinvoice><sodocument><RECORDNO>11</RECORDNO></sodocument><customer><RECORDNO>123</RECORDNO><CUSTOMERID>123</CUSTOMERID><CONTACTNAME>ttest</CONTACTNAME></customer></data></result></operation></soap>';
    }else {
        xml = '<soap><operation><result><key>key</key><status>failure</status><data count="1"><customer><RECORDNO>123</RECORDNO><CUSTOMERID>123</CUSTOMERID><CONTACTNAME>ttest</CONTACTNAME></customer></data></result></operation></soap>';
    }
    res.setBody(xml);
    return res;
  }
}