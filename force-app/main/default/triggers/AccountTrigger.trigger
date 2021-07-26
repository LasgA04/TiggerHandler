trigger AccountTrigger on Account (before update,after update) {
    new AccountTriggeHandler().run();
}