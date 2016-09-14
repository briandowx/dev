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
// 1.0.0		25-03-2008		Mark Sivill		Initial version

//
// Overview
//
// Place to process summary data, assumption that data is ordered by Probability, StageName as it arrives
//

public class SalesPipelineFunnelSummaryData {

	private List<DataClass> summaryData = new List<DataClass>();
	private List<String> colours = new List<String>();
	private DataClass currentSummaryItem;
	private Integer colourCount = 0;
	private Opportunity lastOpp;

	public SalesPipelineFunnelSummaryData (List<String> colours)
	{
		this.colours = colours;
	}

	public void addOpportunity(Opportunity opp, String currencyIsoCode, MultiCurrencyConversion currencyConversion)
	{
		// fix for when Amount has not been set (null)
		if (opp.Amount == null)
		{
			opp.Amount = 0;
		}

		opp.Amount = currencyConversion.calculateCorporateCurrencyAmount(currencyIsoCode, opp.Amount);
		processOpportunity(opp);

	}
	
	//
	// add opportunity to summary table (assumption is data is ordered)
	//	
	public void addOpportunity(Opportunity opp)
	{
		// fix for when Amount has not been set (null)
		if (opp.Amount == null)
		{
			opp.Amount = 0;
		}

		processOpportunity(opp);
		
	}
	
	private void processOpportunity(Opportunity opp)
	{

//System.Debug('SalesPipelineFunnelSummaryData summaryData size ' + summaryData.size() );
//System.Debug('SalesPipelineFunnelSummaryData opp ' + opp );
	
		// first record added
		if( (summaryData.size()==0) && (currentSummaryItem==null) )
		{
			currentSummaryItem = new DataClass(opp.Probability, opp.StageName, 1, opp.Amount, colours[Math.mod(colourCount, colours.size())]);
			colourCount++;			
		}
		else
		{
			// check if stageName has changed even though probability has stayed the same
			if ( (lastOpp.Probability != opp.Probability) || (lastOpp.StageName != opp.StageName) )
			{
				summaryData.add(currentSummaryItem);
				currentSummaryItem = new DataClass(opp.Probability, opp.StageName, 1, opp.Amount, colours[Math.mod(colourCount, colours.size())]);
				colourCount++;
			}
			// add current opportunity details in
			else
			{
				currentSummaryItem.totalCount = currentSummaryItem.totalCount + 1;
				currentSummaryItem.totalAmount = currentSummaryItem.totalAmount + opp.Amount;
			}
		}
		// record last opportunity for comparision
		lastOpp = opp;
		
	}
	
	//
	// need to say when no more opportunties are required for processing
	//
	public void finalOpportunity()
	{
		// if summary data is null then there where no
		// records so no need to update summary data
		if (currentSummaryItem!=null)
		{
			summaryData.add(currentSummaryItem);	
		}
	}
		
	public List<DataClass> getSummaryData()
	{
		return summaryData;
	}

	// data class to hold summary details
	public class DataClass {
  	
  		public Decimal Probability;
		public String StageName;  	
		public Integer totalCount;
		public Decimal totalAmount;
		public String colour;
		  	
		public DataClass (Decimal Probability, String StageName, Integer totalCount, Decimal totalAmount, String colour)
		{
			this.Probability = Probability;
			this.StageName = StageName;  	
			this.totalCount = totalCount;
			this.totalAmount = totalAmount;  	
			this.colour = colour;  	
		}
		
		public Decimal getProbability()
		{
			return this.Probability;
		}

		public String getStageName()
		{
			return this.StageName;
		}
		
		public Integer getTotalCount()
		{
			return this.totalCount;
		}
				
		public Decimal getTotalAmount()
		{
			return this.totalAmount;
		}
				
		public String getColour()
		{
			return this.colour;
		}

	}

}