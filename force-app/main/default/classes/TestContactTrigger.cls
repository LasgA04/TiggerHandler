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
private class TestContactTrigger {

    @isTest
    static void EditOwnerIdOfContact() {
        //We use the default user user created by Salesforce
        List<Contact> Contacts=TestDataFactory.GetContactsToChangeOwnerId('0050U0000068a7nQAA',20); 

        Account account=[SELECT Id FROM Account where OwnerId = '0050U0000068a7nQAA' AND Name = 'Test Account' Limit 1];

        for(Integer i=0; i<Contacts.size();i++){
            Contacts[i].OwnerId='0050U0000068a81QAA';
            
        }

        Test.startTest();
        //Database.update(sobject);
            Database.SaveResult[] results=Database.update(Contacts,false);
        Test.stopTest();
        for(Database.SaveResult result:results){
            System.assert(!result.isSuccess());
        }

    }
    @isTest
    static void EditContact() {
        //We use the default user user created by Salesforce
        List<Contact> Contacts=TestDataFactory.GetContactsToChangeOwnerId('0050U0000068a7nQAA',20); 
        Account account=[SELECT Id FROM Account where OwnerId = '0050U0000068a7nQAA' AND Name = 'Test Account' Limit 1];

        for(Contact cont: Contacts){
            cont.Phone='452 100 000';
        }

        Test.startTest();
            Database.SaveResult[] results=Database.update(Contacts,false);
        Test.stopTest();

        for(Database.SaveResult result:results){
            System.assert(result.isSuccess());
        }

    }

   /* @isTest
    static void EditContacts() {
        List<Contact> Contacts=[SELECT Id,OwnerId,Account.Name FROM Contacts WHERE OwnerId = '0050U0000068a7nQAA' LIMIT 100];

        for(Contact cont: Contacts){
            cont.Phone='452 100 0000';
        }

        Test.startTest();
            update Contacts;
        Test.startTest();

    }*/
}