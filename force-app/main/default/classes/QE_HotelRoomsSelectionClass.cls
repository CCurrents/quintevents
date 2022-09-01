public with sharing class QE_HotelRoomsSelectionClass {
    public List<Product2> lstPackagesToDisplay{get;set;}

    public Product2 hotelProduct{get;set;}
    public List<Product2> selectedPackageList {get;set;}

    public List<wrapperClass> displayProductValues{get;set;}
    public List<wrapperClass> displaySelectedValues{get;set;}
    public Id productId;
    public List<Hotel_Room_Package__c> lstHotelRoomsJun {get;set;}
    public Map<Id,Product2> proMap {get;set;}
    public boolean selectBlock {get;set;}
    public boolean proCheck {get;set;}

    public QE_HotelRoomsSelectionClass(ApexPages.StandardController controller) {
        selectedPackageList = new List<Product2>();
        displaySelectedValues = new List<wrapperClass> ();

        lstHotelRoomsJun = new List<Hotel_Room_Package__c>();
        proMap = new Map<Id,Product2>();
        proCheck = true;

        ProductID=ApexPages.currentPage().getParameters().get('Id');
        lstPackagesToDisplay = [SELECT Id,Name,Price__c,RecordType.Name,cost__c,Event__c,Event__r.Name,Type__c FROM Product2 where id=:ProductID];
        if(lstPackagesToDisplay.size() > 0) {
            hotelProduct = lstPackagesToDisplay[0];
        }
        displayPackage();
    }
    
    public void displayPackage() {
        displayProductValues = new List<wrapperClass>();
        Map<Id,Hotel_Room_Package__c> mapHotelvsRoomPackage = new Map<Id,Hotel_Room_Package__c>();
        List<Hotel_Room_Package__c> lstHotelRoomPackage = [SELECT Id, Name, ARN_Room_Product__c, Hotel_Package_Product__c FROM Hotel_Room_Package__c WHERE Hotel_Package_Product__c =: hotelProduct.Id];
        System.debug('***list***'+lstHotelRoomPackage);
        if(lstHotelRoomPackage.size() > 0) {
            for(Hotel_Room_Package__c arnRoom : lstHotelRoomPackage) {
                if(!mapHotelvsRoomPackage.containsKey(arnRoom.Hotel_Package_Product__c)) {
                    mapHotelvsRoomPackage.put(arnRoom.Hotel_Package_Product__c, arnRoom);
                }
            }
        }
        if(lstPackagesToDisplay.size() > 0) {
           List<Product2> lstProduct2List = [SELECT Id, Name, Room_Type__c, Event__c,Event__r.Name,RecordTypeId,Price__c,RecordType.Name,Type__c, Cost__c, Inventory__c, Product_Type__c FROM Product2 where Event__c = :lstPackagesToDisplay[0].Event__c and IsActive =: true 
                                               AND RecordType.DeveloperName = 'Stay']; //(RecordType.DeveloperName = 'Room_Night' OR  RecordType.DeveloperName = 'Stay')
            if(lstProduct2List.size()>0) {
                for(Product2 item:lstProduct2List) {
                    displayProductValues.add(new wrapperClass(item, mapHotelvsRoomPackage.containsKey(item.Id)));
                }
            }
        }
        selectBlock = false;
    }

    public pageReference AddValues() {
        lstHotelRoomsJun = new List<Hotel_Room_Package__c>();
        if(displayProductValues.size()>0) {
            for(wrapperClass item:displayProductValues) {
                if(item.selectedBit == true) {
                    selectBlock = true;
                    if(!proMap.containsKey(item.objProduct.Id)) {
                        proMap.put(item.objProduct.Id,item.objProduct);
                    }
                }
            }
        }
        if(proMap.size() > 0) {
            selectedPackageList = proMap.values();
        }
        if(selectedPackageList.size() > 0) {
            for(Product2 item : selectedPackageList) {
                Hotel_Room_Package__c objProducts=new Hotel_Room_Package__c();
                objProducts.Hotel_Package_Product__c = ProductId;
                objProducts.ARN_Room_Product__c = item.id;
                lstHotelRoomsJun.add(objProducts);
            }
        }
        return null;
    }

    public pageReference AddPackage() {
        if(lstHotelRoomsJun.Size() > 0) {
            try {
                insert lstHotelRoomsJun;
            } Catch(Exception e) {
                System.debug('Exception==>'+e);
            }
        } else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please select the Product'));
            return null;
        }
        if(ProductID != null) {
            PageReference pref = new PageReference('/' + ProductID); 
            pref.setRedirect(true); 
            return pref;
        }
        return null;
    }

    public class wrapperClass {
        public Product2 objProduct{get;set;}
        public boolean selectedBit{get;set;}
        public boolean preSelectedCheck{get;set;}
        public wrapperClass(Product2 p, boolean s) {
            objProduct = p;
            selectedBit = false;
            preSelectedCheck = s;
        }
    }
}