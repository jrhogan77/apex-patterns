public with sharing class AccountOnboardingQueueable implements Queueable, Database.AllowsCallouts {

    private List<Id> accountIds;

    public AccountOnboardingQueueable(List<Id> accountIds) {
        this.accountIds = accountIds;
    }

    public void execute(QueueableContext ctx) {
        List<Account> accounts = [
            SELECT Id, Name, Type, BillingStreet, BillingCity,
                   BillingState, BillingPostalCode, BillingCountry
            FROM   Account
            WHERE  Id IN :accountIds
            WITH   USER_MODE
        ];

        // Async processing runs outside the trigger transaction —
        // safe for callouts, bulk DML, and governor-limit-sensitive work.
        for (Account acc : accounts) {
            // Place domain logic or callout invocations here.
            System.debug(LoggingLevel.INFO, '[AccountOnboardingQueueable] Processing: ' + acc.Id);
        }
    }
}
