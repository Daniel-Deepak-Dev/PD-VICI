Vue.component ('gn-row',{
    template: '#templateGnRow',
    props:{
        config: Object,
        datiriga: Object,
        arraycolumn: Array,
        fieldsmap: Array,
        iddealer: String,
        showdetail: Boolean,
    },
    data:function(){
        return {
            sobject: {},
            ro: Boolean,
        };
    },
    
    created: function(){
        this.readOnly();
    },
    
    methods:{
        readOnly: function (){
            this.ro=this.datiriga[this.config.readOnlyField];
        },
        
        setForm:function(form,row){
            this.$emit("openform",form,row);
        },  
        
        openLink: function(url){
            this.$emit("openlink", url);
        },  
        
        serialize:function(){
            var oggetto ={};
            var self=this;
            oggetto.sobjectType = this.config.objectName;
            self.arraycolumn.forEach(function(d,index){
                if (d.type=='id' && self.datiriga[d.field]!="") {
                    oggetto[d.type]=self.datiriga[d.field] ;
                }
                if (!d.ro ){
                    oggetto[d.field]=self.datiriga[d.field];
                    if (d.type=='date' && self.datiriga[d.field]!=undefined && typeof self.datiriga[d.field]!='number' ) {
                        oggetto[d.field]= moment.utc(self.datiriga[d.field],"YYYY-MM-DD").valueOf();
                    }
                };
                
            });
            if  (this.config.objectName=='Lead')  {
                oggetto.Country=oggetto.Country__c;
                oggetto.Dealer__c=this.iddealer;
            };
            if  (this.config.objectName=='Opportunity' || this.config.objectName=='Case' )  {
                oggetto.AccountId=this.iddealer;
            };
            return oggetto;
        },
        
        enableSave:function (){
            var oggetto ={};
            var self=this;
            oggetto.sobjectType = this.config.objectName;
            var c=0;
            self.arraycolumn.forEach(function(d,index){
                if (d.required && (self.datiriga[d.field]==""  || self.datiriga[d.field]==undefined))  c=c+1;
            });
            if (c>0) return true
            else return false;
        },
        
        saveRow: function () {
            var self=this;
            var temp = this.serialize();
            cPortaleRivenditori.saveRowTable(self.config.objectName, temp, function(data,event) {
                if (event.status) {
                   // console.log('Row Salvata!');
                    alert ('Record successfully saved'); 
                    self.$emit("refreshtable", self.config.tableName);
                } else
                    console.log(event.message);                
                doBusy(false);    
            }); 
            
        },
    },
});