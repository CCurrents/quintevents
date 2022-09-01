public with sharing class QE_packageSelectionClass {
    public List<Product2> lstPackagesToDisplay{get;set;}
    public string selectedPackage{get;set;}
    public List<Product2> selectedPackageList {get;set;}
    public List<SelectOption> items{get;set;}
    public string selectedProduct{get;set;}
    public List<wrapperClass> displayProductValues{get;set;}
    public List<wrapperClass> displaySelectedValues{get;set;}
    public Id productId;
    public List<Package_Products__c> lstPackageProduct {get;set;}
    public Map<Id,Product2> proMap {get;set;}
    public boolean selectBlock {get;set;}
    public boolean selectedBit{get;set;}
    public boolean proCheck {get;set;}
    
    public QE_packageSelectionClass(ApexPages.StandardController controller) {
        selectedPackageList =new List<Product2>();
        displaySelectedValues=new List<wrapperClass> ();
        items=new List<SelectOption>();          
     lstPackageProduct=new List<Package_Products__c>();
      proMap = new Map<Id,Product2>();
      proCheck = true;

     ProductID=ApexPages.currentPage().getParameters().get('Id');
    lstPackagesToDisplay =[SELECT Id,Name,Price__c,RecordType.Name,cost__c,Event__c,Event__r.Name,Type__c FROM Product2 where id=:ProductID];
 List<RecordType> lstRecordType=[SELECT Id, Name, SobjectType FROM RecordType where SobjectType='Product2' and (Name='Package')];    

    if(lstRecordType.size() > 0) 
    {
        for(RecordType item : lstRecordType) {
            items.add(new SelectOption(string.valueOf(item.Id),string.valueOf(item.name)));
        }
    selectedProduct = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Package').getRecordTypeId();
    }
    System.debug('**recird type**'+selectedProduct);
    displayPackage();
    }
    
    public void displayPackage()
    {
        displayProductValues = new List<wrapperClass>();
        System.debug('***productid**'+productID);
         List<Product2> lstProduct2=[SELECT Id, Name, Event__c FROM Product2 where Id=:ProductID];
         System.debug('***list***'+lstProduct2);
        Map<Id,Package_Products__c> mapPackProducts = new Map<Id,Package_Products__c>();
        List<Package_Products__c> lstPackProducts = [SELECT Id, Name, Package__c, Products_and_Hotels__c FROM Package_Products__c WHERE Products_and_Hotels__c =: lstProduct2[0].Id];
        System.debug('***list***'+lstPackProducts);
        if(lstPackProducts.size() > 0){
            for(Package_Products__c pp: lstPackProducts){
                if(!mapPackProducts.containsKey(pp.Package__c)){
                    mapPackProducts.put(pp.Package__c,pp);
                }
            }
        }
        if(lstProduct2.size()>0)
        {
           List<Product2> lstProduct2List=[SELECT Id, Name, Event__c,Event__r.Name,RecordTypeId,Price__c,RecordType.Name,Type__c, Cost__c, Inventory__c, Product_Type__c FROM Product2 where Event__c=:lstProduct2[0].Event__c and RecordTypeId=:selectedProduct and IsActive =: true];
            if(lstProduct2List.size()>0)
            {
                for(Product2 item:lstProduct2List)
                {
                    if(mapPackProducts.containsKey(item.Id)){
                    System.debug('**prod**'+mapPackProducts);
                        displayProductValues.add(new wrapperClass(item,true));
                        
                    }else{
                        displayProductValues.add(new wrapperClass(item,false));
                        
                    }
                }
            }
        }
        //System.debug('displayProductValues1=>'+displayProductValues);
        selectBlock=false;
        System.debug('**prod2**'+mapPackProducts);
    }
    public pageReference AddValues()
    {
    lstPackageProduct=new List<Package_Products__c>();
    System.debug('**prod**'+displayProductValues);
        if(displayProductValues.size()>0)
        {
            for(wrapperClass item:displayProductValues)
            {
            System.debug('***test2**'+displayProductValues);
            System.debug('***test3**'+item.selectedBit);
                if(item.selectedBit == true)
                {
                 System.debug('***test3**'+item.selectedBit);
                    selectBlock=true;
                    if(!proMap.containsKey(item.objProduct.Id))
                    proMap.put(item.objProduct.Id,item.objProduct);
                }
                System.debug('***test3**'+proMap.size());
            }
        }
        System.debug('***test2**'+proMap.size());
        if(proMap.size() > 0){
        System.debug('***test1**');
            selectedPackageList = proMap.values();
        }
        System.debug('***record**'+selectedPackageList);
        if(selectedPackageList.size() > 0){
            for(Product2 item:selectedPackageList)
            {
                Package_Products__c objProducts=new Package_Products__c();
                objProducts.Products_and_Hotels__c = ProductId;
                objProducts.ApexCost__c = item.Cost__c;
                objProducts.ApexProductName__c = item.Name;
                objProducts.ApexProductType__c = item.RecordType.Name;
                objProducts.package__c = item.id;
                objProducts.Amount__c = item.Price__c;
                System.debug('***recordtype**'+objProducts.ApexProductType__c );
                lstPackageProduct.add(objProducts);
                //System.debug('***recordtype**'+objProducts.RecordType.Name);
            }
            system.debug('**list56**'+lstPackageProduct);  
        }
        system.debug('**list2**'+lstPackageProduct.size());        
       return null;
      
    }
      public pageReference AddPackage()
    {
        //lstPackageProduct = new List<Package_Products__c>();
        System.debug('ProductID==>'+ProductID);
        System.debug('***size**'+lstPackageProduct.Size());
        if(lstPackageProduct.Size() > 0){
            try{
                Insert lstPackageProduct;
                System.debug('***record ins**'+lstPackageProduct);
            }Catch(Exception e){
                System.debug('Exception==>'+e);
            }
            //return null;
        }
        else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please select the Product'));
            return null;
            }
             if (ProductID != null ) {
            PageReference pref = new PageReference('/'+ProductID); 
            pref.setRedirect(true); 
            return pref;
        }
        return null;
    }
    
     public class wrapperClass
    {
        public Product2 objProduct{get;set;}
        public boolean selectedBit{get;set;}
        public boolean preSelectedCheck{get;set;}
        public wrapperClass(Product2 p, boolean s)
        {
        objProduct=p;
        selectedBit= false;
        preSelectedCheck = s;
        }
    }
}