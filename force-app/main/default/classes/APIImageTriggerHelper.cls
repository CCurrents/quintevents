/**
 * @File Name          : APIImageTriggerHelper.cls
 * @Description        : 
 * @Author             : mpatel@addonblue.com
 * @Group              : 
 * @Last Modified By   : mpatel@addonblue.com
 * @Last Modified On   : 09/17/2020
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    09/17/2020   mpatel@addonblue.com     Initial Version
**/
public class APIImageTriggerHelper{
    
    private Map<Id, API_Image__c> newImageMap; 
    private Map<Id, API_Image__c> oldImageMap;
    private List<API_Image__c> newImageList;
    private List<API_Image__c> oldImageList;

    public APIImageTriggerHelper(){
        
        this.newImageMap = (Map<Id, API_Image__c>) Trigger.newMap;
        this.oldImageMap = (Map<Id, API_Image__c>) Trigger.oldMap;
        this.newImageList = (List<API_Image__c>) Trigger.new;
        this.oldImageList = (List<API_Image__c>) Trigger.old;

        switch on Trigger.operationType {
            
            when BEFORE_INSERT {
                System.debug('In Before Insert!');
            }
            
            when BEFORE_UPDATE {
                System.debug('In Before Update!');
            }
            
            when BEFORE_DELETE {
                System.debug('In Before Delete!');
            }
            
            when AFTER_INSERT {
                System.debug('In After Insert!');
            }
            
            when AFTER_UPDATE {
                System.debug('In After Update!');
            }
            
            when AFTER_DELETE {
                captureDeletedApiImages(oldImageList);
            }
            
            when AFTER_UNDELETE {
                System.debug('In After Undelete!');
            }
            
            when else{
                System.debug('Undefined Trigger Operation!');
            }
        }
    }
    
    /**
    * @description  : Capture deleted reseller event
    * @author       : mpatel@addonblue.com | 09/17/2020
    * @param        : list of API_Image__c
    * @return       : 
    **/    
    public void captureDeletedApiImages(List<API_Image__c> oldImageList) {         
        try {
            Utility.processDeletedRecords(oldImageList);
        } catch (Exception e) {
            System.debug('Exception: '+e);
        }
    }    
}