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
public class TestDataFactory {

    public static List<Contact> GetContactsToChangeOwnerId(String OwnerId, Integer numContacts) {
       List<Contact> Contacts=new List<Contact>();

       Account account=new Account(Name='Test Account',OwnerId=OwnerId);
       insert account;

       for(Integer i=0;i<numContacts;i++){
        Contact cont=new Contact(LastName='Test Contact'+i,AccountId=account.Id ,OwnerId=(Id)OwnerId);
        Contacts.add(cont);
       }

       if(Contacts.size()>0){
           insert Contacts;
       }

       return Contacts;
    }

    public static Account CreateAccountWithContacts(String OwnerId, Integer numContacts) {
        List<Contact> Contacts=new List<Contact>();

       Account account=new Account(Name='Test Account',OwnerId=OwnerId);
       insert account;

       for(Integer i=0;i<numContacts;i++){
        Contact cont=new Contact(LastName='Test Contact'+i,AccountId=account.Id ,OwnerId=(Id)OwnerId);
        Contacts.add(cont);
       }

       if(Contacts.size()>0){
           insert Contacts;
       }

       return account;
    }

    public static List<Contact> GetContactsWithBirthDate(Id accountId, Integer numContacts,Integer numYearsOld){
        List<Contact> Contacts=new List<Contact>();

        Date birthdate=numYearsOld > 0 ? Date.newInstance(Date.today().year()-numYearsOld, 1, 1):null;

        for(Integer i=0;i<numContacts;i++){
            Contacts.add(new Contact(LastName='Test Contact'+i,Birthdate=birthdate, AccountId=accountId));
        }
 
        return Contacts;
    }
}