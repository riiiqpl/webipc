package
{
	import flash.display.Sprite;
	import flash.external.ExternalInterface;
	
	
	[SWF(frameRate="60")]
	public class WebIPC extends Sprite
	{
		private var host:IPCHost;
		private var user:IPCUser;
		
		
		public function WebIPC()
		{
			if (ExternalInterface.available) {
				ExternalInterface.addCallback('setChannel', DoSetChannel);
				ExternalInterface.addCallback('watch', DoWatch);
				ExternalInterface.addCallback('unwatch', DoUnwatch);
				ExternalInterface.addCallback('send', DoSend);
				ExternalInterface.addCallback('dispose', DoDispose);
				
				ExternalInterface.call('_IPC_READY');
			}
		}

		public function DoSetChannel(name:String) : void
		{
			// try host
			host = new IPCHost(name);
			host.init();
			
			// create client
			user = new IPCUser(name);
			user.init();
			user.onHostMissing = onHostMissing;
			user.onHostNotify = onHostNotify;
		}
		
		public function DoWatch(subject:int) : void
		{
			user.watch(subject);
		}
		
		public function DoUnwatch(subject:int) : void
		{
			user.unwatch(subject);
		}
		
		public function DoSend(subject:int, msg:String) : void
		{
			user.send(subject, msg);
		}
		
		public function DoDispose() : void
		{
			user.dispose();
			host.dispose();
		}
		
		private function onHostMissing() : void
		{
			host.init();
		}
		
		private function onHostNotify(subject:int, msg:String) : void
		{
			ExternalInterface.call('_IPC_CB', subject, msg);
		}
	}
}