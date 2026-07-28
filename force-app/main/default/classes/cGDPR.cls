public class cGDPR {
    public Lead l {get;set;}
    public Contact c {get;set;}
    public boolean done {get; set;}    
    public boolean isIdValid {get; set;}   
    public boolean isUpdate {get; set;}    
    public boolean privacy {get; set;}    
    public string language {get; set;}    
    public string link {get; set;}    
    
    public void updateGDPR() {
        String id = ApexPages.currentPage().getParameters().get('id');
        language = ApexPages.currentPage().getParameters().get('language');
        link = ApexPages.currentPage().getParameters().get('link');
        system.debug(language);
        if (id!=null) {
            //Lead
            if (id.startsWith('00Q')){
                try{
                    l=[select id, Privacy__c  from lead where id=:id];
                    isIdValid = true;
                } catch (exception e) {
                    system.debug(e);
                }
            }
            if (id.startsWith('003')){
                try{
                    c=[select id, Privacy__c  from contact where id=:id];
                    isIdValid = true;
                } catch (exception e) {
                    system.debug(e);
                }
            }
        }
        
        if (l!=null){
            l.privacy__c= (link=='u') ? 'No':'Yes';
            if (link=='s') l.HasOptedOutOfEmail=false;
            else l.HasOptedOutOfEmail=true;
            l.Data_risposta_GDPR__c  =Datetime.now();
            update l;
            isUpdate =true;
        }
        if (c!=null){
            c.privacy__c= (link=='u') ? 'No':'Yes';
            if (link=='s') c.HasOptedOutOfEmail=false;
            else c.HasOptedOutOfEmail=true;
            c.Data_risposta_GDPR__c  =Datetime.now();
            update c;
            isUpdate =true;
        }
    }
    
    public cGDPR()
    {
        done = false;
        isIdValid = false;
        isUpdate = false;
        
        
    }
}