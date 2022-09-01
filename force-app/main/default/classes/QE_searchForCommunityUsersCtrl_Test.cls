@isTest
public class QE_searchForCommunityUsersCtrl_Test{
    private static string str='test';
    //testing data setup for all methods in this class 
    @testSetup      
    static void setupData() {
        
        //create Lead
        List<Lead> lstLead =   new List<Lead>{
         new Lead(Company = 'JohnMiller', LastName = 'TestCorp', Status = 'Open'),
         new Lead(Company = 'Nike', LastName = 'John', Status = 'Open'),
         new Lead(Company = 'Miles', LastName = 'TestCorp', Status = 'Open'),
         new Lead(Company = 'Reebok', LastName = 'Hillen', Status = 'Open'),
         new Lead(Company = 'Addidas', LastName = 'TestCorp', Status = 'Open')};  
        insert lstLead;
        
         // Convert Lead        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lstLead[0].id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Qualified');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
        
        Database.LeadConvert lcd = new database.LeadConvert();
        lcd.setLeadId(lstLead[1].id);
        lcd.setDoNotCreateOpportunity(true);
        lcd.setConvertedStatus('Qualified');
        Database.LeadConvertResult lcrs = Database.convertLead(lcd);
        System.assert(lcrs.isSuccess());
        
        Database.LeadConvert lcs = new database.LeadConvert();
        lcs.setLeadId(lstLead[2].id);
        lcs.setDoNotCreateOpportunity(true);
        lcs.setConvertedStatus('Qualified');
        Database.LeadConvertResult lcro = Database.convertLead(lcs);
        System.assert(lcro.isSuccess());
        
        //create some contacts
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(FirstName = 'TestCorp', LastName = 'Dachshund',Email='test@gmail.com'));
        contacts.add(new Contact(FirstName = 'TestCorp1', LastName = 'Dachshund',Email='test@gmail.com'));
        contacts.add(new Contact(FirstName = 'TestCorp2', LastName = 'Dachshund',Email='test@gmail.com'));
        contacts.add(new Contact(FirstName = 'TestCorp3', LastName = 'Dachshund',Email='test@gmail.com'));
        contacts.add(new Contact(FirstName = 'TestCorp4', LastName = 'Dachshund',Email='test@gmail.com'));
        insert contacts;
        
    }
    public static testmethod void searchbox(){
    // Initialising StandardSetController Extension
     List<Account> acc = [SELECT Id,Name,PersonEmail FROM Account];
     List<contact> con =[SELECT Id,Name,Email FROM contact];
     List<Lead> ld =[SELECT Id,Name,Email from Lead];
      Id [] fixedSearchResults= new Id[1];
       fixedSearchResults[0] = acc[0].id;
       Test.setFixedSearchResults(fixedSearchResults);
       List<List<SObject>> searchList = [FIND 'TestCorp' 
                                         IN ALL FIELDS RETURNING 
                                            Account(id, name,PersonEmail WHERE name = 'TestCorp' LIMIT 1)];
        ApexPages.StandardSetController stdSet1 = new ApexPages.StandardSetController(acc);
        stdSet1.setSelected([SELECT Id, Name,PersonEmail FROM Account LIMIT 2]);
        ApexPages.StandardSetController stdSet2 = new ApexPages.StandardSetController(con);
        stdSet2.setSelected([SELECT Id, Name, Email FROM Lead LIMIT 2]);
        ApexPages.StandardSetController stdSet3 = new ApexPages.StandardSetController(ld);
        stdSet3.setSelected([SELECT Id, Name, Email FROM contact LIMIT 2]);
        QE_searchForCommunityUsersCtrl sfc = new QE_searchForCommunityUsersCtrl();
        boolean test1 = sfc.hasNext;
        boolean test2 = sfc.hasPrevious;
        sfc.searchRecords ='testcorp';
        List<account> accList =sfc.Accresults;
        List<Lead> ldrec =sfc.ldResults;
        List<contact> conList =sfc.CtResults;
        sfc.hasnext=true;
        sfc.hasnext1=true;
        sfc.hasnext2=true;
        sfc.hasprevious1=true;
        sfc.hasprevious2=true;
        sfc.hasprevious=true;
        sfc.searchbox();
        sfc.first();
        sfc.Last();
        sfc.previous();
        sfc.next();
        sfc.first1();
        sfc.last1();
        sfc.first2();
        sfc.last2();
        sfc.previous1();
        sfc.previous2();
        sfc.next1();
        sfc.next2();
    }
    
   static testmethod void searchbox2(){
           QE_searchForCommunityUsersCtrl sfc = new QE_searchForCommunityUsersCtrl();
           sfc.hasnext=null;
           sfc.hasnext1=null;
           sfc.hasnext2=null;
           sfc.hasprevious=null;
           sfc.hasprevious1=null;
           sfc.hasprevious2=null;
   
   }

}