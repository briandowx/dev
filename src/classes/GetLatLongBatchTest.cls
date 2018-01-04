@isTest(SeeAllData=true)
private class GetLatLongBatchTest {
	
	@isTest static void test_method_one() {
		List<Account> accts = new List<Account>();

		Test.startTest();
		accts = createAccount(90);		
		Database.executeBatch(new GetLatLongBatch(), 100);
		Test.stopTest();

		//validate test data
		accts.clear();

		String query = 'SELECT ' +
						GeolocationController.STREETADDRESS + ',' +
						GeolocationController.CITY + ',' +
						GeolocationController.STATE + ',' +
						GeolocationController.COUNTRY + ',' +
						GeolocationController.POSTALCODE + ',' +
						GeolocationController.LATITUDE + ',' + 
						GeolocationController.LONGITUDE + ' FROM ' + GeolocationController.OBJECT_NAME + 
						' WHERE ' + GeolocationController.STREETADDRESS + ' != null ' +
						' AND ' + GeolocationController.COUNTRY + ' != null ' +						
						' AND CreatedDate = TODAY';
		accts = Database.query(query);

		for (Account a : accts) {
			System.assertEquals(null, a.get(GeolocationController.LATITUDE));
		}
	}
	
	@isTest static void test_method_two() {
		// Implement test code
	}
	

	//Data Utility methods
	private static List<Account> createAccount(Integer count) {
		List<Account> acctsToCreate = new List<Account>();
		GeolocationController.initGeoSettings();		

		for (Integer i=0; i<count; i++) {
			Account a = new Account();
			a.OwnerId = UserInfo.getUserId();
			a.Name = 'Monkey Account ' + i;
			a.put(GeolocationController.STREETADDRESS, '1 Market St #300');
			a.put(GeolocationController.CITY, 'San Francisco');
			a.put(GeolocationController.STATE, 'California');
			a.put(GeolocationController.POSTALCODE, '94105');
			a.put(GeolocationController.COUNTRY, 'United States');

			acctsToCreate.add(a);			
		}

		if (!acctsToCreate.isEmpty())
			Database.insert(acctsToCreate, false);

		return acctsToCreate;
	}

}