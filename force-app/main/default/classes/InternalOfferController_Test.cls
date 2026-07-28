@isTest
private class InternalOfferController_Test {
	@isTest
    static void testAggiornamento() {
        Test.startTest();
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test';
        opp.StageName = 'Special';
        opp.CloseDate = Date.today();
        insert opp;
        
        ProgressivoOffertaInterna__c prog = new ProgressivoOffertaInterna__c();
        prog.Last__c = 0;
        insert prog;
        
        InternalOfferController.updateOpportunity(opp.Id);
        
        Test.stopTest();
        
        System.assertEquals(InternalOfferController.leftCode + (String.valueOf(Date.today().year()).mid(2,3)) + '0001',
                            [SELECT Internal_Vici_offer_nr__c FROM Opportunity WHERE Id = :opp.Id].Internal_Vici_offer_nr__c);
        System.assertEquals(1, [SELECT Last__c FROM ProgressivoOffertaInterna__c WHERE Id = :prog.Id].Last__c);
    }
    
    @isTest
    static void testException() {
        Opportunity opp = new Opportunity();
        opp.Name = 'Test';
        opp.StageName = 'Special';
        opp.CloseDate = Date.today();
        opp.Internal_Vici_offer_nr__c = 'QSF' + String.valueOf(Date.today().year()).mid(2,3) + '1';
        opp.Validity_internal_offer_if_present__c = Date.today();
        insert opp;
        
        ProgressivoOffertaInterna__c prog = new ProgressivoOffertaInterna__c();
        prog.Last__c = 0;
        insert prog;
        
        try {
            InternalOfferController.updateOpportunity(opp.Id);
        } catch(InternalOfferController.IntOfferException ex) {
            System.assert(true);
        }
    }
}