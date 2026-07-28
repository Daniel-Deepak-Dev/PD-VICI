var myApp = new Vue ({
    el:'#myApp',
    data:{
        sobject:{},
        configurazioneColonne:[],
        datiRighe:[],
    },    
    created:function (){
        this.test();  
        this.testRighe();
    },
    methods:{
        test: function(){
            var c1 = {label:'', type:'text',};
            this.configurazioneColonne.push(c1);
            var c2 = {label:'Titolo', type:'text',};
            this.configurazioneColonne.push(c2);
            var c3 = {label:'Descrizione', type:'text',};
            this.configurazioneColonne.push(c3);
            var c4 = {label:'Link', type:'url', };
            this.configurazioneColonne.push(c4);
            var c5 = {label:'Data', type:'data', };
            this.configurazioneColonne.push(c5);
            
        },  
        testRighe:function(){
            var c1 = ['','Risorsa 1','risorsa 1 pdf','link risorsa 1', '2017-01-10'];
            this.datiRighe.push(c1);
            var c2 = ['','Risorsa 1','risorsa 1 pdf','link risorsa 1', '2017-01-10'];
            this.datiRighe.push(c2);
            
        },
    },
});