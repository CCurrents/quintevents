/**
 * @File Name          : Intacct_AppyAdjustment_LEX.cls
 * @Description        : This class used for Appy Adjustment on Payment Term record.
 * @Author             : fsuraitawala@addonblue.com
 * @Group              : 
 * @Last Modified By   : ratiksinghal@addonblue.com
 * @Last Modified On   : 02-09-2022
 * @Modification Log   : 
 * @Unit Test          : Intacct_AppyAdjustment_LEX_Test
 * Ver       Date            Author                     Modification
 * 1.0     02/03/2022     fsuraitawala@addonblue.com    Initial Version
**/
public class Intacct_AppyAdjustment_LEX {

    @AuraEnabled
    public static String submitforAdjustment(String currentRecordId) {
        Payment_Term__c objPT = new Payment_Term__c();
        
        if(String.isNotBlank(currentRecordId)){
            objPT = [Select Id, Commission_Paid__c, Intacct_Adjustment_Id__c FROM Payment_Term__c WHERE Id = :currentRecordId LIMIT 1];
        }
        System.debug(objPT);
        if(objPT != null && objPT.Commission_Paid__c == false && String.isBlank(objPT.Intacct_Adjustment_Id__c)) {
            System.debug(objPT);
            IntacctOrderSyncBatchHelper IntacctOrderSyncBatchHelper = new IntacctOrderSyncBatchHelper();
            IntacctOrderSyncBatchHelper.createAdujusmentCallout(currentRecordId);
        }
        
        return '';
    }

}