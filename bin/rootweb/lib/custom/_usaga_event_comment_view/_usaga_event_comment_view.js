define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!_usaga_event_comment_view/_usaga_event_comment_view.html',
'dojo/_base/array',
'dojo/dom-construct'
],function(declare,_Widget,_Templated,templateString, array, domConstruct){

 return declare([ _Widget, _Templated], {
       widgetsInTemplate:true,
       templateString:templateString,
_setValuesAttr: function(v){
var t = this;
if(v.idcomment>0){
t.IdComment.innerHTML = v.idcomment;
t.Inicio.innerHTML = new Date (v.date_start).toUTCString();
//console.log(v.status);
if(v.status == 0){
t.Estado.innerHTML = 'Abierto';
}else{
t.Estado.innerHTML = 'Finalizado';
}

t.Tiempo.innerHTML = v.seconds+' seg.';
t.Comment.set('content', v.comment);

try{
  array.forEach(v.files.attachments, function(entry, i){

   var RegExPattern = /([^\s]+(?=\.(jpg|gif|png|JPG))\.\2)/gm;

    if ((entry.file_name.match(RegExPattern))) {
domConstruct.place('<img border="0" style="margin:5px;" src="/uploads/'+entry.file_name+'" alt="'+entry.real_name.from_b64()+'" width="100%">', t.AttachmentFilesArea, "first");
	console.log(entry.file_name+' es imagen');
    } else {
	console.log(entry.file_name+' No es imagen');
    } 



  });

//console.log('====== '+v.files.attachments.length);
t.Attachments.innerHTML = v.files.attachments.length;

}
catch(e){
console.log(e);
}




}else{
t.reset();
}
},
reset: function(){
var t = this;
t.IdComment.innerHTML = 0;
t.Inicio.innerHTML = '';
t.Estado.innerHTML = '-';
t.Tiempo.innerHTML = 0+' seg.';
t.Comment.set('content', '');
}
   
});
});
