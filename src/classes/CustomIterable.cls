global class CustomIterable implements Iterator<sObject> {
	List<sObject> sobj {get; set;}
	Integer i {get; set;}
	String query;

	global CustomIterable() {		
		GeolocationController.initGeoSettings();
		try {
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
						' AND ' + GeolocationController.LATITUDE + ' = null';	

			sobj = Database.query(query);  //load data into List		
		} catch (QueryException qe) {
			System.debug('CustomIterable.CustomIterable(): [' + qe.getLineNumber() + '] - Type: ' + qe.getTypeName() + ' - Error: ' + qe.getMessage());
		} catch (Exception e) {
			System.debug('CustomIterable.CustomIterable(): [' + e.getLineNumber() + '] - Type: ' + e.getTypeName() + ' - Error: ' + e.getMessage());
		}
		
		i = 0;
		
	} //CustomIterable()

	global Boolean hasNext() {
		if (i >= sobj.size())
			return false;
		else
			return true;
	} 

	global sObject next() {	
		i++;
		return sobj[i-1];
	}
} //class