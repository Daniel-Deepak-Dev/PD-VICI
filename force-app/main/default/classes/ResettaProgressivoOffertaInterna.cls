global class ResettaProgressivoOffertaInterna implements Schedulable{
    private final static String sch = '0 0 0 1 JAN ? ';
    private final String jobName;
    
    global ResettaProgressivoOffertaInterna(String jobName) {
        this.jobName = jobName;
    }
    global void execute(SchedulableContext sc) {
        ProgressivoOffertaInterna__c cs = [SELECT Last__c FROM ProgressivoOffertaInterna__c];
        cs.Last__c = 0;
        update cs;
        ResettaProgressivoOffertaInterna p = new ResettaProgressivoOffertaInterna(this.jobName);
        
        String newDate = sch + (Date.today().year()+1);
        System.debug('newDate: '+newDate);
        if (sc.getTriggerId() != NULL) System.abortJob(sc.getTriggerId());
        System.schedule(jobName, newDate, p);
    }
}