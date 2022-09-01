public class QE_Product_Active_Handler
{
    public static void afterUpdateMethod(List<Product2> lst_Product2,map<Id,Product2> oldMap_Product)
    {
        try
        {
            List<Package_Products__c> lst_Package_Products=new List<Package_Products__c>();
            Id package_Id=Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Package').getRecordTypeId();
            set<Id> product_Hotel_Id=new set<Id>();
            for(Product2 item:lst_Product2)
            {
                if(oldMap_Product.containsKey(item.Id) && oldMap_Product.get(item.Id).IsActive!=item.IsActive && item.RecordTypeId!=package_Id && !item.IsActive)
                {
                    item.A_La_Carte__c=false;
                    product_Hotel_Id.add(item.Id);
                }
            }
            lst_Package_Products=[select Id,Products_and_Hotels__c from Package_Products__c where Products_and_Hotels__c IN :product_Hotel_Id];
            if(lst_Package_Products.size()>0)
            delete lst_Package_Products;
        }Catch(exception ex)
        {
            system.debug('Error==>'+ex.getMessage()+' Line Number==>'+ex.getLineNumber());
        }
    }
}