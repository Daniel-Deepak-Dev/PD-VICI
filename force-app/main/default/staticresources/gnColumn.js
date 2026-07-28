Vue.component ('gn-column',{
    template: '<th>{{metadati.label}}</th>',
    props:{
        metadati:{
            type: Object,
        }
    },
    data:function(){
        return {
            sobject: {},
        };
    },
    
    created: function(){
    },
    
    
    methods:{
        
    },
});