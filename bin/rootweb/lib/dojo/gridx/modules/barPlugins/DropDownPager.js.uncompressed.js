define("gridx/modules/barPlugins/DropDownPager", [
	"dojo/_base/declare",
	"dojo/_base/lang",
	"dojo/store/Memory",
	"dijit/_WidgetBase",
	"dijit/_FocusMixin",
	"dijit/_TemplatedMixin",
	"dojo/i18n!../../nls/PaginationBar",
	"dijit/form/FilteringSelect"
], function(declare, lang, Store, _WidgetBase, _FocusMixin, _TemplatedMixin, nls, FilteringSelect){

	return declare(/*===== "gridx.modules.barPlugins.DropDownPager", =====*/[_WidgetBase, _FocusMixin, _TemplatedMixin], {
		// summary:
		//		This grid bar plugin is to switch pages using select widget.

		templateString: '<div class="gridxDropDownPager"><label class="gridxPagerLabel">${pageLabel}</label></div>',

		constructor: function(args){
			lang.mixin(this, nls);
		},

		postCreate: function(){
			var t = this,
				c = 'connect',
				p = t.grid.pagination;
			t[c](p, 'onSwitchPage', '_onSwitchPage');
			t[c](p, 'onChangePageSize', 'refresh');
			t[c](t.grid.model, 'onSizeChange', 'refresh');
			t.refresh();
		},

		//Public-----------------------------------------------------------------------------

		//grid: gridx.Grid
		//		The grid widget this plugin works for.
		grid: null,

		//stepperClass: Function
		//		The constructor of the select widget
		stepperClass: FilteringSelect,

		//stepperProps: Object
		//		The properties passed to select widget when creating it.
		stepperProps: null,

		refresh: function(){
			var t = this, mod = t.module,
				items = [],
				selectedItem,
				p = t.grid.pagination,
				pageCount = p.pageCount(),
				currentPage = p.currentPage(),
				stepper = t._pageStepperSelect,
				i, v, item;
			for(i = 0; i < pageCount; ++i){
				v = i + 1;
				item = {
					id: v,
					label: v,
					value: v
				};
				items.push(item);
				if(currentPage == i){
					selectedItem = item;
				}
			}
			var store = new Store({data: items});
			if(!stepper){
				var cls = t.stepperClass,
					props = lang.mixin({
						store: store,
						searchAttr: 'label',
						item: selectedItem,
						'class': 'gridxPagerStepperWidget',
						onChange: function(page){
							p.gotoPage(page - 1);
						}
					}, t.stepperProps || {});
				stepper = t._pageStepperSelect = new cls(props);
				stepper.placeAt(t.domNode, "last");
				stepper.startup();
			}else{
				stepper.set('store', store);
				stepper.set('value', currentPage + 1);
			}
			stepper.set('disabled', pageCount <= 1);
		},

		//Private----------------------------------------------------------------------------
		_onSwitchPage: function(page){
			this._pageStepperSelect.set('value', page + 1);
		}
	});
});
