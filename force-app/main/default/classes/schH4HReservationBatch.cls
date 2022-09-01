/**
 * @File Name          : schH4HReservationBatch.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 3/24/2020, 6:52:10 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/23/2020   jagrawal@addonblue.com     Initial Version
**/
public class schH4HReservationBatch implements Schedulable {

    public static void execute(SchedulableContext sc){
        H4HStayProductInventoryUpdate h4hInventoryUpdate = new H4HStayProductInventoryUpdate(true);
        Database.executeBatch(h4hInventoryUpdate, 20); 

        //H4HReservationBatch objH4Hbatch = new H4HReservationBatch();
        //Database.executeBatch(objH4Hbatch);
    }
    
}