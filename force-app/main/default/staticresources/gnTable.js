Vue.component ('gn-table',{
    
    template: '#templateGnTable',
    props:{
        config: Object,
        arrayrow: Array,
        arraycolumn: Array,
        fieldsmap: Array,
        iddealer: String,
        showdetail: Boolean,
    },
    
    data:function(){
        return {
            sobject: {},
            
        };
    },
    
    created: function(){
    },
    
    
    methods:{
        setForm:function(form,row){
            this.$emit("openform",form,row);
        },  
        
        openLink: function(url){
            this.$emit("openlink", url);
        },  
        
        refreshTable:function(nomeTable){
            this.$emit("refreshtable",nomeTable);
        },  
        
    },
});
