/**
 * @File Name          : QE_TaskTriggerTest.cls
 * @Description        : 
 * @Author             : jagrawal@addonblue.com
 * @Group              : 
 * @Last Modified By   : jagrawal@addonblue.com
 * @Last Modified On   : 5/11/2020, 2:29:29 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/11/2020   jagrawal@addonblue.com     Initial Version
**/
@isTest
private class QE_TaskTriggerTest {
  @isTest static void test_method_one() {
    Task task = new Task(
        Description = 'Change my password (http://f1.qng.test/customers/password/edit?initial=true&reset_password_token=DcvasRKCNEFEzaBwQmX7) more stuff here'
    );
    insert task;

    Task taskAfterCreated = [select Id, Description from Task where Id = :task.Id];

    // System.assertEquals(taskAfterCreated.Description, 'Change my password (http://f1.qng.test/customers/password/edit?initial=true&reset_password_token=fake) more stuff here');
  }
}