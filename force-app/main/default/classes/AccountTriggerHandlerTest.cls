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
private class AccountTriggerHandlerTest {
    
    @isTest
    static void shouldSyncContactsOwnerWithAccountOwner() {
       User user=[SELECT Id FROM User LIMIT 1];
       //System.assertEquals(2,users.size());

      // Id fakeUserId= ATK.fakeId(User.SObjectType, 1);
       TriggerHandler.bypass('ContactTriggerHandler');

       ATK.SaveResult result = ATK.prepare(Account.SObjectType, 1)
       .field(Account.Name).index('Name-{0000}')
       .withChildren(Contact.SObjectType, Contact.AccountId, 20)
           .field(Contact.LastName).index('Name-{0000}')
           .save();

        Account account=[Select Id from Account Where Name Like '%Name-%' Limit 1];

        account.OwnerId=user.Id;

        TriggerHandler.clearBypass('ContactTriggerHandler');

        Test.startTest();
            update account;
        Test.stopTest();

        List<Contact> contacts=[SELECT Id,OwnerId,Account.OwnerId FROM Contact WHERE Account.Id = :account.Id];
        System.assertEquals(20, contacts.size(),'Comentario ');
        
        for (Contact cont : contacts) {
            System.assertEquals(user.Id,cont.OwnerId);  
        }
    }

}