package
{
	import flash.events.AsyncErrorEvent;
	import flash.events.StatusEvent;
	import flash.net.LocalConnection;

	
	public class IPCUser
	{
		public var onHostMissing:Function;
		public var onHostNotify:Function;
		
		private var lc:LocalConnection = new LocalConnection;
		private var arrSubjects:Array = [];
		private var channel:String;
		private var pid:String;
		
		
		
		public function IPCUser(channel:String)
		{
			lc.client = this;
			lc.allowDomain('*');
			lc.addEventListener(StatusEvent.STATUS, handleStatusError);
			lc.addEventListener(AsyncErrorEvent.ASYNC_ERROR, handleAsyncError);
			this.channel = channel;
		}
		
		public function init() : void
		{
			for(var i:int = 1; i < 100; i++) {
				try {
					lc.connect(channel + i);
					break;
				}
				catch(e:Error) {}
			}
			
			// 清理之前可能遗留下的回调接口
			pid = i + '';
			lc.send(channel, 'onClear', pid);
		}
		
		public function dispose() : void
		{
			trace('[IPCUser] dispose');
			
			// 支持unload事件的浏览器可以在此清理
			lc.send(channel, 'onClear', pid);
			lc.close();
		}
		
		public function watch(subject:int) : void
		{
			if (arrSubjects.indexOf(subject) == -1) {
				arrSubjects.push(subject);
				lc.send(channel, 'onWatch', subject, pid);
			}
		}
		
		public function unwatch(subject:int) : void
		{
			var p:int = arrSubjects.indexOf(subject);
			if (p != -1) {
				arrSubjects.splice(p, 1);
				lc.send(channel, 'onUnwatch', subject, pid);
			}
		}
		
		public function send(subject:int, msg:String) : void
		{
			lc.send(channel, 'onPost', subject, msg);
		}
		
		public function onNotify(subject:int, msg:String) : void
		{
			trace('[IPCUser] onNotify(pid=' + pid + ' subject=' + subject + ' msg=' + msg + ')');
			onHostNotify(subject, msg);
		}
		
		public function onRestore() : void
		{
			// 新Host上任，请求Client发送观察着的主题
			for each(var subject:int in arrSubjects) {
				lc.send(channel, 'onWatch', subject, pid);
			}
		}
		
		private function handleStatusError(e:StatusEvent) : void
		{
			trace('[IPCUser] handleStatusError (' + e.level + ')');
			
			if (e.level == 'error') {
				onHostMissing();
			}
		}
		
		private function handleAsyncError(e:AsyncErrorEvent) : void
		{
		}
	}
}