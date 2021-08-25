global class HappyBirthDate implements Schedulable{
    global void execute(SchedulableContext ctx){
        List<Id> accountIds=new List<Id>();

        List<AggregateResult> Contacts=[SELECT AccountId FROM Contact WHERE 
        CALENDAR_MONTH(Birthdate) = :Date.today().month() GROUP BY AccountId];
        
        for (AggregateResult contact : Contacts) {
            accountIds.add((Id)contact.get('AccountId'));
        }
        
        if(accountIds.size()>0) 
        AccountClass.Update_ContactsRelatedInf(AccountIds); 
    }
}
