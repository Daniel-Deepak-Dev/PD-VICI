public class CloneSurveyController {
    
  public String currentRecordId {get;set;}
  public Survey__c survey {get;set;}
    public CloneSurveyController(ApexPages.StandardController stdController){
        survey = (Survey__c)stdController.getRecord();
        system.debug('survey---->' +survey);
    }
    
    public Message pageMessage {
        get {
            if (pageMessage == null) {
                pageMessage = new Message();
            }
            return pageMessage;
        }
        set;
    }

    public Pagereference save(){
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
        Pagereference retVal = null;
        //Adding default CSS to add some space around survey
        //But this is changeable
        List<Survey_Question__c  > surveQuest = new List<Survey_Question__c>();
       
        Survey__c  surv = [SELECT ID,Name,Survey_Header__c,Survey_Container_CSS__c,Hide_Survey_Name__c,Share_with_Guest_User__c,Submit_Response__c,
                           Thank_You_Text__c,URL__c,thankYouLink__c,thankYouText__c FROM Survey__c WHERE id =: currentRecordId];
        Survey__c survCopy = surv.clone(false,true);
        survCopy.Name = survey.name;
        insert survCopy;
        List<Survey_Question__c> quest = [SELECT Id, Name, Survey__c,Question__c,Type__c,OrderNumber__c,Choices__c,Total_Responses__c FROM Survey_Question__c WHERE Survey__c = : surv.Id];
        for(Survey_Question__c q : quest)
        {
            Survey_Question__c questCopy = q.clone(false,true);
            questCopy.Survey__c = survCopy.Id;
            surveQuest.add(questCopy);
        }
        insert surveQuest;
        retVal = new Pagereference('/apex/SurveyManagerPage?id=' + survCopy.Id);
        return retVal;
  }
}