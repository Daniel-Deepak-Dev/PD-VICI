@isTest
public class tcQuote 
{
	static testMethod void testme()
    {
        Account a=new Account(name='prova', billingstate='Modena', billingcountry='Italy');
        insert a;
        
        id pb = Test.getStandardPricebookId();        
        
        Opportunity o=new Opportunity(name='prova', closedate=date.today(), stagename='Closed/Won');
        insert o;
        
        Quote q=new Quote(name='prova',opportunityid=o.id,Pricebook2Id=pb);
        insert q;
        
        Product2 m1 = new Product2(Name = 'MTL X5', Family = 'Machines', Tipo_di_macchina__c='MTL X5');
        insert m1;
        PricebookEntry pm1 = new PricebookEntry(Pricebook2Id = pb, Product2Id = m1.Id, UnitPrice=1, IsActive = true);
        insert pm1;       
        
        Product2 a1 = new Product2(Name = 'acc1', Family = 'Machines', Tipo_di_macchina__c='X200');
        insert a1;        
        PricebookEntry pa1 = new PricebookEntry(Pricebook2Id = pb, Product2Id = a1.Id, UnitPrice=1, IsActive = true);
        insert pa1;       
        
        ApexPages.StandardController apexStd=new ApexPages.StandardController(q);
        
        cQuote cq=new cQuote(apexStd);
        
        cq.idMachine=m1.id;
        cq.doSelectMachine();
        cq.reload();
        
        cq.doDESelectMachine();
        
        cq.idMachine=m1.id;
        cq.doSelectMachine();
        cq.reload();

        cq.doSelectAll();

        cq.doConfirm();
    }
}