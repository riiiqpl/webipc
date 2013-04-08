package
{
	import flash.events.AsyncErrorEvent;
	import flash.events.StatusEvent;
	import flash.net.LocalConnection;

	
	public class IPCHost
	{
		private var lc:LocalConnection = new LocalConnection;
		private var msgMap:Array = [/* int => string[] */];
		private var channel:String;
		
		
		public function IPCHost(channel:String)
		{
			lc.client = this;
			lc.allowDomain('*');
			lc.addEventListener(StatusEvent.STATUS, handleStatusError);
			lc.addEventListener(AsyncErrorEvent.ASYNC_ERROR, handleAsyncError);
			this.channel = channel;
		}
		
		public function init() : void
		{
			try {
				lc.connect(channel);
				trace('[IPCHost] created!!!');
			}
			catch(e:Error) {}
			
			for(var i:int = 0; i < 100; i++) {
				lc.send(channel + i, 'onRestore');
			}
		}
		
		public function dispose() : void
		{
			trace('[IPCHost] dispose');
			lc.close();
		}
		
		public function onClear(pid:String) : void
		{
			var list:Vector.<String>;
			for each(list in msgMap) {
				var p:int = list.indexOf(pid);
				if (p != -1)
					list.splice(p, 1)
			}
		}
		
		public function onWatch(subject:int, id:String) : void
		{
			trace('[IPCHost] onWatch (subject:' + subject + ', pid=' + id + ')');
			
			var list:Vector.<String> = msgMap[subject];
			if (!list)
				list = msgMap[subject] = new Vector.<String>;
			list.push(id);
		}
		
		public function onUnwatch(subject:int, id:String) : void
		{
			trace('[IPCHost] onUnwatch (subject:' + subject + ', pid=' + id + ')');
			
			var list:Vector.<String> = msgMap[subject];
			var p:int = list.indexOf(id);
			if (p != -1)
				list.splice(p, 1)
		}
		
		public function onPost(subject:int, msg:String) : void
		{
			for each(var k:String in msgMap[subject]) {
				lc.send(channel + k, 'onNotify', subject, msg);
			}
		}
		
		private function handleStatusError(e:StatusEvent) : void
		{
		}
		
		private function handleAsyncError(e:AsyncErrorEvent) : void
		{
		}
	}
}