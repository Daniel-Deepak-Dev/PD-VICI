Vue.component('gn-field', {
    props:{
        fieldtype: {
            type:Object,
        },
        value: [String, Number, Boolean],
        fieldsmap: Array,
        arrayrow: Array,
        config: Object,
        ro: Boolean,
        showdetail: Boolean,
    },
    data:function(){
        return {
            fieldValue:[String, Number, Boolean],
            showInputDate: false,
            focustextarea:false,
        }
    },
    
    created: function(){
        this.fieldValue=this.value;
    },
    
    
    template: '#templateGnField',
    filters:{
        formatDate: function(d){
            var v=moment(d).format("YYYY-MM-DD");
            return v;
        },
        formatDateTime: function(d){
            var v=moment(d).format("YYYY-MM-DD HH:mm");
            return v;
        },
    },
    
    methods: {        
        save: function () {
            this.showInputDate=false;
            this.focustextarea=false;
            this.$emit("updateenablesave");            

            if (this.$parent.config.tableName=='tableOpportunityExploded' || this.$parent.config.tableName=='tableLeadExploded') this.$parent.datiform[0][this.fieldtype.field]=this.fieldValue;
            else this.$parent.datiriga[this.fieldtype.field]=this.fieldValue;
        },
        linkDetail:function(){
            this.$emit("openform",this.$parent.config.objectName,this.$parent.datiriga);            
        },  
        
        link:function(){
            this.$emit("openlink", this.$parent.datiriga.Link__c);
        },  
        
    }
});