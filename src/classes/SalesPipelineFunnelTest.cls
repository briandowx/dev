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
// 1.0.0		14-12-2008		Mark Sivill		Initial version
//

@isTest
private class SalesPipelineFunnelTest {

    static testMethod void runTest() {
    	
    	//
    	// delete current opportunities
    	//
    	
    	Account acc = new Account(Name='Mark Test Account');
       	insert acc;

		// test when Amount has not been set    	
    	Opportunity opp = new Opportunity (Name='Mark Test opp', StageName='Prospecting', CloseDate= date.today() );    	
    	insert opp;

    	Opportunity opp2 = new Opportunity (Name='Mark Test opp2', StageName='Qualification', CloseDate= date.today(), Amount=100 );    	
    	insert opp2;
		  			
		Test.startTest();
		
        SalesPipelineFunnelController testController = new SalesPipelineFunnelController();
        
        List<SalesPipelineFunnelSummaryData.DataClass> dc = new List<SalesPipelineFunnelSummaryData.DataClass>();
        dc = testController.getCurrentOpenOppTotals();
        dc = testController.getCurrentClosedOppTotals();
        dc = testController.getNextOpenOppTotals();
        dc = testController.getNextClosedOppTotals();
        
        Boolean result;
        
        result = testController.getCurrentQuarterCountExceeded();
        result = testController.getNextQuarterCountExceeded();
        result = testController.getIsMultiCurrencyOrg();

		String iso = testController.getCorporateCurrencyCode();
		Integer dp = testController.getCorporateCurrencyDecimalPlaces();

		String xmlString;
		
		xmlString = testController.getFusionChartsCurrentOpenOppTotalsAmountFunnelXML();
		xmlString = testController.getFusionChartsCurrentClosedOppTotalsAmountPieXML();
		xmlString = testController.getFusionChartsCurrentOpenOppTotalsNumberFunnelXML();
		xmlString = testController.getFusionChartsCurrentClosedOppTotalsNumberPieXML();

		xmlString = testController.getFusionChartsNextOpenOppTotalsAmountFunnelXML();
		xmlString = testController.getFusionChartsNextClosedOppTotalsAmountPieXML();
		xmlString = testController.getFusionChartsNextOpenOppTotalsNumberFunnelXML();
		xmlString = testController.getFusionChartsNextClosedOppTotalsNumberPieXML();

		Map<String, MultiCurrencyConversion.DataClass> currencyConversions = new Map<String, MultiCurrencyConversion.DataClass>();
		currencyConversions.put('GBP', new MultiCurrencyConversion.DataClass( 2, 1.000 ) );
		MultiCurrencyConversion mcc = new MultiCurrencyConversion(currencyConversions);

		result = mcc.getIsMultiCurrencyOrg();
		String isoCode = mcc.getCorporateCurrencyCode();
		Integer decimalPlaces = mcc.getCorporateCurrencyDecimalPlaces();

		List<String> colours = new List<String>{'fe221c','ff9933', 'ffff33', '00cc00'};
		SalesPipelineFunnelSummaryData summaryData = new SalesPipelineFunnelSummaryData (colours);
		summaryData.addOpportunity(opp);
		summaryData.addOpportunity(opp2);

		summaryData.addOpportunity(opp2, 'GBP', mcc);

		summaryData.finalOpportunity();
		
		
		Test.stopTest();

    }
}