/*************************************
** Class Name: QE_scheduleH4HStayInventoryUpdate
** Created Date: 01/30/2020
** Created By: Vishal Agrawal
** Purpose: H4H Inventory update 
** Unit Test: QE_H4HStayProductInventoryUpdate_Test
** ** ** ** ** ** ** **********
**
*******Modification Logs************
**Modifier Name ***** Modified Date ***** Description
**
*************************************/
public with sharing class QE_scheduleH4HStayInventoryUpdate implements Schedulable {
    public void execute(SchedulableContext ctx) {
        QE_H4HStayProductInventoryUpdate h4hInventoryUpdate = new QE_H4HStayProductInventoryUpdate();
        Id bId = Database.executeBatch(h4hInventoryUpdate, 20);
    }
}