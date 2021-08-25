@isTest
public with sharing class HappyBirthDateTest {
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    public static ATK.SaveResult result;
    static{
        Date current=Date.today();
        Date c24years=Date.newInstance(current.year()-24,1,1);
        Date c18years=Date.newInstance(current.year()-18,current.month(),current.day());

        TriggerHandler.bypass('ContactTriggerHandler');

         result =  ATK.prepare(Account.SObjectType, 3)
                .field(Account.Name).index('Test Account-{0000}')
                .withChildren(Contact.SObjectType, Contact.AccountId, 30)
                    .field(Contact.LastName).index('Name-{0000}')
                    .field(Contact.BirthDate).repeat(c24years,c18years)
                    .save(true);

        TriggerHandler.clearBypass('ContactTriggerHandler');
    }
    
    @isTest
    static void HappyBirthDateTest() {
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('ScheduledApexTest',
            CRON_EXP,
            new HappyBirthDate());

        List<Account> accounts = [SELECT Id, Number_Of_Contacts_Over_18__c  FROM Account WHERE 
        Id IN :(List<Account>)result.get(Account.SObjectType)];

        for(Account account:accounts){
            System.assertEquals(0, account.Number_Of_Contacts_Over_18__c, '');
        }
        Test.stopTest();

        accounts = [SELECT Id, Number_Of_Contacts_Over_18__c  FROM Account WHERE 
        Id IN :(List<Account>)result.get(Account.SObjectType)];

        for(Account account:accounts){
            System.assertEquals(10, account.Number_Of_Contacts_Over_18__c, '');
        }
    }
}
