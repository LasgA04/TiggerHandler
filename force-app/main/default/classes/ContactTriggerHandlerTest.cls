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
private class ContactTriggerHandlerTest {

    @isTest
    static void shouldSyncContactsOwnerWithAccountOwner() {
        //We use the default user user created by Salesforce
       List<User> users=[SELECT Id FROM User LIMIT 2];
       System.assertEquals(2,users.size());  

       if(users.size()==2){
            List<Contact> Contacts=TestDataFactory.GetContactsToChangeOwnerId(users[0].Id,20); 

            for(Integer i=0; i<Contacts.size();i++){
                Contacts[i].OwnerId=users[1].Id;
                
            }
    
            Test.startTest();
                Database.SaveResult[] results=Database.update(Contacts,false);
            Test.stopTest();

            System.assertEquals(20,results.size());
            for(Database.SaveResult result:results){
                System.assertEquals(false,result.isSuccess());
            }
        }
    }
    @isTest
    static void shouldHave100PertengaeOfContactsOver18() {
        Account  account=new account(Name='Test Account');

        insert account;

        List<Contact> Contacts=TestDataFactory.GetContactsWithBirthDate(account.Id,19,24); 
        Contacts.addAll(TestDataFactory.GetContactsWithBirthDate(account.Id,1,30));

        Test.startTest();
            Database.SaveResult[] results=Database.insert(Contacts,false);
        Test.stopTest();

        account=[SELECT Id,Number_Of_Contacts_Over_18__c, Percentage_Of_Contacts_Over_18__c, 
        Oldest_Contact__c, Youngest_Contact__c,
        (SELECT Id, Birthdate FROM Contacts ORDER By Birthdate)
        FROM Account where  Name = 'Test Account' Limit 1];

        System.assertEquals(20, account.Contacts.size(),'it Should have 20 Contacts ');
        System.assertEquals(20, account.Number_Of_Contacts_Over_18__c,'it Should have 20 Contacts over 18 ');
        System.assertEquals(100, account.Percentage_Of_Contacts_Over_18__c,'it Should have 100% of percentage of contacts over 18 ');
        
        System.assertEquals(24, account.Youngest_Contact__c,'the youngest contact Should have '+24+' years old');
        System.assertEquals(30, account.Oldest_Contact__c,'the oldest contact Should have '+30+' years old');
    }
    @isTest
    static void shouldHave50PertengaeOfContactsOver18() {
        Account  account=new account(Name='Test Account');

        insert account;

        List<Contact> Contacts=TestDataFactory.GetContactsWithBirthDate(account.Id,10,24); 
        Contacts.addAll(TestDataFactory.GetContactsWithBirthDate(account.Id,10,16));

        System.debug('Contacts size: '+Contacts.size());

        Test.startTest();
            Database.SaveResult[] results=Database.insert(Contacts,false);
        Test.stopTest();

         account=[SELECT Id,Number_Of_Contacts_Over_18__c, Percentage_Of_Contacts_Over_18__c, 
        Oldest_Contact__c, Youngest_Contact__c,
        (SELECT Id, Birthdate FROM Contacts ORDER By Birthdate)
        FROM Account where  Name = 'Test Account' Limit 1];

        System.assertEquals(20, account.Contacts.size(),'it Should have 20 Contacts ');
        System.assertEquals(10, account.Number_Of_Contacts_Over_18__c,'it Should have 10 Contacts over 18 ');
        System.assertEquals(50, account.Percentage_Of_Contacts_Over_18__c,'it Should have 50% of percentage of contacts over 18 ');
        
        System.assertEquals(16, account.Youngest_Contact__c,'the youngest contact Should have '+16);
        System.assertEquals(24, account.Oldest_Contact__c,'the oldest contact Should have '+24);
    }

    @isTest
    static void shouldHave0PertengaeOfContactsOver18() {
        Account  account=new account(Name='Test Account');

        insert account;

        List<Contact> Contacts=TestDataFactory.GetContactsWithBirthDate(account.Id,20,0); 

        System.debug(Contacts);

        Test.startTest();
            Database.SaveResult[] results=Database.insert(Contacts,false);
        Test.stopTest();

         account=[SELECT Id,Number_Of_Contacts_Over_18__c, Percentage_Of_Contacts_Over_18__c, 
        Oldest_Contact__c, Youngest_Contact__c,
        (SELECT Id, Birthdate FROM Contacts ORDER By Birthdate)
        FROM Account where  Name = 'Test Account' Limit 1];

        System.assertEquals(20, account.Contacts.size(),'it Should have 20 Contacts ');
        System.assertEquals(0, account.Number_Of_Contacts_Over_18__c,'it Should have 0 Contacts over 18 ');
        System.assertEquals(0, account.Percentage_Of_Contacts_Over_18__c,'it Should have 0% of percentage of contacts over 18 ');
        
        System.assertEquals(0, account.Youngest_Contact__c,'the youngest contact Should be 0 ');
        System.assertEquals(0, account.Oldest_Contact__c,'the oldest contact Should be 0 ');
    }

    @isTest
    static void shouldDeleteAllContactsLess18() {
        Account  account=new account(Name='Test Account');

        insert account;
        //We use the default user user created by Salesforce
        List<Contact> Contacts=TestDataFactory.GetContactsWithBirthDate(account.Id,15,16); 
        Contacts.addAll(TestDataFactory.GetContactsWithBirthDate(account.Id,5,24));

        System.debug('Contacts size: '+Contacts.size());

        List<Contact> ContactsToDelete=new List<Contact>(); 

        insert Contacts;

        for (Integer i=0 ; i<Contacts.size() ;i++) {

            if((Contacts[i].Birthdate.daysBetween(Date.today())/365)<18)
                ContactsToDelete.add(Contacts[i]);

        }
        System.debug('Contacts to delete size: '+ContactsToDelete.size());

        Test.startTest();
            delete ContactsToDelete;
        Test.stopTest();

        account=[SELECT Id,Number_Of_Contacts_Over_18__c, Percentage_Of_Contacts_Over_18__c, 
        Oldest_Contact__c, Youngest_Contact__c,
        (SELECT Id, Birthdate FROM Contacts ORDER By Birthdate)
        FROM Account where  Name = 'Test Account' Limit 1];

        System.assertEquals(5, account.Contacts.size(),'it Should have 5 Contacts ');
        System.assertEquals(5, account.Number_Of_Contacts_Over_18__c,'it Should have 5 Contacts over 18 ');
        System.assertEquals(100, account.Percentage_Of_Contacts_Over_18__c,'it Should have 100% of percentage of contacts over 18 ');
        
        System.assertEquals(24, account.Youngest_Contact__c,'the youngest contact Should have '+24);
        System.assertEquals(24, account.Oldest_Contact__c,'the oldest contact Should have '+24);
    }

}