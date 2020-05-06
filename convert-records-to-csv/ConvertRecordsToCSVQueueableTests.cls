@isTest
private class ConvertRecordsToCSVQueueableTests {
    @isTest
    private static void testGenerateCSVContent() {
        List <SObject> objects = new List<SObject>{new Account(Name='Test1', AccountNumber='3445556676'), new Account(Name='Test2', BillingCity='Richmond'), new Account(Name='Test3')};
        Test.startTest();
        String fullCSV = ConvertRecordsToCSVQueueable.generateCSVContent(objects, null, ConvertRecordsToCSVQueueable.CSVParseType.ALL, false);
        Test.stopTest();
        List<String> rows = fullCSV.split('\n');
        System.assertEquals(4, rows.size());

        System.assertEquals(3, rows[0].split(',').size());
        System.assertEquals('Name,AccountNumber,BillingCity', rows[0]);
        System.assertEquals('Test1,3445556676', rows[1]);
        System.assertEquals('Test2,null,Richmond', rows[2]);
        System.assertEquals('Test3,null,null', rows[3]);
    }

    @isTest
    private static void testGenerateCSVContentRelatedFields() {
        Account account1 = new Account(Name='Test1', AccountNumber='3445556676');
        insert account1;

        Contact contact1 = new Contact(LastName='Test1');
        Contact contact2 = new Contact(LastName='Test2', Email='abc@gmail.com');
        Contact contact3 = new Contact(LastName='Test3', Email='abc@gmail.com', FirstName='Jonny');
        insert new List<Contact>{contact1, contact2, contact3};

        contact2.Related_Contact__c = contact1.Id;
        update contact2;

        List<Contact> contacts = [Select FirstName, LastName, Email, Related_Contact__r.LastName from Contact];

        Test.startTest();
        String fullCSV = ConvertRecordsToCSVQueueable.generateCSVContent(contacts, new List<String>{'LastName','Email','Related_Contact__r.LastName'}, ConvertRecordsToCSVQueueable.CSVParseType.ALL, false);
        Test.stopTest();
        List<String> rows = fullCSV.split('\n');
        System.assertEquals(4, rows.size());

        System.assertEquals(3, rows[0].split(',').size(), 'Full row text: ' + rows[0]);
        System.assertEquals('LastName,Email,Related_Contact__r.LastName', rows[0]);

        System.assertEquals('Test1,null,null', rows[1]);
        System.assertEquals('Test2,abc@gmail.com,Test1', rows[2]);
        System.assertEquals('Test3,abc@gmail.com,null', rows[3]);
    }

    @isTest
    private static void testGenerateCSVContentAggregateResult() {
        Account account1 = new Account(Name='Test1', AccountNumber='3445556676');
        insert account1;

        Contact contact1 = new Contact(LastName='Test', FirstName='Sally');
        Contact contact2 = new Contact(LastName='Test', FirstName='Mary', Email='abc@gmail.com');
        Contact contact3 = new Contact(LastName='Test2', Email='abc@gmail.com', FirstName='Jonny');
        insert new List<Contact>{contact1, contact2, contact3};
        update contact2;

        List<AggregateResult> contacts = [Select LastName from Contact GROUP BY LastName];
        
        Test.startTest();
        String fullCSV = ConvertRecordsToCSVQueueable.generateCSVContent(contacts, new List<String>{'name'}, ConvertRecordsToCSVQueueable.CSVParseType.ALL, false);
        String unnamed = ConvertRecordsToCSVQueueable.generateCSVContent(contacts, null, ConvertRecordsToCSVQueueable.CSVParseType.ALL, false);
        Test.stopTest();
        
        List<String> rows = fullCSV.split('\n');
       	System.assertEquals(3, rows.size(), 'Full text: ' + fullCSV);
        System.assertEquals('name', rows[0]);
        System.assertEquals('Test', rows[1]);
        System.assertEquals('Test2', rows[2]);
          
        List<String> rows2 = unnamed.split('\n');
       	System.assertEquals(3, rows2.size(), 'Full text: ' + unnamed);
        System.assertEquals('LastName', rows[0]);
        System.assertEquals('Test', rows2[1]);
        System.assertEquals('Test2', rows2[2]);
    }

    @isTest
    private static void testGenerateDocument() {
        String csvContent = 'this, this, this, this, this \n';

        Account account = new Account(Name='Test');
        insert account;

        Test.startTest();
        ConvertRecordsToCSVQueueable.Outputs result = ConvertRecordsToCSVQueueable.generateDocument(new List<String>{account.Id}, 'MyDoc', 'V', 'ALlUsers', csvContent);
        Test.stopTest();

        System.assert(result.contentDocumentId != null);
        System.assert(result.contentVersionId != null);
        System.assert(result.contentDocumentLinks.size() == 1);
        System.assert(result.contentDocumentLinks[0] != null);
    }

    @isTest
    private static void testGenearteDocumentNoLinks() {
        String csvContent = 'this, this, this, this, this \n';
    
        Test.startTest();
        ConvertRecordsToCSVQueueable.Outputs result = ConvertRecordsToCSVQueueable.generateDocument(null, 'MyDoc', 'V', 'AllUsers', csvContent);
        Test.stopTest();

        System.assert(result.contentDocumentId != null);
        System.assert(result.contentVersionId != null);
        System.assert(result.contentDocumentLinks.size() == 0);
    }
}