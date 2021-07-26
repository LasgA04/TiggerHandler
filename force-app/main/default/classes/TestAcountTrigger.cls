/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestAcountTrigger { // FIRST-CODE-REVIEW: Change the name to AccountTriggerHandlerTest

    @isTest
    static void EditOwnerIdOfAccount() { // FIRST-CODE-REVIEW: As good practice for Test Driven Development test are called "shouldSyncContactsOwnerWithAccountOwner" for example
       Account account=TestDataFactory.CreateAccountWithContacts('0050U0000068a7nQAA', 20); // FIRST-CODE-REVIEW: Do not hardcode IDs
       account.OwnerId='0050U0000068a81QAA'; // FIRST-CODE-REVIEW: Do not hardcode IDs
        Test.startTest();
            update account;
        Test.stopTest();

        List<Contact> contacts=[SELECT Id,OwnerId,Account.OwnerId FROM Contact WHERE Account.Id = :account.Id];
        // FIRST-CODE-REVIEW: You can do query for different things like: 
        // Integer numOfContactWithCorrectOwner = [SELECT COUNT() FROM Contact WHERE Account.Id = :account.Id AND OwnerId = :account.OwnerId];
        // THEN you can do something like:
        // System.assertEquals(20, numOfContactWithCorrectOwner);

        for (Contact cont : contacts) {
            System.assert(cont.Account.OwnerId==cont.OwnerId); // FIRST-CODE-REVIEW: Use System.assertEquals() or System.assertNotEquals()
        }
    }
    @isTest
    static void EditAccount() { // FIRST-CODE-REVIEW: Same as the other method, but I'm not sure what are you trying to test in this one
        Account account=TestDataFactory.CreateAccountWithContacts('0050U0000068a7nQAA', 20); // FIRST-CODE-REVIEW: Do not hardcode IDs
        account.Phone='452 100 0000';

         Test.startTest();
            update account;
        	
         Test.stopTest();

      	 List<Contact> contacts=[SELECT Id,OwnerId,Account.OwnerId FROM Contact WHERE Account.Id = :account.Id];
         for (Contact cont : contacts) {
             System.assert(cont.Account.OwnerId==cont.OwnerId); // FIRST-CODE-REVIEW: Use System.assertEquals() or System.assertNotEquals()
         }
 
     }

}
