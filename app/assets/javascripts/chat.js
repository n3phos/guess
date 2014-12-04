
			
		function flash() {
			return document.getElementById("flashDiv");
		}
		
		function connect() {
			var host = "irc.freenode.org";
			var port = 6667;
			
			var f = flash();
      f.connect(host, port);
		}
		
		function join() {
			var channel = document.getElementById("channel").value
			irc_join(channel);
		}
		
		function message() {
			var msg = document.getElementById("msg").value
			var target = "#nephos";
			
			irc_msg(target, msg);
		}
		
		function connected()
		{
			nick();
			user();
		}
		
		function nick()
		{
			irc_nick("nephos_user2");
		}
		
		function user()
		{
			irc_user("guest",0,"mrnobody24");
		}
		
		function irc_nick(nick)
		{
			var cmd = "NICK " + nick;
			send_cmd(cmd);
		}
		
		function irc_user(username, mode, realname)
		{
			var cmd = "USER " + username + " " + mode + " * " + ":" + realname;
			send_cmd(cmd);
		}
			
		
		function irc_join(channel)
		{
			var cmd = "JOIN " + channel;
			send_cmd(cmd);
		}
		
		function irc_msg(target, msg)
		{
			var cmd = "PRIVMSG " + target + " :" + msg;
			send_cmd(cmd);
		}
		
		function send_cmd(cmd)
		{
			cmd = cmd + "\r\n";
			send_data(cmd);
		}
		
		
		
		function send_data(data)
		{
			flash().send_data(data);
		}
		
		function receive_data(data)
		{
			//var data = parse(data);
			
			var from = data[0];
			var msg = data[1];
			
			var table_wrapper = document.getElementById("table-wrapper");
			var chat_wrapper = document.getElementById("chatWrapper");
			
			
			var lines = parse(data);
			
			
			
			for( var i = 0; i < lines.length; i++)
			{
				
				
				//var c_from = row.insertCell();
				//var c_msg = row.insertCell();
				var row = chat_wrapper.insertRow();
				row.insertCell().innerHTML = lines[i];
				
				//c_from.innerHTML = from;
				//c_msg.innerHTML = msg;
				table_wrapper.scrollTop = table_wrapper.scrollHeight;
				
			}
			
		}
		
		function parse(data)
		{
			
			return data.split("\r\n");
			/*
			var parsed_message = [];
			var msg = data.split(" ");
			
			parsed_message[0] = msg[0];
			parsed_message[1] = msg[1];
			
			return parsed_message;
			*/
		}
		
		function connection_closed()
		{
		}
		
		function flash_ready()
		{
			alert("flash is loaded");
		}
