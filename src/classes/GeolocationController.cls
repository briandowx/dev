/***
Helpers: 
	http://stackoverflow.com/questions/3122038/how-do-i-integrate-salesforce-with-google-maps
	https://developers.google.com/maps/documentation/geocoding/start
	https://help.salesforce.com/articleView?id=configuring_remoteproxy.htm&type=0
	http://stackoverflow.com/search?q=%5Bgoogle-maps%5D+salesforce
	http://blog.jeffdouglas.com/2010/01/07/using-list-custom-settings-in-salesforce-com/
**/
public without sharing class GeolocationController {
	public static String LONGITUDE;
	public static String LATITUDE;
	public static String OBJECT_NAME;
	public static String STREETADDRESS;
	public static String CITY;
	public static String STATE;
	public static String COUNTRY;
	public static String POSTALCODE;
	private static String GOOGLE_API_KEY;
	private static final String BASE_URI = 'https://maps.googleapis.com/maps/api/geocode/json?address=';
	private static final Integer MAX_CALLOUTS_FROM_APEX = 100;
	private static final Integer STANDARD_USAGE_LILMIT = 2500;
	private static final Integer PREMIUM_USAGE_LIMIT = 100000;

	public GeolocationController() {
		
	}

	public static void initGeoSettings() {
		
	 	GOOGLE_API_KEY = GeolocationUtility__c.getInstance('GoogleMapAPI').GoogleAPIKey__c;
		OBJECT_NAME = GeolocationUtility__c.getInstance('GoogleMapAPI').SObjectName__c;
		STREETADDRESS = GeolocationUtility__c.getInstance('GoogleMapAPI').AddressStreetField__c;
		CITY = GeolocationUtility__c.getInstance('GoogleMapAPI').CityField__c;
		STATE = GeolocationUtility__c.getInstance('GoogleMapAPI').StateProvinceField__c;
		COUNTRY = GeolocationUtility__c.getInstance('GoogleMapAPI').CountryField__c;
		POSTALCODE = GeolocationUtility__c.getInstance('GoogleMapAPI').PostalCodeField__c;
		LONGITUDE = GeolocationUtility__c.getInstance('GoogleMapAPI').LongitudeField__c;
		LATITUDE = GeolocationUtility__c.getInstance('GoogleMapAPI').LatitudeField__c;
	}//

	public static void getLatLong(List<sObject> sobj) {
		initGeoSettings();

		List<sObject> sobjToUpdate = new List<sObject>();
		Http h = new Http();
		HttpRequest req = new HttpRequest();
		req.setMethod('GET');
		req.setTimeout(10000);

		for (sObject a : sobj) {
			if((a.get(LONGITUDE) == null || a.get(LATITUDE) == null)){
            String address = String.valueOf(a.get(STREETADDRESS) != null ? a.get(STREETADDRESS) + ' ' : '' +
                a.get(CITY) != null ? a.get(CITY) + ' ' : '' +
                a.get(STATE) != null ? a.get(STATE) + ' ' : '' +
                a.get(POSTALCODE) != null ? a.get(POSTALCODE) + ' ' : '' +
                a.get(COUNTRY) != null ? a.get(COUNTRY) : '');
                
	            if(address != ''){
	                req.setEndpoint(BASE_URI + EncodingUtil.urlEncode(address, 'UTF-8')+'&key='+GOOGLE_API_KEY);
	                try{
	                    HttpResponse res = h.send(req);
	                    GResponse gr = (GResponse) JSON.deserialize(res.getBody(), GeolocationController.GResponse.class);
	                    if(gr.status == 'OK'){
	                        LatLng ll = gr.results[0].geometry.location;
	                        a.put(LATITUDE, ll.lat);
	                        a.put(LONGITUDE, ll.lng);
	                        sobjToUpdate.add(a);
	                    } else {
	                        System.debug('Geocoding of "' + address + '" failed:' + gr.status);
	                    }
	                }catch(Exception e){
	                    System.debug(e);
	                }
	            }
	            // Bail out if we've reached limit of callouts (not all records might have been processed).
	            if(Limits.getCallouts() == MAX_CALLOUTS_FROM_APEX) {
	                break;
	            }
        	}
		} //for

		if (!sobjToUpdate.isEmpty()) {
			Database.update(sobjToUpdate, false);
		}

	} //getLatLong()


	//method to run in the iterable batch class
	public static List<sObject> returnLatLong(List<sObject> sobj) {
		initGeoSettings();

		List<sObject> sobjToUpdate = new List<sObject>();
		Http h = new Http();
		HttpRequest req = new HttpRequest();
		req.setMethod('GET');
		req.setTimeout(10000);

		for (sObject a : sobj) {
			if((a.get(LONGITUDE) == null || a.get(LATITUDE) == null)){
            String address = String.valueOf(a.get(STREETADDRESS) != null ? a.get(STREETADDRESS) + ' ' : '' +
                a.get(CITY) != null ? a.get(CITY) + ' ' : '' +
                a.get(STATE) != null ? a.get(STATE) + ' ' : '' +
                a.get(POSTALCODE) != null ? a.get(POSTALCODE) + ' ' : '' +
                a.get(COUNTRY) != null ? a.get(COUNTRY) : '');
                
	            if(address != ''){
	                req.setEndpoint(BASE_URI + EncodingUtil.urlEncode(address, 'UTF-8')+'&key='+GOOGLE_API_KEY);
	                try{
	                    HttpResponse res = h.send(req);
	                    GResponse gr = (GResponse) JSON.deserialize(res.getBody(), GeolocationController.GResponse.class);
	                    if(gr.status == 'OK'){
	                        LatLng ll = gr.results[0].geometry.location;
	                        a.put(LATITUDE, ll.lat);
	                        a.put(LONGITUDE, ll.lng);
	                        sobjToUpdate.add(a);
	                    } else {
	                        System.debug('Geocoding of "' + address + '" failed:' + gr.status);
	                    }
	                }catch(Exception e){
	                    System.debug(e);
	                }
	            }
	            // Bail out if we've reached limit of callouts (not all records might have been processed).
	            if(Limits.getCallouts() == MAX_CALLOUTS_FROM_APEX) {
	                break;
	            }
        	}
		} //for

		return sobjToUpdate;

	} //getLatLong()

	/****** Not needed methods, but helpful to keep for references
	public static List<String> getFieldNamesFromSet(sObject obj, String fsName) {
   	if(fsName == null || obj == null)
   		return null;
    	List<String> fls = null;
    	Schema.sObjectType T = obj.getSObjectType();
    	Schema.FieldSet fs = T.getDescribe().fieldSets.getMap().get(fsName);
    	if(fs != null) {
    	  fls = new List<String>();
          for(Schema.FieldSetMember fsm : fs.getFields()) {
          	fls.add(fsm.getFieldPath());
          }	
        }
        return fls;
    }

    public static sObject getSObjectTypeFromCustomSetting() {
		return Schema.getGlobalDescribe().get(GeolocationUtility__c.getInstance('GoogleMapAPI').SObjectName__c).newSObject();
	} *********/

	// Helper class - template into which results of lookup will be parsed. Some fields are skipped!
	// Visit https://developers.google.com/maps/documentation/geocoding/#Results if you need to create full mapping.
	public class GResponse {
	    public String status;
	    public GComponents[] results;
	}

	public class GComponents {
	   public String formatted_address;
	   public GGeometry geometry;
	}

	public class GGeometry {
	    public LatLng location;
	}

	public class LatLng{
	    public Double lat, lng;
	}
} //class