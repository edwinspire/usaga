define(['dojo/_base/declare',
'dijit/_Widget',
'dijit/_Templated',
'dojo/text!_common_notification_area/_common_notification_area.html',
"dojo/dom-construct",
"dojo/dom-style"
],function(declare,_Widget,_Templated,templateString, domConstruct, domStyle){

 return declare([ _Widget, _Templated], {
       widgetsInTemplate:true,
       templateString:templateString,
//	_boxShadowColor: new Array(),
baseUrl: '/lib/custom/_common_notification_area/media/',
postCreate: function(){
/*
var t = this;
t._boxShadowColor[0] = 'background: linear-gradient(to bottom, rgba(255,255,255,0) 0%, rgba(242,0,0,1) 100%); ';
t._boxShadowColor[1] = 'background: linear-gradient(to right, rgba(229,69,0,1) 0%,rgba(255,255,255,0) 100%); ';
t._boxShadowColor[2] = 'background: linear-gradient(to right, rgba(229,118,0,1) 0%,rgba(255,255,255,0) 100%); ';
t._boxShadowColor[3] = 'background: linear-gradient(to right, rgba(228,67,0,1) 0%,rgba(255,255,255,0) 100%); ';
t._boxShadowColor[4] = 'background: linear-gradient(to right, rgba(230,174,0,1) 0%,rgba(255,255,255,0) 100%); ';
t._boxShadowColor[5] = 'background: linear-gradient(to right, rgba(233,227,0,1) 0%,rgba(255,255,255,0) 100%); ';
t._boxShadowColor[6] = 'background: linear-gradient(to right, rgba(189,231,0,1) 0%,rgba(255,255,255,0) 100%); ';
t._boxShadowColor[7] = 'background: linear-gradient(to right, rgba(140,237,0,1) 0%,rgba(255,255,255,0) 100%); ';
t._boxShadowColor[8] = 'background: linear-gradient(to right, rgba(88,238,0,1) 0%,rgba(255,255,255,0) 100%); ';
t._boxShadowColor[9] = 'background: linear-gradient(to right, rgba(37,237,0,1) 0%,rgba(255,255,255,0) 100%); ';
t._boxShadowColor[100] = '#000000';
*/
},
setText: function(t){

// TODO: Eliminar esta clase, se la mantiene solo por compatibilidad
 var node = domConstruct.create("span");
img = this.baseUrl+'dialog-information-3.png';
node.innerHTML = ' <div style="border: 1px solid #c9c9c9; border-radius: 3px; margin: 5px; -moz-box-shadow: 3px 4px 7px #000000; -webkit-box-shadow: 3px 4px 7px #000000; box-shadow: 3px 4px 7px #000000; width: 300px; background-color: white; opacity: 0.8;">  <div style="padding: 5px;">   <div style="margin: 5px; display: inline-block; clear: both; float: left;">    <img src="'+img+'" style="background-color: transparent;"></img>    <audio autoplay="true"> <source src="media/alert-1.ogg" type="audio/ogg"></source>    </audio>  </div>   <div style="padding: 5px;"><div>'+t+'</div>  </div> </div></div>';

  domConstruct.place(node, this.container, "first");

setTimeout(function(){
dojo.destroy(node);
}, 15000);

},
_args: function(a){
if(a.message === undefined || a.message.length < 1){
a.message = '';
}

if(a.title === undefined || a.title.length < 1){
a.title = '';
}

if(a.img === undefined || a.img.length < 5){
a.img = this.baseUrl+'img/dialog-information-3.png';
}else{
a.img = this.baseUrl+'img/'+a.img;
}

if(a.snd === undefined || a.snd.length < 5){
a.snd = this.baseUrl+'snd/131659_bertrof_game-sound-intro-to-game.mp3';
}else{
a.snd = this.baseUrl+'snd/'+a.snd;
}

if(a.timeout === undefined || a.timeout < 2){
a.timeout = 10;
}

if(a.urgency === undefined || a.urgency < 1){
a.urgency = 100;
}

return a;
},
notify: function(args_){

var t = this;
var args = t._args(args_);

var bsc = '';

if(args.urgency <= 2){
bsc = '#d80000';
}else if(args.urgency <= 4){
bsc = '#ff6100';
}else if(args.urgency <= 6){
bsc = '#ffc700';
}else if(args.urgency <= 8){
bsc = '#ffe100';
}else{
bsc = '#8b9fb2';
}

 var node = domConstruct.create("span");

if(args.closable){
 dojo.connect(node, "onclick", function(){
	dojo.destroy(this);
});
}

node.innerHTML = ' <div style="border: 1px solid '+bsc+'; border-radius: 5px; margin: 5px; -moz-box-shadow: 3px 4px 7px #000000; -webkit-box-shadow: 3px 4px 7px #000000; box-shadow: 3px 4px 7px #000000; width: 300px; background-color: white; opacity: 0.8;"><div style="padding: 5px;"><table border="0" style="border-collapse:collapse;table-layout:inherit;width:100%;height:100%;"> <colgroup>   <col style="vertical-align: top; width: 5%;"></col>   <col style="width: auto;"></col> </colgroup> <tbody>   <tr>     <td>       <div style="margin: 5px; display: inline-block;">         <img src="'+args.img+'" style="width: 40px; height: auto; background-color: transparent;"></img>         <audio src="'+args.snd+'" autoplay loop></audio>       </div>     </td>     <td>       <div style="padding: 5px; width: 100%; height: 100%; display: inline-block;">         <div style="color: black; font-size: 1.5em; font-weight: bold;">'+args.title+'</div>         <div>'+args.message+'</div>       </div>     </td>   </tr> </tbody></table></div></div>';

  domConstruct.place(node, this.container, "first");

setTimeout(function(){
dojo.destroy(node);
}, args.timeout*1000);

} 







   
});
});
