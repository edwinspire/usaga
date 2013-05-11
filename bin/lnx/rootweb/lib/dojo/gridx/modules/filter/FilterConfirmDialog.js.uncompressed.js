require({cache:{
'url:gridx/templates/FilterConfirmDialog.html':"<div class=\"gridxFilterConfirmDialogMessage\">${clearFilterMsg}</div\n><div class=\"gridxFilterConfirmDialogButtons\"\n\t><input type=\"button\" data-dojo-type=\"dijit.form.Button\" label=\"${clearButton}\"\n\t/><input type=\"button\" data-dojo-type=\"dijit.form.Button\" label=\"${cancelButton}\"\n/></div>\n"}});
define("gridx/modules/filter/FilterConfirmDialog", [
	"dojo/_base/declare",
	"dojo/string",
	"dijit/Dialog",
	"dojo/text!../../templates/FilterConfirmDialog.html",
	"dojo/i18n!../../nls/FilterBar"
], function(declare, string, Dialog, template, i18n){

	return declare(Dialog, {
		title: i18n.clearFilterDialogTitle,
		cssClass: 'gridxFilterConfirmDialog',
		autofocus: false,
		postCreate: function(){
			this.inherited(arguments);
			this.set('content', string.substitute(template, i18n));
			var arr = dijit.findWidgets(this.domNode);
			this.btnClear = arr[0];
			this.btnCancel = arr[1];
			this.connect(this.btnCancel, 'onClick', 'hide');
			this.connect(this.btnClear, 'onClick', 'onExecute');
			this.connect(this, 'show', function(){
				this.btnCancel.focus();
			});
		},
		onExecute: function(){
			this.execute();
		},
		execute: function(){}
	});
});
