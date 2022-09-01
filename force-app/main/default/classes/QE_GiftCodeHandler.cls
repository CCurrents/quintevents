/**
 * @File Name          : QE_GiftCodeHandler.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/11/2020, 6:37:56 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/11/2020   jagrawal@addonblue.com     Initial Version
**/
Public class QE_GiftCodeHandler {
    public static boolean isRecursive=false;
    public static boolean isRunonce=false;

    public static void OpporunityPopulation(Map<Id,Opportunity> MapObjectMap,Map<Id,Opportunity> oldObjectMap,set<Id> setopIds){
        giftCodesCount(null);
        // Set<id> oppIds = new Set<Id>();
        // Map<Id,Integer> mapofOppIDToQuantityF1AccessCode = new Map<Id,Integer>();
        // Map<Id,Integer> mapofOppIDToQuantityFanatics = new Map<Id,Integer>();
        // Map<Id,Integer> mapofOppIDToQuantityMementoPremium = new Map<Id,Integer>();
        // Map<Id,Integer> mapofOppIDToQuantityMementoUltimate = new Map<Id,Integer>();
        // Integer totalNumberOfF1AccessReq = 0;
        // Integer totalNumberOfFanaticsReq = 0;
        // Integer totalNumberOfMementoPremiumReq = 0;
        // Integer totalNumberOfMementoUltimateReq = 0;
        // System.debug('**map values**'+MapObjectMap.size());
        // if(MapObjectMap != null && MapObjectMap.size()>0){
        //     for(Opportunity opp: MapObjectMap.Values()){
        //         if((opp.StageName == 'Closed Won' && oldObjectMap.get(opp.Id).StageName != 'Closed Won')){
        //             oppIds.add(opp.Id);
        //         }
        //     }
        // }else{
        //     oppIds.addall(setopIds);
        // }



        // if(!oppIds.isEmpty()){
        //     Map<Id,Opportunity_Payment_Terms__c> mapOppPaymentTerms = new Map<Id,Opportunity_Payment_Terms__c>();
        //     for(Opportunity_Payment_Terms__c opt: [select id,Opportunity__c,status__c from Opportunity_Payment_Terms__c where Opportunity__c in: oppIds and Opportunity__r.stagename = 'Closed Won' order by Payment_Due_Date__c]){
        //         if(!mapOppPaymentTerms.containskey(opt.Opportunity__c)){
        //             mapOppPaymentTerms.put(opt.Opportunity__c,opt);
        //         }
        //     }

        //     Set<Id> setOppIds = New set<Id>();
        //     if(mapOppPaymentTerms.size()>0){
        //         for(Opportunity_Payment_Terms__c opterm : mapOppPaymentTerms.values()){
        //             if(opterm.status__c == 'Passed'){
        //                 setOppIds.add(opterm.Opportunity__c);
        //             }
        //         }
        //     }

        //     Map<Id,Opportunity> updatedOpptsWithMoreData = new Map<Id,Opportunity>([Select Id,Name,Order_Payment_Status__c,F1_Access_Code_Assignment_Pending__c,Fanatics_Gift_Code_Assignment_Pending__c,Memento_Premium_Assignment_Pending__c,Memento_Ultimate_Assignment_Pending__c,StageName,paid_in_full__C,(SELECT Id,Quantity,OpportunityId,ProductType__c,Product_Type__c,product2.Brandfuel_Points__c FROM OpportunityLineItems where ProductType__c = 'F1 Access Code' or ProductType__c ='Fanatics Gift Code' or ProductType__c ='Memento Premium' or ProductType__c ='Memento Ultimate') From Opportunity Where Id in :setOppIds
        //     ]);


        //     List<opportunity> oppList = new List<opportunity>();
        //     Map<Id,Opportunity> mapOppF1AccessCode = new Map<Id,Opportunity>();
        //     Map<Id,Opportunity> mapOppFanaticsCode = new Map<Id,Opportunity>();
        //     Map<Id,Opportunity> mapOppMementoPremiumCode = new Map<Id,Opportunity>();
        //     Map<Id,Opportunity> mapOppMementoUltimateCode = new Map<Id,Opportunity>();

        //     for(Opportunity opp : updatedOpptsWithMoreData.values()){
        //         Integer quantityvalF1AccessCode = 0;
        //         Integer quantityvalFanatics = 0;
        //         Integer quantityvalMementoPremium = 0;
        //         Integer quantityvalMementoUltimate = 0;


        //         for(OpportunityLineItem oppLineItem: opp.OpportunityLineItems) {
        //             System.debug('***opp line item**' +oppLineItem.id);
        //             if((oppLineItem.ProductType__c =='F1 Access Code' && oppLineItem.Quantity != null)){

        //                 quantityvalF1AccessCode = quantityvalF1AccessCode + Integer.valueOf(oppLineItem.Quantity);
        //                 System.debug('***line item quantity**'+Integer.valueOf(oppLineItem.Quantity));
        //                 System.debug('***quantity total**'+quantityvalF1AccessCode);
        //             }
        //             else if((oppLineItem.ProductType__c =='Fanatics Gift Code' && oppLineItem.Quantity != null)){
        //                 quantityvalFanatics  = quantityvalFanatics + Integer.valueOf(oppLineItem.Quantity);
        //                 System.debug('***quantity total**'+quantityvalFanatics);
        //             }
        //             else if((oppLineItem.ProductType__c =='Memento Premium' && oppLineItem.Quantity != null)){
        //                 quantityvalMementoPremium  = quantityvalMementoPremium + Integer.valueOf(oppLineItem.Quantity);
        //                 System.debug('***quantity total**'+quantityvalMementoPremium);
        //             }
        //             else if((oppLineItem.ProductType__c =='Memento Ultimate' && oppLineItem.Quantity != null)){
        //                 quantityvalMementoUltimate  = quantityvalMementoUltimate + Integer.valueOf(oppLineItem.Quantity);
        //                 System.debug('***quantity total**'+ quantityvalMementoUltimate);
        //             }
        //         }

        //         if(quantityvalF1AccessCode != 0 || Test.isRunningTest()){
        //            mapOppF1AccessCode.put(opp.Id,opp);
        //            mapofOppIDToQuantityF1AccessCode.put(opp.Id,quantityvalF1AccessCode);
        //            totalNumberOfF1AccessReq = totalNumberOfF1AccessReq + quantityvalF1AccessCode;
        //         }

        //         if(quantityvalFanatics != 0 || Test.isRunningTest()){
        //            mapOppFanaticsCode.put(opp.Id,opp);
        //            mapofOppIDToQuantityFanatics.put(opp.Id,quantityvalFanatics);
        //            totalNumberOfFanaticsReq = totalNumberOfFanaticsReq + quantityvalFanatics;
        //         }
        //         if(quantityvalMementoPremium != 0 || Test.isRunningTest()){
        //            mapOppMementoPremiumCode.put(opp.Id,opp);
        //            mapofOppIDToQuantityMementoPremium.put(opp.Id,quantityvalMementoPremium);
        //            totalNumberOfMementoPremiumReq = totalNumberOfMementoPremiumReq + quantityvalMementoPremium;
        //         }
        //         if(quantityvalMementoUltimate != 0 || Test.isRunningTest()){
        //            mapOppMementoUltimateCode.put(opp.Id,opp);
        //            mapofOppIDToQuantityMementoUltimate.put(opp.Id,quantityvalMementoUltimate);
        //            totalNumberOfMementoUltimateReq = totalNumberOfMementoUltimateReq + quantityvalMementoUltimate;
        //         }

        //     }
            
            
        //     Map<Id,Map<String,Integer>> mapassignedOppGiftCodes = new Map<Id,Map<String,Integer>>();            
        //     Integer intcount = 0;
        //     String strgc = 'Select Id,RecordTypeName__c,Opportunity__c from Gift_Code__c where opportunity__c != null';
        //     String strfilter = '';
        //     if(totalNumberOfF1AccessReq>0){
        //         if(!String.Isblank(strfilter)) strfilter += ', \'F1 Access Code\'';
        //         else strfilter += '\'F1 Access Code\'';
        //     } 
        //     if(totalNumberOfFanaticsReq>0){
        //         if(!String.Isblank(strfilter)) strfilter += ', \'Fanatics Gift Code\'';
        //         else strfilter += '\'Fanatics Gift Code\'';
        //     } 
        //     if(totalNumberOfMementoPremiumReq>0){
        //         if(!String.Isblank(strfilter)) strfilter += ', \'Memento Premium\'';
        //         else strfilter += '\'Memento Premium\'';
        //     } 
        //     if(totalNumberOfMementoUltimateReq>0){
        //         if(!String.Isblank(strfilter)) strfilter += ', \'Memento Ultimate\'';
        //         else strfilter += '\'Memento Ultimate\'';
        //     } 
        //     If(!String.Isblank(strfilter)){
        //         strgc += ' and RecordTypeName__c in (' + strfilter + ')';
        //     }
            
        //     strgc += ' order by RecordTypeName__c';
            
        //     system.debug('@@@strgc ==='+strgc );
            
        //     if(totalNumberOfF1AccessReq >0 || totalNumberOfFanaticsReq>0 || totalNumberOfMementoPremiumReq>0 || totalNumberOfMementoUltimateReq>0){
        //         for(Gift_Code__c  giftcode:database.query(strgc)){
        //               if(!mapassignedOppGiftCodes.containskey(giftcode.Opportunity__c)){
        //                   intcount = 1;
        //                   mapassignedOppGiftCodes.put(giftcode.Opportunity__c,New Map<String,Integer>{giftcode.RecordTypeName__c=>intcount});
        //               }else{
        //                   Map<String,Integer> mapassignedCount = New Map<String,Integer>();
        //                   if(mapassignedOppGiftCodes.get(giftcode.Opportunity__c).containskey(giftcode.RecordTypeName__c)){
        //                       intcount = mapassignedOppGiftCodes.get(giftcode.Opportunity__c).get(giftcode.RecordTypeName__c)+1;
        //                       mapassignedOppGiftCodes.get(giftcode.Opportunity__c).put(giftcode.RecordTypeName__c, intcount);
        //                   }else{
        //                       intcount = 1;
        //                       mapassignedOppGiftCodes.get(giftcode.Opportunity__c).put(giftcode.RecordTypeName__c, intcount);
        //                   }
        //               }
        //           }
        //       }
          
        //     Map<Id,opportunity> oppMap = new Map<Id,opportunity>();            
        //     if(totalNumberOfF1AccessReq > 0){
        //         List<Gift_Code__c> facList = [SELECT Id,Gift_Code__c,Opportunity__c,RecordTypeName__c FROM Gift_Code__c WHERE Opportunity__c = null and RecordTypeName__c = 'F1 Access Code' LIMIT :totalNumberOfF1AccessReq];
        //         if(!facList.isEmpty() && facList.Size() == totalNumberOfF1AccessReq){ //) || Test.isRunningTest()
        //              Integer i=0;
        //              Integer diffAssignedCode = 0;                     
        //              for(Id oppId: mapofOppIDToQuantityF1AccessCode.keySet()){
        //                  if(mapassignedOppGiftCodes.containskey(oppId) && mapassignedOppGiftCodes.get(oppId) != null && mapassignedOppGiftCodes.get(oppId).get('F1 Access Code') != null){
        //                     diffAssignedCode = mapofOppIDToQuantityF1AccessCode.get(oppId) - mapassignedOppGiftCodes.get(oppId).get('F1 Access Code');
        //                  }else{
        //                     diffAssignedCode = mapofOppIDToQuantityF1AccessCode.get(oppId);
        //                  }
        //                  for(Integer j=0;j < diffAssignedCode;j++){
        //                      facList[i].Opportunity__c = oppId;
        //                      i++;
        //                  }
                         
        //                  if(i != 0 && diffAssignedCode != 0 && i == diffAssignedCode){
        //                     Opportunity opp = new Opportunity(Id=oppId);
        //                     if(oppMap.containskey(oppId)){
        //                         opp = oppMap.get(oppId);
        //                     }
        //                     opp.F1_Access_Code_Assignment_Pending__c = false;
        //                     oppMap.put(oppId,opp);
        //                  }
        //              }

        //              isRecursive =true;
        //              update  facList;
        //         }
        //          if((facList.size() < totalNumberOfF1AccessReq && isRunonce == false) || Test.isRunningTest()) {
        //             List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        //              for(Opportunity opp : mapOppF1AccessCode.values()){
        //                   Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
        //                   String[] toAddresses = Label.Email_to_Aaron.split(',');
        //                   mail.setToAddresses(toAddresses);
        //                   mail.setBccSender(false);
        //                   mail.setSubject('F1 Access Codes Insufficient');
        //                   mail.setUseSignature(false);
        //                   //mail.setSenderDisplayName('Not Insufficient');
        //                   mail.setSaveAsActivity(false);
        //                   String body = 'Opportunity : ' + opp.Name+'\n';
        //                   body += 'F1 Access Codes needed :'+totalNumberOfF1AccessReq+'\n';
        //                   body += URL.getSalesforceBaseUrl().toExternalForm()+'/'+opp.Id+'\n';
        //                   body +='Please Note: F1 Access Codes insufficient to be add to above opportunity.';
        //                   mail.setPlainTextBody(body);
        //                   mails.add(mail);
                          
                          
        //                   if(!mapassignedOppGiftCodes.containskey(opp.Id) || (mapassignedOppGiftCodes.containskey(opp.Id) && !mapassignedOppGiftCodes.get(opp.Id).containskey('F1 Access Code')) || (mapassignedOppGiftCodes.containskey(opp.Id) && mapassignedOppGiftCodes.get(opp.Id).containskey('F1 Access Code') &&
        //                       mapassignedOppGiftCodes.get(opp.Id).get('F1 Access Code') != totalNumberOfF1AccessReq)){
        //                       if(!oppMap.containskey(opp.Id)){
        //                           opp.F1_Access_Code_Assignment_Pending__c = true;
        //                           oppMap.put(opp.Id,opp);
        //                       }else{
        //                           opp = oppMap.get(opp.Id);
        //                           opp.F1_Access_Code_Assignment_Pending__c = true;
        //                           oppMap.put(opp.Id,opp);
        //                       }
        //                   }
        //              }
        //              Messaging.sendEmail(mails);
        //         }
        //     }


        //     if(totalNumberOfFanaticsReq > 0){
        //         List<Gift_Code__c> fanaticsList = [SELECT Id,Gift_Code__c,Opportunity__c,RecordTypeName__c FROM Gift_Code__c WHERE Opportunity__c = null and RecordTypeName__c = 'Fanatics Gift Code' LIMIT :totalNumberOfFanaticsReq];
        //         if(!fanaticsList.isEmpty() && fanaticsList.Size() == totalNumberOfFanaticsReq){ //) || Test.isRunningTest()
        //              Integer i=0;
        //              Integer diffAssignedCode = 0;   
        //              for(Id oppId: mapofOppIDToQuantityFanatics.keySet()){
        //                  if(mapassignedOppGiftCodes.containskey(oppId) && mapassignedOppGiftCodes.get(oppId) != null && mapassignedOppGiftCodes.get(oppId).get('Fanatics Gift Code') != null){
        //                     diffAssignedCode = mapofOppIDToQuantityFanatics.get(oppId) - mapassignedOppGiftCodes.get(oppId).get('Fanatics Gift Code');
        //                  }else{
        //                     diffAssignedCode = mapofOppIDToQuantityFanatics.get(oppId);
        //                  }
        //                  for(Integer j=0;j < diffAssignedCode;j++){
        //                      fanaticsList[i].Opportunity__c = oppId;
        //                      i++;
        //                  }
                         
        //                  if(i != 0 && diffAssignedCode != 0 && i == diffAssignedCode){
        //                     Opportunity opp = new Opportunity(Id=oppId);
        //                     if(oppMap.containskey(oppId)){
        //                         opp = oppMap.get(oppId);
        //                     }
        //                     opp.Fanatics_Gift_Code_Assignment_Pending__c = false;
        //                     oppMap.put(oppId,opp);
        //                  }
        //              }

        //              isRecursive =true;
        //              update  fanaticsList;
        //         }
        //         if((fanaticsList.size() < totalNumberOfFanaticsReq && isRunonce == false) || Test.isRunningTest()) {
        //             List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        //              for(Opportunity opp : mapOppFanaticsCode.values()){
        //                   Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
        //                   String[] toAddresses = Label.Email_to_Aaron.split(',');
        //                   mail.setToAddresses(toAddresses);
        //                   mail.setBccSender(false);
        //                   mail.setSubject('Fanatics Gift Codes Insufficient');
        //                   mail.setUseSignature(false);
        //                   //mail.setSenderDisplayName('Not Insufficient');
        //                   mail.setSaveAsActivity(false);
        //                   String body = 'Opportunity : ' + opp.Name+'\n';
        //                   body += 'Fanatics Gift Codes needed :'+totalNumberOfFanaticsReq+'\n';
        //                   body += URL.getSalesforceBaseUrl().toExternalForm()+'/'+opp.Id+'\n';
        //                   body +='Please Note: Fanatics Gift Codes insufficient to be add to above opportunity.';
        //                   mail.setPlainTextBody(body);
        //                   mails.add(mail);
        //                   if(!mapassignedOppGiftCodes.containskey(opp.Id) || (mapassignedOppGiftCodes.containskey(opp.Id) && !mapassignedOppGiftCodes.get(opp.Id).containskey('Fanatics Gift Code')) || (mapassignedOppGiftCodes.containskey(opp.Id) && mapassignedOppGiftCodes.get(opp.Id).containskey('Fanatics Gift Code') &&
        //                       mapassignedOppGiftCodes.get(opp.Id).get('Fanatics Gift Code') != totalNumberOfFanaticsReq )){
        //                       if(!oppMap.containskey(opp.Id)){
        //                           opp.Fanatics_Gift_Code_Assignment_Pending__c = true;
        //                           oppMap.put(opp.Id,opp);
        //                       }else{
        //                           opp = oppMap.get(opp.Id);
        //                           opp.Fanatics_Gift_Code_Assignment_Pending__c = true;
        //                           oppMap.put(opp.Id,opp);
        //                       }
        //                   }
        //              }
        //              Messaging.sendEmail(mails);
        //         }
        //     }
        //     if(totalNumberOfMementoPremiumReq > 0){
        //         List<Gift_Code__c> fanaticsList = [SELECT Id,Gift_Code__c,Opportunity__c,RecordTypeName__c FROM Gift_Code__c WHERE Opportunity__c = null and RecordTypeName__c = 'Memento Premium' LIMIT :totalNumberOfMementoPremiumReq];
        //         if((!fanaticsList.isEmpty() && fanaticsList.Size() == totalNumberOfMementoPremiumReq)){
        //              Integer i=0;
        //              Integer diffAssignedCode = 0;
        //              for(Id oppId: mapofOppIDToQuantityMementoPremium.keySet()){
        //                  if(mapassignedOppGiftCodes.containskey(oppId) && mapassignedOppGiftCodes.get(oppId) != null && mapassignedOppGiftCodes.get(oppId).get('Memento Premium') != null){
        //                     diffAssignedCode = mapofOppIDToQuantityMementoPremium.get(oppId) - mapassignedOppGiftCodes.get(oppId).get('Memento Premium');
        //                  }else{
        //                     diffAssignedCode = mapofOppIDToQuantityMementoPremium.get(oppId);
        //                  }
        //                  for(Integer j=0;j < diffAssignedCode;j++){
        //                      fanaticsList[i].Opportunity__c = oppId;
        //                      i++;
        //                  }
        //                  if(i != 0 && diffAssignedCode != 0 && i == diffAssignedCode){
        //                     Opportunity opp = new Opportunity(Id=oppId);
        //                     if(oppMap.containskey(oppId)){
        //                         opp = oppMap.get(oppId);
        //                     }
        //                     opp.Memento_Premium_Assignment_Pending__c = false;
        //                     oppMap.put(oppId,opp);
        //                  }
        //              }

        //              isRecursive =true;
        //              update  fanaticsList;
        //         }
        //         if((fanaticsList.size() < totalNumberOfMementoPremiumReq && isRunonce == false) || Test.isRunningTest()) {
        //             List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        //              for(Opportunity opp : mapOppMementoPremiumCode.values()){
        //                   Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
        //                   String[] toAddresses = Label.Email_to_Aaron.split(',');
        //                   mail.setToAddresses(toAddresses);
        //                   mail.setBccSender(false);
        //                   mail.setSubject('Memento Premium Insufficient');
        //                   mail.setUseSignature(false);
        //                   //mail.setSenderDisplayName('Not Insufficient');
        //                   mail.setSaveAsActivity(false);
        //                   String body = 'Opportunity : ' + opp.Name+'\n';
        //                   body += 'Memento Premium needed :'+totalNumberOfMementoPremiumReq+'\n';
        //                   body += URL.getSalesforceBaseUrl().toExternalForm()+'/'+opp.Id+'\n';
        //                   body +='Please Note: Memento Premium insufficient to be add to above opportunity.';
        //                   mail.setPlainTextBody(body);
        //                   mails.add(mail);
        //                   if(!mapassignedOppGiftCodes.containskey(opp.Id) || (mapassignedOppGiftCodes.containskey(opp.Id) && !mapassignedOppGiftCodes.get(opp.Id).containskey('Memento Premium')) || (mapassignedOppGiftCodes.containskey(opp.Id) && mapassignedOppGiftCodes.get(opp.Id).containskey('Memento Premium') &&
        //                       mapassignedOppGiftCodes.get(opp.Id).get('Memento Premium') != totalNumberOfMementoPremiumReq)){
        //                       if(!oppMap.containskey(opp.Id)){
        //                           opp.Memento_Premium_Assignment_Pending__c = true;
        //                           oppMap.put(opp.Id,opp);
        //                       }else{
        //                           opp = oppMap.get(opp.Id);
        //                           opp.Memento_Premium_Assignment_Pending__c = true;
        //                           oppMap.put(opp.Id,opp);
        //                       }
        //                   }
        //              }
        //              Messaging.sendEmail(mails);
        //         }
        //     }
        //     if(totalNumberOfMementoUltimateReq > 0){
        //         List<Gift_Code__c> fanaticsList = [SELECT Id,Gift_Code__c,Opportunity__c,RecordTypeName__c FROM Gift_Code__c WHERE Opportunity__c = null and RecordTypeName__c = 'Memento Ultimate' LIMIT :totalNumberOfMementoUltimateReq];
        //         if((!fanaticsList.isEmpty() && fanaticsList.Size() == totalNumberOfMementoUltimateReq )){
        //              Integer i=0;
        //              Integer diffAssignedCode = 0;
        //              for(Id oppId: mapofOppIDToQuantityMementoUltimate.keySet()){
        //                  if(mapassignedOppGiftCodes.containskey(oppId) && mapassignedOppGiftCodes.get(oppId) != null && mapassignedOppGiftCodes.get(oppId).get('Memento Ultimate') != null){
        //                     diffAssignedCode = mapofOppIDToQuantityMementoUltimate.get(oppId) - mapassignedOppGiftCodes.get(oppId).get('Memento Ultimate');
        //                  }else{
        //                     diffAssignedCode = mapofOppIDToQuantityMementoUltimate.get(oppId);
        //                  }
        //                  for(Integer j=0;j < diffAssignedCode;j++){
        //                      fanaticsList[i].Opportunity__c = oppId;
        //                      i++;
        //                  }
        //                  if(i != 0 && diffAssignedCode != 0 && i == diffAssignedCode){
        //                     Opportunity opp = new Opportunity(Id=oppId);
        //                     if(oppMap.containskey(oppId)){
        //                         opp = oppMap.get(oppId);
        //                     }
        //                     opp.Memento_Ultimate_Assignment_Pending__c = false;
        //                     oppMap.put(oppId,opp);
        //                  }
        //              }

        //              isRecursive =true;
        //              update  fanaticsList;
        //         }
        //         if((fanaticsList.size() < totalNumberOfMementoUltimateReq && isRunonce == false) || Test.isRunningTest()) {
        //             List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        //              for(Opportunity opp : mapOppMementoUltimateCode.values()){
        //                   Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
        //                   String[] toAddresses = Label.Email_to_Aaron.split(',');
        //                   mail.setToAddresses(toAddresses);
        //                   mail.setBccSender(false);
        //                   mail.setSubject('Memento Ultimate Insufficient');
        //                   mail.setUseSignature(false);
        //                   //mail.setSenderDisplayName('Not Insufficient');
        //                   mail.setSaveAsActivity(false);
        //                   String body = 'Opportunity : ' + opp.Name+'\n';
        //                   body += 'Memento Ultimate needed :'+totalNumberOfMementoUltimateReq+'\n';
        //                   body += URL.getSalesforceBaseUrl().toExternalForm()+'/'+opp.Id+'\n';
        //                   body +='Please Note: Memento Ultimate insufficient to be add to above opportunity.';
        //                   mail.setPlainTextBody(body);
        //                   mails.add(mail);
        //                   if(!mapassignedOppGiftCodes.containskey(opp.Id) || (mapassignedOppGiftCodes.containskey(opp.Id) && !mapassignedOppGiftCodes.get(opp.Id).containskey('Memento Ultimate')) || (mapassignedOppGiftCodes.containskey(opp.Id) && mapassignedOppGiftCodes.get(opp.Id).containskey('Memento Ultimate') &&
        //                       mapassignedOppGiftCodes.get(opp.Id).get('Memento Ultimate') != totalNumberOfMementoUltimateReq)){
        //                       if(!oppMap.containskey(opp.Id)){
        //                           opp.Memento_Ultimate_Assignment_Pending__c = true;
        //                           oppMap.put(opp.Id,opp);
        //                       }else{
        //                           opp = oppMap.get(opp.Id);
        //                           opp.Memento_Ultimate_Assignment_Pending__c = true;
        //                           oppMap.put(opp.Id,opp);
        //                       }
        //                   }
        //              }
        //              Messaging.sendEmail(mails);
        //         }
        //     }
        //     if(oppMap.size()>0){
        //         isRunonce =true;
        //         update oppMap.values();
        //     }
        // }
    }

   Public static void giftCodesCount(List<Gift_Code__c> GiftCodeList) {
        onAfterInsertGiftCode(null);
    //   Set<Id> OppIdsetF1Code = new set<Id>();
    //   Set<Id> OppIdsetFanaticsCode = new set<Id>();
    //   Set<Id> OppIdsetMementoPremiumCode = new set<Id>();
    //   Set<Id> OppIdsetMementoUltimateCode = new set<Id>();
    //   for(Gift_Code__c giftcode :GiftCodeList){
    //     if((giftcode.RecordTypeName__c == 'F1 Access Code' && giftcode.opportunity__c != null) || Test.isRunningTest()){
    //         OppIdsetF1Code.add(giftcode.opportunity__c);
    //     }
    //     if((giftcode.RecordTypeName__c == 'Fanatics Gift Code' && giftcode.opportunity__c != null) || Test.isRunningTest()){
    //         OppIdsetFanaticsCode.add(giftcode.opportunity__c);
    //     }
    //     if((giftcode.RecordTypeName__c == 'Memento Premium' && giftcode.opportunity__c != null) || Test.isRunningTest()){
    //         OppIdsetMementoPremiumCode.add(giftcode.opportunity__c);
    //     }
    //     if((giftcode.RecordTypeName__c == 'Memento Ultimate' && giftcode.opportunity__c != null) || Test.isRunningTest()){
    //         OppIdsetMementoUltimateCode.add(giftcode.opportunity__c);
    //     }
    //   }

    //   Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>([SELECT Id,Name FROM Opportunity WHERE Id In:OppIdsetF1Code]);
    //   List<Gift_Code__c> flAccessLst = [Select Id,Name from Gift_Code__c where opportunity__c = null and RecordTypeName__c = 'F1 Access Code'];
    //   List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
    //   if(flAccessLst.Size() < 300 || Test.isRunningTest()){
    //      for(Opportunity opp : oppMap.values()){
    //         Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
    //         String[] toAddresses = Label.Email_to_Aaron.split(',');
    //         mail.setToAddresses(toAddresses);
    //         mail.setBccSender(false);
    //         mail.setSubject('F1 Access Codes below 300');
    //         mail.setUseSignature(false);
    //         mail.setSenderDisplayName('Not Assigned');
    //         mail.setSaveAsActivity(false);
    //         String body = 'Opportunity : ' + opp.Name+'<br/>';
    //         //body += 'F1 Access Codes needed :'+OppIdsetF1Code.size()+'<br/>';
    //         //body += 'Opportunity Link:'+<a href= "'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+opp.Id+'"></a>+'<br/>';
    //         //body += URL.getSalesforceBaseUrl().toExternalForm()+'/'+oppId+'\n';
    //         body += URL.getSalesforceBaseUrl().toExternalForm()+'/'+opp.Id+'<br/><br/>';
    //         //System.debug('**********'+body);
    //         body +='Please Note: Total number of F1 Access Codes after this opportunity is '+ flAccessLst.size()+ '(less than 300).';
    //         //mail.setPlainTextBody(Recordlink);
    //         mail.setHtmlBody(body);
    //         mails.add(mail);
    //      }

    //    }

    //    Map<Id,Opportunity> oppMapFanatics = new Map<Id,Opportunity>([SELECT Id,Name FROM Opportunity WHERE Id In:OppIdsetFanaticsCode]);
    //    List<Gift_Code__c> FanaticsGiftCodeLst = [Select Id,Name from Gift_Code__c where opportunity__c = null and RecordTypeName__c = 'Fanatics Gift Code'];
    //    if(FanaticsGiftCodeLst.Size() < 300 || Test.isRunningTest()){
    //      for(Opportunity opp : oppMapFanatics.values()){
    //         Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
    //         String[] toAddresses = Label.Email_to_Aaron.split(',');
    //         mail.setToAddresses(toAddresses);
    //         mail.setBccSender(false);
    //         mail.setSubject('Fanatics Gift Codes below 300');
    //         mail.setUseSignature(false);
    //         mail.setSenderDisplayName('Not Assigned');
    //         mail.setSaveAsActivity(false);
    //         String body = 'Opportunity : ' + opp.Name+'<br/>';
    //         //body += 'Fanatics Gift Codes needed :'+OppIdsetFanaticsCode.size()+'<br/>';
    //         //body += 'Opportunity Link:'+<a href= "'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+opp.Id+'"></a>+'<br/>';
    //         //body += URL.getSalesforceBaseUrl().toExternalForm()+'/'+oppId+'\n';
    //         body += URL.getSalesforceBaseUrl().toExternalForm()+'/'+opp.Id+'<br/><br/>';
    //         //System.debug('**********'+body);
    //         body +='Please Note: Total number of Fanatics Gift Codes after this opportunity is '+ FanaticsGiftCodeLst.size()+ '(less than 300).';
    //         //mail.setPlainTextBody(Recordlink);
    //         mail.setHtmlBody(body);
    //         mails.add(mail);
    //      }
    //    }
    //    Map<Id,Opportunity> oppMapMementoPremium= new Map<Id,Opportunity>([SELECT Id,Name FROM Opportunity WHERE Id In:OppIdsetMementoPremiumCode]);
    //    List<Gift_Code__c> MementoPremiumCodeLst = [Select Id,Name from Gift_Code__c where opportunity__c = null and RecordTypeName__c = 'Memento Premium'];
    //    if(MementoPremiumCodeLst.Size() < 300 || Test.isRunningTest()){
    //      for(Opportunity opp : oppMapMementoPremium.values()){
    //         Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
    //         String[] toAddresses = Label.Email_to_Aaron.split(',');
    //         mail.setToAddresses(toAddresses);
    //         mail.setBccSender(false);
    //         mail.setSubject('MementoPremium below 300');
    //         mail.setUseSignature(false);
    //         mail.setSenderDisplayName('Not Assigned');
    //         mail.setSaveAsActivity(false);
    //         String body = 'Opportunity : ' + opp.Name+'<br/>';
    //         //body += 'Memento Premium needed :'+OppIdsetMementoPremiumCode.size()+'<br/>';
    //         //body += 'Opportunity Link:'+<a href= "'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+opp.Id+'"></a>+'<br/>';
    //         //body += URL.getSalesforceBaseUrl().toExternalForm()+'/'+oppId+'\n';
    //         body += URL.getSalesforceBaseUrl().toExternalForm()+'/'+opp.Id+'<br/><br/>';
    //         //System.debug('**********'+body);
    //         body +='Please Note: Total number of Memento Premium after this opportunity is '+ MementoPremiumCodeLst.size()+ '(less than 300).';
    //         //mail.setPlainTextBody(Recordlink);
    //         mail.setHtmlBody(body);
    //         mails.add(mail);
    //      }
    //    }
    //    Map<Id,Opportunity> oppMapMementoUltimate= new Map<Id,Opportunity>([SELECT Id,Name FROM Opportunity WHERE Id In:OppIdsetMementoUltimateCode]);
    //    List<Gift_Code__c> MementoUltimateCodeLst = [Select Id,Name from Gift_Code__c where opportunity__c = null and RecordTypeName__c = 'Memento Ultimate'];
    //    if(MementoUltimateCodeLst.Size() < 300 || Test.isRunningTest()){
    //      for(Opportunity opp : oppMapMementoUltimate.values()){
    //         Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
    //         String[] toAddresses = Label.Email_to_Aaron.split(',');
    //         mail.setToAddresses(toAddresses);
    //         mail.setBccSender(false);
    //         mail.setSubject('MementoUltimate Code below 300');
    //         mail.setUseSignature(false);
    //         mail.setSenderDisplayName('Not Assigned');
    //         mail.setSaveAsActivity(false);
    //         String body = 'Opportunity : ' + opp.Name+'<br/>';
    //         //body += 'Memento Premium needed :'+OppIdsetMementoUltimateCode.size()+'<br/>';
    //         //body += 'Opportunity Link:'+<a href= "'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+opp.Id+'"></a>+'<br/>';
    //         //body += URL.getSalesforceBaseUrl().toExternalForm()+'/'+oppId+'\n';
    //         body += URL.getSalesforceBaseUrl().toExternalForm()+'/'+opp.Id+'<br/><br/>';
    //         //System.debug('**********'+body);
    //         body +='Please Note: Total number of Memento Premium after this opportunity is '+ MementoUltimateCodeLst.size()+ '(less than 300).';
    //         //mail.setPlainTextBody(Recordlink);
    //         mail.setHtmlBody(body);
    //         mails.add(mail);
    //      }
    //    }
    //    if(mails.size()>0){
    //        Messaging.sendEmail(mails);
    //    }

   }


   public static void onAfterInsertGiftCode(List<Gift_Code__c> lstGiftCodes){
       captureDeletedProducts(null);
    //    Id F1AccessCodeRecordTypeId = Schema.SObjectType.Gift_Code__c.getRecordTypeInfosByName().get('F1 Access Code').getRecordTypeId();
    //    Id FanaticsCodeRecordTypeId = Schema.SObjectType.Gift_Code__c.getRecordTypeInfosByName().get('Fanatics Gift Code').getRecordTypeId();
    //    Id MementoPremiumCodeRecordTypeId = Schema.SObjectType.Gift_Code__c.getRecordTypeInfosByName().get('Memento Premium').getRecordTypeId();
    //    Id MementoUltimateCodeRecordTypeId = Schema.SObjectType.Gift_Code__c.getRecordTypeInfosByName().get('Memento Ultimate').getRecordTypeId();
    //    map<Id,Gift_Code__c> mapF1AccessCode = New map<Id,Gift_Code__c>();
    //    map<Id,Gift_Code__c> mapFanaticsCode = New map<Id,Gift_Code__c>();
    //    map<Id,Gift_Code__c> mapMementoPremiumCode = New map<Id,Gift_Code__c>();
    //    map<Id,Gift_Code__c> mapMementoUltimateCode = New map<Id,Gift_Code__c>();
    //    for(Gift_Code__c gcode: lstGiftCodes){
    //        if(gcode.opportunity__c == null){
    //            if(gcode.recordtypeid == F1AccessCodeRecordTypeId) mapF1AccessCode.put(gcode.Id,gcode);
    //            else if(gcode.recordtypeid == FanaticsCodeRecordTypeId) mapFanaticsCode.put(gcode.Id,gcode);
    //            else if(gcode.recordtypeid == MementoPremiumCodeRecordTypeId) mapMementoPremiumCode.put(gcode.Id,gcode);
    //            else if(gcode.recordtypeid == MementoUltimateCodeRecordTypeId) mapMementoUltimateCode.put(gcode.Id,gcode);
    //        }
    //    }

    //    if(mapF1AccessCode.size()>0 || mapFanaticsCode.size()>0 || mapMementoPremiumCode.size()>0 || mapMementoUltimateCode.size()>0){
    //        Map<Id,Opportunity> mapOpportunity = New Map<Id,Opportunity>([Select Id,Name,Fanatics_Gift_Code_Assignment_Pending__c,F1_Access_Code_Assignment_Pending__c,Memento_Premium_Assignment_Pending__c,Memento_Ultimate_Assignment_Pending__c,
    //            (SELECT Id,Quantity,OpportunityId,ProductType__c,Product_Type__c,product2.Brandfuel_Points__c FROM OpportunityLineItems where ProductType__c = 'F1 Access Code' or ProductType__c ='Fanatics Gift Code' or ProductType__c ='Memento Ultimate' or ProductType__c ='Memento Premium'),
    //            (Select id,status__c from Opportunity_payment_terms__r order by Payment_Due_Date__c asc limit 1)
    //            from opportunity where stagename='Closed Won' and (F1_Access_Code_Assignment_Pending__c = true or Fanatics_Gift_Code_Assignment_Pending__c = true or Memento_Premium_Assignment_Pending__c = true or Memento_Ultimate_Assignment_Pending__c =true)]);

    //        if(mapOpportunity.size()>0){
    //            Integer totalNumberOfF1AccessReq = 0;
    //            Integer totalNumberOfFanaticsReq = 0;
    //            Integer totalNumberOfMementoPremiumReq = 0;
    //            Integer totalNumberOfMementoUltimateReq = 0;

    //            Map<Id,Integer> mapofOppIDToQuantityF1AccessCode = new Map<Id,Integer>();
    //            Map<Id,Integer> mapofOppIDToQuantityFanatics = new Map<Id,Integer>();
    //            Map<Id,Integer> mapofOppIDToQuantityMementoPremium = new Map<Id,Integer>();
    //            Map<Id,Integer> mapofOppIDToQuantityMementoUltimate = new Map<Id,Integer>();
    //            for(Opportunity opp: mapOpportunity.values()){
    //                if(opp.Opportunity_payment_terms__r != null && opp.Opportunity_payment_terms__r.size()>0 && opp.Opportunity_payment_terms__r[0].status__c == 'Passed'){
    //                    Integer quantityvalF1AccessCode = 0;
    //                    Integer quantityvalFanatics = 0;
    //                    Integer quantityvalMementoPremium = 0;
    //                    Integer quantityvalMementoUltimate = 0;

    //                     for(OpportunityLineItem oppLineItem: opp.OpportunityLineItems) {
    //                         System.debug('***opp line item**' +oppLineItem.id);
    //                         if((oppLineItem.ProductType__c =='F1 Access Code' && oppLineItem.Quantity != null) || Test.isRunningTest() ){
    //                             quantityvalF1AccessCode = quantityvalF1AccessCode + Integer.valueOf(oppLineItem.Quantity);
    //                             System.debug('***line item quantity**'+Integer.valueOf(oppLineItem.Quantity));
    //                             System.debug('***quantity total**'+quantityvalF1AccessCode);
    //                         }
    //                         else if((oppLineItem.ProductType__c =='Fanatics Gift Code' && oppLineItem.Quantity != null) || Test.isRunningTest() ){
    //                             quantityvalFanatics  = quantityvalFanatics + Integer.valueOf(oppLineItem.Quantity);
    //                             System.debug('***quantity total**'+quantityvalFanatics);
    //                         }
    //                         else if((oppLineItem.ProductType__c =='Memento Premium' && oppLineItem.Quantity != null) || Test.isRunningTest()){
    //                             quantityvalMementoPremium  = quantityvalMementoPremium + Integer.valueOf(oppLineItem.Quantity);
    //                             System.debug('***quantity total**'+quantityvalMementoPremium);
    //                         }
    //                         else if((oppLineItem.ProductType__c =='Memento Ultimate' && oppLineItem.Quantity != null) || Test.isRunningTest()){
    //                             quantityvalMementoUltimate  = quantityvalMementoUltimate + Integer.valueOf(oppLineItem.Quantity);
    //                             System.debug('***quantity total**'+ quantityvalMementoUltimate);
    //                         }
    //                     }

    //                     if(quantityvalF1AccessCode != 0 || Test.isRunningTest()){
    //                        mapofOppIDToQuantityF1AccessCode.put(opp.Id,quantityvalF1AccessCode);
    //                        totalNumberOfF1AccessReq = totalNumberOfF1AccessReq + quantityvalF1AccessCode;
    //                     }

    //                     if(quantityvalFanatics != 0 || Test.isRunningTest()){
    //                        mapofOppIDToQuantityFanatics.put(opp.Id,quantityvalFanatics);
    //                        totalNumberOfFanaticsReq = totalNumberOfFanaticsReq + quantityvalFanatics;
    //                     }
    //                     if(quantityvalMementoPremium != 0 || Test.isRunningTest()){
    //                         mapofOppIDToQuantityMementoPremium.put(opp.Id,quantityvalMementoPremium);
    //                         totalNumberOfMementoPremiumReq = totalNumberOfMementoPremiumReq + quantityvalMementoPremium;
    //                     }
    //                     if(quantityvalMementoUltimate != 0 || Test.isRunningTest()){
    //                        mapofOppIDToQuantityMementoUltimate.put(opp.Id,quantityvalMementoUltimate);
    //                        totalNumberOfMementoUltimateReq = totalNumberOfMementoUltimateReq + quantityvalMementoUltimate;
    //                     }
    //                 }
    //           }


    //           Map<Id,Map<String,Integer>> mapassignedOppGiftCodes = new Map<Id,Map<String,Integer>>();

    //           Integer intcount = 0;
    //           String strgc = 'Select Id,RecordTypeName__c,Opportunity__c from Gift_Code__c where opportunity__c != null';
    //           if(mapF1AccessCode.size()>0) strgc += ' and RecordTypeName__c = \'F1 Access Code\'';
    //           if(mapFanaticsCode.size()>0) strgc += ' and RecordTypeName__c = \'Fanatics Gift Code\'';
    //           if(mapMementoPremiumCode.size()>0) strgc += ' and RecordTypeName__c = \'Memento Premium\'';
    //           if(mapMementoUltimateCode.size()>0) strgc += ' and RecordTypeName__c = \'Memento Ultimate\'';
    //           strgc += ' order by RecordTypeName__c';

    //           for(Gift_Code__c  giftcode:database.query(strgc)){
    //               if(!mapassignedOppGiftCodes.containskey(giftcode.Opportunity__c)){
    //                   intcount = 1;
    //                   mapassignedOppGiftCodes.put(giftcode.Opportunity__c,New Map<String,Integer>{giftcode.RecordTypeName__c=>intcount});
    //               }else{
    //                   Map<String,Integer> mapassignedCount = New Map<String,Integer>();
    //                   if(mapassignedOppGiftCodes.get(giftcode.Opportunity__c).containskey(giftcode.RecordTypeName__c)){
    //                       intcount = mapassignedOppGiftCodes.get(giftcode.Opportunity__c).get(giftcode.RecordTypeName__c)+1;
    //                       mapassignedOppGiftCodes.get(giftcode.Opportunity__c).put(giftcode.RecordTypeName__c, intcount);
    //                   }else{
    //                       intcount = 1;
    //                       mapassignedOppGiftCodes.get(giftcode.Opportunity__c).put(giftcode.RecordTypeName__c, intcount);
    //                   }
    //               }
    //           }
    //           system.debug('@@@mapassignedOppGiftCodes=='+mapassignedOppGiftCodes);

    //           List<Gift_Code__c> lstNewGiftCodes = new List<Gift_Code__c>([Select Id,RecordTypeName__c,Opportunity__c from Gift_Code__c where id in: lstGiftCodes and opportunity__c = null]);
    //           Map<Id,Opportunity> mapOpportunityToUpdate = new Map<Id,Opportunity>();
    //           List<Gift_Code__c> lstGiftCodesToUpdates = new List<Gift_Code__c>();
    //           Set<Id> setF1GCId = New Set<Id>();
    //           Set<Id> setFanaticsGCId = New Set<Id>();
    //           Set<Id> setMementoPremiumGCId = New Set<Id>();
    //           Set<Id> setMementoUltimateGCId = New Set<Id>();


    //           // For F1 Access Code
    //           if(mapF1AccessCode.size()>0){
    //               for(Id OpId: mapofOppIDToQuantityF1AccessCode.keyset()){
    //                 Integer F1Count = 0;
    //                 Integer diffF1AssignedCode = 0;
    //                 system.debug('@@@mapofOppIDToQuantityF1AccessCode.get(OpId)=='+mapofOppIDToQuantityF1AccessCode.get(OpId));
    //                 //system.debug('@@@mapassignedOppGiftCodes.get(OpId).get(F1 Access Code)==='+mapassignedOppGiftCodes.get(OpId).get('F1 Access Code'));

    //                 if(mapassignedOppGiftCodes.containskey(OpId) && mapassignedOppGiftCodes.get(OpId) != null && mapassignedOppGiftCodes.get(OpId).get('F1 Access Code') != null){
    //                     diffF1AssignedCode = mapofOppIDToQuantityF1AccessCode.get(OpId) - mapassignedOppGiftCodes.get(OpId).get('F1 Access Code');
    //                 }else{
    //                     diffF1AssignedCode = mapofOppIDToQuantityF1AccessCode.get(OpId);
    //                 }
    //                 for(Integer j=0;j < diffF1AssignedCode;j++){
    //                     for(Gift_Code__c gc: lstNewGiftCodes){
    //                         if(!setF1GCId.contains(gc.Id) && gc.RecordTypeName__c == 'F1 Access Code'){
    //                             gc.Opportunity__c = OpId;
    //                             setF1GCId.add(gc.Id);
    //                             lstGiftCodesToUpdates.add(gc);
    //                             F1Count++;
    //                             break;
    //                         }
    //                     }
    //                 }
    //                 system.debug('@@@@diffF1AssignedCode=='+diffF1AssignedCode);
    //                 system.debug('@@@@F1Count=='+F1Count);
    //                 if(F1Count != 0 && diffF1AssignedCode != 0 && F1Count == diffF1AssignedCode){
    //                     Opportunity opp = new Opportunity(Id=OpId);
    //                     if(mapOpportunityToUpdate.containskey(OpId)){
    //                         opp = mapOpportunityToUpdate.get(OpId);
    //                     }
    //                     opp.F1_Access_Code_Assignment_Pending__c = false;
    //                     mapOpportunityToUpdate.put(OpId,opp);
    //                 }
    //             }
    //           }
    //             system.debug('@@@@mapFanaticsCode=='+mapFanaticsCode);
    //           // For Fanatics Gift Code
    //           if(mapFanaticsCode.size()>0){
    //               for(Id OppId: mapofOppIDToQuantityFanatics.keyset()){
    //                   Integer FanaticsCount = 0;
    //                   Integer diffFanaticsAssignedCode = 0;

    //                   if(mapassignedOppGiftCodes.containskey(OppId) && mapassignedOppGiftCodes.get(OppId) != null && mapassignedOppGiftCodes.get(OppId).get('Fanatics Gift Code') != null){
    //                      diffFanaticsAssignedCode = mapofOppIDToQuantityFanatics.get(OppId) - mapassignedOppGiftCodes.get(OppId).get('Fanatics Gift Code');
    //                   }else{
    //                      diffFanaticsAssignedCode = mapofOppIDToQuantityFanatics.get(OppId);
    //                   }

    //                   for(Integer i=0;i < diffFanaticsAssignedCode;i++){
    //                      for(Gift_Code__c fanagc: lstNewGiftCodes){
    //                         if(!setFanaticsGCId.contains(fanagc.Id) && fanagc.RecordTypeName__c == 'Fanatics Gift Code'){
    //                             fanagc.Opportunity__c = OppId;
    //                             setFanaticsGCId.add(fanagc.Id);
    //                             lstGiftCodesToUpdates.add(fanagc);
    //                             FanaticsCount++;
    //                             break;
    //                         }
    //                     }
    //                   }
                      
    //                   system.debug('@@@@diffFanaticsAssignedCode =='+diffFanaticsAssignedCode );
    //                 system.debug('@@@@FanaticsCount=='+FanaticsCount);
                    
    //                   if(FanaticsCount != 0 && diffFanaticsAssignedCode != 0 && FanaticsCount == diffFanaticsAssignedCode){
    //                       Opportunity oppFana = new Opportunity(Id=OppId);
    //                       if(mapOpportunityToUpdate.containskey(OppId)){
    //                           oppFana = mapOpportunityToUpdate.get(OppId);
    //                       }
    //                       oppFana.Fanatics_Gift_Code_Assignment_Pending__c = false;
    //                       mapOpportunityToUpdate.put(OppId,oppFana);
    //                   }
    //               }
    //           }

    //           // For Memento Premium Gift Code
    //           if(mapMementoPremiumCode.size()>0){
    //               for(Id OppId: mapofOppIDToQuantityMementoPremium.keyset()){
    //                   Integer MementoPremiumCount = 0;
    //                   Integer diffMementoPremiumCode = 0;

    //                   if(mapassignedOppGiftCodes.containskey(OppId) && mapassignedOppGiftCodes.get(OppId) != null && mapassignedOppGiftCodes.get(OppId).get('Memento Premium') != null){
    //                      diffMementoPremiumCode = mapofOppIDToQuantityMementoPremium.get(OppId) - mapassignedOppGiftCodes.get(OppId).get('Memento Premium');
    //                   }else{
    //                      diffMementoPremiumCode = mapofOppIDToQuantityMementoPremium.get(OppId);
    //                   }
    //                   for(Integer i=0;i < diffMementoPremiumCode;i++){
    //                      for(Gift_Code__c momentogc: lstNewGiftCodes){
    //                         if(!setMementoPremiumGCId.contains(momentogc.Id) && momentogc.RecordTypeName__c == 'Memento Premium'){
    //                             momentogc.Opportunity__c = OppId;
    //                             setMementoPremiumGCId.add(momentogc.Id);
    //                             lstGiftCodesToUpdates.add(momentogc);
    //                             MementoPremiumCount++;
    //                             break;
    //                         }
    //                     }
    //                   }
    //                   if(MementoPremiumCount != 0 && diffMementoPremiumCode != 0 && MementoPremiumCount == diffMementoPremiumCode){
    //                       Opportunity oppMementoPremium = new Opportunity(Id=OppId);
    //                       if(mapOpportunityToUpdate.containskey(OppId)){
    //                           oppMementoPremium = mapOpportunityToUpdate.get(OppId);
    //                       }
    //                       oppMementoPremium.Memento_Premium_Assignment_Pending__c= false;
    //                       mapOpportunityToUpdate.put(OppId,oppMementoPremium);
    //                   }
    //               }
    //           }

    //           // For Memento Ultimate Gift Code
    //           if(mapMementoUltimateCode.size()>0){
    //               for(Id OppId: mapofOppIDToQuantityMementoUltimate.keyset()){
    //                   Integer MementoUltimateCount = 0;
    //                   Integer diffMementoUltimateCode = 0;

    //                   if(mapassignedOppGiftCodes.containskey(OppId) && mapassignedOppGiftCodes.get(OppId) != null && mapassignedOppGiftCodes.get(OppId).get('Memento Ultimate') != null){
    //                      diffMementoUltimateCode = mapofOppIDToQuantityMementoUltimate.get(OppId) - mapassignedOppGiftCodes.get(OppId).get('Memento Ultimate');
    //                   }else{
    //                      diffMementoUltimateCode = mapofOppIDToQuantityMementoUltimate.get(OppId);
    //                   }

    //                   for(Integer i=0;i < diffMementoUltimateCode;i++){
    //                      for(Gift_Code__c moMentogcB: lstNewGiftCodes){
    //                         if(!setMementoPremiumGCId.contains(moMentogcB.Id) && moMentogcB.RecordTypeName__c == 'Memento Ultimate'){
    //                             moMentogcB.Opportunity__c = OppId;
    //                             setMementoPremiumGCId.add(moMentogcB.Id);
    //                             lstGiftCodesToUpdates.add(moMentogcB);
    //                             MementoUltimateCount++;
    //                             break;
    //                         }
    //                     }
    //                   }
    //                   if(MementoUltimateCount != 0 && diffMementoUltimateCode != 0 && MementoUltimateCount == diffMementoUltimateCode){
    //                       Opportunity oppMementoUltimate = new Opportunity(Id=OppId);
    //                       if(mapOpportunityToUpdate.containskey(OppId)){
    //                           oppMementoUltimate = mapOpportunityToUpdate.get(OppId);
    //                       }
    //                       oppMementoUltimate.Memento_Ultimate_Assignment_Pending__c= false;
    //                       mapOpportunityToUpdate.put(OppId,oppMementoUltimate);
    //                   }
    //               }
    //           }

    //           if(lstGiftCodesToUpdates.size()>0){
    //               isRecursive=true;
    //               Update lstGiftCodesToUpdates;
    //           }

    //           if(mapOpportunityToUpdate.size()>0){
    //               Update mapOpportunityToUpdate.values();
    //           }

    //        }
    //    }
   }
   
   // Capture deleted Gift_Code__c
    public static void captureDeletedProducts(List<Gift_Code__c> oldList) {
        // Capture deleted product 
        // List<QE_Deleted_Record__c> recordsBeingDeleted = new List<QE_Deleted_Record__c>();
        // for (Gift_Code__c gc: oldList) {
        //     QE_Deleted_Record__c deletedRecord = new QE_Deleted_Record__c();
        //     deletedRecord.Name = gc.Name;
        //     deletedRecord.DeletedId__c = gc.Id;
        //     recordsBeingDeleted.add(deletedRecord);
        // }
        // try {
        //     insert recordsBeingDeleted;
        // } catch (Exception e) {
        //     System.debug('Exception: '+e);
        // }
    }
}