@isTest
public class ResetProgressivoOffertaInterna_Test {
	@isTest
    static void testSchedule() {
        Test.startTest();
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test';
        opp.StageName = 'Special';
        opp.CloseDate = Date.today();
        insert opp;
        
        ProgressivoOffertaInterna__c prog = new ProgressivoOffertaInterna__c();
        prog.Last__c = 999;
        insert prog;
        
        String jobId = ResettaProgressivoOffertaInternaSchedule.schedule('TestSchedule');
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger WHERE id = :jobId];
        System.debug('TimesTriggered: '+ct.TimesTriggered);
        System.debug('NextFireTime: '+ String.valueOf(ct.NextFireTime));
        System.assertEquals(999, [SELECT Last__c FROM ProgressivoOffertaInterna__c].Last__c);
        // Verify the next time the job will run
        System.assertEquals('2021-01-01 00:00:00', String.valueOf(ct.NextFireTime));
        
        Test.stopTest();
        
        System.assertEquals(0, [SELECT Last__c FROM ProgressivoOffertaInterna__c].Last__c);
    }
}