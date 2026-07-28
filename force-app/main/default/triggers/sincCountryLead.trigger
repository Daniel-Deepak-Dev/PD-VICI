trigger sincCountryLead on Lead (after insert, after update) 
{    
    Map<String, String> mss = new Map<String,String>();
    for (lead l : Trigger.new)
    {
        if(trigger.isInsert){
            if (l.Country!=null) {
                mss.put(l.Id, l.Country);
            }
            if (l.Country==null && l.Country__c!=null) {
                mss.put(l.Id, l.Country__c);
            }
        }
        
        if(trigger.isUpdate) {
            Lead oldLead = trigger.oldMap.get(l.Id);
            system.debug(oldLead.country);
            system.debug(l.country);
            if (l.Country!=null) {
                if(l.Country__c != oldLead.Country__c && l.Country != l.Country__c)
                    mss.put(l.Id, l.country__c);
                if(l.Country != oldLead.Country && l.Country != l.Country__c)
                    mss.put(l.Id, l.country);
            }
            if (l.Country==null && (l.Country__c!=null || l.Country__c != oldLead.Country)) mss.put(l.id, l.Country__c);            
        }
    }
    
    if(mss.keySet().size() > 0) {
        List<Lead> ll = [Select Id, Name, Country, Country__c FROM Lead WHERE Id=:mss.keySet()];
        
        for(Lead l : ll)  {
            if(mss.containsKey(l.Id)) {
                l.Country = mss.get(l.Id);
                l.Country__c = mss.get(l.Id);
            }
        }
        
        update ll;
    }
}