public class ContactTriggerHandler extends TriggerHandler {
    /*with sharing*/
    private Map<Id,Contact> newContMap;
    public ContactTriggerHandler() {
        this.newContMap=(Map<Id,Contact>)Trigger.newMap;
    }
    public override void beforeUpdate(){
       List<Contact> contacts=[SELECT Id,OwnerId,Account.OwnerId FROM Contact WHERE Id IN : Trigger.new];
       for(Contact cont:contacts){
           if(newContMap.get(cont.Id).OwnerId!=cont.Account.OwnerId){
               //cont.OwnerId=cont.Account.OwnerId;
              // cont.addError('The owner Id it is different');
               newContMap.get(cont.Id).addError('The owner Id it is different');
               System.debug('The owner Id it is different');
           }
       }

    }
}
