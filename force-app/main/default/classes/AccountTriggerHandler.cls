public with sharing class AccountTriggerHandler extends TriggerHandler {

    private List<Account>    newList;
    private List<Account>    oldList;
    private Map<Id, Account> newMap;
    private Map<Id, Account> oldMap;

    public AccountTriggerHandler() {
        newList = Trigger.new;
        oldList = Trigger.old;
        newMap  = (Map<Id, Account>) Trigger.newMap;
        oldMap  = (Map<Id, Account>) Trigger.oldMap;
    }

    protected override void beforeInsert() {
        AccountService.setDefaults(newList);
    }

    protected override void beforeUpdate() {
        AccountService.validateTypeChange(newList, oldMap);
    }

    protected override void afterInsert() {
        AccountService.handleAfterInsert(newMap);
    }

    protected override void afterUpdate() {
        AccountService.handleAfterUpdate(newMap, oldMap);
    }
}
