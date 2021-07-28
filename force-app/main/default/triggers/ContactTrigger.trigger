trigger ContactTrigger on Contact (before update,after update,after insert, after delete) {
    new ContactTriggerHandler().run();
}