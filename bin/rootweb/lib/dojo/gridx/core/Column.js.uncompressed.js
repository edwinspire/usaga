define("gridx/core/Column", [
	"dojo/_base/declare"
], function(declare){

	
	return declare(/*===== "gridx.core.Column", =====*/[], {
		// summary:
		//		Represents a column of a grid
		// description:
		//		An instance of this class represents a grid column.
		//		This class should not be directly instantiated by users. It should be returned by grid APIs.

		/*=====
		// id: [readonly] String
		//		The ID of this column
		id: null,

		// grid: [readonly] gridx.Grid
		//		Reference to the grid
		grid: null,

		// model: [readonly] grid.core.model.Model
		//		Reference to this grid model
		model: null,
		=====*/

		

		constructor: function(grid, id){
			this.grid = grid;
			this.model = grid.model;
			this.id = id;
		},

		
		index: function(){
			// summary:
			//		Get the index of this column
			// returns:
			//		The index of this column
			var c = this.def();
			return c ? c.index : -1;	//Integer
		},

		
		def: function(){
			// summary:
			//		Get the definition of this column
			// returns:
			//		The definition of this column
			return this.grid._columnsById[this.id];	//Object
		},

		
		cell: function(row, isId, parentId){
			// summary:
			//		Get a cell object in this column
			// row: gridx.core.Row|Integer|String
			//		Row index or row ID or a row object
			// returns:
			//		If the params are valid and the row is in cache return a cell object, else return null
			return this.grid.cell(row, this, isId, parentId);	//gridx.core.Cell|null 
		},

		
		cells: function(start, count, parentId){
			// summary:
			//		Get cells in this column.
			//		If some rows are not in cache, there will be NULLs in the returned array.
			// start: Integer?
			//		The row index of the first cell in the returned array.
			//		If omitted, defaults to 0, so column.cells() gets all the cells.
			// count: Integer?
			//		The number of cells to return.
			//		If omitted, all the cells starting from row 'start' will be returned.
			// returns:
			//		An array of cells in this column
			var t = this,
				g = t.grid,
				cells = [],
				total = g.rowCount(parentId),
				i = start || 0,
				end = count >= 0 ? start + count : total;
			for(; i < end && i < total; ++i){
				cells.push(g.cell(i, t, 0, parentId));	//1 as true
			}
			return cells;	//gridx.core.Cell[]
		},

		
		name: function(){
			// summary:
			//		Get the name of this column.
			// description:
			//		Column name is the string displayed in the grid header cell.
			//		Column names can be anything. Two columns can share one name. But they must have different IDs.
			// returns:
			//		The name of this column
			return this.def().name || '';	//String
		},

		
		setName: function(name){
			// summary:
			//		Set the name of this column
			// name: String
			//		The new name
			// returns:
			//		Return self reference, so as to cascade methods
			this.def().name = name;
			return this;	//gridx.core.Column
		},

		
		field: function(){
			// summary:
			//		Get the store field of this column
			// description:
			//		If a column corresponds to a field in store, this method returns the field.
			//		It's possible for a column to have no store field related.
			// returns:
			//		The store field of this column
			return this.def().field || null;	//String
		},

		
		getWidth: function(){
			// summary:
			//		Get the width of this column
			// returns:
			//		The CSS value of column width
			return this.def().width;	//String
		}
	});
});
