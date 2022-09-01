/* ====================================================
@Name:  QE_packageProductSelectionClass
@Copyright notice: 
Copyright (c) 2016, developed by 
    All rights reserved.
    
    Redistribution and use in source and binary forms, 
    with or without modification, are not permitted.                                                                                                    
@======================================================
@======================================================
@Purpose: 
@======================================================
@======================================================
@History                                                                                                                    
@---------                                                                                                                       
@VERSION________AUTHOR______________DATE______________DETAIL                   
 1.0        Sundar Subramaniam   19/12/2016      INITIAL DEVELOPMENT                                 
   
@=======================================================  */
public class QE_packageProductSelectionClass
{
    public string selectedProduct{get;set;}
    public List<SelectOption> items{get;set;}
    public List<wrapperClass> displayProductValues{get;set;}
    public List<wrapperClass> displaySelectedValues{get;set;}
    public Id ProductID;
    public List<Product2> lstProduct2Display{get;set;}
    public boolean errorBit{get;set;}
    public boolean selectBlock{get;set;}
    public List<Product2> selectedProductList {get;set;}
    public Map<Id,Product2> proMap {get;set;}
    public List<Package_Products__c> lstPackageProduct {get;set;}
    public boolean proCheck {get;set;}
    
    public QE_packageProductSelectionClass(ApexPages.StandardController stdController)
    {
    selectedProductList =new List<Product2>();
     displaySelectedValues=new List<wrapperClass> ();
     items=new List<SelectOption>();
     lstPackageProduct=new List<Package_Products__c>();
     proMap = new Map<Id,Product2>();
     proCheck = true;
     
     ProductID=ApexPages.currentPage().getParameters().get('Id');
     lstProduct2Display=[SELECT Id, Name, Event__c,Event__r.Name,RecordTypeId,Price__c,RecordType.Name, Short_Description__c, Cost__c, Margin__c, Margin_Percentage__c FROM Product2 where id=:ProductID];
        List<RecordType> lstRecordType=[SELECT Id, Name, SobjectType FROM RecordType where SobjectType='Product2' and (Name='Products' or name='Hotels')];
        if(lstRecordType.size()>0)
        {
            for(Recordtype item:lstRecordType)
            {
                items.add(new SelectOption(string.valueof(item.Id),string.valueof(item.Name)));
            }
            selectedProduct = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Products').getRecordTypeId();
        }
        displayProduct();
    }
    
    public void displayProduct()
    {
        displayProductValues=new List<wrapperClass> ();
        List<Product2> lstProduct2=[SELECT Id, Name, Event__c FROM Product2 where Id=:ProductID];
        Map<Id,Package_Products__c> mapPackProducts = new Map<Id,Package_Products__c>();
        List<Package_Products__c> lstPackProducts = [SELECT Id, Name, Package__c, Products_and_Hotels__c FROM Package_Products__c WHERE Package__c =: lstProduct2[0].Id];
        
        if(lstPackProducts.size() > 0){
            for(Package_Products__c pp: lstPackProducts){
                if(!mapPackProducts.containsKey(pp.Products_and_Hotels__c)){
                    mapPackProducts.put(pp.Products_and_Hotels__c,pp);
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
                        displayProductValues.add(new wrapperClass(item,true));
                        System.debug('item=>'+displayProductValues);
                    }else{
                        displayProductValues.add(new wrapperClass(item,false));
                    }
                }
            }
        }
        System.debug('displayProductValues1=>'+displayProductValues);
        selectBlock=false;
        //AddValues();
    }
    
    public pageReference AddValues()
    {
   // displaySelectedValues=new List<wrapperClass> ();
    lstPackageProduct=new List<Package_Products__c>();
    System.debug('displayProductValues2=>'+displayProductValues);
        if(displayProductValues.size()>0)
        {
            for(wrapperClass item:displayProductValues)
            {
                if(item.selectedBit==true)
                {
                    //errorBit=false;
                    selectBlock=true;
                    //displaySelectedValues.add(item);
                    if(!proMap.containsKey(item.objProduct.Id))
                    proMap.put(item.objProduct.Id,item.objProduct);
                }
                /*else
                {
                    errorBit=true;
                    selectBlock=false;
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please Select the Product'));
                }*/
            }
            //system.debug('displaySelectedValues==>'+displaySelectedValues);
        }
        
        if(proMap.size() > 0){
            selectedProductList = proMap.values();
        }
        
        if(selectedProductList.size() > 0){
            for(Product2 item:selectedProductList)
            {
                Package_Products__c objProducts=new Package_Products__c();
                objProducts.Package__c=ProductID;
                objProducts.ApexCost__c = item.Cost__c;
                objProducts.ApexProductName__c = item.Name;
                objProducts.ApexProductType__c = item.RecordType.Name;
                objProducts.Products_and_Hotels__c=item.Id;
                objProducts.Amount__c=item.Price__c;
                lstPackageProduct.add(objProducts);
            }
        }
        return null;
    }
    
    public pageReference AddPackage()
    {
    
        System.debug('ProductID==>'+ProductID);
        if(lstPackageProduct.Size() > 0){
            try{
                Insert lstPackageProduct;
            }Catch(Exception e){
                System.debug('Exception==>'+e);
            }
            //return null;
        }
        else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please select the Product'));
            return null;
            }
        
            
            //return null; 
        if (ProductID != null ) {
            
            PageReference pref = new PageReference('/'+ProductID); 
            pref.setRedirect(true); 
            return pref;
        }
        return null;
        
        /*if(displaySelectedValues.size()>0)
        {
            List<Package_Products__c> lstPackageProduct=new List<Package_Products__c>();
            for(wrapperClass item:displaySelectedValues)
            {
                Package_Products__c objProducts=new Package_Products__c();
                objProducts.Package__c=ProductID;
                objProducts.Products_and_Hotels__c=item.objProduct.Id;
                objProducts.Amount__c=item.objProduct.Price__c;
                lstPackageProduct.add(objProducts);
            }
            insert lstPackageProduct;
        }*/
            //return null;
    }
    
    public class wrapperClass
    {
        public Product2 objProduct{get;set;}
        public boolean selectedBit{get;set;}
        public boolean preSelectedCheck {get;set;}
        
        public wrapperClass(Product2 p, boolean s)
        {
        objProduct=p;
        selectedBit=false;
        preSelectedCheck = s;
        }
    }
}