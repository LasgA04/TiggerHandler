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
private class TestAcountTrigger {

    @isTest
    static void EditOwnerIdOfAccount() {
       Account account=TestDataFactory.CreateAccountWithContacts('0050U0000068a7nQAA', 20);
       account.OwnerId='0050U0000068a81QAA';
        Test.startTest();
            update account;
        Test.stopTest();

        List<Contact> contacts=[SELECT Id,OwnerId,Account.OwnerId FROM Contact WHERE Account.Id = :account.Id];

        for (Contact cont : contacts) {
            System.assert(cont.Account.OwnerId==cont.OwnerId);  
        }
    }
    @isTest
    static void EditAccount() {
        Account account=TestDataFactory.CreateAccountWithContacts('0050U0000068a7nQAA', 20);
        account.Phone='452 100 0000';

         Test.startTest();
            update account;
        	
         Test.stopTest();

      	 List<Contact> contacts=[SELECT Id,OwnerId,Account.OwnerId FROM Contact WHERE Account.Id = :account.Id];
         for (Contact cont : contacts) {
             System.assert(cont.Account.OwnerId==cont.OwnerId);  
         }
 
     }

}