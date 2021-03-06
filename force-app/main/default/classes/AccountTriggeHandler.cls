public class AccountTriggeHandler extends TriggerHandler {
    private Map<Id,Account> newAcctMap;

    public AccountTriggeHandler() {
        this.newAcctMap=(Map<Id,Account>)Trigger.newMap;
        
    }
    public override void beforeUpdate(){
        /*Map<Id,Account> oldAcctMap=(Map<Id,Account>)Trigger.oldMap;

        List<Account> acctsWithOtherOwnerId=new List<Account>();

        for(Account account:(List<Account>)Trigger.new){
            
            if(account.OwnerId!=oldAcctMap.get(account.Id).OwnerId){
                acctsWithOtherOwnerId.add(account);
            }
        }
        //(List<Account>) accounts.where(acc=>{acc.OwnerId==''}).toList();

        if(acctsWithOtherOwnerId.size()>0){
            List<Contact> contacts=[SELECT Id, OwnerId,AccountId,Account.OwnerId FROM Contact Where AccountId IN :acctsWithOtherOwnerId ];

            for (Integer i=0;i< contacts.size();i++) {
                contacts[i].OwnerId=newAcctMap.get(contacts[i].AccountId).OwnerId;
            }
            update contacts;
        }*/
    }

    public override void afterUpdate(){

        List<Contact> contacts=[SELECT Id, OwnerId,AccountId,Account.OwnerId FROM Contact Where AccountId IN :Trigger.new];
        List<Contact> contWithOtherOwnerId=new List<Contact>();

        for (Contact contact : contacts) {
            if(contact.OwnerId!=contact.Account.OwnerId){
                contact.OwnerId=contact.Account.OwnerId;
                contWithOtherOwnerId.add(contact);
            }
        }

        if(contWithOtherOwnerId.size()>0)
            update contWithOtherOwnerId;
    }
}
