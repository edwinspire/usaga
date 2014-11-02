define("gridx/modules/filter/FilterTooltip", [
	"dojo",
	"dijit",
	"dojo/_base/declare",
	"dojo/string",
	"dojo/i18n!../../nls/FilterBar",
	"./Filter",
	"./FilterDialog",
	"dijit/TooltipDialog",
	"dijit/popup",
	"dijit/Tooltip",
	"dojo/_base/array",
	"dojo/_base/event",
	"dojo/_base/html"
], function(dojo, dijit, declare, string, i18n){
	
	return declare(dijit.TooltipDialog, {
		// summary:
		//	Show status dialog of filter.
		grid: null,
		filterBar: null,
		postCreate: function(){
			this.inherited(arguments);
			this.filterBar = this.grid.filterBar;
			this.connect(this, 'onClick', '_onClick');
			this.connect(this, 'onMouseEnter', '_onMouseEnter');
			this.connect(this, 'onMouseLeave', '_onMouseLeave');
			dojo.addClass(this.domNode, 'gridxFilterTooltip');
			dojo.addClass(this.domNode, 'dijitTooltipBelow');
		},
		show: function(evt){
			this.inherited(arguments);
			dijit.popup.open({
				popup: this,
				x: evt.pageX,
				y: evt.pageY,
				padding: {x: -6, y: -3}
			});
		},
		hide: function(){
			this.inherited(arguments);
			dijit.popup.close(this);
		},

		buildContent: function(){
			// summary:
			//	Build the status of current filter.
			
			var fb = this.filterBar, nls = fb._nls, data = fb.filterData;
			if(!data || !data.conditions.length){return;}
			
			var typeString = data.type === 'all' ? nls.statusTipHeaderAll : nls.statusTipHeaderAny;
			var arr = ['<div class="gridxFilterTooltipTitle"><b>${i18n.statusTipTitleHasFilter}</b> ', 
				typeString, '</div><table><tr><th>${i18n.statusTipHeaderColumn}</th><th>${i18n.statusTipHeaderCondition}</th></tr>'
			];
			
			dojo.forEach(data.conditions, function(d, idx){
				var odd = idx%2 ? ' class="gridxFilterTooltipOddRow"' : '';
				arr.push('<tr', odd, '><td>', (d.colId ? this.grid.column(d.colId).name() : '${i18n.anyColumnOption}'), 
					'</td><td class="gridxFilterTooltipValueCell">', 
					'<div>',
					fb._getRuleString(d.condition, d.value, d.type),
					'<span action="remove-rule" title="${i18n.removeRuleButton}"',
					' class="gridxFilterTooltipRemoveBtn"><span class="gridxFilterTooltipRemoveBtnText">x</span></span></div></td></tr>');
			}, this);
			arr.push('</table>');
			this.i18n = i18n;
			this.set('content', string.substitute(arr.join(''), this));
			dojo.toggleClass(this.domNode, 'gridxFilterTooltipSingleRule', data.conditions.length === 1);
		},
		_onMouseEnter: function(e){
			this.isMouseOn = true;
		},
		_onMouseLeave: function(e){
			this.isMouseOn = false;
			this.hide();
		},
		_onClick: function(e){
			var tr = this._getTr(e), fb = this.filterBar;
			if(tr && /^span$/i.test(e.target.tagName)){
				//remove the rule
				fb.filterData.conditions.splice(tr.rowIndex - 1, 1);
				tr.parentNode.removeChild(tr);
				fb.applyFilter(fb.filterData);
				dojo.stopEvent(e);
			}else{
				this.filterBar.showFilterDialog();
				this.hide();
			}
		},
		_getTr: function(e){
			// summary:
			//	Get table row of status
			var tr = e.target;
			while(tr && !/^tr$/i.test(tr.tagName) && tr !== this.domNode){
				tr = tr.parentNode;
			}
			return (tr && /^tr$/i.test(tr.tagName)) ? tr : null;
		}
	});
});
