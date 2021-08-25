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

   /* static ATK.SaveResult result =  ATK.prepare(Account.SObjectType, 5)
        .field(Account.Name).index('Test Account-{0000}')
        .withChildren(Contact.SObjectType, Contact.AccountId, 250)
            .field(Contact.LastName).index('Name-{0000}')
            .field(Contact.BirthDate).repeat(c24years,c16years)
            .save();
    
         //   Map<Id,Account> AccountsByIds.keySet() MapIdsToAccounts

*/
    @TestSetup
    static void makeData(){
        Date current=Date.today();
        Date c24years=Date.newInstance(current.year()-24,1,1);
        Date c16years=Date.newInstance(current.year()-16,1,1);

        ATK.SaveResult result =  ATK.prepare(Account.SObjectType, 5)
                .field(Account.Name).index('Test Account-{0000}')
                .withChildren(Contact.SObjectType, Contact.AccountId, 250)
                    .field(Contact.LastName).index('Name-{0000}')
                    .field(Contact.BirthDate).repeat(c24years,c16years)
                    .save();
    }

    @isTest
    static void shouldSyncContactsOwnerWithAccountOwner() {
        //We use the default user user created by Salesforce
       List<User> users=[SELECT Id FROM User LIMIT 2];
       if(users.size()==2){
            Account account=[SELECT Id ,(SELECT Id FROM Contacts) FROM Account WHERE Name = 'Test Account-0001'];

            List<Contact> Contacts=account.Contacts; 

            for(Integer i=0; i<Contacts.size();i++){
                Contacts[i].OwnerId=users[1].Id;
            }
    
            Test.startTest();
                Database.SaveResult[] results=Database.update(Contacts,false);
            Test.stopTest();

            System.assertEquals(Contacts.size(),results.size());
            for(Database.SaveResult result:results){
                System.assertEquals(false,result.isSuccess());
            }
        }
    }
    @isTest
    static void shouldHave50PercentageOfContactsOver18() {

        Account account=[SELECT Id,Number_Of_Contacts_Over_18__c, Percentage_Of_Contacts_Over_18__c, 
        Oldest_Contact__c, Youngest_Contact__c,
        (SELECT Id, Birthdate FROM Contacts ORDER By Birthdate)
        FROM Account WHERE  Name = 'Test Account-0003'];

        //System.assertEquals(Contacts.size(), account.Contacts.size(),'it Should have 20 Contacts ');
        System.assertEquals((account.Contacts.size()/2), account.Number_Of_Contacts_Over_18__c,'it Should have '+(account.Contacts.size()/2)+' Contacts over 18 ');
        System.assertEquals(50, account.Percentage_Of_Contacts_Over_18__c,'it Should have 50% of percentage of contacts over 18 ');
        
        System.assertEquals(16, account.Youngest_Contact__c,'the youngest contact Should have 16');
        System.assertEquals(24, account.Oldest_Contact__c,'the oldest contact Should have 24');
    }

    @isTest
    static void shouldHave100PercentageOfContactsOver18() {
        Date current=Date.today();
        Date over30years=Date.newInstance(current.year()-30,1,1);

        Account account=[SELECT Id ,(SELECT Id FROM Contacts) FROM Account WHERE Name = 'Test Account-0002'];
        List<Contact> Contacts=account.Contacts; 

        Test.startTest();
            ATK.prepare(Contact.SObjectType, Contacts)
                .field(Contact.Birthdate).repeat(over30years)
                .save();
        Test.stopTest();

        System.debug(contacts);

        account=[SELECT Id,Number_Of_Contacts_Over_18__c, Percentage_Of_Contacts_Over_18__c, 
        Oldest_Contact__c, Youngest_Contact__c,
        (SELECT Id, Birthdate FROM Contacts ORDER By Birthdate)
        FROM Account WHERE Name = 'Test Account-0002'];

        //System.assertEquals(50, account.Contacts.size(),'it Should have 50 Contacts ');
        System.assertEquals(Contacts.size(), account.Number_Of_Contacts_Over_18__c,'it Should have '+Contacts.size()+' Contacts over 18 ');
        System.assertEquals(100, account.Percentage_Of_Contacts_Over_18__c,'it Should have 100% of percentage of contacts over 18 ');
        
        System.assertEquals(30, account.Youngest_Contact__c,'the youngest contact Should have 30 years old');
        System.assertEquals(30, account.Oldest_Contact__c,'the oldest contact Should have 30 years old');
        
    }
    

    @isTest
    static void shouldDeleteAllContactsOver18() {
        Account  account=[SELECT Id,
                        (SELECT Id, Birthdate FROM Contacts) 
                        FROM Account WHERE Name = 'Test Account-0004'];

        List<Contact> ContactsToDelete=new List<Contact>(); 

        for(Contact contact:account.Contacts){
            Integer contantYears=contact.Birthdate.daysBetween(Date.today())/365;
            if(contantYears>=18){
                ContactsToDelete.add(Contact);
            }
        }

        System.debug(ContactsToDelete);

        Test.startTest();
            delete ContactsToDelete;
        Test.stopTest();

        account=[SELECT Id,Number_Of_Contacts_Over_18__c, Percentage_Of_Contacts_Over_18__c, 
        Oldest_Contact__c, Youngest_Contact__c,
        (SELECT Id FROM Contacts) 
        FROM Account WHERE Name = 'Test Account-0004'];

        System.assertEquals(25, account.Contacts.size(),'it Should have 20 Contacts ');
        System.assertEquals(0, account.Number_Of_Contacts_Over_18__c,'it Should have 0 Contacts over 18 ');
        System.assertEquals(0, account.Percentage_Of_Contacts_Over_18__c,'it Should have 0% of percentage of contacts over 18 ');
        
        System.assertEquals(16, account.Youngest_Contact__c,'the youngest contact Should be 0 ');
        System.assertEquals(16, account.Oldest_Contact__c,'the oldest contact Should be 0 ');
    }

    @isTest
    static void shouldDeleteAllContactsLess18() {
        Account  account=[SELECT Id, (SELECT Id, Birthdate FROM Contacts) 
                        FROM Account WHERE Name = 'Test Account-0005'];

        List<Contact> ContactsToDelete=new List<Contact>(); 

        for(Contact contact:account.Contacts){
            Integer contantYears=contact.Birthdate.daysBetween(Date.today())/365;
            if(contantYears<18){
                ContactsToDelete.add(Contact);
            }
        }

        System.debug('Contacts size: '+account.Contacts.size());
        System.debug('Contacts to delete size: '+ContactsToDelete.size());

        Test.startTest();
            delete ContactsToDelete;
        Test.stopTest();

        account=[SELECT Id,Number_Of_Contacts_Over_18__c, Percentage_Of_Contacts_Over_18__c, 
        Oldest_Contact__c, Youngest_Contact__c,
        (SELECT Id FROM Contacts ORDER By Birthdate)
        FROM Account WHERE Name = 'Test Account-0005'];

       // System.assertEquals((Contacts.size()/2), account.Contacts.size(),'it Should have 5 Contacts ');
        System.assertEquals(25, account.Number_Of_Contacts_Over_18__c,'it Should have 25 Contacts over 18 ');
        System.assertEquals(100, account.Percentage_Of_Contacts_Over_18__c,'it Should have 100% of percentage of contacts over 18 ');
        
        System.assertEquals(24, account.Youngest_Contact__c,'the youngest contact Should have 24');
        System.assertEquals(24, account.Oldest_Contact__c,'the oldest contact Should have 24');
    }

}