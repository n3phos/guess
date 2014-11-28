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
		public var keyHit:Sprite;
		
		
		private var socket:Socket;
		
		private var hostPath:String = "irc.freenode.net";
		private var hostPort:int = 6667;
		
		private var nickname:String = "nephos_user";
		private var username:String = "Test User";
		private var hostname:String = "TEST-HOST";
		private var realname:String = "NO NAME";
		
		private var connectionState:String = "INIT";

		
		public function Main():void 
		{
			
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			trace("in init");
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			ExternalInterface.addCallback("connect", initSocket);
			ExternalInterface.addCallback("join", joinChannel);
			ExternalInterface.addCallback("send_msg", sendMessage);

		}
		
		
		public function initSocket():void
		{
			ExternalInterface.call("alert", "connect called");
			socket = new Socket(hostPath, hostPort);
			socket.addEventListener(Event.CONNECT, connectHandler);
			socket.addEventListener(Event.CLOSE, closeHandler);
			socket.addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
			
			connectionState = "CONNECTING";
		}
		
		private function sendNick():void
		{
			/*
				Command: NICK
   				Parameters: <nickname> [ <hopcount> ]
				
				Command: USER
				Parameters: <username> <hostname> <servername> <realname>
			*/
			
			// connectionState = "HANDSHAKE";

			socket.writeUTFBytes("NICK " + nickname + "\r\n");
			socket.writeUTFBytes("USER " + username + " " + hostname + " " + hostPath + ": " + realname + "\r\n");
			socket.flush();
		}
		
		private function quit():void
		{
			trace("quit");
			
			connectionState = "QUIT";
			socket.writeUTFBytes("QUIT :i quit there 4...\r\n");
			socket.flush();
		}
		
		public function joinChannel(channel:String):void
		{
			trace("JOIN: " + channel);
			socket.writeUTFBytes("JOIN " + channel + "\r\n");
			socket.flush();
		}
		
		public function sendMessage(msg:String):void
		{
			ExternalInterface.call("alert", "called sendMessage " + msg);
			socket.writeUTFBytes("PRIVMSG #nephos :" + msg + "\r\n");
			socket.flush();
		}
		
		private function sendTime():void
		{
			var now:Date = new Date();
			
			trace("TIME: " + now.toString());
			socket.writeUTFBytes("PRIVMSG #fort :teh time is now " + now.toString() + "\r\n");
			socket.flush();
		}
		
		private function pongServer(daemon:String):void
		{
			trace("PONG: *" + daemon + "*");
			socket.writeUTFBytes("PONG " + daemon + "\r\n");
			socket.flush();
		}
		
		private function readData():void
		{
			var socketData:String = socket.readUTFBytes(socket.bytesAvailable);
			trace(socketData);
			
			if (socketData.split(' ', 1)[0] == "PING")
			{
				// PING Command, send PONG
				pongServer(socketData.split(':')[1]);
			}
			else
			{
				var msg:String = socketData.substr(socketData.lastIndexOf(":"));
				trace("MSG: " + msg);
				if (msg.toLowerCase().indexOf("time") >= 0)
				{
					sendTime();
				}
				else if (msg.toLowerCase().indexOf("test") >= 0)
				{
					sendMessage("test");
				}
			}
		}
		
		private function socketDataHandler(e:ProgressEvent):void
		{
			trace("Data");
			readData();
		}
		
		private function connectHandler(e:Event):void
		{
			trace("Connect");
			connectionState = "CONNECTED";
			sendNick();
			joinChannel("#nephos");
		}
		
		private function closeHandler(e:Event):void
		{
			trace("Close");
			connectionState = "CLOSED";
		}
		
		
	}
	
}