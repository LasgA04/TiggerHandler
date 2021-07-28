public with sharing class AccountClass {
    public AccountClass() {

    }
    @InvocableMethod(label='Update Contacts Related Info' description='Update the contact related info in the Account Object' category='Account')
    public static void UpdateContactsRelatedInfo(){

        //AccountIds=AccountIds.size()>0 ? AccountIds : new List<Id>();
        List<Id> accountIds=new List<Id>();

        List<Contact> Contacts=[SELECT Id, Birthdate,
        Account.Number_Of_Contacts_Over_18__c, Account.Percentage_Of_Contacts_Over_18__c, 
        Account.Oldest_Contact__c, Account.Youngest_Contact__c FROM Contact WHERE CALENDAR_MONTH(Birthdate) = :Date.today().month() and DAY_IN_MONTH(Birthdate) =: Date.today().day() ];
        
        for (Contact contact : Contacts) {
            if(!accountIds.contains(contact.AccountId))
                accountIds.add(contact.AccountId);
        }
        
        if(accountIds.size()>0) 
        Update_ContactsRelatedInf(AccountIds); 
    }

    public static void Update_ContactsRelatedInf (List<Id> AccountIds){
        List<Account> accounts=[SELECT Id,Number_Of_Contacts_Over_18__c, Percentage_Of_Contacts_Over_18__c, 
        Oldest_Contact__c, Youngest_Contact__c, 
        (SELECT Id, Birthdate FROM Contacts ORDER By Birthdate)  FROM Account WHERE Id In :AccountIds];

        List<Account> updatedAccounts=new List<Account>();
        
        Integer currentYear=Date.Today().year();
        Integer contactYears=0;
        Double totalOfContacts=0;
        Double contactOver18Years=0;
        Integer Youngest_Contact=0;
        Integer Oldest_Contact=0;
        
        for (Integer i=0;i<accounts.size();i++) {

            totalOfContacts=accounts[i].Contacts.size();
            contactOver18Years=0;
            Oldest_Contact=0;
            Youngest_Contact=0;

            for(Contact contact: accounts[i].Contacts){
                contactYears=0;
                if(contact.Birthdate!=null){
                    contactYears=(contact.Birthdate.daysBetween(Date.today())/365);
                    Oldest_Contact=(Oldest_Contact==0 ||Oldest_Contact<contactYears) ? contactYears:Oldest_Contact  ;
                    Youngest_Contact=(Youngest_Contact==0 || Youngest_Contact>contactYears) ? contactYears:Youngest_Contact ;
                }
                if(contactYears >= 18 ){
                    contactOver18Years++;
                }
            }
            accounts[i].Oldest_Contact__c= Oldest_Contact;
            accounts[i].Youngest_Contact__c=Youngest_Contact;
            accounts[i].Number_Of_Contacts_Over_18__c=contactOver18Years;
            accounts[i].Percentage_Of_Contacts_Over_18__c=totalOfContacts==0 ? 0 :(contactOver18Years / totalOfContacts)*100;

            if(totalOfContacts>0){
                updatedAccounts.add(accounts[i]);
            }
            

        }

        if(updatedAccounts.size()>0)
            update updatedAccounts;
    }

}
