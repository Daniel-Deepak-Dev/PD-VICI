@isTest
public class tcEmailGDPR {
    testMethod static void testEmailGDPRcontact()
    {
        contact c = new contact();
        c.LastName='test';
        c.Email='test@gmail.com';
        insert c;
        
        c.Email='testCambio@gmail.com';
        update c;
        
        pagereference page = page.landingPageGDPR;
        page.getParameters().put('Id',c.id);
        test.setCurrentPage(page);
        
        cGDPR controller = new cGDPR();
        controller.privacy = true;
        controller.updateGDPR();
    }
    
    
    testMethod static void testEmailGDPRlead()
    {
        lead l = new lead();
        l.Email='test@gmail.com';
        l.LastName='test';
        l.Country='Italy';
        l.company='test';
        insert l;
        
        l.Email='testCambio@gmail.com';
        update l;
        
        pagereference page = page.landingPageGDPR;
        page.getParameters().put('Id',l.id);
        test.setCurrentPage(page);
        
        cGDPR controller = new cGDPR();
        controller.privacy = true;
        controller.updateGDPR();
    }
}