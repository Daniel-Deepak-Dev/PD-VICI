Vue.component ('gn-form',{
    template: '#templateGnForm',
    props:{
        arrayrow: Array,
        fieldsmap: Array,
        datiform: Array,
        config: Object,
    },
    data:function(){
        return {
            sobject: {},
            ro: Boolean,
        };
    },
    
    
    filters:{
        formatDate: function(d){
            d=moment(d).format("YYYY-MM-DD HH:mm");
            return d;
        },
    },
    
    created: function(){
        this.readOnly();
        
    },
    
    methods:{
        
        readOnly: function (){
            this.ro=this.datiform[0][this.config.readOnlyField];
            
        },
        
        
        returnTable: function () {
            this.$emit("returntable");
        },
        
        serialize:function(){
            var oggetto ={};
            var self=this;
            oggetto.sobjectType = this.config.objectName;
            self.config.configurazioneForm.forEach(function(d,index){
                if (!d.ro && !d.issection && self.datiform[0][d.field]!=undefined){
                    oggetto[d.field]=self.datiform[0][d.field];
                    if (d.type=='date') {
                        oggetto[d.field]=Date.now();
                    }
                };
            });
            oggetto.Id=this.datiform[0]['Id'];
            return oggetto;
        },
        
        saveFormField: function () {
            var self=this;
            var temp = this.serialize();
            cPortaleRivenditori.saveRowTable(self.config.objectName, temp, function(data,event) {
                if (event.status) {
                    console.log('Row Salvata!');
                    alert ('Successfully saved');
                    console.log(self.config.tableName);
                    var tableName = self.config.tableName.substring(0, self.config.tableName.indexOf("E"));
                    console.log(tableName);
                    self.$emit("refreshtable", tableName);

                } else
                    console.log(event.message);                
                doBusy(false);    
            }); 
            
        },
    },
});
