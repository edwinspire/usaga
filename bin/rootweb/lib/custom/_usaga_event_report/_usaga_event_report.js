define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!_usaga_event_report/_usaga_event_report.html'
],function(declare,_Widget,_Templated,templateString){

 return declare([ _Widget, _Templated], {
       widgetsInTemplate:true,
       templateString:templateString,
       postCreate: function(){
       
       
       },
       load: function(_id){
        var t = this;
            t.EV.load(_id);  
            t.EV.on('onloadevent', function(e){
            t.TB.set('label', 'REPORTE');            
            window.setTimeout(t.EC.load(e.idevent), 1500);
            });
       }
       
          
});
});
