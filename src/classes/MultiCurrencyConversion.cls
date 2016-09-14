//Copyright (c) 2008, Mark Sivill, Sales Engineering, Salesforce.com Inc.
//All rights reserved.
//
//Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer. 
//Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//Neither the name of the salesforce.com nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission. 
//THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
//INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
//SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
//LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
//CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, 
//EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

//
// History
//
// Version		Date			Author			Comments
// 1.0.0		04-04-2009		Mark Sivill		Initial version

//
// Overview
//
// Utility class to do multi-currency conversions, classes use dynamic SOQL so can be run in non multi-currency orgs 
//
// Assume there will never be more than 200 currencies
//
//
public class MultiCurrencyConversion {

	private Boolean isMultiCurrencyOrg = false;
	private String corporateCurrencyCode;
	private Integer corporateCurrencyDecimalPlaces; 
	private Map<String, DataClass> currencyConversions = new Map<String, DataClass>();
		
	public MultiCurrencyConversion()
	{

		List<SObject> sobjects;
		String currentIsoCode;

		//
		// method needs to be dynamic SOQL so can safely run in org where
		// multi-currency is not set up
		//
		try
		{
			sobjects = Database.query('SELECT c.Id, c.IsoCode, c.IsCorporate, c.DecimalPlaces, c.ConversionRate FROM CurrencyType c');

			for (sObject i:sobjects)
			{
			
				currentIsoCode = String.valueOf(i.get('IsoCode'));
					
				// store corporate code
				if (true==Boolean.valueOf(i.get('IsCorporate')))
				{
					corporateCurrencyCode = currentIsoCode;
					corporateCurrencyDecimalPlaces = Integer.valueOf(i.get('DecimalPlaces')); 
					
				}		
				currencyConversions.put(currentIsoCode, new DataClass( Integer.valueOf(i.get('DecimalPlaces')), Double.valueOf(String.valueOf(i.get('ConversionRate')))) );
			}
						
			// if still here then org is multi-currency
			isMultiCurrencyOrg = true;
			
		}
		catch (Exception e)
		{
			isMultiCurrencyOrg = false;
		}
				
	}

	//
	// constructor created to help test other parts of the code
	//
	public MultiCurrencyConversion(Map<String, DataClass> currencyConversions)
	{
		this.currencyConversions = currencyConversions;
	}
	
	public Boolean getIsMultiCurrencyOrg()
	{
		return isMultiCurrencyOrg;
	}

	public String getCorporateCurrencyCode()
	{
		return corporateCurrencyCode;
	}

	public Integer getCorporateCurrencyDecimalPlaces()
	{
		return corporateCurrencyDecimalPlaces;
	}

	//
	// return amount in corporate currency
	//
	public Decimal calculateCorporateCurrencyAmount(String currencyIsoCode, Decimal Amount)
	{
		return ( Amount / currencyConversions.get(currencyIsoCode).conversionRate );
	}
		
	//
	// used to hold conversion values
	//
	public class DataClass {
  	
		public Integer decimalPlaces;
  		public Double conversionRate;

		public DataClass (Integer decimalPlaces, Double conversionRate)
		{
			this.decimalPlaces = decimalPlaces;
			this.conversionRate = conversionRate; 
		}
		
	}

}