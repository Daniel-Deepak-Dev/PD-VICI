@isTest
public class tStatusCaseUpdatedByMail 
{
    @isTest
    public static void testCaseUpdatedByMail() 
    {
        Account a = new Account(name='prova');
        insert a;
        Contact c=new Contact(accountId=a.id, lastname='prova', email='prova@prova.it');
        insert c;
        
        Case ca=new Case(accountId=a.id, contactId=c.id,status='Nuovo');
        insert ca;
        
        datetime dt=datetime.now();
        EmailMessage em=new EmailMessage(subject='prova', FromAddress='prova@prova.it', parentId=ca.id, Incoming=true, MessageDate=dt);
        insert em;
        
        case ca2=[select Nuova_email__c, Data_ora_ultima_mail__c from Case where id=:ca.id];
        system.debug(ca2);
        system.assert(ca2.Nuova_email__c==true);
        system.assert(ca2.Data_ora_ultima_mail__c!=dt);
    }
}