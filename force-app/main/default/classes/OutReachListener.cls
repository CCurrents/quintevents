/**
 * @description       : 
 * @author            : ratiksinghal@addonblue.com
 * @group             : 
 * @last modified on  : 08-05-2022
 * @last modified by  : ratiksinghal@addonblue.com
**/
public class OutReachListener{

    public static HttpRequest executeCallout(String method, String resourceName, String requestBody){
        HttpRequest request = new HttpRequest();

        IntegrationTokens__c intergrationOutReach = null;
        if(Test.isRunningTest()){
            intergrationOutReach = new IntegrationTokens__c();
            intergrationOutReach.Access_Token__c = 'fserfwr';
            intergrationOutReach.Service_Endpoint__c = 'https://api.outreach.io/api/v2/';
        }else{
            intergrationOutReach = [Select id,name,client_id__c,Client_secret__c,refresh_token__c,Service_Endpoint__c,endpoint__c,access_token__c from IntegrationTokens__c where name = 'Outreach'];
        }
 		request.setEndpoint(intergrationOutReach.Service_Endpoint__c + resourceName);
		request.setMethod(method);
        request.setHeader('Accept', 'application/json');
        request.setHeader('Authorization', 'Bearer '+ intergrationOutReach.access_token__c );
        if (String.isNotBlank(requestBody)) {
            request.setBody(requestBody);
            request.setHeader('Content-Type', 'text/json');
        }
        return request;
    }
    
    public static Map<Integer,RequestResponse_Log__c> addSequenceState(Integer prospectId, Integer sequenceId, Integer mailBoxId, Id LeadId){
        String reqEndpoint = '';
        String responsebody = '';
        Integer responseCode;
       	String jsonBody = '{"data":{"type":"sequenceState","relationships":{"prospect":{"data":{"type":"prospect","id":'+prospectId+'}},"sequence":{"data":{"type":"sequence","id":'+sequenceId+'}},"mailbox":{"data":{"type":"mailbox","id":'+mailBoxId+'}}}}}';
        Map<Integer,RequestResponse_Log__c> reqRepsMap = new Map<Integer,RequestResponse_Log__c>();
        
        RequestResponse_Log__c reqRespLog= new RequestResponse_Log__c();
        reqRespLog.Request__c = jsonBody;
        reqRespLog.Class_Name__c = 'OutReachListener';
        reqRespLog.Method_Name__c = 'sequenceStates';
        reqRespLog.lead__c = leadId; 
        try{
            if(!Test.isRunningTest()){           
                HttpRequest request = executeCallout('POST','sequenceStates', jsonBody); 
                HttpResponse response = new Http().send(request);   
                reqEndpoint = request.getEndpoint();
                responsebody = response.getBody();
                responseCode = response.getStatusCode();
                System.debug('###response.getBody()=='+response.getBody());             
            } else{
                reqEndpoint = 'https://api.outreach.io/api/v2/sequenceStates';
                responsebody = '{"data":{"type":"sequenceState","id":909991,"attributes":{"activeAt":null,"bounceCount":0,"callCompletedAt":null,"clickCount":0,"createdAt":"2022-08-02T13:50:39.000Z","deliverCount":0,"errorReason":null,"failureCount":0,"negativeReplyCount":0,"neutralReplyCount":0,"openCount":0,"optOutCount":0,"pauseReason":null,"positiveReplyCount":0,"repliedAt":null,"replyCount":0,"scheduleCount":0,"state":"pending","stateChangedAt":"2022-08-02T13:50:39.000Z","updatedAt":"2022-08-02T13:50:39.000Z"},"relationships":{"account":{"data":{"type":"account","id":1061782}},"activeStepMailings":{"data":[],"links":{"related":"https://api.outreach.io/api/v2/mailings?filter%5BsequenceState%5D%5Bid%5D=909991"},"meta":{"count":0}},"activeStepTasks":{"data":[],"links":{"related":"https://api.outreach.io/api/v2/tasks?filter%5BsequenceState%5D%5Bid%5D=909991"},"meta":{"count":0}},"batchItemCreator":{"data":null},"calls":{"links":{"related":"https://api.outreach.io/api/v2/calls?filter%5BsequenceState%5D%5Bid%5D=909991"}},"creator":{"data":{"type":"user","id":354}},"mailbox":{"data":{"type":"mailbox","id":31}},"mailings":{"links":{"related":"https://api.outreach.io/api/v2/mailings?filter%5BsequenceState%5D%5Bid%5D=909991"}},"opportunity":{"data":null},"prospect":{"data":{"type":"prospect","id":1059526}},"sequence":{"data":{"type":"sequence","id":2072}},"sequenceStateRecipients":{"data":[{"type":"sequenceStateRecipient","id":893797}],"links":{"related":"https://api.outreach.io/api/v2/sequenceStateRecipients?filter%5BsequenceState%5D%5Bid%5D=909991"},"meta":{"count":1}},"sequenceStep":{"data":null},"tasks":{"links":{"related":"https://api.outreach.io/api/v2/tasks?filter%5BsequenceState%5D%5Bid%5D=909991"}}},"links":{"self":"https://api.outreach.io/api/v2/sequenceStates/909991"}}}';
                responsecode = 201;
            }
            if(responsecode == 201){
                reqRespLog.Status_Code__c = String.ValueOf(responseCode);
                Map<String, Object> jsonResponseMap = (Map<String, Object>)JSON.deserializeUntyped(responsebody);                
            }else{
                reqRespLog.Status_Code__c = String.ValueOf(responseCode);
            }
            reqRespLog.API_URL__c = reqEndpoint;
            reqRespLog.Response__c = responsebody;
            reqRepsMap.put(prospectId, reqRespLog);
        }
        catch(Exception ex){
            System.debug('Exception :OutReachListener-'+ex.getlinenumber()+'--'+ex.getmessage());
            Log.debug('Error: ' + ex.getMessage() + '--' + ex.getLineNumber() + '--' + ex.getStackTraceString());
        }        
        return reqRepsMap;
    }
}