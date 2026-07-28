trigger computeQuoteDefaultAddresses on Quote (before insert, before update) 
{

	for (Quote q:Trigger.new)
	{
		List<Opportunity> lo=[select 
			Account.BillingStreet,Account.BillingCity,Account.BillingPostalCode,Account.BillingCountry,Account.BillingState, 
			Account.ShippingStreet,Account.ShippingCity,Account.ShippingPostalCode,Account.ShippingCountry,Account.ShippingState,
			Account_Final_Customer__c,
			Account_Final_Customer__r.ShippingStreet,Account_Final_Customer__r.ShippingCity,Account_Final_Customer__r.ShippingPostalCode,
				Account_Final_Customer__r.ShippingCountry,Account_Final_Customer__r.ShippingState 
				from Opportunity where id=:q.opportunityid];
		if (lo.size()>0)
		{
			if (lo[0].Account_Final_Customer__c!=null)
			{
				if (q.ShippingStreet==null)
					q.ShippingStreet=lo[0].Account_Final_Customer__r.ShippingStreet;
				if (q.ShippingCity==null)
					q.ShippingCity=lo[0].Account_Final_Customer__r.ShippingCity;
				if (q.ShippingState==null)
					q.ShippingState=lo[0].Account_Final_Customer__r.ShippingState;
				if (q.ShippingPostalCode==null)
					q.ShippingPostalCode=lo[0].Account_Final_Customer__r.ShippingPostalCode;
				if (q.ShippingCountry==null)
					q.ShippingCountry=lo[0].Account_Final_Customer__r.ShippingCountry;
				
			}
			else
			{
				if (q.ShippingStreet==null)
					q.ShippingStreet=lo[0].Account.ShippingStreet;
				if (q.ShippingCity==null)
					q.ShippingCity=lo[0].Account.ShippingCity;
				if (q.ShippingState==null)
					q.ShippingState=lo[0].Account.ShippingState;
				if (q.ShippingPostalCode==null)
					q.ShippingPostalCode=lo[0].Account.ShippingPostalCode;
				if (q.ShippingCountry==null)
					q.ShippingCountry=lo[0].Account.ShippingCountry;
			}
			
			if (q.BillingStreet==null)
				q.BillingStreet=lo[0].Account.BillingStreet;
			if (q.BillingCity==null)
				q.BillingCity=lo[0].Account.BillingCity;
			if (q.BillingState==null)
				q.BillingState=lo[0].Account.BillingState;
			if (q.BillingPostalCode==null)
				q.BillingPostalCode=lo[0].Account.BillingPostalCode;
			if (q.BillingCountry==null)
				q.BillingCountry=lo[0].Account.BillingCountry;

		}
	}
}