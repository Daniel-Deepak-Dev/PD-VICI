Vue.component ('gn-attachment',{
    
    template: '#templateGnAttachment',
    props:{
        parentid: '',
        ro: Boolean,
        
    },
    
    data:function(){
        return {
            arrayattachment: [],
            description: '',

        }
    },
    filters:{
        formatDate: function(d){
            d=moment(d).format("DD-MM-YYYY");
            return d;
        },
        formatDateTime: function(d){
            d=moment(d).format("DD-MM-YYYY HH:mm");
            return d;
        },
        formatSize: function(d){
            d=d/1024;
            d = d.toFixed(2);
            return d;
        },
    },
    created: function(){
        
    },
    
    mounted: function(){
        this.loadAttachment();
    },
    
    
    methods:{
        loadAttachment: function (){
            var self=this;
            cPortaleRivenditori.getAttachment(this.parentid, function(data, event){
                if (event.status){
                    self.arrayattachment.splice(0, self.arrayattachment.length);
                    self.arrayattachment=data;
                };                
            });
        },          
        
        downloadFile: function(idFile){
            if (idFile!=undefined){
                var l ='/servlet/servlet.FileDownload?file=' + idFile;
                window.open(l);
            }
        },  
        
        saveNewAttachment: function () {
            
        },
        
        onchange: function(evt) {
            
            var file;
            var files = evt.target.files;
            if (!files || files.length == 0) return;
            file = files[0];
			//console.log(file.size);
            var sizeAttachment = file.size/(1024*1024);
            if (sizeAttachment >2) {alert ('You can not upload files larger than 2MB'); return;}
            var newattachment = {};
            newattachment.Name=file.name;
            newattachment.BodyLength=file.size;
            newattachment.ParentId=this.parentid;
			var self=this;
            
            var reader = new FileReader();
            reader.readAsDataURL(file);
            reader.onload = function () {
                console.log(reader.result.substr(0.100));
                var x=reader.result.search('base64,');
                if (x>=0) {
                    newattachment.Body=reader.result.substr(x+7, reader.result.length);
                  //  console.log(newattachment.Body.substr(0.100));
                    self.uploadNewAttachment(newattachment);
                }
            };
            
        },
        
        uploadNewAttachment: function (sobjectAttachment){
            var self=this;
            cPortaleRivenditori.uploadAttachment(sobjectAttachment.ParentId, sobjectAttachment.Name, sobjectAttachment.Body, function(data, event){
                self.arrayattachment.push(sobjectAttachment);
            }, { buffer: false, escape: true, timeout: 120000 });
        },  
        
    },
});
