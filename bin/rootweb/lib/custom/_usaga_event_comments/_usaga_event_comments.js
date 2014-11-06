define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!_usaga_event_comments/_usaga_event_comments.html',
'dojo/request', 
'jspire/request/Xml',
'_usaga_event_comment_view/_usaga_event_comment_view'
],function(declare,_Widget,_Templated,templateString, R, RXml, ECV){

 return declare([ _Widget, _Templated], {
       widgetsInTemplate:true,
       templateString:templateString,
load: function(_id){
var t = this;
t.reset();
   R.get('fun_view_events_comments_xml.usaga', {
            // Parse data from xml
	query: {idevent: _id},
            handleAs: "xml"
        }).then(
                function(response){
var d = new RXml.getFromXhr(response, 'row');
numrows = d.length;

var myData = {identifier: "unique_id", items: []};

if(numrows > 0){
var i = 0;
while(i<numrows){
x = new ECV();
var f = {attachments:[]};

try{
f = JSON.parse(d.getString(i, "files"));
}
catch(e){
//f = d.getString(i, "files");
//console.log(e);
}

x.set('values', {comment: d.getStringFromB64(i, "comment"), idcomment: d.getInt(i, "idcomment"), date_start: d.getString(i, "date_start"), date_end: d.getString(i, "date_end"), seconds: d.getInt(i, "seconds"), status: d.getInt(i, "idstatusevent"), files: f});
t.Container.addChild(x);
i++;
}

}

                },
                function(error){
                    // Display the error returned
console.log(error);
t.emit('notify_message', {message: error}); 
                }
            );
},
reset: function(){
var t = this;
t.Container.destroyDescendants(false);
}

   
});
});
