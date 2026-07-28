public class cCreateQuote 
{

    public ApexPages.StandardController mycontroller {get;set;}
    public Quote myQuote {get;set;}
    public Saved_Quote__c sQuote {get;set;}
    
    public List<Saved_Quote__c> lsaved { get;set;}

    public PageReference doCreate()
    {
        squote.date__c=date.today();
        squote.quote__c=myquote.id;
        squote.name=myquote.quotenumber+'/'+squote.version__c.format();
        squote.amount__c=myquote.grandTotal;           
        if (squote.language__c==null)    squote.language__c='ITA';
           
        insert squote;     
        
        PageReference preventivo;
        
        preventivo=Page.Quote_ita;
        
        if (squote.language__c=='IT')    preventivo=Page.Quote_ita;
        
        preventivo.getParameters().put('id',myquote.id);

        Blob pdf;
        if (Test.IsRunningTest())
            pdf=Blob.valueOf('UNIT.TEST');
        else
            pdf=preventivo.getContent();
                                
        Attachment attach = new Attachment();
        attach.Body = pdf;
        attach.Name = 'Preventivo.doc';
        attach.IsPrivate = false;
        attach.ParentId = sQuote.id;
        
        insert attach;
        
        squote.idfile__c=attach.id;
        update squote;
                
        return new PageReference('/'+sQuote.id);
    }

    public void reload()
    {
        if (myquote.id==null) return ;
        
        lsaved=[select id, name, version__c, date__c, amount__c, language__c from saved_quote__c where quote__c=:myQuote.id order by version__c desc];
        
        if (lsaved.size()>0)
        {
            squote.version__c=lsaved[0].version__c+1;
            squote.language__c=lsaved[0].language__c;
        } else
        {
            squote.version__c=1;
            squote.language__c='ITA';
        }
    }
    
    public cCreateQuote(ApexPages.StandardController controller) 
    {
        mycontroller=controller;
        myquote=(quote)controller.getRecord();
        
        sQuote=new Saved_Quote__c();
        reload();
    }

}