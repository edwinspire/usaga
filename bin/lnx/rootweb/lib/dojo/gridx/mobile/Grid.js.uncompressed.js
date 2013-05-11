define("gridx/mobile/Grid", [
	"dojo/_base/kernel",
	'dojo/_base/declare',
	'dojo/_base/lang',
	'dojo/_base/array',
	'dojo/aspect',
	'dojo/string',
	'dojo/dom-class',
	'dojox/mobile/_DataMixin',
	'dojox/mobile/Pane',
	'dojox/mobile/ScrollablePane'
], function(kernel, declare, lang, array, aspect, string, css, _DataMixin, Pane, ScrollablePane){
	// module:
	//	gridx/mobile/Grid
	// summary:
	//	A mobile grid that has fixed header, footer and a scrollable body.
	
	kernel.experimental('gridx/mobile/Grid');
	
	var Grid = declare('gridx.mobile.Grid', [Pane, _DataMixin], {
		// summary:
		//	A mobile grid that has fixed header, footer and a scrollable body.
		
		//autoHeight: boolean
		//	If true, it's must be a children of dojox.mobile.View
		//  and it occupies the rest height of the screen. If false it could be in any container
		//	using a specified height.
		autoHeight: true,
		
		//showHeader: boolean
		//	Whether to show the grid header
		showHeader: false,
		
		//vScroller: boolean
		//	Whether to show the virtical scroller
		vScroller: true,
		
		//hScroller: boolean
		//	Whether to show the horizontal scroller
		hScroller: false,
		
		//columns: array
		//	Column definition to show the grid from store
		columns: null,
		
		//plugins: array
		//	Plugins for the mobile grid.
		//,plugins: [],
		
		setStore: function(store, query, queryOptions){
			// summary
			//	Set the store of the grid, it causes rebuild the grid body.
			this.inherited(arguments);
			this._buildBody();
		},
		
		setColumns: function(columns){
			// summary:
			//	Set columns to show for the grid. 
			//  Maybe improve performance by adding/removing some columns instead of re-rendering.
			this.columns = columns;
			this.buildGrid();
		},
		
		postMixInProperties: function(){
			this.inherited(arguments);
			this.queryOptions = this.queryOptions || {};
			this.query = this.query || {};
		},
		
		buildGrid: function(){
			// summary:
			//	Build the whole grid
			this._buildHeader();
			this._buildBody();
			this.resize();
		},
		
		_buildHeader: function(){
			// summary:
			//	Build the grid header when showHeader is true.
			if(!this.showHeader){
				this.headerNode.style.display = 'none';
				return;
			}else{
				this.headerNode.style.display = 'block';
			}
			
			var arr = ['<div class="mobileGridxHeaderRow"><table><tr>'];
			array.forEach(this.columns, function(col){
				arr.push(
					'<th class="mobileGridxHeaderCell ', col.cssClass || ''
						,col.align ? ' align-' + col.align : ''
					,col.width? '" style="width:' + col.width + ';"' : ''
					,'>', col.title, '</th>'
				);
			});
			arr.push('</tr></table></div>');
			this.headerNode.innerHTML = arr.join('');
		},
		
		_buildBody: function(){
			// summary:
			//	Build the grid body
			var self = this, q = this.query, opt = this.queryOptions;
			this.store.fetch({
				query: q,
				queryOptions: opt,
				sort: opt && opt.sort || [],
				onComplete: function(items){
					var arr = [];
					array.forEach(items, function(item, i){
						arr.push(self._createRow(item, i));
					});
					self.bodyPane.containerNode.innerHTML = arr.join('');
				},
				onError: function(err){
					console.error('Failed to fetch items from store:', err);
				},
				start: opt && opt.start,
				count: opt && opt.count
			});
		},
		
		_createRow: function(item, i){
			// summary:
			//	Create a grid row by object store item.
			var isOdd = !(i%2);	//i is from 0
			var rowId = this.store.getIdentity(item);
			var arr = ['<div class="mobileGridxRow ' + (isOdd ? 'mobileGridxRowOdd' : '' ) + '"',
				' rowId="' + rowId + '"',
				 '><table><tr>'];
			array.forEach(this.columns, function(col){
				var value = this._getCellContent(col, item);
				arr.push(
					'<td class="mobileGridxCell ' 
					,((col.cssClass || col.align) ? ((col.cssClass || '') + (col.align ? ' align-' + col.align : '')) : '')
					,'"'
					,(col.width? ' style="width:' + col.width + ';"' : '') 
					,'>', value, '</td>'
				);
			}, this);
			arr.push('</tr></table></div>');
			return arr.join('');
		},
		
		_getCellContent: function(col, item){
			// summary:
			//	Get a cell content by the column definition.
			//	* Currently only support string content, will add support for widget in future.
			var f = col.formatter, obj = this._itemToObject(item);
			if(col.template){
				return string.substitute(col.template, obj);
			}else{
				return f ? f(obj, col) : obj[col.field];
			}
		},
		
		buildRendering: function(){
			// summary:
			//	Build the grid dom structure.
			this.inherited(arguments);
			css.add(this.domNode, 'mobileGridx');
			this.domNode.innerHTML = '<div class="mobileGridxHeader"></div><div class="mobileGridxBody"></div><div class="mobileGridxFooter"></div>';
			this.headerNode = this.domNode.childNodes[0];
			this.bodyNode = this.domNode.childNodes[1];
			this.footerNode = this.domNode.childNodes[2];
			this.containerNode = this.bodyNode;
			var scrollDir = (this.vScroller ? 'v' : '') + (this.hScroller ? 'h' : '');
			if(!scrollDir)scrollDir = 'v';
			this.bodyPane = new ScrollablePane({
				scrollDir: scrollDir
			}, this.bodyNode);
			
			if(this.showHeader){
				var h = this.headerNode;
				this.connect(this.bodyPane, 'scrollTo', function(to){
					if((typeof to.x) != "number")return;
					h.firstChild.style.webkitTransform = this.bodyPane.makeTranslateStr({x:to.x});
				});
				
				this.connect(this.bodyPane, 'slideTo', function(to, duration, easing){
					this.bodyPane._runSlideAnimation({x:this.bodyPane.getPos().x}, {x:to.x}
						, duration, easing, h.firstChild, 2);	//2 means it's a containerNode
				});
				
				this.connect(this.bodyPane, 'stopAnimation', function(){
					css.remove(h.firstChild, 'mblScrollableScrollTo2');
				});
			}
		},
		
		resize: function(){
			// summary:
			//	Calculate the height of grid body according to the autoHeight property.
			this.inherited(arguments);
			var h = this.domNode.offsetHeight;
			if(this.autoHeight){
				//if auto height, grid occupies the rest height of the screen.
				this.domNode.style.height = 'auto';
				var n = this.domNode, p = n.parentNode;
				h = this.bodyPane.getScreenSize().h;
				array.forEach(p.childNodes, function(node){
					if(node == n)return;
					h -= (node.offsetHeight || 0);
				});
			}
			h = h - this.headerNode.offsetHeight - this.footerNode.offsetHeight;
			this.bodyNode.style.height = h + 'px';
		},
		
		startup: function(){
			this.inherited(arguments);
			this.bodyPane.startup();
		},
		
		_itemToObject: function(item){
			// summary:
			//	Convert a store item to object
			var store = this.store, arr = store.getAttributes(item), res = {};
			array.forEach(arr, function(key){
				res[key] = store.getValue(item, key);
			});
			return res;
		}
	});
	
	return Grid;
});