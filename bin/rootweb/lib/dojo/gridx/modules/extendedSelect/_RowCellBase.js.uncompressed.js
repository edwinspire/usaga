define("gridx/modules/extendedSelect/_RowCellBase", [
	"dojo/_base/declare",
	"dojo/_base/lang",
	"dojo/_base/query",
	"./_Base",
	"../../core/model/extensions/Mark"
], function(declare, lang, query, _Base, Mark){

	return declare(_Base, {
		modelExtensions: [Mark],

		_getRowId: function(visualIndex){
			var node = query('[visualindex="' + visualIndex + '"]', this.grid.bodyNode)[0];
			return node && node.getAttribute('rowid');
		},

		_init: function(){
			var t = this, m = t.model;
			t.batchConnect(
				[t.grid.body, 'onMoveToCell', '_onMoveToCell'],
				[m, 'onMarkChange', '_onMark']
			);
		}
	});
});

