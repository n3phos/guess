package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.Socket;
	import flash.events.ProgressEvent;
	import flash.external.ExternalInterface;
	import flash.system.Security;
	
	Security.allowDomain("http://localhost", "*");
	
	public class Main extends Sprite 
	{
		
		private var socket:Socket;
		private var connectionState:String = "INIT";

		
		public function Main():void 
		{
			
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			
			trace("initializing...");
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			ExternalInterface.addCallback("connect", connect);
			ExternalInterface.addCallback("close_connection", close);
			ExternalInterface.addCallback("send_data", send_data);
			
			
			//ExternalInterface.call("flash_ready");
		}
		
		
		public function connect(host:String, port:int):void
		{
			trace("connecting to: " + host + ":" + port);
			socket = new Socket(host, port);
			socket.addEventListener(Event.CONNECT, connectHandler);
			socket.addEventListener(Event.CLOSE, closeHandler);
			socket.addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
		}
		
		public function send_data(data:String):void
		{
			trace("sending data: " + data);
			socket.writeUTFBytes(data);
			socket.flush();
		}
		
		private function receive_data():void
		{
			
			var data:String = socket.readUTFBytes(socket.bytesAvailable);
			trace("received data: " + data);
			ExternalInterface.call("receive_data", data);
		}
		
		public function close():void 
		{
			socket.close();
		}
		
		private function socketDataHandler(e:ProgressEvent):void
		{
			receive_data();
		}
		
		private function connectHandler(e:Event):void
		{
			trace("connected");
			ExternalInterface.call("connected");
		}
		
		private function closeHandler(e:Event):void
		{
			ExternalInterface.call("connection_closed");
			trace("connection closed");
		}
		
		
	}
	
}