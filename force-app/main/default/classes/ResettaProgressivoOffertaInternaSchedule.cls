public class ResettaProgressivoOffertaInternaSchedule {
    public static String schedule(String jobName) {
        String sch = '0 0 0 1 JAN ? ' + (Date.today().year()+1);
        ResettaProgressivoOffertaInterna p = new ResettaProgressivoOffertaInterna(jobName);
        
        System.debug('CRONEXP: ' + sch);
        return System.schedule(jobName, sch, p);
    }
}