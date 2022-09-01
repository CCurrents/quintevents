public class AWS_S3_Brochures {
    
    String endpointBase = 'https://s3.amazonaws.com/QuintEvents/';
    public String prefixFromLinkClick {get; set;}
    public String searchQuery {get; set;}
    //public List<S3Element> s3Elements {get; set;}
    //public List<String> breadCrumbs {get; set;}
    public Map<Integer,String> mapOfBreadCrumbPrefixes {get; set;}
    public List<S3Element> allS3ElementsForCurrentRep {get; set;}
    Boolean displayGenericBrochure;
    
    public AWS_S3_Brochures() {
        displayGenericBrochure = [Select Display_Generic_Brochures__c From User Where Id = :UserInfo.getUserId()][0].Display_Generic_Brochures__c;
        // if at base level
        if (String.isBlank(prefixFromLinkClick)) {
            System.debug('getListOfAllS3Elements called!');
        	getListOfAllS3Elements();
        }
    }
    
    // Get only First level
    public list<S3Element> getListOfS3Elements() {
        List<S3Element> s3Elements = new List<S3Element>();
        HttpRequest req = new HttpRequest();
        String params = '';
        if (!String.isBlank(prefixFromLinkClick)) {
			params = String.join(getReqParams(prefixFromLinkClick), '&');
        } else {
            if (displayGenericBrochure) {
                params = String.join(getReqParams('SalesReps/QuintEvents/'), '&');
            } else {
            	params = String.join(getReqParams('SalesReps/'+UserInfo.getFirstName()+' '+UserInfo.getLastName()+'/'), '&');
            }
        }
        req.setEndpoint(endpointBase + '?' + params);
        req.setMethod('GET');
        req.setHeader('list-type', '2');
        s3Elements = processHttpRequest(req);
        return s3Elements;
    }
    
    // Get All files and folders under current rep (to store for searching)
    public void getListOfAllS3Elements() {
        allS3ElementsForCurrentRep = new List<S3Element>();
        HttpRequest req = new HttpRequest();
        String params;
        if (displayGenericBrochure) {
            params = 'SalesReps/QuintEvents/';
        } else {
        	params = 'SalesReps/'+UserInfo.getFirstName()+' '+UserInfo.getLastName()+'/';
        }
        req.setEndpoint(endpointBase + '?' + 'prefix=' + EncodingUtil.urlEncode(params,'UTF-8'));
        req.setMethod('GET');
        req.setHeader('list-type', '2');
        allS3ElementsForCurrentRep = processHttpRequest(req);
        System.debug('allS3ElementsForCurrentRep: '+allS3ElementsForCurrentRep);
    }
    
    // Process request and parse data
    public list<S3Element> processHttpRequest(HttpRequest req) {
    	List<S3Element> s3Elements = new List<S3Element>();
        try {
            Http http = new Http();
            HTTPResponse res = new HTTPResponse();
            if(!test.isrunningtest()) {
            	res = http.send(req);
            } else {
                res.setStatus('OK');
                res.setStatusCode(200);
                res.setBody('<ListBucketResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/"> <Contents><Key>SalesReps/Jeet Patel/Derby 2017/</Key></Contents></ListBucketResult>');
            }
            System.debug('DEBUG: ' + ' RESPONSE STRING: ' + res.toString());
            System.debug('DEBUG: ' + ' RESPONSE STATUS: '+ res.getStatus());
            System.debug('DEBUG: ' + ' STATUS_CODE:'+ res.getStatusCode());
            System.debug('DEBUG: ' + ' GET_BODY:'+ res.getBody());
            // Parse xml
            XmlStreamReader reader = res.getXmlStreamReader();
            reader.setCoalescing(true);
            boolean isSafeToGetNextXmlElement = true;
            while(isSafeToGetNextXmlElement) {
                // Check if its Contents
                if (reader.getEventType() == XmlTag.START_ELEMENT) {
                    if (reader.getEventType() == XmlTag.START_ELEMENT) {
                        if ('Contents' == reader.getLocalName()) {
                            // Pass the element to the parseS3Element method (below)
                            S3Element s3Element = parseS3Element(reader,'file');
                            s3Elements.add(s3Element);
                        }
                        if ('CommonPrefixes' == reader.getLocalName()) {
                            // Pass the element to the parseS3Element method (below)
                            S3Element s3Element = parseS3Element(reader,'folder');
                            s3Elements.add(s3Element);
                        }
                    }
                    // check if we have not reached the end of the stream
                    if (reader.hasNext()) {
                        reader.next();
                    } else {
                        isSafeToGetNextXmlElement = false;
                        break;
                    }
                }
                // we have not reached the end of the stream
                if (reader.hasNext()) {
                    reader.next();
                } else {
                    isSafeToGetNextXmlElement = false;
                    break;
                }
            }
            
        } catch(System.CalloutException e) {
            system.debug('MYDEBUG: AWS Service Callout Exception on ' + 'ERROR: ' + e.getMessage());
        }
		return s3Elements;
    }
    
    // Get Bread Crumb
    public Map<Integer,String> getMapOfBreadCrumbNames() {
        Map<Integer,String> breadCrumbNames = new Map<Integer,String>();
        mapOfBreadCrumbPrefixes = new Map<Integer,String>();
        List<String> tempNamesOfCrumbs = prefixFromLinkClick.split('/');
        Integer counter = 0;
        String prefixForCrumb = '';
        for(String crumb : tempNamesOfCrumbs) {
            breadCrumbNames.put(counter, crumb);
            prefixForCrumb += crumb+'/';
            mapOfBreadCrumbPrefixes.put(counter,prefixForCrumb);
            counter++;
        }
        return breadCrumbNames;
    }
    
    // Prepare Params
    public List<String> getReqParams(String prefix) {
        List<String> tempParamList = new List<String>{
            'prefix=' + EncodingUtil.urlEncode(prefix,'UTF-8'),
                'delimiter=' + EncodingUtil.urlEncode('/','UTF-8')};
                    return tempParamList;
    }
    
    // Parse s3 element
    S3Element parseS3Element(XmlStreamReader reader, String elementType) {
        S3Element s3Element = new S3Element();
        s3Element.elementType = elementType;
        boolean isSafeToGetNextXmlElement = true;
        while(isSafeToGetNextXmlElement) {
            if (reader.getEventType() == XmlTag.END_ELEMENT) {
                break;
            } else if (reader.getEventType() == XmlTag.CHARACTERS) {
                // This is file
                if (elementType == 'file') {
                	s3Element.key = reader.getText();
                    s3Element.fileName = (s3Element.key).substringAfterLast('/');
                }
                // This is folder
                if (elementType == 'folder') {
                	s3Element.prefix = reader.getText();
                    String subStringBeforeDelimiter = (s3Element.prefix).substringBeforeLast('/');
                    s3Element.folderName = (subStringBeforeDelimiter).substringAfterLast('/');
                }
            }
            // check if we have not reached the end of the stream
            if (reader.hasNext()) {
                reader.next();
            } else {
                isSafeToGetNextXmlElement = false;
                break;
            }
        }
        return s3Element;
    }
    
    // s3Element
    public class S3Element {
        public String key {get; set;}
        public String fileName {get; set;}
        public String prefix {get; set;}
        public String elementType {get; set;}
        public String folderName {get; set;}
    }
}