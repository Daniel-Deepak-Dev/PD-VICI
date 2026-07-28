@isTest
public class tcPortaleRivenditori 
{
	testMethod static void testMe()
    {
        Lead l=new Lead(Lastname='prova', Company='prova', Country='Italy');
        insert l;
        
        l.Country = 'Albania';
        update l;
        
        Account a=new Account(name='prova');
        insert a;
        
        Contact c=new Contact(AccountId=a.id, lastname='prova', username__c='u', Password__c='p', email='prova@prova.it');
        insert c;
        
        
        cPortaleRivenditori.saveRowTable('Lead', l);
        
        cPortaleRivenditori.doLogin('u','p');
        cPortaleRivenditori.doLogin('u','p1');
        cPortaleRivenditori.doLogin('u1','p1');

        cPortaleRivenditori.sendEmailForgetPwd('prova@prova.it');
        cPortaleRivenditori.sendEmailForgetPwd('test@prova.it');
        
//        Attachment att=new Attachment(parentId=a.id, name='prova', body=blob.valueOf('prova'));
        cPortaleRivenditori.uploadAttachment(a.id, 'prova', 'prova');

        cPortaleRivenditori.getAttachment (a.id);
//        cPortaleRivenditori.fieldType ft=new cPortaleRivenditori.fieldType();
//        ft.oggetto='prova';
        
        List<String> oggetti=new List<String>();
        oggetti.add('Lead');
        
        cPortaleRivenditori.getCampi(oggetti);

        Field_Dealer_Portal__c f1=new Field_Dealer_Portal__c();
        f1.Key_Field__c='Lead.LastName';
        f1.type__c='text';
        f1.Label__c='LastName';
        insert f1;
        
        Table_Dealer_Portal__c t1=new Table_Dealer_Portal__c();
        t1.Name='t1';
        t1.Key_Table__c='t1';
        t1.soql__c='select id, lastname from lead';
        t1.soql_2__c='select id, lastname from lead';
        insert t1;

        Column_Dealer_Portal__c c1=new Column_Dealer_Portal__c();
        c1.Table_Dealer_Portal__c=t1.id;
        c1.Field_Dealer_Portal__c=f1.id;
        c1.Order__c=1;
        insert c1;
        
        
        Form_Dealer_Portal__c fo1=new Form_Dealer_Portal__c();
        fo1.Name='fo1';
        fo1.Key_Form__c ='fo1';
        fo1.soql__c='select id, lastname from lead';
        insert fo1;

        Row_Dealer_Portal__c r1=new Row_Dealer_Portal__c();
        r1.Form_Dealer_Portal__c =fo1.id;
        r1.Field_Dealer_Portal__c=f1.id;
            
        cPortaleRivenditori.getConfigurazioneCampi(oggetti);
        
        cPortaleRivenditori.getConfigurazioneCampiForm(oggetti);

        
        List<String> lo=new List<String>();
        lo.add('t1');

        Map<String, List< List<sObject>>> m=cPortaleRivenditori.getDati( lo, a.id );
        
        cPortaleRivenditori.getDatiForm('fo1', l.id);
        cPortaleRivenditori.getDatiForm('xxx', l.id);
        
        /*
    global static Map <String,sobject>  saveRowTable (Map <String,sobject> mappa, String nomeOggetto, boolean updt) 

		*/
    }
       
}