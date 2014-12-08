
var current_room = "";
			
		function flash() {
			return document.getElementById("my_flash");
		}
		
		function connect() {
			var host = "128.199.35.15";
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
			var target = current_room;
			
			irc_msg(target, msg);
		}
		
		function connected()
		{
			nick();
			user();
		}
		
		function nick()
		{
			irc_nick("tguser");
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
      current_room = channel;
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
			
			
			var lines = data.split("\r\n");
      var msg = parse_lines(lines);
			
			
			
			for( var i = 0; i < msg.length; i++)
			{
				
				
				//var c_from = row.insertCell();
				//var c_msg = row.insertCell();
				var row = chat_wrapper.insertRow();
				row.insertCell().innerHTML = msg[i].from + ": " + msg[i].text;
				
				//c_from.innerHTML = from;
				//c_msg.innerHTML = msg;
				table_wrapper.scrollTop = table_wrapper.scrollHeight;
				
			}
			
		}
		
  function parse_lines(lines)
  {
    var msg = {};
    var msgs = [];
    var from = "";
    var text = "";

    for( var i = 0; i < lines.length; i++)
    {
      var l = lines[i].split(' ');
      from = l[0].replace(":", "");
      from = from.replace(/!~.+/, "");

      for(var p = 1; p < l.length; p++)
      {
        var part = l[p];
        var res = part.match(/:/);
        if(res)
        {
          text = l[p].replace(":","");
          for(var n = p + 1; n < l.length; n++)
          {
            text = text + " " + l[n];
          }
          break;
        }
      }

      msgs.push({ "text": text, "from":from});

  }

  return msgs;

  }
		
		function connection_closed()
		{
		}
		
		function flash_ready()
		{
			alert("flash is loaded");
		}
