/**
* @File Name          : Order_RequestDefaultActon_LEX_Test.cls
* @Description        : 
* @Author             : fsuraitawala@addonblue.com
* @Group              : 
* @Last Modified By   : jagrawal@addonblue.com
* @Last Modified On   : 09-07-2020
* @Modification Log   : 
* Ver       Date            Author                  Modification
* 1.0    8/12/2020   fsuraitawala@addonblue.com     Initial Version
**/
public class Order_RequestDefaultActon_LEX {
    
    /**
    * @description  : This method update order status to Defaulted and call approval for Defaulted order.
    * @author       : fsuraitawala@addonblue.com
    * @param        : currentPricebookId(Current Pricebook Id)
    * @return       : List<Pricebook2>
    **/
    @AuraEnabled
    public static String submitForDefaulted(String CurrentOrderId, String DefaultedComments) {
        
        if(CurrentOrderId != null && CurrentOrderId.Startswith('801') && String.IsNotEmpty(DefaultedComments)) {
            try {
                Order currentOrder = new Order();
                currentOrder.Id = CurrentOrderId;
                currentOrder.Defaulted_Comments__c = DefaultedComments;
                currentOrder.Status = 'Defaulted - Pending';
                update currentOrder;
                
                Id userId = userInfo.getUserId();
                
                // Create an approval request for the account
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setComments('Submitting request for approval.');
                req1.setObjectId(currentOrder.Id);
                
                // Submit on behalf of a specific submitter
                req1.setSubmitterId(userId); 
                
                // Submit the record to specific process and skip the criteria evaluation
                req1.setProcessDefinitionNameOrId('Request_Default_Order_Approval');
                req1.setSkipEntryCriteria(true);
                
                // Submit the approval request for the account
                Approval.ProcessResult result = Approval.process(req1);
                
                // create the new approval request to submit
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Submitted for approval. Please approve.');
                req.setObjectId(currentOrder.Id);
                // submit the approval request for processing
                if(!Approval.isLocked(currentOrder.Id)){
                    try {
                        //Approval.ProcessResult result = Approval.process(req);
                        // display if the reqeust was successful
                        System.debug('Submitted for approval successfully: '+result.isSuccess());
                    } catch(Exception ex) {
                        throw new AuraHandledException('Approval Process ALREADY_IN_PROCESS, This Quote is currently in an approval process. A record can be in only one approval process at a time ');
                    }
                }
            } catch(Exception ex) {
                throw new AuraHandledException(ex.getMessage());
            }
            return 'Success';
        }
        return '';
    }
}