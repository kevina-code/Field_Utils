/**
 * Author       : Kevin Antonioli (braveitnow@pm.me)
 * Description  : Utility class for getting information about fields and field paths
 * Created      : 03.27.2023
 *
 * Revisions:
 * Date : Name : Notes
 */
public class FieldUtils {
  // map to cache describes in for better performance:
  private static Map<String, Schema.DescribeSObjectResult> objApiNameToDescribeMap = new Map<String, Schema.DescribeSObjectResult>();

  /**
   * @description: dynamically get the describe for a given object without using a Global Describe call
   * @param   objApiName  object api name to get the describe for
   * @return  describe    the Schema.DescribeSObjectResult for the given object
   */
  public static Schema.DescribeSObjectResult getDynamicDescribe(
    String objApiName
  ) {
    Schema.DescribeSObjectResult describe = objApiNameToDescribeMap.get(
        objApiName
      ) == null
      ? ((SObject) Type.forName('Schema', objApiName).newInstance())
          .getSObjectType()
          .getDescribe(SObjectDescribeOptions.DEFERRED)
      : objApiNameToDescribeMap.get(objApiName);
    objApiNameToDescribeMap.put(objApiName, describe);

    return describe;
  }

  /**
   * @description: given an SObject record, return a Schema.DescribeSObjectResult, without using a Global Describe call
   * @param   record    SObject record to get the describe for
   * @return  describe  the Schema.DescribeSObjectResult describe to return
   */
  public static Schema.DescribeSObjectResult getDynamicDescribe(
    SObject record
  ) {
    return getDynamicDescribe(String.valueOf(record.getSObjectType()));
  }

  /**
   * @description   Given an SObject name, return a Schema.SObjectField field map.
   * @param         objApiName   the name of the SObject in which to return a Schema.SObjectField field map for
   * @return        the Schema.SObjectField field map to return
   */
  public static Map<String, Schema.SObjectField> getFieldMap(
    String objApiName
  ) {
    return getDynamicDescribe(objApiName).fields.getMap();
  }

  /**
   * @description   Given an SObject record, return a Schema.SObjectField field map.
   * @param         record   SObject record to get the field map for
   * @return        the Schema.SObjectField field map to return
   */
  public static Map<String, Schema.SObjectField> getFieldMap(SObject record) {
    return getDynamicDescribe(record).fields.getMap();
  }

  /**
   * @description: Given a child object API name (ex: Contact) and a lookup field on that object
   *   (ex: AccountId) get the parent object API name for the lookup (ex: 'Account')
   * @param   childObjApiName     API name of the child object (ex: Contact)
   * @param   lookupFieldApiName  API name of the lookup field on the child object (ex: AccountId)
   * @return  parent object API name (ex: Account)
   */
  public static String getParentObjApiNameFromLookup(
    String childObjApiName,
    String lookupFieldApiName
  ) {
    return getFieldMap(childObjApiName)
        .get(lookupFieldApiName)
        .getDescribe()
        .getReferenceTo()[0]
      .getDescribe()
      .getName();
  }

  /**
   * @description: get picklist lables for one of an object's picklist fields
   * @param   objApiName      object api name
   * @param   fieldApiName    picklist field api name
   * @return  picklistLabels  picklist labels
   */
  public static List<String> getPicklistLabels(
    String objApiName,
    String fieldApiName
  ) {
    List<String> picklistLabels = new List<String>();
    Schema.DescribeFieldResult fieldResult = getFieldMap(objApiName)
      .get(fieldApiName)
      .getDescribe();
    for (Schema.PicklistEntry plEntry : fieldResult.getPicklistValues()) {
      picklistLabels.add(plEntry.getLabel());
    }
    return picklistLabels;
  }

  /**
   * @description: get picklist values for one of an object's picklist fields
   * @param   objApiName      object api name
   * @param   fieldApiName    picklist field api name
   * @return  picklistValues  picklist values
   */
  public static List<String> getPicklistValues(
    String objApiName,
    String fieldApiName
  ) {
    List<String> picklistValues = new List<String>();
    Schema.DescribeFieldResult fieldResult = getFieldMap(objApiName)
      .get(fieldApiName)
      .getDescribe();
    for (Schema.PicklistEntry plEntry : fieldResult.getPicklistValues()) {
      picklistValues.add(plEntry.getValue());
    }
    return picklistValues;
  }

  /**
   * @description -> Method to get properties of a field set.
   * @usage example:
   *  List<Schema.FieldSetMember> fieldSetMemberList =  readFieldSet('Account_Field_Set1','Account');
   *  for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {
   *      system.debug('API Name ====>' + fieldSetMemberObj.getFieldPath()); //api name
   *      system.debug('Label ====>' + fieldSetMemberObj.getLabel()); //label
   *      system.debug('Required ====>' + fieldSetMemberObj.getRequired()); //required
   *      system.debug('DbRequired ====>' + fieldSetMemberObj.getDbRequired()); //DbRequired
   *      system.debug('Type ====>' + fieldSetMemberObj.getType()); //type - STRING,PICKLIST
   *  }
   * @param   fieldSetName  name of field set you wish to get the properties (ex: fields) for
   * @param   objApiName    api name of object that field set resides on
   * @return  List<Schema.FieldSetMember -> field set properties to return.
   */
  public static List<Schema.FieldSetMember> readFieldSet(
    String fieldSetName,
    String objApiName
  ) {
    return getDynamicDescribe(objApiName)
      .FieldSets.getMap()
      .get(fieldSetName)
      .getFields();
  }

  /**
   * @description: get list of field API names to query, given a Schema.FieldSetMember list:
   * @param   fieldSetName  name of field set you wish to get the properties (ex: fields) for
   * @param   objApiName    api name of object that field set resides on
   * @return  objApiName a list of field API names parsed from the field set parameter
   */
  public static List<String> getFieldSetFieldAPINames(
    String fieldSetName,
    String objApiName
  ) {
    return getFieldSetFieldAPINames(readFieldSet(fieldSetName, objApiName));
  }

  /**
   * @description: get list of field API names to query, given a Schema.FieldSetMember list:
   * @param   fieldSetMemberList    a Schema.FieldSetMember list in which to parse the field API names from
   * @return  fieldSetFieldAPINames a list of field API names parsed from the field set parameter
   */
  public static List<String> getFieldSetFieldAPINames(
    List<Schema.FieldSetMember> fieldSetMemberList
  ) {
    Set<String> fieldSetFieldAPINamesSet = new Set<String>();
    for (Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {
      fieldSetFieldAPINamesSet.add(fieldSetMemberObj.getFieldPath());
    }
    List<String> fieldSetFieldAPINames = new List<String>(
      fieldSetFieldAPINamesSet
    );
    return fieldSetFieldAPINames;
  }

  /**
   * @description: given an object api name and a field Api Name, determine if the field is createable
   * @param   objApiName      object api name (ex: 'Account')
   * @param   fieldApiName    field as string to check if it is createable (ex: 'Industry')
   * @return  Boolean         whether or not the field is createable
   */
  public static Boolean isFieldCreateable(
    String objApiName,
    String fieldApiName
  ) {
    return getFieldMap(objApiName)
      .get(fieldApiName)
      .getDescribe()
      .isCreateable();
  }

  /**
   * @description: given an object api name and a field Api Name, determine if the field is accessible
   * @param   objApiName      object api name (ex: 'Account')
   * @param   fieldApiName    field as string to check if it is accessible (ex: 'Industry')
   * @return  Boolean         whether or not the field is accessible
   */
  public static Boolean isFieldAccessible(
    String objApiName,
    String fieldApiName
  ) {
    return getFieldMap(objApiName)
      .get(fieldApiName)
      .getDescribe()
      .isAccessible();
  }

  /**
   * @description: given an object api name and a field Api Name, determine if the field is updateable
   * @param   objApiName      object api name (ex: 'Account')
   * @param   fieldApiName    field as string to check if it is updateable (ex: 'Industry')
   * @return  Boolean         whether or not the field is updateable
   */
  public static Boolean isFieldUpdateable(
    String objApiName,
    String fieldApiName
  ) {
    return getFieldMap(objApiName)
      .get(fieldApiName)
      .getDescribe()
      .isUpdateable();
  }

  /**
   * @description: given an object api name and a field Api Name, determine if the field is an external id field
   * @param   objApiName      object api name (ex: 'Account')
   * @param   fieldApiName    field as string to check if it is an external Id field
   * @return  Boolean         whether or not the field is an external Id field
   */
  public static Boolean isFieldExternalId(
    String objApiName,
    String fieldApiName
  ) {
    return getFieldMap(objApiName)
      .get(fieldApiName)
      .getDescribe()
      .isExternalId();
  }

  /**
   * @description: given an object api name and a field Api Name, determine if the field is autoNumber
   * @param   objApiName      object api name (ex: 'Account')
   * @param   fieldApiName    field as string to check if it is autoNumber
   * @return  Boolean         whether or not the field is autoNumber
   */
  public static Boolean isFieldAutoNumber(
    String objApiName,
    String fieldApiName
  ) {
    return getFieldMap(objApiName)
      .get(fieldApiName)
      .getDescribe()
      .isAutoNumber();
  }

  /**
   * @description: given an object api name and a field Api Name, determine if the field is calculated
   * @param   objApiName      object api name (ex: 'Account')
   * @param   fieldApiName    field as string to check if it is calculated
   * @return  Boolean         whether or not the field is calculated
   */
  public static Boolean isFieldCalculated(
    String objApiName,
    String fieldApiName
  ) {
    return getFieldMap(objApiName)
      .get(fieldApiName)
      .getDescribe()
      .isCalculated();
  }

  /**
   * @description: given an object api name and a field Api Name, determine the field type
   * @param   objApiName      object api name (ex: 'Account')
   * @param   fieldApiName    field as string to check if it is updateable (ex: 'Industry')
   * @return  String          the field type (ex: 'PICKLIST')
   */
  public static String getFieldType(String objApiName, String fieldApiName) {
    return String.valueOf(
      getFieldMap(objApiName).get(fieldApiName).getDescribe().getType()
    );
  }

  /**
   * @description   Get all fields for an sobject as a list - helpful for dynamic SOQL
   * @param         objApiName  : the object name to get the fields for
   * @return        allFields    : of all fields for the object;
   */
  public static List<String> getAllFieldsForSobj(String objApiName) {
    List<String> allFields = new List<String>(getFieldMap(objApiName).keySet());
    return allFields;
  }

  /**
   * @description   Get all fields for an sobject as a comma-delimited string - helpful for dynamic SOQL
   * @param         objApiName  : the object name to get the fields for
   * @return        String       : comma delimited string of all fields for the object delimited by commas
   */
  public static String getAllFieldsForSObjAsStr(String objApiName) {
    return String.join(getAllFieldsForSobj(objApiName), ', ');
  }

  /**
   * Method to return list of creatable fields for a given object.
   * @param String objApiName
   * @return List of creatable fields for a given SObject.
   */
  public static List<String> getCreatableFields(String objApiName) {
    List<String> creatableFields = new List<String>();
    for (Schema.SObjectField field : getFieldMap(objApiName).values()) {
      // field is updateable
      Schema.DescribeFieldResult fieldDescribe = field.getDescribe(); // describe each field (fd)
      if (fieldDescribe.isCreateable()) {
        creatableFields.add(fieldDescribe.getName());
      }
    }

    return creatableFields;
  }

  /**
   * Method to return list of accessible fields for a given object.
   * @param String objApiName
   * @return List of accessible fields for a given SObject.
   */
  public static List<String> getAccessibleFields(String objApiName) {
    List<String> accessibleFields = new List<String>();
    for (Schema.SObjectField field : getFieldMap(objApiName).values()) {
      Schema.DescribeFieldResult fieldDescribe = field.getDescribe(); // describe each field (fd)
      if (fieldDescribe.isAccessible()) {
        accessibleFields.add(fieldDescribe.getName());
      }
    }
    return accessibleFields;
  }

  /**
   * @description: get all updateable fields for an sobject as a list
   * @param  objApiName        API name of SObject to get updateable fields for
   * @return updateableFields   List of updateable fields for a given SObject.
   */
  public static List<String> getUpdateableFields(String objApiName) {
    List<String> updateableFields = new List<String>();
    for (Schema.SObjectField field : getFieldMap(objApiName).values()) {
      Schema.DescribeFieldResult fieldDescribe = field.getDescribe(); // describe each field (fd)
      if (fieldDescribe.isUpdateable()) {
        updateableFields.add(fieldDescribe.getName());
      }
    }
    return updateableFields;
  }

  /**
   * @description   Get all creatable fields for an sobject as a comma-delimited string - helpful for dynamic SOQL
   * @param         objApiName  : the object name to get the fields for
   * @return        String       : comma delimited string of all creatable fields for the object delimited by commas
   */
  public static String getAllCreatableFieldsAsStr(String objApiName) {
    return String.join(getCreatableFields(objApiName), ', ');
  }

  /**
   * @description   get all getAccessibleFields fields for an sobject as a comma-delimited string - helpful for dynamic SOQL
   * @param         objApiName  : the object name to get the fields for
   * @return        String       : comma delimited string of all getAccessibleFields fields for the object delimited by commas
   */
  public static String getAllAccessibleFieldsAsStr(String objApiName) {
    return String.join(getAccessibleFields(objApiName), ', ');
  }

  /**
   * @description   get all updateable fields for an sobject as a comma-delimited string - helpful for dynamic SOQL
   * @param         objApiName  : the object name to get the fields for
   * @return        String       : comma delimited string of all updateable fields for the object delimited by commas
   */
  public static String getAllUpdateableFieldsAsStr(String objApiName) {
    return String.join(getUpdateableFields(objApiName), ', ');
  }

  /**
   * @description   Get all fields for an sobject as a list, except those in the blacklist
   * @param         objApiName  : the object name to get the fields for
   * @param         blackList    : a list of fields to exclude
   * @return        List<String> : a list of all fields (except blacklist) for an SObject
   */
  public static List<String> getAllFieldsExceptBlacklist(
    String objApiName,
    List<String> blackList
  ) {
    Set<string> fields = new Set<String>(getAllFieldsForSobj(objApiName));
    for (String blackListedField : blackList) {
      if (fields.contains(blackListedField)) {
        fields.remove(blackListedField);
      } else if (fields.contains(blackListedField.toLowerCase())) {
        fields.remove(blackListedField.toLowerCase());
      }
    }
    return new List<String>(fields);
  }

  /**
   * @description   Get all fields (except blacklist) for an sobject as a comma-delimited string - helpful for dynamic SOQL
   * @param         objApiName  : the SOBbject name to get the fields for
   * @param         blackList    : a list of fields to exclude
   * @return        String       : comma delimited string of all fields for the SObject (except blacklist)
   */
  public static String getAllFieldsExceptBlacklistAsStr(
    String objApiName,
    List<String> blackList
  ) {
    return String.join(
      getAllFieldsExceptBlacklist(objApiName, blackList),
      ', '
    );
  }

  /**
   * @description, for a given record and field path, parse the last sub object from the path
   *  For example: for an Contact record and Account.Owner.Name path, parse the User (Owner) record from the path
   * @param   record    record to parse last sub object from
   * @param   fieldpath the field path to use in the parsing (ex: Account.Owner.Name)
   */
  public static SObject parseLastSubObjectFromPath(
    SObject record,
    String fieldPath
  ) {
    SObject tempObj = record;
    String objsOnly = fieldPath.substringBeforeLast('.');
    for (String obj : objsOnly.split('\\.')) {
      try {
        tempObj = (SObject) tempObj.getSobject(obj);
      } catch (Exception e) {
        return null;
      }
    }
    return tempObj;
  }

  /**
   * @description:  method to parse field values from field references, even if in dot notation (ex: Account.Owner.Name)
   * @usage:        if I have a queried Task record where I queried Account.Owner.Name from the Task,
   *  if I pass in the Task record and 'Contract.Account.Name', this method will return the value stored in the 'Name'.
   *  Useful for when SObjectRecord.get(field) falls short since it can't do SObjectRecord.get(relationshipField.Field)
   * @param         record          : the record in which to parse the field reference from
   * @param         fieldPath       : the field reference in which to parse. Ex: 'Account.Owner.Name' will get the Name field value parsed
   * @return        fieldVal        : the String, Integer, Boolean, etc parsed value.
   */
  public static Object parseValueFromFieldPath(
    SObject record,
    String fieldPath
  ) {
    SObject tempObj = record;
    Object fieldVal;
    try {
      // If provided field is using dot notation, get nested object and field
      if (!fieldPath.contains('.')) {
        return record.get(fieldPath);
      } else {
        // ex: Account.Owner.Name, loop through Account.Owner
        for (
          String pathSegment : fieldPath.substringBeforeLast('.').split('\\.')
        ) {
          // dynamically accommodate for when path contains multiple nested SObjects (ex: Account.Owner.Name)
          tempObj = (SObject) tempObj.getSobject(pathSegment);
        }
        String fieldApiName = fieldPath.substringAfterLast('.');
        fieldVal = tempObj.get(fieldApiName);
      }
    } catch (Exception e) {
      return null;
    }

    return fieldVal;
  }

  /**
   * @description method to get a RecordTypeId of an Object from an Object Api Name and a RecordType Developer Name
   * @param   objApiName Object Api Name
   * @param   rtDevName RecordType Developer Name
   * @return  Id recordTypeId
   */
  public static Id getObjRecordTypeIdFromDeveloperName(
    String objApiName,
    String rtDevName
  ) {
    return getDynamicDescribe(objApiName)
      .getRecordTypeInfosByDeveloperName()
      .get(rtDevName)
      .getRecordTypeId();
  }

  /**
   * @description method to get a RecordTypeId of an Object from an Object Api Name and a RecordType Name
   * @param   objApiName Object Api Name
   * @param   rtName RecordType Name
   * @return  Id Record Type Id
   */
  public static Id getObjRecordTypeIdFromName(
    String objApiName,
    String rtName
  ) {
    return getDynamicDescribe(objApiName)
      .getRecordTypeInfosByName()
      .get(rtName)
      .getRecordTypeId();
  }

  /**
   * @description method to get a Record Type Developer Name of an Object from an Object Api Name and a RecordType Id
   * @param   objApiName Object Api Name
   * @param   rtId Record Type Id
   * @return  String Record Type Dev Name
   */
  public static String getRecordTypeDevNameFromRecordTypeId(
    String objApiName,
    Id rtId
  ) {
    return getDynamicDescribe(objApiName)
      .getRecordTypeInfosById()
      .get(rtId)
      .getDeveloperName();
  }

  /**
   * @description method to get a Record Type Name of an Object from an Object Api Name and a RecordType Id
   * @param   objApiName Object Api Name
   * @param   getName Record Type Id
   * @return  String Record Type Name
   */
  public static String getRecordTypeNameFromRecordTypeId(
    String objApiName,
    Id rtId
  ) {
    return getDynamicDescribe(objApiName)
      .getRecordTypeInfosById()
      .get(rtId)
      .getName();
  }

  /**
   * @description: Determines whether the specified field value has changed from the old object to the new object.
   * @param   oldObject   the old object, typically from Trigger.oldMap
   * @param   newObject   the new object, typically from Trigger.new
   * @param   field       the field which should be checked for a value change
   * @return  Boolean     if the value has changed or not
   */
  public static Boolean fieldValueChanged(
    SObject oldObject,
    SObject newObject,
    Schema.SObjectField field
  ) {
    Object oldValue = oldObject.get(field);
    Object newValue = newObject.get(field);
    return oldValue != newValue;
  }

  /**
   * @description: Determines whether the specified field value has been set from null to non-null value
   * on the new object.
   * @param   oldObject the old object, typically from Trigger.oldMap
   * @param   newObject the new object, typically from Trigger.new
   * @param   field     the field which should be checked as being set
   * @return  Boolean   if the value has been set or not
   */
  public static Boolean fieldValueSet(
    SObject oldObject,
    SObject newObject,
    Schema.SObjectField field
  ) {
    Object oldValue = oldObject.get(field);
    Object newValue = newObject.get(field);
    return (oldValue == null) && (newValue != null);
  }
}
