public class QE_AwsS3Helper {
    
    String s3Key = AWS_S3_Settings__c.getOrgDefaults().S3_Key__c;
    String s3Secret = AWS_S3_Settings__c.getOrgDefaults().S3_Secret__c;
    String s3Host = 's3.amazonaws.com';

    public void uploadXmlFileToS3(String xmlContentString, String filename, String bucketname) {
        String method = 'PUT';
        String contentType = 'text/xml';
        String formattedDateString = Datetime.now().formatGMT('EEE, dd MMM yyyy HH:mm:ss z');
        
        // Encode xml data
        String encodedXmlContentString = EncodingUtil.base64Encode(Blob.valueOf(xmlContentString));
        
        // Request
        HttpRequest req = new HttpRequest();
        req.setMethod(method);
        req.setEndpoint('https://' + bucketname + '.' + s3Host + '/' + filename);
        req.setHeader('Host', bucketname + '.' + s3Host);
        req.setHeader('Content-Length', string.valueOf(encodedXmlContentString.length()));
        req.setHeader('Content-Encoding', 'UTF-8');
        req.setHeader('Content-type', contentType);
        req.setHeader('Connection', 'keep-alive');
        req.setHeader('Date', formattedDateString);
        req.setHeader('ACL', 'public-read');
        req.setBodyAsBlob(Blob.valueOf(xmlContentString));
        
        // Sign
        String stringToSign = method+'\n\n' +
            contentType + '\n' +
            formattedDateString + '\n' +
            '/' + bucketname + '/' + filename;
        
        String encodedStringToSign = EncodingUtil.urlEncode(stringToSign, 'UTF-8');
        Blob mac = Crypto.generateMac('HMACSHA1', blob.valueof(stringToSign),blob.valueof(s3Secret));
        String signed = EncodingUtil.base64Encode(mac);
        String authHeader = 'AWS' + ' ' + s3Key + ':' + signed;
        req.setHeader('Authorization',authHeader);
        String decoded = EncodingUtil.urlDecode(encodedStringToSign , 'UTF-8');
        
        System.debug('Request:'+req);
        
    if(!Test.isRunningTest()) {
    Http http = new Http();
   HTTPResponse res = http.send(req);
    System.debug('*Resp:' + String.ValueOF(res.getBody()));
    System.debug('RESPONSE STRING: ' + res.toString());
    System.debug('RESPONSE STATUS: ' + res.getStatus());
    System.debug('STATUS_CODE: ' + res.getStatusCode());
    
    }
    }
    
}