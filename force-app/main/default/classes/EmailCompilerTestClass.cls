@isTest
private class EmailCompilerTestClass{
    static testMethod void runPositiveTest(){
        //set up user
        Test.startTest();
        User NA = [Select ID FROM User WHERE Name = 'Not Assigned'];
        //run as not assigned
        System.RunAs(NA){
            System.debug('Inserting lead');
            Lead myLead3 = new Lead(FirstName = 'Whale', LastName='Kaner', Email = 'porcha6@gmail.com', DE_Event_Interest__c = 'derby 2017', form_type__c = 'info request', Source__c = 'web derbyexperiences.com');
            insert myLead3;
            myLead3.OwnerId = '005i0000001r82Z';
			myLead3.FirstName = 'Wheelie';
            update myLead3;

            
            
            Lead myLead2 = new Lead(FirstName = 'Melo', LastName='Kaneer', Email = 'porcha2@gmail.com', DE_Event_Interest__c = 'derby 2017', form_type__c = 'info request', Source__c = 'web derbyexperiences.com');
            insert myLead2;
			myLead2.FirstName = 'Mellie';
            myLead2.OwnerID = '005i0000006UBB4';
            update mylead2;

Test.stopTest();


        }
        
    }
    
}