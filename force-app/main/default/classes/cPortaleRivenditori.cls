global class cPortaleRivenditori {
    @RemoteAction
    global static String doLogin(String username, String password) 
    {
        system.debug(username);
        system.debug(password);
        
        List<Contact> lc=[select id, accountId, Username__c, Password__c , Login_Error_Count__c, Last_Succesfully_Login__c from Contact where username__c=:username and isBlocked__c=false];
        
        if (lc.size()>0)
        {            
            if (lc[0].password__c==password) {
                lc[0].Last_Succesfully_Login__c=DateTime.now();
                lc[0].Login_Error_Count__c=0;
                update lc[0]; 
                return lc[0].accountId;
            } else
            {
                // wrong password
                if (lc[0].Login_Error_Count__c!=null)
                    lc[0].Login_Error_Count__c++;
                else
                    lc[0].Login_Error_Count__c=1;
                update lc[0]; 
                return null;
            }
            
        } else return null;
        
    }
    
    @RemoteAction
    global static String sendEmailForgetPwd(String email ) 
    {
        system.debug(email);        
        List<Contact> lc=[select id, accountId, Email , Username__c, Password__c , resetPwdDealer__c , Login_Error_Count__c, Last_Succesfully_Login__c from Contact where Email=:email ];
        
        if (lc.size()>0)
        {    
            
            lc[0].resetPwdDealer__c=true;
            update lc[0]; 
            return 'Email Send';
            
        } else return null;
        
    }
    
    
    
    
    @RemoteAction
    global static String uploadAttachment(String parentId, String filename, String payload )
    {
        Attachment att=new Attachment();
        att.Name=filename;
        if (att.Name=='') att.Name='untitled';
        att.ParentId=parentId;
        att.Body=EncodingUtil.base64Decode(payload);
        system.debug(att);
        
        insert att;
        
        return 'File Caricato con successo';
    }
    
    
    @RemoteAction
    global static List<Attachment> getAttachment (String parentid)
    {
        List <Attachment> attachment = [select id, name, Description, OwnerId , BodyLength, CreatedDate from Attachment where parentId=:parentid order by CreatedDate desc];
        return attachment;
    }
    
    
    global class fieldType
    {
        string oggetto;
        string name;
        string label;
        string format;
        integer size;
        integer size2;
        string values;
        string labels;
    }
    
    
    @RemoteAction
    global static List<fieldType> getCampi(List<String> oggetti)
    {
        
        // nome, tipo, size, size2, valori
        List<fieldType> lf=new List<fieldType>();
        
        for (String oggetto: oggetti) {
            Schema.SObjectType targetType = Schema.getGlobalDescribe().get(oggetto);
            Schema.DescribeSObjectResult dsr = targetType.getDescribe();
            
            for (Schema.SObjectField sof:dsr.fields.getMap().values())
            {
                Schema.DescribeFieldResult dfr=sof.getDescribe();
                Schema.DisplayType dt = dfr.getType(); 
                
                fieldType ft=new fieldType();
                ft.oggetto=oggetto;
                ft.name=dfr.getName();
                ft.label=dfr.getLabel();
                ft.size=dfr.getLength();
                ft.size2=dfr.getScale();
                
                //system.debug(ft.name);
                //system.debug(ft.label);
                
                if (dt==Schema.DisplayType.Boolean)         ft.format='Boolean';
                if (dt==Schema.DisplayType.Date)            ft.format='Date';
                if (dt==Schema.DisplayType.Currency )       ft.format='Currency';
                if (dt==Schema.DisplayType.String )         ft.format='String';
                if (dt==Schema.DisplayType.TextArea )       ft.format='TextArea';
                if (dt==Schema.DisplayType.picklist )       ft.format='Picklist';
                if (dt==Schema.DisplayType.multipicklist )  ft.format='MultiPicklist';
                
                ft.values='';
                ft.labels='';

                List<Schema.PicklistEntry> lpe = dfr.getPicklistValues();
                for (Schema.PicklistEntry pe:lpe)
                {  
                    ft.labels+=pe.getLabel()+';';
                    ft.values+=pe.getValue()+';';
                }
                
                
                //system.debug(ft.values);
                lf.add(ft);
            }
        }
        
        return lf;        
        
        
    }

    @RemoteAction
    global static map <string, List <LIst <sObject>>> getDati(List<String> oggetti,  String idDealer) 
    {
        system.debug(idDealer);
        List <Table_Dealer_Portal__c> ltd = [Select Name, Key_Table__c , SOQL__c , SOQL_2__c  From Table_Dealer_Portal__c WHERE Name=:oggetti ];
        system.debug(ltd);
        map <string, List <LIst <sObject>>> mappa = new  map <string, List <LIst <sObject>>>();
        if (ltd.size()>0)
        {
            for (Table_Dealer_Portal__c tdp:ltd) {
                List <LIst <sObject>> lista = new List <LIst <sObject>>();
                String query = '';
                String target = '$id';
                if (tdp.SOQL__c.contains(target)) query = tdp.SOQL__c.replace(target,idDealer);
                else query = tdp.SOQL__c;
                
                system.debug(query);
                LIst <sObject> llr = database.query(query);
                lista.add(llr);
                
                //da rivedere SOQL2
                /*
                if (tdp.SOQL_2__c!=null && tdp.SOQL_2__c!='') {
                LIst <sObject> llr2 = database.query(tdp.SOQL_2__c);
                lista.add(llr2);
                }
                
                */
                
                mappa.put(tdp.name,lista);
            }
        }
        return mappa;
    }
    
    @RemoteAction
    global static sObject getDatiForm(String oggetto, String idOggetto) 
    {
        system.debug(oggetto); 
        system.debug(idOggetto); 
        List <Form_Dealer_Portal__c > ltd = [Select Name, Key_Form__c , SOQL__c  From Form_Dealer_Portal__c  WHERE Name=:oggetto ];
        system.debug(ltd);        
        if (ltd.size()>0)
        {
            String query = ltd[0].SOQL__c + ' WHERE Id= \'' + idOggetto +'\' ';
            system.debug(query); 
            
            sObject obj = database.query(query);
            
            return obj;
        }
        
        return null;
    }
    
    @RemoteAction
    global static List <Column_Dealer_Portal__c> getConfigurazioneCampi(List<String> oggetti) 
    {
        
        List <Column_Dealer_Portal__c> llr = [Select Field_Dealer_Portal__r.Id, Table_Dealer_Portal__r.Name, Order__c, Field_Dealer_Portal__r.Key_Field__c, Field_Dealer_Portal__r.Name,  
                                              Field_Dealer_Portal__r.Label__c, Field_Dealer_Portal__r.Type__c, Field_Dealer_Portal__r.Value__c , Field_Dealer_Portal__r.isReadOnly__c , Field_Dealer_Portal__r.isRequired__c 
                                              from Column_Dealer_Portal__c  
                                              where Table_Dealer_Portal__r.Name=:oggetti order by Order__c];
        return llr;
    }
    
    @RemoteAction
    global static List <Row_Dealer_Portal__c> getConfigurazioneCampiForm(List<String> oggetti) 
    {
        
        List <Row_Dealer_Portal__c> llr = [Select Name, Field_Dealer_Portal__r.Id, Form_Dealer_Portal__r.Name, Order__c, Field_Dealer_Portal__r.Key_Field__c, Field_Dealer_Portal__r.Name,  
                                           Field_Dealer_Portal__r.Label__c, Field_Dealer_Portal__r.Type__c, Field_Dealer_Portal__r.Value__c , isSection__c  , Position__c , Section__c , Field_Dealer_Portal__r.isReadOnly__c , Field_Dealer_Portal__r.isRequired__c 
                                           from Row_Dealer_Portal__c   
                                           where Form_Dealer_Portal__r.Name=:oggetti order by Section__c , Order__c, Position__c];
        return llr;
    }
    
    @RemoteAction
    global static sobject saveRowTable (String oggettoNome, sobject riga) 
    {   
        system.debug(riga);
        upsert riga ;
        return riga;
    }

    /*
    
    @RemoteAction
    global static String deleteRowTable (String idRow) 
    {   
        system.debug(idRow);
        
        list <Opportunity> lo = [select id from Opportunity where id=:idRow];
        
        delete lo;
        return idRow;
    }
	*/
    
}