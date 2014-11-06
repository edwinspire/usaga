/*
 * This file is provided for custom JavaScript logic that your HTML files might need.
 * Maqetta includes this JavaScript file by default within HTML pages authored in Maqetta.
 */
require(["dojo/ready",
"dojo/query", "dojo/_base/array", "dojo/NodeList-traverse"], function(ready, query, array){
     ready(function(){
         // logic that requires that Dojo is fully initialized should go here

var a = {};
var w = dojo.byId('test');
console.log(w);

var c = query(w).children();
//console.log(c);

 array.forEach(c, function(item, i){

n = item.getAttribute("data-name");
if(n){
console.log(item+'  '+n);
c[n] = item;

}


 
});


console.log(c.a);

for (key in c) {
//console.log(key);
//console.log(c.a);
}






     });
});
