//
// WebIPC Plugin by etherdream
//
var WebIPC = function() {

	function setDOMContentLoaded(cb) {
		if(window.addEventListener) {
			window.addEventListener('DOMContentLoaded', cb, false);
		}
		else {
			(function() {
				try	{
					document.documentElement.doScroll('left');
					cb();
				}
				catch(e) {
					setTimeout(arguments.callee, 1);
				}
			})();
		}
	}
	
	function createSwf(src) {
		var id = 'F' + ~~(1e6 * Math.random());
		var box = document.createElement('div');
		box.innerHTML = window.ActiveXObject?
			'<object id=' + id + ' classid=clsid:D27CDB6E-AE6D-11cf-96B8-444553540000><param name=movie value=' + src + '><param name=wmode value=opaque></object>':
			'<embed name=' + id + ' src=' + src + ' wmode=opaque></embed>';

		var fla = box.firstChild;
		var sty = fla.style;
		sty.position = 'fixed';
		sty.left = '1px';
		sty.top = '1px';
		sty.width = '1px';
		sty.height = '1px';
		sty.opacity = 0.1;
		//fla.style.top = '-999px';
		document.body.appendChild(fla);
		
		return fla;
	}

	_IPC_READY = function() {
		WebIPC.onready();
	}
	
	_IPC_CB = function(subject, msg) {
		WebIPC.onmessage(subject, msg);
	}

	function onUnload() {
		f.close();
	}

	if (window.addEventListener)
		window.addEventListener('unload', onUnload);
	else
		window.attachEvent('onunload', onUnload);

	var f;
	
	setDOMContentLoaded(function() {
		f = createSwf('WebIPC.swf');
	});

	return {
		setChannel: function(channel) {
			f.setChannel(channel);
		},
		watch: function(subject) {
			f.watch(subject);
		},
		unwatch: function(subject) {
			f.unwatch(subject);
		},
		send: function(subject, msg) {
			f.send(subject, msg);
		},
		dispose: function() {
			f.dispose();
		},

		onready: function(){},
		onmessage: function(){}
	};
}();