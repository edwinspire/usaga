define("gridx/modules/SingleSort", [
	"dojo/_base/declare",
	"dojo/_base/lang",
	"dojo/keys",
	"../core/model/extensions/Sort",
	"../core/_Module"
], function(declare, lang, keys, Sort, _Module){

	return declare(/*===== "gridx.modules.SingleSort", =====*/_Module, {
		// summary:
		//		This module provides the single column sorting functionality for grid.

		name: 'sort',

		forced: ['header'],

		modelExtensions: [Sort],
		
		getAPIPath: function(){
			// tags:
			//		protected extension
			return {
				sort: this
			};
		},

		preload: function(){
			// tags:
			//		protected extension
			var t = this,
				g = t.grid, sort;
			t.connect(g, 'onHeaderCellClick', '_onClick');
			t.connect(g, 'onHeaderCellKeyDown', '_onKeyDown');
			//persistence support
			if(g.persist){
				sort = g.persist.registerAndLoad('sort', function(){
					return [{
						colId: t._sortId,
						descending: t._sortDescend 
					}];
				});
			}
			//Presort...
			sort = sort || t.arg('initialOrder');
			if(lang.isArrayLike(sort)){
				sort = sort[0];
			}
			if(sort && sort.colId){
				t._sortId = sort.colId;
				t._sortDescend = sort.descending;
				//sort here so the body can render correctly.
				t.model.sort([sort]);
			}
		},
	
		load: function(){
			// tags:
			//		protected extension
			var t = this,
				colId,
				f = function(){
					if(t._sortId){
						t._updateHeader(t._sortId, t._sortDescend);
					}
				};
			t.connect(t.grid.header, 'onRender', f);
			for(colId in t.grid._columnsById){
				t._initHeader(colId);
			}
			//If presorted, update header UI
			f();
			t.loaded.callback();
		},
	
		columnMixin: {
			sort: function(isDescending, skipUpdateBody){
				// summary:
				//		Sort this column.
				this.grid.sort.sort(this.id, isDescending, skipUpdateBody);
				return this;
			},
	
			isSorted: function(){
				// summary:
				//		Check wheter this column is sorted.
				return this.grid.sort.isSorted(this.id);
			},
	
			clearSort: function(skipUpdateBody){
				// summary:
				//		Clear sort on this column
				if(this.isSorted()){
					this.grid.sort.clear(skipUpdateBody);
				}
				return this;
			},
	
			isSortable: function(){
				// summary:
				//		Check whether this column is sortable.
				var col = this.grid._columnsById[this.id];
				return col.sortable || col.sortable === undefined;
			},
	
			setSortable: function(isSortable){
				// summary:
				//		Set sortable for this column
				this.grid._columnsById[this.id].sortable = !!isSortable;
				return this;
			}
		},
	
		//Public--------------------------------------------------------------

	/*=====
		// initialOrder: Object|Array
		//		The initial sort order when grid is created.
		//		This is of the same format of the sort argument of the store fetch function.
		//		If an array of sort orders is provided, only the first will be used.
		initialOrder: null,
	=====*/

		sort: function(colId, isDescending, skipUpdateBody){
			// summary:
			//		Sort the grid on given column.
			// colId: String
			//		The column ID
			// isDescending: Boolean?
			//		Whether to sort the column descendingly
			// skipUpdateBody: Boolean?
			//		If set to true, the grid body will not automatically be refreshed after this call,
			//		so that several grid operations could be done altogether
			//		without refreshing the grid over and over.
			var t = this, g = t.grid, col = g._columnsById[colId];
			if(col && (col.sortable || col.sortable === undefined)){
				if(t._sortId != colId || t._sortDescend == !isDescending){
					t._updateHeader(colId, isDescending);
				}
				t.model.sort([{colId: colId, descending: isDescending}]);
				if(!skipUpdateBody){
					g.body.refresh();
				}
			}
		},
	
		isSorted: function(colId){
			// summary:
			//		Check wheter (and how) the grid is sorted on the given column.
			// colId: String
			//		The columnn ID
			// returns:
			//		Positive number if the column is sorted ascendingly;
			//		Negative number if the column is sorted descendingly;
			//		Zero if the column is not sorted.
			if(colId == this._sortId){
				return this._sortDescend ? -1 : 1;	//Number
			}
			return 0;	//Number
		},
	
		clear: function(skipUpdateBody){
			// summary:
			//		Clear sort.
			// skipUpdateBody:
			//		If set to true, the grid body will not automatically be refreshed after this call,
			//		so that several grid operations could be done altogether
			//		without refreshing the grid over and over.
			var t = this;
			if(t._sortId !== null){
				t._initHeader(t._sortId);
				t._sortId = t._sortDescend = null;
				t.model.sort();
				if(!skipUpdateBody){
					t.grid.body.refresh();
				}
			}
		},

		getSortData: function(){
			// summary:
			//		Get an array of objects that can be accepted by the store's "sort" argument.	
			// returns:
			//		An array containing the sort info
			return this._sortId ? [{	//Object[]|null
				colId: this._sortId, 
				descending: this._sortDescend
			}] : null;
		},
	
		//Private--------------------------------------------------------------
		_sortId: null,

		_sortDescend: null,
		
		_initHeader: function(colId){
			var g = this.grid,
				headerCell = g.header.getHeaderNode(colId),
				col = g.column(colId, 1);	//1 as true
			headerCell.innerHTML = ["<div class='gridxSortNode'>", col.name(), "</div>"].join('');
			if(col.isSortable()){
				headerCell.setAttribute('aria-sort', 'none');
			}else{
				headerCell.removeAttribute('aria-sort');
			}
		},
	
		_updateHeader: function(colId, isDescending){
			//Change the structure of sorted header
			var t = this;
			if(t._sortId && t._sortId != colId){
				t._initHeader(t._sortId);
			}
			t._sortId = colId;
			t._sortDescend = !!isDescending;
			var g = t.grid,
				headerCell = g.header.getHeaderNode(colId);
			headerCell.innerHTML = ["<div class='gridxSortNode ",
				isDescending ? 'gridxSortDown' : 'gridxSortUp',
				"'><div class='gridxArrowButtonChar'>",
				isDescending ? "&#9662;" : "&#9652;",
				"</div><div role='presentation' class='gridxArrowButtonNode'>&nbsp;</div><div class='gridxColCaption'>",
				g.column(colId, 1).name(),	//1 as true
				"</div></div>"
			].join('');
			headerCell.setAttribute('aria-sort', isDescending ? 'descending' : 'ascending');
			g.vLayout.reLayout();
		},
	
		_onClick: function(e){
			this.sort(e.columnId, this._sortId != e.columnId ? 0 : !this._sortDescend);
		},
		
		_onKeyDown: function(e){
			if(e.keyCode == keys.ENTER){
				this._onClick(e);
			}
		}
	});
});
