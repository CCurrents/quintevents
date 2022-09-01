/**
 * @description       : 
 * @author            : ratiksinghal@addonblue.com
 * @group             : 
 * @last modified on  : 10-20-2021
 * @last modified by  : ratiksinghal@addonblue.com
**/
global class ScheduleDeleteLog implements Schedulable {

    Integer days;
    global ScheduleDeleteLog(){
        this.days = 0;
    }

    global ScheduleDeleteLog(Integer days){
        this.days = days;
    }

    global void execute(SchedulableContext sc) {
        DeleteReqRespLogs deletelogBatch =  null;
        if(days > 0){
            deletelogBatch = new DeleteReqRespLogs(days);
        }else{
            deletelogBatch = new DeleteReqRespLogs();
        }
        Database.executebatch(deletelogBatch);
    }
}