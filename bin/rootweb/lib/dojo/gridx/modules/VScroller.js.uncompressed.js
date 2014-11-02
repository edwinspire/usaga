define("gridx/modules/VScroller", [
	"dojo/_base/declare",
	"dojo/_base/Deferred",
	"dojo/_base/event",
	"dojo/_base/sniff",
	"dojo/_base/query",
	"dojo/dom-geometry",
	"dojo/keys",
	"dojox/html/metrics",
	"../core/_Module"
], function(declare, Deferred, event, sniff, query, domGeo, keys, metrics, _Module){
	
	var st = 'scrollTop';

	return declare(/*===== "gridx.modules.VScroller", =====*/_Module, {
		// summary:
		//		This module provides basic vertical scrolling logic for grid.
		// description:
		//		This module will make the grid body render all rows without paging.
		//		So it is very fast for small client side store, and might be extremely slow
		//		for large server side store.

		name: 'vScroller',
	
		forced: ['body', 'vLayout', 'columnWidth'],

		optional: ['pagination'],
	
		getAPIPath: function(){
			// tags:
			//		protected extension
			return {
				vScroller: this
			};
		},

		constructor: function(){
			var t = this,
				g = t.grid,
				dn = t.domNode = g.vScrollerNode;
			t.stubNode = dn.firstChild;
			if(g.autoHeight){
				dn.style.display = 'none';
				if(sniff('ie') < 8){
					dn.style.width = '0px';
				}
			}else{
				var w = metrics.getScrollbar().w,
					ltr = g.isLeftToRight();
				dn.style.width = w + 'px';
				dn.style[ltr ? 'right' : 'left'] = -w + 'px';
				if(sniff('ie') < 8){
					t.stubNode.style.width = w;
				}
			}
		},

		preload: function(args){
			// tags:
			//		protected extension
			this.grid.hLayout.register(null, this.domNode, 1);
		},

		load: function(args, startup){
			// tags:
			//		protected extension
			var t = this,
				g = t.grid,
				bd = g.body,
				dn = t.domNode,
				bn = g.bodyNode;
			t.batchConnect(
				[t.domNode, 'onscroll', '_doScroll'],
				[bn, 'onmousewheel', '_onMouseWheel'],
				[g.mainNode, 'onkeypress', '_onKeyScroll'],
				sniff('ff') && [bn, 'DOMMouseScroll', '_onMouseWheel']);
			t.aspect(g, '_onResizeEnd', '_onBodyChange');
			t.aspect(bd, 'onForcedScroll', '_onForcedScroll');
			t.aspect(bd, 'onRender', '_onBodyChange');
			if(!g.autoHeight){
				t.aspect(bd, 'onEmpty', function(){
					var ds = dn.style;
					ds.display = 'none';
					ds.width = '';
					if(sniff('ie') < 8){
						ds.width = t.stub.style.width = '0px';
					}
					g.hLayout.reLayout();
					g.hScroller.refresh();
				});
			}
			startup.then(function(){
				t._updatePos();
				Deferred.when(t._init(args), function(){
					t.domNode.style.width = '';
					t.loaded.callback();
				});
			});
		},
	
		//Public ----------------------------------------------------

		scrollToRow: function(rowVisualIndex, toTop){
			// summary:
			//		Scroll the grid until the required row is in view.
			// description:
			//		This job will be an asynchronous one if the lazy-loading and lazy-rendering are used.
			// rowVisualIndex: Integer
			//		The visual index of the row
			// toTop: Boolean?
			//		If set this to true, the grid will try to scroll the required row to the top of the view.
			//		Otherwise, the grid will stop scrolling as soon as the row is visible.
			// returns:
			//		A deferred object indicating when the scrolling process is finished. This will be useful
			//		when using lazy-loading and lazy-rendering.
			var d = new Deferred(),
				bn = this.grid.bodyNode,
				dn = this.domNode,
				dif = 0,
				n = query('[visualindex="' + rowVisualIndex + '"]', bn)[0],
				finish = function(success){
					setTimeout(function(){
						d.callback(success);
					}, 5);
				};
			if(n){
				var no = n.offsetTop,
					bs = bn[st];
				if(toTop){
					dn[st] = no;
					finish(true);
					return d;	//dojo.Deferred
				}else if(no < bs){
					dif = no - bs;
				}else if(no + n.offsetHeight > bs + bn.clientHeight){
					dif = no + n.offsetHeight - bs - bn.clientHeight;
				}else{
					finish(true);
					return d;	//dojo.Deferred
				}
				dn[st] += dif;
			}
			finish(!!n);
			return d;	//dojo.Deferred
		},
	
		//Protected -------------------------------------------------
		_init: function(){
			this._onForcedScroll();
		},

		_update: function(){
			var t = this,
				g = t.grid;
			if(!g.autoHeight){
				var bd = g.body,
					bn = g.bodyNode,
					toShow = bd.renderCount < bd.visualCount || bn.scrollHeight > bn.clientHeight,
					ds = t.domNode.style;
					scrollBarWidth = metrics.getScrollbar().w + (sniff('webkit') ? 1 : 0);//Fix a chrome RTL defect
				if(sniff('ie') < 8){
					var w = toShow ? scrollBarWidth + 'px' : '0px';
					t.stubNode.style.width = w;
					ds.width = w;
				}else{
					ds.width = '';
				}
				ds.display = toShow ? '' : 'none';
				t._updatePos();
			}
			g.hLayout.reLayout();
		},

		_updatePos: function(){
			var g = this.grid,
				dn = this.domNode,
				ds = dn.style,
				ltr = g.isLeftToRight(),
				mainBorder = domGeo.getBorderExtents(g.mainNode);
			ds[ltr ? 'right' : 'left'] = -(dn.offsetWidth + (ltr ? mainBorder.r : mainBorder.l)) + 'px';
		},

		_doScroll: function(){
			this.grid.bodyNode[st] = this.domNode[st];
		},
	
		_onMouseWheel: function(e){
			if(this.grid.vScrollerNode.style.display != 'none'){
				var rolled = typeof e.wheelDelta === "number" ? e.wheelDelta / 3 : (-40 * e.detail); 
				this.domNode[st] -= rolled;
				event.stop(e);
			}
		},
	
		_onBodyChange: function(){
			var t = this,
				g = t.grid;
			t._update();
			//IE7 Needs setTimeout
			setTimeout(function(){
				if(!g.bodyNode){
					//fix FF10 - g.bodyNode will be undefined during a quick recreation
					return;
				}				
				t.stubNode.style.height = g.bodyNode.scrollHeight + 'px';
				t._doScroll();
				//FIX IE7 problem:
				g.vScrollerNode[st] = g.vScrollerNode[st] || 0;
			}, 0);
		},

		_onForcedScroll: function(){
			var t = this,
				bd = t.grid.body;
			return t.model.when({
				start: bd.rootStart,
				count: bd.rootCount
			}, function(){
				bd.renderRows(0, bd.visualCount);
			});
		},
	
		_onKeyScroll: function(evt){
			var t = this,
				g = t.grid,
				bd = g.body,
				bn = g.bodyNode,
				focus = g.focus,
				sn = t.domNode,
				rowNode;
			if(bn.childNodes.length && (!focus || focus.currentArea() == 'body')){
				if(evt.keyCode == keys.HOME){
					sn[st] = 0;
					rowNode = bn.firstChild;
				}else if(evt.keyCode == keys.END){
					sn[st] = sn.scrollHeight - sn.offsetHeight;
					rowNode = bn.lastChild;
				}else if(evt.keyCode == keys.PAGE_UP){
					if(!sn[st]){
						rowNode = bn.firstChild;
					}else{
						sn[st] -= sn.offsetHeight;
					}
				}else if(evt.keyCode == keys.PAGE_DOWN){
					if(sn[st] >= sn.scrollHeight - sn.offsetHeight){
						rowNode = bn.lastChild;
					}else{
						sn[st] += sn.offsetHeight;
					}
				}else{
					return;
				}
				if(focus){
					if(rowNode){
						bd._focusCellRow = parseInt(rowNode.getAttribute('visualindex'), 10);
						focus.focusArea('body', 1);	//1 as true
					}else{
						setTimeout(function(){
							var rowNodes = bn.childNodes,
								start = 0,
								end = rowNodes.length - 1,
								containerPos = domGeo.position(bn),
								i, p,
								checkPos = function(idx){
									var rn = rowNodes[idx],
										pos = domGeo.position(rn);
									if(evt.keyCode == keys.PAGE_DOWN){
										var prev = rn.previousSibling;
										if((!prev && pos.y >= containerPos.y) || pos.y == containerPos.y){
											return 0;
										}else if(!prev){
											return -1;
										}else{
											var prevPos = domGeo.position(prev);
											if(prevPos.y < containerPos.y && prevPos.y + prevPos.h >= containerPos.y){
												return 0;
											}else if(prevPos.y > containerPos.y){
												return 1;
											}else{
												return -1;
											}
										}
									}else{
										var post = rn.nextSibling;
										if((!post && pos.y + pos.h <= containerPos.y + containerPos.h) ||
											pos.y + pos.h == containerPos.y + containerPos.h){
											return 0;
										}else if(!post){
											return 1;
										}else{
											var postPos = domGeo.position(post);
											if(postPos.y <= containerPos.y + containerPos.h &&
													postPos.y + postPos.h > containerPos.y + containerPos.h){
												return 0;
											}else if(postPos.y > containerPos.y + containerPos.h){
												return 1;
											}else{
												return -1;
											}
										}
									}
								};
							//Binary search the row to focus
							while(start <= end){
								i = Math.floor((start + end) / 2);
								p = checkPos(i);
								if(p < 0){
									start = i + 1;
								}else if(p > 0){
									end = i - 1;
								}else{
									rowNode = rowNodes[i];
									break;
								}
							}
							if(rowNode){
								bd._focusCellRow = parseInt(rowNode.getAttribute('visualindex'), 10);
								focus.focusArea('body', 1);	//1 as true
							}
						}, 0);
					}
				}
				event.stop(evt);
			}
		}
	});
});
