var myApp = new Vue ({
    el:'#myApp',
    data:{
        sobject:{},
        error:false,
        errorSendEmail:false,
        ready:false,
        showLogin:false,
        showForgetYourPwd:false,
        showSendEmail:false,
        showTab:false,
        showOpportunity: true,
        showLead: true,
        readyFormOpportunity: false,
        edit:false,
        tableName: [{nome:'tableLead', oggetto:'Lead'},
                    {nome:'tableOpportunity', oggetto:'Opportunity'},
                    {nome:'tableCase', oggetto:'Case'},
                    {nome:'tableDocumentationMarketing', oggetto:'Materiale_Marketing__c'}],
        
        formName : [{nome:'tableOpportunityExploded', oggetto:'Opportunity' },
                    {nome:'tableLeadExploded', oggetto:'Lead' }
                   ],
        
        
        credentials: {
            idDealer:'00111000012XlKwAAK',
            username: '',
            password: '',
            error:'',
            email:'',
            errorSendEmail:'',
        },       
    },
    
    created: function(){
        var self = this;
        
        async.series([
            function(callback) {
                self.createTableStructure(callback);
            },
            function(callback) {
                self.createFormStructure(callback);
            },
            function(callback) {
                var v=[];
                v=v.concat(self.tableName);
                v=v.concat(self.formName);
                self.initCampi(v,callback);
            }
        ], function(err, result) {
            //console.log(result);
            //console.log(err);
            self.showLogin=true;
            self.ready=true;
        });
    },
    
    methods:{
        
        loadDealerPortalData: function(){
            var self = this;
            async.series([
                function(callbackParallel) {
                    async.parallel([
                        function(callback) {
                            console.log('loadConfiguraTabelle');
                            self.loadConfiguraTabelle(self.tableName, callback);
                        },
                        function(callback) {
                            console.log('loadConfiguraForm');
                            self.loadConfiguraForm(self.formName, callback);
                        }
                    ], function(err, results ) {
                        callbackParallel();
                    });
                },   
                function(callback){
                    self.showTab=true;
                    self.loadColonne(self.tableName,callback);
                }
            ], function(err, result) {
                //console.log(result);
                //console.log(err);
            });        
        },
        
        createTableStructure: function (callback){
            var self = this;
            this.tableName.forEach(function(d){
                var struttura= { objectName:d.oggetto, tableName:d.nome, readOnlyField: 'isReadOnly__c', configurazioneColonne:[], datiRighe:[], fieldsMap: [], fieldsloaded: false,};
                Vue.set(self.sobject,d.nome,struttura);
                
            });
            if (callback!=undefined) callback(null,'create structure table');
            
        }, 
        
        createFormStructure: function (callback){
            var self = this;
            this.formName.forEach(function(d){
                var struttura= { objectName:d.oggetto, tableName:d.nome, readOnlyField: 'isReadOnly__c', configurazioneForm:[], strutturaForm:[], datiForm:[], fieldsMap: [], fieldsloaded: false,};
                Vue.set(self.sobject,d.nome,struttura);
                
            });
            console.log(this.formName);
            
            if (callback!=undefined) callback(null,'create structure form');
            
        }, 
        
        addRowTable: function (tabella){
            var newRow={};
            var ultimaRiga= tabella.datiRighe.length;
            if (ultimaRiga>0){
                var contenutoUltimaRiga = tabella.datiRighe[ultimaRiga-1];
                if (this.checkRowRequired(contenutoUltimaRiga,tabella)) return;
            }
            tabella.configurazioneColonne.forEach(function(d,index){ 
                newRow[d.field]="";  
                if (d.field==tabella.readOnlyField) newRow[d.field]=false;
                if (d.type=="date") newRow[d.field]=undefined;
                if (d.field=="LastModifiedDate" || d.field=="CreatedDate") newRow[d.field]=moment().format();
                
            });
            
            tabella.datiRighe.push(newRow);
        }, 
        
        checkRowRequired:function (oggetto,tabella){
            var self=this;
            var c=0;
            tabella.configurazioneColonne.forEach(function(d,index){
                if (d.required && oggetto[d.field]=="") c=c+1;
            });
            if (c>0) return true
            else return false;
        },
        
        decodeHTML: function(elemento){
            var parser = new DOMParser;
            var elem = document.createElement('textarea');
            elem.innerHTML = elemento;
            var text = parser.parseFromString(elem.value, 'text/html');
            elemento= text.body.textContent;
            return elemento;
        },
        
        
        initCampi: function (tabelle,callback) {
            var self=this;
            var oggetti=[];
            var mappa={};
            tabelle.forEach(function(d){               
                self.sobject[d.nome].fieldsMap.splice(0, self.sobject[d.nome].fieldsMap.length);
                mappa[d.oggetto]=d.nome;                
            });
            for (v in mappa)
                oggetti.push(v);
            doBusy(true);
            cPortaleRivenditori.getCampi(oggetti, function(data,event) {
                data.forEach(function(d,i){
                    d.values=self.decodeHTML(d.values);
                    d.labels=self.decodeHTML(d.labels);
                    tabelle.forEach(function(d2){
                        if (d2.oggetto==d.oggetto) {
                            var so=self.sobject[d2.nome];
                            so.fieldsMap[d.name]=d;
                        }
                    });
                });
                doBusy(false); 
                if (callback!=undefined) callback(null,'init campi');
            });            
        }, 
        
        getTableName: function(tabelle) {
            var oggetti=[];
            var mappa={};
            tabelle.forEach(function(d){               
                mappa[d.nome]=d.nome;                
            });
            for (v in mappa)
                oggetti.push(v);
            return oggetti;
        },
        
        creaColonna: function(l,t,f,v,r,re) {
            var o={label:l,type:t,field:f,value:v,ro:r,required:re};
            return o;
        },
        
        loadConfiguraTabelle: function (tabelle,callback){
            var self=this;
            var oggetti = this.getTableName(tabelle);
            doBusy(true);
            cPortaleRivenditori.getConfigurazioneCampi(oggetti, function(data, event){
                //console.log('getConfigurazioneCampi');
                if (event.status){
                    data.forEach(function(d,index){
                        tabelle.forEach(function(d2){
                            if (d2.nome==d.Table_Dealer_Portal__r.Name) {
                                var so=self.sobject[d2.nome];
                                so.configurazioneColonne.push(self.creaColonna(d.Field_Dealer_Portal__r.Label__c, d.Field_Dealer_Portal__r.Type__c, d.Field_Dealer_Portal__r.Name, d.Field_Dealer_Portal__r.Value__c, d.Field_Dealer_Portal__r.isReadOnly__c, d.Field_Dealer_Portal__r.isRequired__c ));
                            }
                        });
                    });
                };
                doBusy(false); 
                if (callback!=undefined) callback(null,'load colonne');
                
            });
        },  
        
        loadColonne: function (tabelle,callback){
            var self=this;
            var oggetti = this.getTableName(tabelle);
            doBusy(true);
            cPortaleRivenditori.getDati(oggetti, self.credentials.idDealer, function(data,  event){
                // console.log('getConfigurazioneCampi');
                if (event.status){
                    tabelle.forEach(function(d,index){
                        self.sobject[d.nome].datiRighe.splice(0, self.sobject[d.nome].datiRighe.length);
                        var record = data[d.nome];
                        record.forEach(function(d2,index){
                            d2.forEach(function(d3,index){
                                self.sobject[d.nome].datiRighe.push(d3);
                            });
                        });
                    });
                };
                doBusy(false);
                if (callback!=undefined) callback(null,'load colonne');
            });
        },  
        
        
        loadFieldForm:function(tabella, d){
            tabella.configurazioneRighe.forEach(function(f,i) {
                if (d[f.field]==undefined) f.value='';
                else f.value=d[f.field];
            });
        },
        
        creaRowForm: function(is,o,p,s,l,t,f,v,r,re) {
            var o={issection:is, order:o, position:p, section:s, label:l, type:t, field:f, value:v, ro:r, required:re};
            return o;
        },
        
        loadConfiguraForm: function (form,callback){
            var self=this;
            var oggetti = this.getTableName(form);
            cPortaleRivenditori.getConfigurazioneCampiForm(oggetti, function(data, event){
                //console.log('getConfigurazioneCampiForm');
                if (event.status){
                    data.forEach(function(d,index){
                        form.forEach(function(d2){
                            if (d2.nome==d.Form_Dealer_Portal__r.Name) {
                                var so=self.sobject[d2.nome];
                                if (!d.isSection__c)
                                    so.configurazioneForm.push(self.creaRowForm(d.isSection__c,d.Order__c,d.Position__c, d.Section__c, d.Field_Dealer_Portal__r.Label__c, d.Field_Dealer_Portal__r.Type__c, d.Field_Dealer_Portal__r.Name, d.Field_Dealer_Portal__r.Value__c, d.Field_Dealer_Portal__r.isReadOnly__c, d.Field_Dealer_Portal__r.isRequired__c ));
                                else
                                    so.configurazioneForm.push(self.creaRowForm(d.isSection__c,d.Order__c,d.Position__c, d.Section__c, d.Name));
                                self.setConfigurazioneForm(so);
                            };
                        });
                    });
                };
                if (callback!=undefined) callback(null,'load form');
            });
        },  
        
        
        setConfigurazioneForm: function (form){
            var array=[];
            var ordine=1;
            var o=[];
            //console.log(form.configurazioneForm);
            form.configurazioneForm.forEach(function(d,index){
                if (d.issection) array.push(d);
                else {
                    if (d.order!=ordine) {
                        o.push(d);
                        ordine=d.order;
                    } else {
                        o.push(d);
                        array.push(o);
                        //o.splice(0,o.length);
                        o=[];
                    };                    
                };
            });
            form.strutturaForm.splice(0,form.strutturaForm.length);
            form.strutturaForm=array;            
        },
        
        
        
        loadForm: function (form,row,callback){
            var self=this;
            var nomeForm ='';
            this.formName.forEach(function(d,index){
                if (d.oggetto==form)  nomeForm=d.nome;
            });
            doBusy(true);
            cPortaleRivenditori.getDatiForm(nomeForm, row.Id, function(data, event){
                if (event.status){
                    self.sobject[nomeForm].datiForm.splice(0, self.sobject[nomeForm].datiForm.length);
                    self.sobject[nomeForm].datiForm.push(data);
                    var datiForm =  self.sobject[nomeForm].datiForm;
                    var configurazioneForm  = self.sobject[nomeForm].configurazioneForm ;
                    configurazioneForm.forEach(function(d,index){
                                            console.log(d);

                        if (!d.issection) {
                            if (datiForm[0][d.field]==undefined) datiForm[0][d.field]=undefined;
                        }
                    });
                };   
                if (callback!=undefined) callback(null,'load form');
                doBusy(false);
            });
            this.readyFormOpportunity=true;
            
        }, 
        
        setForm: function (form,row){
            var self=this;
            console.log(form);
            async.series([ 
                function(callback){
                    self.loadForm(form,row, callback);  
                }
            ], function(err, result) {
                if (form=='Opportunity') self.showOpportunity=false;
                if (form=='Lead') self.showLead=false;
                
            });                 
        }, 
        
        openLink: function(url){
            if (url!=undefined){
                window.open(url);
            }
        },  
        
        refreshTable:function(nomeTable){
            var array = new Array();
            array.push({nome: nomeTable});
            this.sobject[nomeTable].datiRighe.splice(0, this.sobject[nomeTable].datiRighe.length);
            this.loadColonne(array,null);
        },  
        
        
        save:function(tabella){
            var self=this;
            doBusy(true);
            cPortaleRivenditori.insertOpportunity(query, function(data, event){
                if (event.status){
                    data.forEach(function(d,index){
                        self.loadField(tabella,d);
                    });
                    doBusy(false);    
                }
            });
        },
        
        loadRighe:function(tabella, query, callback){
            var self=this;
            doBusy(true);
            cPortaleRivenditori.getDati(query, function(data, event){
                if (event.status){
                    data.forEach(function(d,index){
                        self.loadFieldForm(tabella,d);
                    });
                    doBusy(false);    
                }
                if (callback!=undefined) callback(null,'load righe');
            });
        },
        
        
        sendEmailForgetPwd:function(){
            
            if (this.credentials.email!='') {
                var self=this;
                doBusy(true);
                cPortaleRivenditori.sendEmailForgetPwd(self.credentials.email, function(data, event){
                    if (event.status) {
                        if (data==null) {
                            self.credentials.errorSendEmail='Wrong Email';
                            self.errorSendEmail=true;
                        }
                        else {
                            self.errorSendEmail=false;
                            self.credentials.errorSendEmail='';
                        }
                        console.log(data);  
                        self.showSendEmail=true;
                    } else console.log(event.message);
                    doBusy(false);   
                });
                
            }
            
        },
        
        
        forgetYourPwd: function () {
            this.showLogin=false;
            this.showForgetYourPwd=true;
        },
        
        
        logIn: function () {
            var self = this;
            doBusy(true);
            this.showLogin=false;
            cPortaleRivenditori.doLogin(self.credentials.username, self.credentials.password, function(data,event){
                if (event.status) {
                    if (data==null) {
                        self.credentials.error='Wrong Login';
                        self.errorSendEmail=true;
                        self.showLogin=true;
                        self.error=true;
                        
                    }
                    else {
                        self.errorSendEmail=false;
                        self.credentials.error='';
                        self.credentials.idDealer=data;
                        self.loadDealerPortalData();
                    }
                    
                } else console.log(event.message);
                doBusy(false);    
            });
        },
        
    },
})

function doBusy(status)
{
    if (status) $('#busy').show();
    else $('#busy').hide();
}

function getParameterByName(name, url) {
    if (!url) url = window.location.href;
    name = name.replace(/[\[\]]/g, "\\$&");
    var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
        results = regex.exec(url);
    if (!results) return null;
    if (!results[2]) return '';
    return decodeURIComponent(results[2].replace(/\+/g, " "));
}