@IsTest
public class GPT_CreateEventApextoJson_Test {
	
	// This test method should give 100% coverage
	static testMethod void testParse() {
		String json = '['+
		'    {'+
		'        \"id\": 3870,'+
		'        \"thumbnail\": \"https://s3.eu-central-1.amazonaws.com/gpt-v2-img/img/events/vietnam.jpg\",'+
		'        \"banner\": \"https://s3.eu-central-1.amazonaws.com/gpt-v2-img/img/flaggen/VN.png\",'+
		'        \"country\": \"Vietnam\",'+
		'        \"town\": \"Hanoi\",'+
		'        \"title\": \"FORMULA 1 VIETNAM GRAND PRIX 2020\",'+
		'        \"fromdate\": \"2020-04-01\",'+
		'        \"todate\": \"2020-04-30\"'+
		'    }'+
		']';
		List<GPT_CreateEventApextoJson> r = GPT_CreateEventApextoJson.parse(json);
		System.assert(r != null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		GPT_CreateEventApextoJson objGPT_CreateEventApextoJson = new GPT_CreateEventApextoJson(System.JSON.createParser(json));
		System.assert(objGPT_CreateEventApextoJson != null);
		System.assert(objGPT_CreateEventApextoJson.id == null);
		System.assert(objGPT_CreateEventApextoJson.thumbnail == null);
		System.assert(objGPT_CreateEventApextoJson.banner == null);
		System.assert(objGPT_CreateEventApextoJson.country == null);
		System.assert(objGPT_CreateEventApextoJson.town == null);
		System.assert(objGPT_CreateEventApextoJson.title == null);
		System.assert(objGPT_CreateEventApextoJson.fromdate == null);
		System.assert(objGPT_CreateEventApextoJson.todate == null);
	}
}