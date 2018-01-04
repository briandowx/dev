/***
http://salesforce.stackexchange.com/questions/112654/how-to-work-around-the-100-callout-limitation/112660
http://salesforce.stackexchange.com/questions/137443/what-is-the-iterable-interface-used-for-in-batch-apex
https://help.salesforce.com/articleView?id=000192834&language=en_US&type=1
https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_dynamic_dml.htm#sObjectCreationSectionTitle
https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_iterable.htm
https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_batch_interface.htm
https://developer.salesforce.com/blogs/engineering/2015/11/avoiding-the-concurrent-request-limit-via-synchronous-callout-optimization.html
Dynamic SOQL in Batch - https://developer.salesforce.com/forums/?id=906F0000000AfrRIAS
Getting Iterator to work with Batchable - https://developer.salesforce.com/forums/?id=906F0000000942sIAA
Batchable - https://developer.salesforce.com/forums/?id=906F0000000kIrAIAU
**/
//global class GetLatLongBatch implements Database.Batchable<sObject>, Iterable<sObject>, Iterator<sObject>, Schedulable {
global class GetLatLongBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful, Schedulable {
	
	global Iterable<sObject> start(Database.BatchableContext info) {		
		return new CustomIterableWrapper();
	}

	global void execute(Database.BatchableContext info, List<sObject> scope) {		
		List<sObject> sobjToUpdate = new List<sObject>();
		GeolocationController.initGeoSettings();
		sobjToUpdate.addAll(GeolocationController.returnLatLong(scope));
		
		if (!sobjToUpdate.isEmpty()) {			
			Database.update(sobjToUpdate, false);
		}	
		
	}

	global void execute (SchedulableContext info) {		
		Database.executeBatch(this, 100);
	}

	global void finish (Database.BatchableContext info) {
		//do something
		//System.debug('Batch finishes!');
	}

	/*
	Integer index;
	String query = '';
	List<sObject> aggregates;
	global GetLatLongBatch() {
		GeolocationController.initGeoSettings();
		index = 0;
		query = 'SELECT ' +
					GeolocationController.STREETADDRESS + ',' +
					GeolocationController.CITY + ',' +
					GeolocationController.STATE + ',' +
					GeolocationController.COUNTRY + ',' +
					GeolocationController.POSTALCODE + ',' +
					GeolocationController.LATITUDE + ',' + 
					GeolocationController.LONGITUDE + ' FROM ' + GeolocationController.OBJECT_NAME + 
					' WHERE ' + GeolocationController.STREETADDRESS + ' != null ' +
					' AND ' + GeolocationController.COUNTRY + ' != null ' +
					' AND ' + GeolocationController.LATITUDE + ' != null';
		System.debug('query: ' + query);
		//String query1 = 'SELECT BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode, Location__Latitude__s, Location__Longitude__s FROM Account';
		aggregates = Database.query(query);
	}

	global void execute(SchedulableContext context) {
		Database.executeBatch(this);
		System.debug('Executing SchedulableContext');
	}

	global Iterator<sObject> iterator() {
		return this;
	}

	global Boolean hasNext() {
		return index < aggregates.size();
	}

	global sObject next() {
		return aggregates[index++];
	}
	
	global Iterable<sObject> start(Database.BatchableContext context) {		
		return this;
	}

   	global void execute(Database.BatchableContext context, List<sObject> scope) {
		// do stuff
		System.debug('Executing batch job');
		GeolocationController.getLatLong(scope);
	}
	
	global void finish(Database.BatchableContext context) {
		// do stuff
		System.debug('Batch job is done');
	} */

} //class