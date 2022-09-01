/**
 * @description       : 
 * @author            : ratiksinghal@addonblue.com
 * @group             : 
 * @last modified on  : 10-20-2021
 * @last modified by  : ratiksinghal@addonblue.com
**/
public class DeleteReqRespLogs implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    public String query;
    Datetime lastNdays;
    String classNameDeleteLog;
    public DeleteReqRespLogs() {
        this.lastNdays = System.now().adddays(-7);
        this.classNameDeleteLog = 'ProductUpdateBatchClass';
    }  

    public DeleteReqRespLogs(Integer days) {
        this.lastNdays = (days == 0) ? System.now() : System.now().adddays(-days);
        this.classNameDeleteLog = 'ProductUpdateBatchClass';
    }

    public DeleteReqRespLogs(Integer days, String className) {
        this.lastNdays = System.now().adddays(-days);
        classNameDeleteLog = className;
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        query = 'Select Id  from RequestResponse_Log__c where Price_Book_Event__c != null and  Class_Name__c = \''+classNameDeleteLog+'\' and CreatedDate < :lastNdays';
        System.debug('@lastNdays: '+lastNdays);
        System.debug('@query: '+query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<RequestResponse_Log__c> scope){ 
        System.debug('deleteting logs: '+scope.size());
        if(scope.size() > 0){
            Utility.processRecords(scope, 'delete');  
        }
    }

    public void finish(Database.BatchableContext bc){
        System.debug('delete batch completed!');
    }
}