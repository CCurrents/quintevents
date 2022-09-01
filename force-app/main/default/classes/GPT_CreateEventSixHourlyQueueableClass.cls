public class GPT_CreateEventSixHourlyQueueableClass implements Queueable, Database.AllowsCallouts{
    
    public final Set<String> eventIdSet;
    public List<Product2> ProductIdSet = new List<Product2>();
    public List<Product2> ProductIdSet1 = new List<Product2>();

    public GPT_CreateEventSixHourlyQueueableClass(Set<String> eventIdSet){
        this.eventIdSet = eventIdSet;
    }
    public GPT_CreateEventSixHourlyQueueableClass(List<Product2> ProductIdSet, List<Product2> ProductIdSet1){
        this.ProductIdSet = ProductIdSet;
        this.ProductIdSet1 = ProductIdSet1;
    }
    List<Integer> YearList = new List<Integer> { System.Today().Year(), System.Today().Year()+1};
   
    public void execute(QueueableContext context) {
        
        //System.debug('eventIdSet.size()-->'+eventIdSet.size());
        //System.debug('years-->'+YearList);
        try{
            if(!ProductIdSet.isEmpty()){
                //System.debug('calling from Hourly batch'+ProductIdSet);
                
                //insert ProductIdSet;
                Database.SaveResult[] InsertProductList = Database.insert(ProductIdSet, false);

            }
            else{
                //System.debug('calling from Six hourly batch-->'+eventIdSet);
                Map<String, GPT_CreateEventApextoJson> apexJsonMap = new Map<String, GPT_CreateEventApextoJson>();
                List<QE360_Event__c> eventList = new List<QE360_Event__c>();

                for(Integer years : YearList){
                    System.debug('years-->'+years);
                    HttpRequest req = new HttpRequest();
                    req.setMethod('GET');
                    req.setEndpoint('https://www.gpt-worldwide.com/api/v1.1/gpe/en/events/formel1/'+years);
                    req.setHeader('Content-Type', 'text/xml');
                    req.setHeader('Authorization', 'Bearer Qe1v0yrj9XTDwJHkWNF3Mu2lLQzlvz6swblTQJleHHncpMdqL7v6S3bmzAxu'); 
                    req.setTimeout(120000);
                    Http http = new Http();
                    HttpResponse res = http.send(req);

                    List<GPT_CreateEventApextoJson> ApextoJsonList = (List<GPT_CreateEventApextoJson>) JSON.deserialize(res.getBody(), List<GPT_CreateEventApextoJson>.class);
                    
                    if(!ApextoJsonList.isEmpty()){
                        for(GPT_CreateEventApextoJson apexJsonObj : ApextoJsonList){
                            if(!apexJsonMap.containsKey(String.valueOf(apexJsonObj.Id)) && !eventIdSet.contains(String.valueOf(apexJsonObj.Id))){
                            System.debug('apexJsonObj.Id-->'+apexJsonObj.Id);
                                //apexJsonMap.put(String.valueOf(apexJsonObj.Id), String.valueOf(apexJsonObj.title));
                                apexJsonMap.put(String.valueOf(apexJsonObj.Id), apexJsonObj);
                            }
                        }
                    }
                }
                System.debug('First Loop End');
                for(String eventId : apexJsonMap.keyset()){
                    System.debug('GPE - +apexJsonMap.get(eventId)--> '+'GPE - '+apexJsonMap.get(eventId).title);
                    System.debug('GPE - +apexJsonMap.get(eventId)--> '+'id - '+eventId);
                    QE360_Event__c eventObj = new QE360_Event__c();
                    eventObj.Name = 'GPE - '+apexJsonMap.get(eventId).title;
                    eventObj.GPE_Event__c = true;
                    eventObj.GPT_Event_Id__c = eventId;
                    eventObj.Active__c = true;
                    eventObj.Start_Date__c = Date.valueof(apexJsonMap.get(eventId).fromdate);
                    eventObj.End_Date__c = Date.valueof(apexJsonMap.get(eventId).todate);
                    eventList.add(eventObj);
                }
                if(!eventList.isEmpty()){
                    insert eventList;
                    System.debug('eventList-->'+eventList);
                }
            }
        }
        catch(Exception e){
            System.debug('Exception: '+e.getMessage()+' ==> '+ e.getLineNumber());
        }
    }
}