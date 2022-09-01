public without sharing class QE_searchForCommunityUsersCtrl {
        public string searchRecords{get; set;}
        Public Integer size{get;set;}
        public integer noOfRecords1{get;set;}
        public integer noOfRecords2{get;set;}
        public integer noOfRecords3{get;set;}

        public ApexPages.StandardSetController stdSet1{get; set;} 
        public ApexPages.StandardSetController stdSet2{get; set;} 
        public ApexPages.StandardSetController stdSet3{get; set;} 

        public QE_searchForCommunityUsersCtrl(){
            Accresults = new List<Account>();
             ldResults = new List<Lead>();
             CtResults = new List<Contact>();
        }
        public List<Account> Accresults {  
        get{  
            if(stdSet1 != null)  
                return (List<Account>)stdSet1.getRecords();  
            else  
                return null ;  
        }  
        set;
        }  
        public List<Lead> ldResults {  
        get{  
            if(stdSet2 != null)  
                return (List<Lead>)stdSet2.getRecords();  
            else  
                return null ;}  
        set;
        } 
        public List<contact> CtResults {  
        get{  
            if(stdSet3 != null)  
                return (List<Contact>)stdSet3.getRecords();  
            else  
                return null ;}  
        set;
        }       
         public void searchbox(){            
            List<Account> AccresultsNew = new List<Account>();
            List<Lead> ldResultsNew = new List<Lead>();
            List<Contact> CtResultsNew = new List<Contact>();
             if(searchRecords.length() > 1) {
             String searchStr = '*'+searchRecords+'*';
             String searchQuery = 'FIND \'' +searchStr +'\' IN ALL FIELDS RETURNING Account(Id, Name,PersonEmail,OwnerId),Lead(Id,Name,Email,OwnerId),Contact(Id,Name,Email,OwnerId)';
             List<List <sObject>> searchList = search.query(searchQuery);
             AccresultsNew = [SELECT Id,Name,PersonEmail,OwnerId FROM Account where id =:((List<Account>)searchList[0])];
             ldResultsNew = [SELECT Id,Name,Email,OwnerId FROM Lead where id=:((List<Lead>)searchList[1])];
             CtResultsNew = [SELECT Id,Name,Email,OwnerId FROM Contact where id=:((List<Contact>)searchList[2])];
             stdSet1 = new ApexPages.StandardSetController(AccresultsNew);
             stdSet2 = new ApexPages.StandardSetController(ldResultsNew);
             stdSet3 = new ApexPages.StandardSetController(CtResultsNew);
             size=25;
             stdSet1.setPageSize(size);
             stdSet2.setPageSize(size);
             stdSet3.setPageSize(size);
             noOfRecords1 = stdset1.getResultSize();
             noOfRecords2 = stdset2.getResultSize();
             noOfRecords3 = stdset3.getResultSize();

             if(AccresultsNew.size() == 0 && ldResultsNew.size() == 0 && CtResultsNew.size() == 0){
                apexPages.addmessage(new apexpages.message(apexpages.severity.Error, 'Sorry, no results returned with matching string..'));
                return;
                }
              }
            else{
                apexPages.addmessage(new apexpages.message(apexpages.severity.Error, 'Please enter at least two characters'));
                return;
            }         
        }
    public Boolean hasNext {
        get {
            if(stdSet1 != null)
            return stdSet1.getHasNext();
            else
            return null;
        }
        set;
    }

    public Boolean hasPrevious {
        get {
             if(stdSet1 != null)
            return stdSet1.getHasPrevious();
            else 
            return null;
        }
        set;
    }

     public void first() {
                 if(stdSet1 != null)
         stdSet1.first();
     }

     public void last() {
                 if(stdSet1 != null)

         stdSet1.last();
     }
     public void previous() {
           if(stdSet1 != null)
         stdSet1.previous();
     }

     public void next() {
                 if(stdSet1 != null)
         stdSet1.next();
     }
    public Boolean hasNext1 {
        get {
                    if(stdSet2 != null)
            return stdSet2.getHasNext();
            else 
            return null;
        }
        set;
    }

    public Boolean hasPrevious1 {
        get {
             if(stdSet2 != null)
            return stdSet2.getHasPrevious();
            else 
            return null;
        }
        set;
    }

     public void first1() {
          if(stdSet2 != null)
         stdSet2.first();
     }

     public void last1() {
                 if(stdSet2!= null)

         stdSet2.last();
     }

     public void previous1() {
                 if(stdSet2 != null)
         stdSet2.previous();
     }

     public void next1() {
                 if(stdSet2 != null)
         stdSet2.next();
     }
    public Boolean hasNext2 {
        get {
             if(stdSet3 != null)
            return stdSet3.getHasNext();
            else 
            return null;
        }
        set;
    }

    public Boolean hasPrevious2 {
        get {
             if(stdSet3 != null)
            return stdSet3.getHasPrevious();
            else
            return null;
        }
        set;
    }

     public void first2() {
                 if(stdSet3 != null)

         stdSet3.first();
     }

     public void last2() {
                 if(stdSet3 != null)
         stdSet3.last();
     }

     public void previous2() {
                 if(stdSet3 != null)

         stdSet3.previous();
     }

     public void next2() {
          if(stdSet3 != null)
         stdSet3.next();
     }
     /*public Integer pageNumber1 {
        get {
            return stdSet1.getPageNumber();
        }
        set;
    }public Integer pageNumber2 {
        get {
            return stdSet2.getPageNumber();
        }
        set;
    }
      public Integer pageNumber3 {
        get {
            return stdSet3.getPageNumber();
        }
        set;
    }*/
  
    }