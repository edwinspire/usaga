define("gridx/core/model/extensions/Query", [
	"dojo/_base/declare",
	'../_Extension'
], function(declare, _Extension){

	return declare(/*===== "gridx.core.model.extensions.Query", =====*/_Extension, {
		name: 'query',

		priority: 40,

		constructor: function(model, args){
			this._mixinAPI('query');
			if(args.query){
				this.query(args.query, args.queryOptions);
			}
		},

		//Public--------------------------------------------------------------
		query: function(/* query, queryOptions */){
			this.model._addCmd({
				name: '_cmdQuery',
				scope: this,
				args: arguments
			});
		},
	
		//Private--------------------------------------------------------------
		_cmdQuery: function(){
			var a = arguments,
				args = a[a.length - 1],
				m = this.model,
				c = m._cache, 
				op = c.options = c.options || {};
			op.query = args[0];
			op.queryOptions = args[1];
			m._msg('storeChange');
			c.clear();
		}
	});
});
