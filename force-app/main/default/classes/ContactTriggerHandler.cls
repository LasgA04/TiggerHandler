public class ContactTriggerHandler extends TriggerHandler {
    /*with sharing*/
    private Map<Id,Contact> newContMap;

    public ContactTriggerHandler() {
        this.newContMap=(Map<Id,Contact>)Trigger.newMap;
    }

    public override void beforeUpdate(){
        List<Contact> contacts=[SELECT Id,OwnerId,Account.OwnerId,AccountId,Birthdate FROM Contact WHERE Id IN : Trigger.newMap.keySet()];

        for(Contact contact:contacts){
            if(newContMap.get(contact.Id).OwnerId!=contact.Account.OwnerId){
                //cont.OwnerId=cont.Account.OwnerId;
                // cont.addError('The owner Id it is different');
                newContMap.get(contact.Id).addError('The owner Id it is different');
                //System.debug('The owner Id it is different');
            }
        }
    }

    public override void afterUpdate(){

        List<Id> AccountIds=new List<Id>();

        for(Contact contact:(List<Contact>) Trigger.New){
            if(((Map<Id,Contact>)Trigger.oldMap).get(contact.Id).Birthdate!=contact.Birthdate)
                 AccountIds.add(contact.AccountId);
        }
 
        AccountClass.Update_ContactsRelatedInf(AccountIds);
    }

    public override void afterInsert(){
        List<Id> AccountIds=new List<Id>();

        for(Contact contact:(List<Contact>) Trigger.New){
            if(Contact.Birthdate!=null)
                AccountIds.add(contact.AccountId);
        }
 
        AccountClass.Update_ContactsRelatedInf(AccountIds);
    }

    public override void afterDelete(){
        if(trigger.isafter && trigger.isdelete) // Using context variable.
        {
            List<Id> AccountIds=new List<Id>();
            System.debug(' Deleted Records from contacts '+Trigger.oldMap.keySet());

            for(Contact contact:(List<Contact>) Trigger.old){
            AccountIds.add(((Contact)contact).AccountId);
            }
            AccountClass.Update_ContactsRelatedInf(AccountIds);
        }
    }
}
