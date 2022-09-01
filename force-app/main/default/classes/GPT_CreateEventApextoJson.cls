public class GPT_CreateEventApextoJson {

	public Integer id {get;set;} 
	public String thumbnail {get;set;} 
	public String banner {get;set;} 
	public String country {get;set;} 
	public String town {get;set;} 
	public String title {get;set;} 
	public String fromdate {get;set;} 
	public String todate {get;set;} 

	public GPT_CreateEventApextoJson(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'id') {
						id = parser.getIntegerValue();
					} else if (text == 'thumbnail') {
						thumbnail = parser.getText();
					} else if (text == 'banner') {
						banner = parser.getText();
					} else if (text == 'country') {
						country = parser.getText();
					} else if (text == 'town') {
						town = parser.getText();
					} else if (text == 'title') {
						title = parser.getText();
					} else if (text == 'fromdate') {
						fromdate = parser.getText();
					} else if (text == 'todate') {
						todate = parser.getText();
					} else {
						System.debug(LoggingLevel.WARN, 'GPT_CreateEventApextoJson consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	
	public static List<GPT_CreateEventApextoJson> parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return arrayOfGPT_CreateEventApextoJson(parser);
	}
	
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}
	



    private static List<GPT_CreateEventApextoJson> arrayOfGPT_CreateEventApextoJson(System.JSONParser p) {
        List<GPT_CreateEventApextoJson> res = new List<GPT_CreateEventApextoJson>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new GPT_CreateEventApextoJson(p));
        }
        return res;
    }


}