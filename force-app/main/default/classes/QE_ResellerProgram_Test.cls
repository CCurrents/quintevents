@isTest
Public class QE_ResellerProgram_Test {
    
    Static testMethod void insertResellerEvents() {
    
    Test.startTest();
        List<Reseller__C> resList = new List<Reseller__c>();
        List<Program__C> proList = new List<Program__C>();
        List<Reseller_event__c > resEvList = new List<Reseller_event__c >();
        
    
            Reseller__C res = new Reseller__c();
            res.name = 'resTest';
            resList.add(res);            
            insert resList;
    
            Program__c pro = new Program__c();
            pro.name = 'testPro';
            proList.add(pro);            
            insert proList;
            
            QE360_event__C eve = new QE360_event__C();
            eve.name = 'testEv';
            eve.program__C = proList[0].id;
            eve.end_date__c = system.today();
            eve.start_date__C = system.today();
            eve.Active__c = true;
            insert eve;
    
        Reseller_program__C resp = new Reseller_program__C();
            resp.reseller__c = resList[0].id;
            resp.program__C = proList[0].id;
            insert resp;
    
        Map<Id,Reseller_program__C> newresPMap = new Map<Id,Reseller_program__c>();
             for( Reseller_program__C respg:[select id,reseller__C,program__c from Reseller_program__C]){
                 newresPMap.put(respg.id,respg);            
                 }
        Reseller_event__c resEv = new Reseller_event__C();
        resEv.reseller__c = resList[0].id;
        resEv.event__c = eve.id;
        resEvList.add(resEv);
    
    //QE_ResellerProgramHandler handler = new QE_ResellerProgramHandler();
    QE_ResellerProgramHandler.onAfterInsert(newresPMap);
    Test.stopTest();
        
    }


}