@IsTest
private class AccountServiceTest {

    @TestSetup
    static void makeData() {
        insert new List<Account>{
            new Account(Name = 'Test Customer', Type = 'Customer'),
            new Account(Name = 'Test Prospect')
        };
    }

    @IsTest
    static void setDefaults_assignsProspectType() {
        Account acc = new Account(Name = 'New');
        AccountService.setDefaults(new List<Account>{ acc });
        Assert.areEqual('Prospect', acc.Type, 'Missing type should default to Prospect');
    }

    @IsTest
    static void setDefaults_doesNotOverrideExistingType() {
        Account acc = new Account(Name = 'Existing', Type = 'Partner');
        AccountService.setDefaults(new List<Account>{ acc });
        Assert.areEqual('Partner', acc.Type, 'Existing type should not be overwritten');
    }

    @IsTest
    static void validateTypeChange_blocksCustomerDowngrade() {
        Account customer = [SELECT Id FROM Account WHERE Name = 'Test Customer' LIMIT 1];
        customer.Type    = 'Prospect';
        Boolean threw    = false;
        Test.startTest();
        try {
            update customer;
        } catch (DmlException e) {
            threw = true;
        }
        Test.stopTest();
        Assert.isTrue(threw, 'Downgrading a Customer type should raise a DML error');
    }

    @IsTest
    static void getAccountDetails_returnsMatchingRecord() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Customer' LIMIT 1];
        Test.startTest();
        List<AccountService.Result> results = AccountService.getAccountDetails(new List<Id>{ acc.Id });
        Test.stopTest();
        Assert.areEqual(1, results.size(), 'Expected exactly one result');
        Assert.areEqual('Test Customer', results[0].account.Name, 'Name should match inserted record');
    }

    @IsTest
    static void getAccountDetails_returnsEmptyForUnknownId() {
        Test.startTest();
        List<AccountService.Result> results = AccountService.getAccountDetails(new List<Id>{ '001000000000000AAA' });
        Test.stopTest();
        Assert.areEqual(0, results.size(), 'Unknown Id should return empty list');
    }
}
