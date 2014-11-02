define("gridx/modules/move/Row", [
	"dojo/_base/declare",
	"dojo/_base/array",
	"dojo/keys",
	"../../core/_Module",
	"../../core/model/extensions/Move"
], function(declare, array, keys, _Module, Move){

	return declare(/*===== "gridx.modules.move.Row", =====*/_Module, {
		// summary:
		//		This module provides some APIs to move rows within grid
		// description:
		//		This module requires the "Move" model extension.
		//		This module does not include any UI. So different kind of row dnd UI implementations can be built
		//		upon this module.

		name: 'moveRow',
		
		modelExtensions: [Move],

		constructor: function(){
			this.connect(this.model, 'onMoved', '_onMoved');
		},
	
		getAPIPath: function(){
			// tags:
			//		protected extension
			return {
				move: {
					row: this
				}
			};
		},

		preload: function(){
			this.aspect(this.grid, 'onRowKeyDown', '_onKeyDown');
		},
		
		rowMixin: {
			moveTo: function(target, skipUpdateBody){
				this.grid.move.row.move([this.index()], target, skipUpdateBody);
				return this;
			}
		},
		
		//Public-----------------------------------------------------------------

		//moveSelected: Boolean
		//		When moving using keyboard, whether to move all selected rows together.
		moveSelected: true,

		move: function(rowIndexes, target, skipUpdateBody){
			// summary:
			//		Move some rows to target position
			// rowIndexes: Integer[]
			//		An array of row indexes
			// target: Integer
			//		The rows will be moved to the position before the target row
			// skipUpdateBody: Boolean?
			//		If set to true, the grid will not refresh immediately, so that several
			//		grid operations can be done altogether.
			var m = this.model;
			m.moveIndexes(rowIndexes, target);
			if(!skipUpdateBody){
				m.when();
			}
		},
		
		moveRange: function(start, count, target, skipUpdateBody){
			// summary:
			//		Move a range of rows to target position
			// start: Integer
			//		The index of the first row to be moved
			// count: Integer
			//		The count of rows to be moved
			// skipUpdateBody: Boolean?
			//		
			var m = this.model;
			m.move(start, count, target);
			if(!skipUpdateBody){
				m.when();
			}
		},
		
		//Events------------------------------------------------------------------
		onMoved: function(/* rowIndexMapping */){
			// summary:
			//		Fired when row move is performed successfully
			// tags:
			//		callback
		},
		
		//Private-----------------------------------------------------------------
		_onMoved: function(){
			this.grid.body.refresh();
			this.onMoved();
		},

		_onKeyDown: function(e){
			var t = this,
				g = t.grid,
				selector = g.select && g.select.row;
			if(e.ctrlKey && !e.shiftKey && !e.altKey && (e.keyCode == keys.UP_ARROW || e.keyCode == keys.DOWN_ARROW)){
				var target = e.rowIndex,
					doMove = function(rowIdxes){
						if(e.keyCode == keys.UP_ARROW){
							while(array.indexOf(rowIdxes, target) >= 0){
								target--;
							}
							if(target >= 0){
								t.move(rowIdxes, target);
							}
						}else{
							while(array.indexOf(rowIdxes, target) >= 0){
								target++;
							}
							if(target < g.body.rootStart + g.body.rootCount){
								t.move(rowIdxes, target + 1);
							}
						}
					};
				if(t.arg('moveSelected') && selector && selector.isSelected(e.rowId)){
					var selected = selector.getSelected();
					g.model.when({id: selected}, function(){
						var rowIdxes = array.map(selected, function(id){
							return g.model.idToIndex(id);
						});
						doMove(rowIdxes);
					});
				}else{
					doMove([g.model.idToIndex(e.rowId)]);
				}
			}
		}
	});
});
