@isTest
private class testQuoteDefaultAddresses {

    static testMethod void myUnitTest() 
    {
    	Account a=new Account(name='pippo',billingstreet='via del via',billingcity='rimini',shippingstreet='via del posto',shippingcity='riccione');
    	insert a;
    	
    	Account a2=new Account(name='pippo',billingstreet='via del via',billingcity='rimini',shippingstreet='via del posto',shippingcity='riccione');
    	insert a2;
    	
    	Contact c=new Contact(lastname='pluto',accountid=a.id);
    	insert c;
    	    	
		Opportunity o=new Opportunity(name='opp1',stagename='Prospecting/Rumors',closedate=date.today(),accountid=a.id);
		insert o;
		
		Quote q=new Quote(opportunityid=o.id,name='quote1');
		insert q;

		o.Account_Final_Customer__c=a2.id;
		update o;
		update q;
		    	
    }
}