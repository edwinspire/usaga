require([
	'gridx/Grid',
	'gridx/core/model/cache/Async',
	'gridx/tests/support/data/MusicData',
	'gridx/tests/support/stores/ItemFileWriteStore',
	'gridx/tests/support/modules',
	'dojo/domReady!'
], function(Grid, Cache, dataSource, storeFactory, modules){

	window.Cache = Cache;
	window.store = storeFactory({
		dataSource: dataSource,
		size: 100
	});
	window.dataSource = dataSource;
	window.modules = modules;
});
