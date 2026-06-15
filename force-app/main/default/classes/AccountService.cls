public with sharing class AccountService {

    public static void setDefaults(List<Account> accounts) {
        for (Account acc : accounts) {
            if (String.isBlank(acc.Type)) {
                acc.Type = 'Prospect';
            }
        }
    }

    public static void validateTypeChange(List<Account> newAccounts, Map<Id, Account> oldMap) {
        for (Account acc : newAccounts) {
            Account prior = oldMap.get(acc.Id);
            if (prior.Type == 'Customer' && acc.Type != 'Customer') {
                acc.addError('Customer account type cannot be downgraded.');
            }
        }
    }

    public static void handleAfterInsert(Map<Id, Account> newMap) {
        if (newMap.isEmpty()) return;
        System.enqueueJob(new AccountOnboardingQueueable(new List<Id>(newMap.keySet())));
    }

    public static void handleAfterUpdate(Map<Id, Account> newMap, Map<Id, Account> oldMap) {
        List<Id> changed = new List<Id>();
        for (Id accId : newMap.keySet()) {
            if (newMap.get(accId).BillingPostalCode != oldMap.get(accId).BillingPostalCode) {
                changed.add(accId);
            }
        }
        if (!changed.isEmpty()) {
            System.enqueueJob(new AccountOnboardingQueueable(changed));
        }
    }

    @InvocableMethod(label='Get Account Details' description='Returns Account record by Id for use in Flow')
    public static List<Result> getAccountDetails(List<Id> accountIds) {
        List<Account> records = [
            SELECT Id, Name, Type, Phone, Website,
                   BillingStreet, BillingCity, BillingState,
                   BillingPostalCode, BillingCountry
            FROM   Account
            WHERE  Id IN :accountIds
            WITH   USER_MODE
        ];
        List<Result> results = new List<Result>();
        for (Account acc : records) {
            Result r  = new Result();
            r.account = acc;
            results.add(r);
        }
        return results;
    }

    public class Result {
        @InvocableVariable(label='Account')
        public Account account;
    }
}
