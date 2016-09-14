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
// 1.0.0		06-11-2008		Mark Sivill		Initial version
// 1.1.0		18-12-2008		Mark Sivill		Fixed issue when Amount has not been set
// 1.2.0		23-12-2008		Mark Sivill		Fixed issue when more than 999 records are returned for a query. Graceful error/warning now appears on screen
// 1.3.0		02-01-2009		Mark Sivill		Fixed issue when different stages have the same probability
// 1.4.0		20-03-2009		Mark Sivill		Widen doughnut chart, have default empty/white charts for no data, add mutli-curreny warning, change SOQL statements
// 1.5.0		05-04-2009		Mark Sivill		Add multi-currency support

//
// Overview
//
// Opportunity data is queried through SOQL, then summarised (by amount and number), then used to create XML strings that is then used by Free FusionCharts
// to display the graphs 
//

//
// Future wishlist
//
// Order stages correctly using OpportunityStage table, not using order by prob and stage name
//

//
// Change following line to be 'with sharing' (user visibility)
// or 'without sharing' (system/organisation visibility)
//

//public with sharing class SalesPipelineFunnelController
public without sharing class SalesPipelineFunnelController
{

	// used for colours in funnel
	// values can be added/removed/changed
	private List<String> colours = new List<String>{'fe221c','ff9933', 'ffff33', '00cc00','3159ff','be5cff','55beff'};

	// used to return more helpful error messages to the end user
	public class SalesPipelineFunnelControllerException extends Exception {}

	// summary data for funnel
	SalesPipelineFunnelSummaryData thisQuarterOpenOppSummary = new SalesPipelineFunnelSummaryData(colours);
	SalesPipelineFunnelSummaryData thisQuarterClosedOppSummary = new SalesPipelineFunnelSummaryData(colours);
	SalesPipelineFunnelSummaryData nextQuarterOpenOppSummary = new SalesPipelineFunnelSummaryData(colours);
	SalesPipelineFunnelSummaryData nextQuarterClosedOppSummary = new SalesPipelineFunnelSummaryData(colours);

	private MultiCurrencyConversion multicurrency;
	
	//
	// values used in visualforce page
	//
	private Boolean currentQuarterCountExceeded = false;
	private Boolean nextQuarterCountExceeded = false;

	// set as too many rows to process	
	private String fusionChartsCurrentOpenOppTotalsAmountFunnelXML = '<chart isSliced=\'1\' slicingDistance=\'3\' decimalPrecision=\'0\' bgColor=\'f3f3ec\'><set name=\'Too many records\' value=\'0.001\' color=\'ffffff\' /></chart>';
	private String fusionChartsCurrentOpenOppTotalsNumberFunnelXML = '<chart isSliced=\'1\' slicingDistance=\'3\' decimalPrecision=\'0\' bgColor=\'f3f3ec\'><set name=\'Too many records\' value=\'0.001\' color=\'ffffff\' /></chart>';

	// set as too many rows to process	
	private String fusionChartsCurrentClosedOppTotalsAmountPieXML = '<graph showShadow=\'0\' shownames=\'1\' showPercentageValues=\'1\' showPercentageInLabel=\'0\' decimalPrecision=\'0\' bgColor=\'f3f3ec\'><set name=\'No Data Found\' value=\'0.001\' color=\'ffffff\' /></graph>';
	private String fusionChartsCurrentClosedOppTotalsNumberPieXML = '<graph showShadow=\'0\' shownames=\'1\' showPercentageValues=\'1\' showPercentageInLabel=\'0\' decimalPrecision=\'0\' bgColor=\'f3f3ec\'><set name=\'No Data Found\' value=\'0.001\' color=\'ffffff\' /></graph>';

	// set as too many rows to process	
	private String fusionChartsNextOpenOppTotalsAmountFunnelXML = '<chart isSliced=\'1\' slicingDistance=\'3\' decimalPrecision=\'0\' bgColor=\'f3f3ec\'><set name=\'Too many records\' value=\'0.001\' color=\'ffffff\' /></chart>';
	private String fusionChartsNextOpenOppTotalsNumberFunnelXML = '<chart isSliced=\'1\' slicingDistance=\'3\' decimalPrecision=\'0\' bgColor=\'f3f3ec\'><set name=\'Too many records\' value=\'0.001\' color=\'ffffff\' /></chart>';
	
	// set as too many rows to process	
	private String fusionChartsNextClosedOppTotalsAmountPieXML = '<graph showShadow=\'0\' shownames=\'1\' showPercentageValues=\'1\' showPercentageInLabel=\'0\' decimalPrecision=\'0\' bgColor=\'f3f3ec\'><set name=\'No Data Found\' value=\'0.001\' color=\'ffffff\' /></graph>';
	private String fusionChartsNextClosedOppTotalsNumberPieXML = '<graph showShadow=\'0\' shownames=\'1\' showPercentageValues=\'1\' showPercentageInLabel=\'0\' decimalPrecision=\'0\' bgColor=\'f3f3ec\'><set name=\'No Data Found\' value=\'0.001\' color=\'ffffff\' /></graph>';

	// constructor
	public SalesPipelineFunnelController()
	{

		multicurrency = new MultiCurrencyConversion();
		Integer queryCount = 0;
			
		try
		{
			
			if (false == multicurrency.getIsMultiCurrencyOrg())
			{

				//
				// processing for this quarter
				//
				for (Opportunity[] tmp : [SELECT o.StageName, o.Probability, o.Name, o.ExpectedRevenue, o.CloseDate, o.Amount, o.IsClosed
								FROM Opportunity o
								WHERE o.closeDate = THIS_QUARTER
								ORDER BY o.Probability DESC, o.StageName DESC
								LIMIT 5000])
				{
					queryCount = queryCount + tmp.size();
					System.Debug('Opportunity batch size for current quarter is ' + tmp.size() + ' running total ' + queryCount);
					for (Opportunity i:tmp)
					{
						if (i.IsClosed == true)
						{
							thisQuarterClosedOppSummary.addOpportunity(i);
						}
						else
						{
							thisQuarterOpenOppSummary.addOpportunity(i);					
						}
					}
				}
			
				if (queryCount >= 5000)
				{
					currentQuarterCountExceeded = true;
				}
					queryCount = 0;
		
				//
				// processing for next quarter
				//
				for (Opportunity[] tmp : [SELECT o.StageName, o.Probability, o.Name, o.ExpectedRevenue, o.CloseDate, o.Amount, o.IsClosed
								FROM Opportunity o
								WHERE o.closeDate = NEXT_QUARTER
								ORDER BY o.Probability DESC, o.StageName DESC
								LIMIT 5000])
				{
		
					queryCount = queryCount + tmp.size();
					System.Debug('Opportunity batch size for next quarter is ' + tmp.size() + ' running total ' + queryCount);
					for (Opportunity i:tmp)
					{
						if (i.IsClosed == true)
						{
							nextQuarterClosedOppSummary.addOpportunity(i);
						}
						else
						{
							nextQuarterOpenOppSummary.addOpportunity(i);					
						}
					}
				}

				if (queryCount >= 5000)
				{
					nextQuarterCountExceeded = true;
				}

			} // end if statement for no multi-currency
			else
			{
			
				// count to check that not too many rows have been queried

				//
				// processing for this quarter, need dynamic statement so class can run in non multi-currency orgs
				//
				for (sObject[] tmp : Database.query('SELECT o.CurrencyIsoCode, o.StageName, o.Probability, o.Name, o.ExpectedRevenue, o.CloseDate, o.Amount, o.IsClosed FROM Opportunity o WHERE o.closeDate = THIS_QUARTER ORDER BY o.Probability DESC, o.StageName DESC LIMIT 4900') )
				{
					queryCount = queryCount + tmp.size();
//					System.Debug('Opportunity batch size for current quarter is ' + tmp.size() + ' running total ' + queryCount);
					Opportunity currentOpp;
					
					for (sObject i:tmp)
					{
							currentOpp = (Opportunity)i;
																	
						if (currentOpp.IsClosed == true)
						{
							thisQuarterClosedOppSummary.addOpportunity(currentOpp, String.valueOf(i.get('CurrencyIsoCode')), multicurrency );
						}
						else
						{
							thisQuarterOpenOppSummary.addOpportunity(currentOpp, String.valueOf(i.get('CurrencyIsoCode')), multicurrency);					
						}
					}
				}
			
				if (queryCount >= 4900)
				{
					currentQuarterCountExceeded = true;
				}
					queryCount = 0;
			
				//
				// processing for next quarter, need dynamic statement so class can run in non multi-currency orgs
				//
				for (sObject[] tmp : Database.query('SELECT o.CurrencyIsoCode, o.StageName, o.Probability, o.Name, o.ExpectedRevenue, o.CloseDate, o.Amount, o.IsClosed FROM Opportunity o WHERE o.closeDate = NEXT_QUARTER ORDER BY o.Probability DESC, o.StageName DESC LIMIT 4900') )								
				{
		
					queryCount = queryCount + tmp.size();
//					System.Debug('Opportunity batch size for current quarter is ' + tmp.size() + ' running total ' + queryCount);
					Opportunity currentOpp;
					
					for (sObject i:tmp)
					{
						currentOpp = (Opportunity)i;
																	
						if (currentOpp.IsClosed == true)
						{
							nextQuarterClosedOppSummary.addOpportunity(currentOpp, String.valueOf(i.get('CurrencyIsoCode')), multicurrency );
						}
						else
						{
							nextQuarterOpenOppSummary.addOpportunity(currentOpp, String.valueOf(i.get('CurrencyIsoCode')), multicurrency);					
						}
					}
				}

				if (queryCount >= 4900)
				{
					nextQuarterCountExceeded = true;
				}

			} // end else statement for multi-currency

			// close summaries
			thisQuarterClosedOppSummary.finalOpportunity();
			thisQuarterOpenOppSummary.finalOpportunity();					
			nextQuarterClosedOppSummary.finalOpportunity();
			nextQuarterOpenOppSummary.finalOpportunity();					

			if (false == currentQuarterCountExceeded)
			{
				fusionChartsCurrentOpenOppTotalsAmountFunnelXML = createFusionChartsAmountFunnelXML(thisQuarterOpenOppSummary.getSummaryData()); 
				fusionChartsCurrentOpenOppTotalsNumberFunnelXML = createFusionChartsNumberFunnelXML(thisQuarterOpenOppSummary.getSummaryData()); 
				fusionChartsCurrentClosedOppTotalsAmountPieXML = createFusionChartsPieAmountXML(thisQuarterClosedOppSummary.getSummaryData());
				fusionChartsCurrentClosedOppTotalsNumberPieXML = createFusionChartsPieNumberXML(thisQuarterClosedOppSummary.getSummaryData());			
			}
		
			if (false == nextQuarterCountExceeded)
			{
				fusionChartsNextOpenOppTotalsAmountFunnelXML = createFusionChartsAmountFunnelXML(nextQuarterOpenOppSummary.getSummaryData()); 
				fusionChartsNextOpenOppTotalsNumberFunnelXML = createFusionChartsNumberFunnelXML(nextQuarterOpenOppSummary.getSummaryData()); 
				fusionChartsNextClosedOppTotalsAmountPieXML = createFusionChartsPieAmountXML(nextQuarterClosedOppSummary.getSummaryData());
				fusionChartsNextClosedOppTotalsNumberPieXML = createFusionChartsPieNumberXML(nextQuarterClosedOppSummary.getSummaryData());			
			}
		}
		catch(Exception e)
		{
			throw new SalesPipelineFunnelControllerException('Error in SalesPipelineFunnelController.SalesPipelineFunnelController - ' + e.getMessage() ,e);
		}

	} // end controller
		
	// get summary details			
	public List<SalesPipelineFunnelSummaryData.DataClass> getCurrentOpenOppTotals()
	{
		return thisQuarterOpenOppSummary.getSummaryData();
	}
		
	// get summary details			
	public List<SalesPipelineFunnelSummaryData.DataClass> getCurrentClosedOppTotals()
	{
		return thisQuarterClosedOppSummary.getSummaryData();
	}

	// get summary details			
	public List<SalesPipelineFunnelSummaryData.DataClass> getNextOpenOppTotals()
	{
		return nextQuarterOpenOppSummary.getSummaryData();

	}

	// get summary details			
	public List<SalesPipelineFunnelSummaryData.DataClass> getNextClosedOppTotals()
	{
		return nextQuarterClosedOppSummary.getSummaryData();
	}

	// to many records?
	public Boolean getCurrentQuarterCountExceeded()
	{
		return currentQuarterCountExceeded;
	}
	
	// to many records?
	public Boolean getNextQuarterCountExceeded()
	{
		return nextQuarterCountExceeded;
	}

	// Fusion charts XML strings
	public String  getFusionChartsCurrentOpenOppTotalsAmountFunnelXML()
	{
		return fusionChartsCurrentOpenOppTotalsAmountFunnelXML;
	}
	
	// Fusion charts XML strings
	public String  getFusionChartsCurrentClosedOppTotalsAmountPieXML()
	{
		return fusionChartsCurrentClosedOppTotalsAmountPieXML;
	}

	// Fusion charts XML strings
	public String  getFusionChartsCurrentOpenOppTotalsNumberFunnelXML()
	{
		return fusionChartsCurrentOpenOppTotalsNumberFunnelXML;
	}
	
	// Fusion charts XML strings
	public String  getFusionChartsCurrentClosedOppTotalsNumberPieXML()
	{
		return fusionChartsCurrentClosedOppTotalsNumberPieXML;
	}

	// Fusion charts XML strings
	public String  getFusionChartsNextOpenOppTotalsAmountFunnelXML()
	{
		return fusionChartsNextOpenOppTotalsAmountFunnelXML;
	}
	
	// Fusion charts XML strings
	public String  getFusionChartsNextClosedOppTotalsAmountPieXML()
	{
		return fusionChartsNextClosedOppTotalsAmountPieXML;
	}

	// Fusion charts XML strings
	public String getFusionChartsNextOpenOppTotalsNumberFunnelXML()
	{
		return fusionChartsNextOpenOppTotalsNumberFunnelXML;
	}
	
	// Fusion charts XML strings
	public String getFusionChartsNextClosedOppTotalsNumberPieXML()
	{
		return fusionChartsNextClosedOppTotalsNumberPieXML;
	}

	//
	// method to see if multicurrency is turned on
	//
	public Boolean getIsMultiCurrencyOrg()
	{
		return multicurrency.getIsMultiCurrencyOrg();
	}

	//
	// get corporate currency code
	//
	public String getCorporateCurrencyCode()
	{
		return 	multicurrency.getCorporateCurrencyCode();
	}

	//
	// get corporate currency decimal
	//
	public Integer getCorporateCurrencyDecimalPlaces()
	{
		return 	multicurrency.getCorporateCurrencyDecimalPlaces();
	}

	//
	// method to create FusionCharts funnel XML based on 'DataClass' values
	//
	public String createFusionChartsAmountFunnelXML(List<SalesPipelineFunnelSummaryData.DataClass> summaryData)
	{
		String xmlResult = '<chart isSliced=\'1\' slicingDistance=\'3\' decimalPrecision=\'0\' bgColor=\'f3f3ec\'>';

		if (summaryData.size()>0)
		{
			for(SalesPipelineFunnelSummaryData.DataClass i:summaryData)
			{
				xmlResult = xmlResult + '<set name=\'' + i.StageName + '\' value=\'' + i.totalAmount + '\' color=\'' + i.colour + '\' />';
			}
		}
		else
		{
				xmlResult = xmlResult + '<set name=\'No Data Found\' value=\'0.001\' color=\'ffffff\' />';			
		}
		xmlResult = xmlResult + '</chart>';	
		return xmlResult;
	}

	//
	// method to create FusionCharts pie XML based on 'DataClass' values
	//
	public String createFusionChartsPieAmountXML(List<SalesPipelineFunnelSummaryData.DataClass> summaryData)
	{

		// change decimal to above zero stop rounding to nearest thousand or million
		String xmlResult = '<graph showShadow=\'0\' shownames=\'1\' showPercentageValues=\'1\' showPercentageInLabel=\'0\' decimalPrecision=\'0\' bgColor=\'f3f3ec\'>';

		if (summaryData.size()>0)
		{

			for(SalesPipelineFunnelSummaryData.DataClass i:summaryData)
			{
				xmlResult = xmlResult + '<set name=\'' + i.StageName + '\' value=\'' + i.totalAmount + '\' color=\'' + i.colour + '\' />';
			}
		}
		else
		{
				xmlResult = xmlResult + '<set name=\'No Data Found\' value=\'0.001\' color=\'ffffff\' />';			
		}

		xmlResult = xmlResult + '</graph>';	
		return xmlResult;		
	}

	//
	// method to create FusionCharts funnel XML based on 'DataClass' values
	//
	public String createFusionChartsNumberFunnelXML(List<SalesPipelineFunnelSummaryData.DataClass> summaryData)
	{
		String xmlResult = '<chart isSliced=\'1\' slicingDistance=\'3\' decimalPrecision=\'0\' bgColor=\'f3f3ec\'>';

		if (summaryData.size()>0)
		{
			for(SalesPipelineFunnelSummaryData.DataClass i:summaryData)
			{
				xmlResult = xmlResult + '<set name=\'' + i.StageName + '\' value=\'' + i.totalCount + '\' color=\'' + i.colour + '\' />';
			}
		}
		else
		{
				xmlResult = xmlResult + '<set name=\'No Data Found\' value=\'0.001\' color=\'ffffff\' />';			
		}

		xmlResult = xmlResult + '</chart>';	
		return xmlResult;
	}

	//
	// method to create FusionCharts pie XML based on 'DataClass' values
	//
	public String createFusionChartsPieNumberXML(List<SalesPipelineFunnelSummaryData.DataClass> summaryData)
	{
		String xmlResult = '<graph showShadow=\'0\' shownames=\'1\' showPercentageValues=\'1\' showPercentageInLabel=\'0\' decimalPrecision=\'0\' bgColor=\'f3f3ec\'>';

		if (summaryData.size()>0)
		{
			for(SalesPipelineFunnelSummaryData.DataClass i:summaryData)
			{
				xmlResult = xmlResult + '<set name=\'' + i.StageName + '\' value=\'' + i.totalCount + '\' color=\'' + i.colour + '\' />';
			}
		}
		else
		{
				xmlResult = xmlResult + '<set name=\'No Data Found\' value=\'0.001\' color=\'ffffff\' />';			
		}

		xmlResult = xmlResult + '</graph>';	
		return xmlResult;		
	}

}