@isTest
public class QE_HotelRoomPackageTriggerHandler_Test{
    
    @isTest static void hotelRoomPackageTriggerTest() {
        // Event
        QE360_Event__c eventTest = new QE360_Event__c(Name = 'test', X100__c = true, X1_3__c =true, X1_2__c=true,Custom__c =1);
        Insert eventTest;
        
        Parent_Package__c  pp1 = new Parent_Package__c(Name = 'Legend', Event__c = eventTest.Id);
        Insert pp1;
        
        List<product2> lstProducttoInsert = New List<product2>();
        // Package
        Product2 proPack = new Product2(Name='BXCD111', isActive=true, 
                                        Event__c = eventTest.Id,
                                        Type__c = 'Package',
                                        Parent_Package__c = pp1.Id,
                                       RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Package').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1);
        lstProducttoInsert.add(proPack);
        
        // Product (Hotel)
        Product2 proHotel = new Product2(Name='BXCD333', isActive=true, 
                                       Event__c = eventTest.Id,
                                         A_La_Carte__c = true, Type__c = 'Hotel',
                                      RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Hotels').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1);
        lstProducttoInsert.add(proHotel);
        
        // Product (ARN Hotel)
        Product2 proARNHotel = new Product2(Name='ARN Hotel', isActive=true, 
                                                Event__c = eventTest.Id,
                                                A_La_Carte__c = true, Type__c = 'Hotel',Hotel_Id__c='111222133344',
                                                Check_In_Date__c=System.Today().addDays(2),Check_Out_Date__c=System.Today().addDays(4),
                                                RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Hotels').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1);
        lstProducttoInsert.add(proARNHotel);
        
        // Product (Stay)
        Product2 proStay = new Product2(Name='ARN Hotel Stay 1', isActive=true, 
                                                Event__c = eventTest.Id,
                                                A_La_Carte__c = true, Type__c = 'Hotel',Hotel_Id__c='111222133344',
                                                Check_In_Date__c=System.Today().addDays(2),Check_Out_Date__c=System.Today().addDays(4),
                                                RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Stay').getRecordTypeId(),Available__c=true,Quantity_Per_Order_Threshold__c=1);
        lstProducttoInsert.add(proStay);

        Test.StartTest();
        insert lstProducttoInsert;
        
        Hotel_Room_Package__c hotelRoomPackage = new Hotel_Room_Package__c(Hotel_Package_Product__c=proARNHotel.Id, ARN_Room_Product__c=proStay.Id);
        insert hotelRoomPackage;
        update hotelRoomPackage;
        
        hotelRoomPackage = new Hotel_Room_Package__c(Hotel_Package_Product__c=proARNHotel.Id, ARN_Room_Product__c=proStay.Id);
        
        try{
            insert hotelRoomPackage;
        } catch(Exception e){}

        Test.StopTest();
    }
}