# Field_Utils

Helpful methods to get information about fields and objects, including schema information.

Examples:

Get the describe for an object without ever running an expensive Schema.globalDescribe() call
```java
Schema.DescribeSObjectResult accountDescribe = FieldUtils.getDynamicDescribe('Account'); // string param version

Schema.DescribeSObjectResult accountDescribe = FieldUtils.getDynamicDescribe(accountRecord); // SObject param version
```

Get the field map for an object without ever running an expensive Schema.globalDescribe() call
```java
Map<String, Schema.SObjectField> accountFieldMap = FieldUtils.getFieldMap('Account'); // string param version

Map<String, Schema.SObjectField> accountFieldMap = FieldUtils.getFieldMap(accountRecord); // SObject param version
```

Get the properties for a particular field set:
```java
List<Schema.FieldSetMember> accountFieldSet = FieldUtils.readFieldSet( 'My_Field_Set',  'Account');
```

Get just the api names of the fields belonging to a particular field set:
```java
List<Schema.FieldSetMember> acctFieldSetApiNames = FieldUtils.getFieldSetFieldAPINames( 'My_Field_Set',  'Account');
```

Determine if SObjectField is createable:
```java
Boolean isCreateable = FieldUtils.isFieldCreateable(Account.Industry);
```

Determine if SObjectField is accessible:
```java
Boolean isAccessible = FieldUtils.isFieldAccessible(Account.Industry);
```

Determine if SObjectField is updateable:
```java
Boolean isUpdateable = FieldUtils.isFieldUpdateable(Account.Industry);
```

Get a list of all field api names for a given object:
```java
List<String> acctFields = FieldUtils.getAllFieldsForSobj('Account');
```

Get a list of all createable fields for a given object:
```java
List<String> acctCreateableFields = FieldUtils.getCreateableFields('Account');
```

Get a list of all accessible fields for a given object:
```java
List<String> acctAccessibleFields = FieldUtils.getAccessibleFields('Account');
```

Get a list of all updateable fields for a given object:
```java
List<String> acctUpdateableFields = FieldUtils.getUpdateable('Account');
```

Get a list of all fields (except within a specified blacklist) for a given object:
```java
List<String> acctFieldsExceptBlacklist = FieldUtils.getAllFieldsExceptBlacklist('Account', new List<String>{'PersonPronouns', 'PersonGenderIdentity'});
```

Parse last object from field path:
```java
// sample data:
Contact contact = [SELECT Id, Name, Account.Name FROM Contact LIMIT 1];

// dynamically get the last object within a multi-level path (in this case, User/Owner):
SObject deepestRecordFromPath = ApexUtils.parseLastSubObjectFromPath(contact, 'Account.Owner.Name');
```

Parse value from field path:
```java
// sample data:
Contact contact = [SELECT Id, Name, Account.Name FROM Contact LIMIT 1];

// dynamically get the field value as an Object for a multi-level path:
Object fieldValueObj = ApexUtils.parseValueFromFieldPath(contact, 'Account.Owner.Name');
```
