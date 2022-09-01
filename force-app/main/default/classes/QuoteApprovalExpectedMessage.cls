/**
 * @File Name          : QuoteApprovalExpectedMessage.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 4/28/2020, 2:17:49 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/28/2020   jagrawal@addonblue.com     Initial Version
**/
public with sharing class QuoteApprovalExpectedMessage {

    @InvocableMethod(label='Quote Approval is expected to confirm Message in slack' description='Send message to user')
    public static void postSlackUserMessage(List<Id> quoteIds) {
        System.enqueueJob(new QuoteApprovalExpectedMessageQueuable(quoteIds));
    }
}