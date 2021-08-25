public with sharing class AccountClass {
    public AccountClass() {

    }

    public static void Update_ContactsRelatedInf (List<Id> AccountIds){
        Date over18years=Date.newInstance(Date.today().Year()-18, 12, 31);
        Map<Id,Account> accountsToUpdate=new Map<Id,Account>();
        Integer contactYears=0;

        List<AggregateResult> ContactsInfoByAccount=[SELECT AccountId, MAX(BirthDate) Younger, Count(Id) Total FROM  
        contact WHERE AccountId IN :AccountIds GROUP BY  AccountId];
        List<AggregateResult> Contacts18ByAccount=[SELECT AccountId, MIN(BirthDate) Older, Count(Id) Contacts FROM  
        contact WHERE AccountId IN :AccountIds AND BirthDate < :over18years GROUP BY  AccountId];

        for(AggregateResult result:Contacts18ByAccount){
            contactYears=((Date)result.get('Older')).daysBetween(Date.today())/365;
            
            accountsToUpdate.put((Id)result.get('AccountId'),
                                new Account(Id=(Id)result.get('AccountId'),
                                            Number_Of_Contacts_Over_18__c=(Integer)result.get('Contacts'),
                                            Oldest_Contact__c=contactYears));
        }

        for(AggregateResult result:ContactsInfoByAccount){
            contactYears=((Date)result.get('Younger')).daysBetween(Date.today())/365;
            Decimal ContactsOver18=accountsToUpdate.get((Id)result.get('AccountId')).Number_Of_Contacts_Over_18__c;
            accountsToUpdate.get((Id)result.get('AccountId')).Youngest_Contact__c=contactYears;
            accountsToUpdate.get((Id)result.get('AccountId')).Percentage_Of_Contacts_Over_18__c=ContactsOver18/(Integer)result.get('Total');
        }
        
        update (List<Account>)accountsToUpdate.values();
    }

}
