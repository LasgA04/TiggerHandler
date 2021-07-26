trigger ContactTrigger on Contact (before update) {
    new ContactTriggerHandler().run();
}