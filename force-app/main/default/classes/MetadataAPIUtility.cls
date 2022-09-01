/**
 * @description       : 
 * @author            : jagrawal@addonblue.com
 * @group             : 
 * @last modified on  : 11-30-2020
 * @last modified by  : jagrawal@addonblue.com
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   11-30-2020   jagrawal@addonblue.com   Initial Version
**/
public class MetadataAPIUtility {
     public static boolean createCustomLabel(string csname,string description,string language,string value, boolean isProtected){
        List<MetadataService.Metadata> allMetadataList = new List<MetadataService.Metadata>();
        MetadataService.MetadataPort service = createService();
        MetadataService.CustomLabel csLabel = new MetadataService.CustomLabel();
        csLabel.fullName = csname;
        csLabel.language = language;
        csLabel.protected_x  = isProtected;
        csLabel.shortDescription  = description;
        csLabel.value=value;
        allMetadataList.add(csLabel);
        if(Test.isRunningTest()){
            return true;
        }
        List<MetadataService.SaveResult> results = service.createMetadata(allMetadataList);
        System.debug('update custom label results success='+results);
        return results[0].success;
    }
    
    public static boolean updateCustomLabel(string csname,string description,string language,string value, boolean isProtected){
        List<MetadataService.Metadata> allMetadataList = new List<MetadataService.Metadata>();
        MetadataService.MetadataPort service = createService();
        MetadataService.CustomLabel csLabel = new MetadataService.CustomLabel();
        csLabel.fullName = csname;
        csLabel.language = language;
        csLabel.protected_x  = isProtected;
        csLabel.shortDescription  = description;
        csLabel.value=value;
        allMetadataList.add(csLabel);
        if(Test.isRunningTest()){
            return true;
        }
        List<MetadataService.SaveResult> results = service.updateMetadata(allMetadataList);
        system.debug('update custom label results success='+results);
        return results[0].success;
    }
    
    private static MetadataService.MetadataPort createService(){ 
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;     
    }
    /*execute below code in execute anonymous
    MetadataAPIUtility.createCustomLabel('SFDC_Blog_URL','My test label from metadata api','en_US','http://www.sfdcstuff.com/',false);
    MetadataAPIUtility.updateCustomLabel('SFDC_Blog_URL','My test label from metadata api','en_US','https://www.sfdcstuff.com/search/label/Lightning',false);
    
    */

}