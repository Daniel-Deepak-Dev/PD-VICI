public class cQuote {

    public ApexPages.StandardController mycontroller {get;set;}
    public Quote myQuote {get;set;}
    
    public id idMachine {get;set;}
    public Product2 pMachine {get;set;}

    public List<PriceBookEntry> machines {get;set;}
    public List<PriceBookEntry> accessories {get;set;}
    
    public string order {get;set;}

    public boolean fPriceBook {get;set;}
    public boolean fEdit {get;set;}
    
    public List<PriceBook2> lpricebooks {get;set;}
    
    public List<SelectOption> getPriceBooks()
    {
        List<PriceBook2> lpb=[select id,name from PriceBook2 where isActive=true];
        
        List<SelectOption> lo=new List<SelectOption>();
        for (PriceBook2 pb : lpb)
        {
            SelectOption o=new SelectOption(pb.id,pb.name);
            lo.add(o);
        }
        return lo;
    }
    
    public PageReference doSelectPB()
    {
        fPricebook=true;
        upsert myQuote;
        
        reload();
        return null;
    }
   
    public PageReference doConfirm()
    {
        integer iSort=0;
        
        List<Id> myorder=new List<Id>();
        
        List<QuoteLineItem> lq=[select id, sortorder from QuoteLineItem where quoteid=:myquote.id order by sortorder asc];
        if (lq.size()>0)
        {
            for (QuoteLineItem qli:lq)
                myorder.add(qli.id);
        }
        
        List<QuoteLineItem> lqli=new List<QuoteLineItem>();
        
        QuoteLineItem qli=new QuoteLineItem();
        qli.QuoteId=myquote.id;
        qli.Quantity=1;
        qli.PricebookEntryId=machines[0].id;
        qli.UnitPrice=machines[0].UnitPrice;
        
        if (!fEdit)
        {
            insert qli;
            myorder.add(qli.id);      
            
	        lqli.add( qli );
        }        
        
        for (PriceBookEntry pbe:accessories)
        {
            if (pbe.fSelect__c)
            {
                QuoteLineItem qlia=new QuoteLineItem();
                qlia.QuoteId=myquote.id;
                qlia.Quantity=1;
                qlia.PricebookEntryId=pbe.id;
                qlia.UnitPrice=pbe.UnitPrice;
                
                insert qlia;
                
                myorder.add(qlia.id);            
            }
        }
        
        order=String.join(myorder, ',');
        
//        cQuote.reorder(myquote.id,qli.id);  

        Pagereference p=new Pagereference('/'+myquote.id);
        p.setRedirect(true);
        return p;
    }

    @future (callout=true)
    public static void reorder(id quoteId, string order)
    {
        /*
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
    
        req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm()+'/oppitm/lineitemsort.jsp');
        req.setMethod('POST');
        req.setBody('id='+EncodingUtil.urlEncode(quoteId, 'UTF-8')+'&duel0='+EncodingUtil.urlEncode(order, 'UTF-8')
                    +'retURL='+EncodingUtil.urlEncode('/'+quoteId, 'UTF-8')+'save=save');
        req.setCompressed(true); // otherwise we hit a limit of 32000
    
        try {
            res = http.send(req);
            system.debug(res);
        } catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
            System.debug(res.toString());
        }    
                */
    }
    
    public PageReference doSelectAll()
    {
        for (PriceBookEntry pbe:accessories)
            pbe.fSelect__c=true;
            
        return null;            
    }
    
    public PageReference doSelectMachine()
    {
         if (idMachine!=null)
         {
             pMachine=[select id, name, family, Tipo_di_macchina__c from Product2 where id=:idMachine];
             reload();
         }
    
        return null;
    }
    
    public PageReference doDESelectMachine()
    {
         idMachine=null;
         reload();
    
        return null;
    }
    
    public void reload()
    {
        if (idMachine==null) // non si è selezionato ancora nulla
        {
            machines=[select id,name, Product2Id, ProductCode, UnitPrice, UseStandardPrice 
                from Pricebookentry where isactive=true and product2.family='machines' and pricebook2id=:myquote.Pricebook2Id order by productcode];        
            accessories=new List<PriceBookEntry>();                
        } else
        {
            machines=[select id,name, Product2Id, ProductCode, UnitPrice, UseStandardPrice 
                from Pricebookentry where isactive=true and product2.family='machines' and pricebook2id=:myquote.Pricebook2Id 
                and Product2Id=:idMachine
                order by productcode];        
                
            accessories=[select id,name, Product2Id, ProductCode, UnitPrice, UseStandardPrice, fSelect__c
                from Pricebookentry where isactive=true and product2.family='accessories' and pricebook2id=:myquote.Pricebook2Id 
                and product2.Tipo_di_macchina__c includes(:pmachine.Tipo_di_macchina__c)
                order by productcode];    
            
        }
    }

    public cQuote(ApexPages.StandardController controller) 
    {
        mycontroller=controller;
        myquote=(quote)controller.getRecord();
        
        idMachine=null;
        fPriceBook=false;
        fEdit=false;
        
        if (myquote.Pricebook2Id!=null)
                fPriceBook=true;
        
		if (myquote.id!=null)
        {
            List<QuoteLineItem> lqlp=[select product2Id from QuoteLineItem where product2.family='machines' and quoteId=:myquote.id order by sortorder desc];
            if (lqlp.size()>0)
            {
                idMachine=lqlp[0].product2Id;
                
                pMachine=[select id, name, family, Tipo_di_macchina__c from Product2 where id=:idMachine];
                fEdit=true;
            }
        }
        
        reload();
        
    }

}