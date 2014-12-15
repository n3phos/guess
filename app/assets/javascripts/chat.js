/* class definition */

var WebChat = function() {
  this.connection = null;
  this.initialized = false;
  this._room_name = "";
  this._room = "";
  this._room_op = "";
  this._user = {};
  this._users = {};
}

/* global chat instance */

var chat = new WebChat();
var from = "";

/*$(document).ready(function() {
  chat.initialize();
});
*/
var timestamp = null;

var load_callback = function (e) {


  if(!e.success || !e.ref) { return false; }

  swfLoadEvent(function() {

    chat.init();

  },e);


};

function swfLoadEvent(fn, e) {
  if(typeof fn !== "function") { return false; }

  var initialTimeout = setTimeout(function () {
    if(typeof e.ref.PercentLoaded !== "undefined" && e.ref.PercentLoaded()) {
      var loadCheckInterval = setInterval(function () {
        if(e.ref.PercentLoaded() === 100) {
          fn();
          clearInterval(loadCheckInterval);
        }
      }, 1500);
    }
  }, 200);
}

WebChat.prototype.receive_data = function(data) {
  var lines = data.split("\r\n");
  var msg = parse_lines(lines);
  handle_message(msg);
}

WebChat.prototype.on_welcome = function() {
  this.join();

  seconds = $.now();
  seconds = timestamp - seconds;
  seconds = seconds / 1000;

  welcome_user("Welcome to the chat, it took " + seconds + " seconds to init chat");
}


WebChat.prototype.connected = function()
{
  nick();
  user();
}

WebChat.prototype.send_data = function(data) {
  this.connection.send_data(data);
}

WebChat.prototype.join = function() {

  var room = this.room();
  irc_join(room);

}

WebChat.prototype.init = function()
{

  timestamp = $.now();

  $.ajax({
    url: $(location).attr('href') + "/info",
    type: "GET",
    dataType: 'json',
    success: function(data) {
      chat.set_users(data["users"]);
      chat.set_room_op(data["room_operator"]);
      chat.set_room_name(data["name"]);
      chat.set_room_channel(data["channel"]);
      chat.set_user(data["current_user"]);

      chat.init_flash();

      chat.connect();

    }
  });



}

WebChat.prototype.set_users = function (users)
{
  this._users = users;
}

WebChat.prototype.init_flash = function() {
  var f = flash();
  if( f == "undefined") {
    alert("undefined");
  }
  this.connection = f;
}

WebChat.prototype.users = function()
{
  return this._users;
}

WebChat.prototype.set_room_channel = function(channel)
{
  this._room = channel;
}

WebChat.prototype.room = function()
{
  return this._room;
}

WebChat.prototype.set_room_name = function (name) {
  this._room_name = name;
}

WebChat.prototype.room_name = function() {
  return this._room_name;
}

WebChat.prototype.set_room_op = function (operator) {
  this._room_op = operator;
}

WebChat.prototype.room_op = function() {
  return this._room_op;
}

WebChat.prototype.set_user = function(user) {
  this._user = user;
}

WebChat.prototype.user = function(irc_nick) {
  irc_nick = irc_nick || "";
  if(irc_nick == "") {
    return this._user;
  }
  var user = this._users[irc_nick];
  if(!user) { return irc_nick };
  return user;
}

WebChat.prototype.connect = function() {

  var host = "128.199.35.15";
  var port = 6667;

  this.connection.connect(host, port);

}


$(function() {
  $("#usermsg").keypress(function(e) {
    if(e.which == 13) {
      e.stopImmediatePropagation();
      var msg = $(this).val();
      message(msg);
      $(this).val("");

      return false;
    }
  });
});

window.onbeforeunload = function () {

  var curl = $(location).attr('href');

  $.ajax({
    url: curl + "/leave",
    type: "GET",
    async: false,
    dataType: "json"
  });

}

		function flash() {
			return document.getElementById("my_flash");
		}
		
		
		function join() {
			var channel = document.getElementById("channel").value
			irc_join(channel);
		}
		
    function message(msg) {
      var target = chat.room();

      irc_msg(target, msg);
      update_chat([{ "from": chat.user().name, "text": msg}]);
    }
		
		
		function nick()
		{
      var nick = chat.user().irc_nick;
			irc_nick(nick);
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
			chat.send_data(cmd);
		}
		
		
		
		


  function handle_message(msgs)
  {
    var chat_messages = [];

    for(i = 0; i < msgs.length; i++) {

      switch(msgs[i].command) {
        case "PRIVMSG":
          chat_messages.push(msgs[i]);
          break;
        case "JOIN":
          on_user_join(msgs[i]);
          break;
        case "PING":
          pong(msgs[i]);
          break;
        case "QUIT":
          on_user_left(msgs[i]);
          break;
        case "001":
          chat.on_welcome(msgs[i]);
          break;

        default:
          break;
      }
    }

    if(chat_messages.length > 0)
    {
      chat_handle_message(chat_messages);
    }
  }

  function update_users()
  {

      var curl = $(location).attr('href');

      $.ajax({
        url: curl + "/info",
        async: false,
        type: "GET",
        dataType: 'json',
        success: function(data) {

          chat.set_users(data["users"]);

        }
      });
  }

  function on_user_join(msg)
  {

    if(chat.user().irc_nick !== msg.from) {


      update_users();

      event_message = chat.user(msg.from) + " joined the room";

      render_new_users();
    }
  }

  function on_user_left(msg)
  {

    event_message = chat.user(msg.from) + " has left the room";

    update_users();

    render_new_users();

  }

  function render_new_users()
  {
    var curl = $(location).attr('href');

    $.ajax({
      url: curl + "/users",
      type: "GET",
      success: function() {

        chat.append(event_message);
        event_message = "";
      }
    });
  }





  function welcome_user(welcome_message)
  {
    chat.append(welcome_message);
  }

  WebChat.prototype.append = function(msg) {

    var table_wrapper = document.getElementById("table-wrapper");
    var chat_wrapper = document.getElementById("chatWrapper");

    var row = chat_wrapper.insertRow();
    row.insertCell().innerHTML = msg;

    table_wrapper.scrollTop = table_wrapper.scrollHeight;

  }


  function pong(msg)
  {
    irc_pong(msg.target);
  }

  function irc_pong(target)
  {
    var cmd = "PONG " + target;
    send_cmd(cmd);
  }

  function update_chat(msgs)
  {
    var table_wrapper = document.getElementById("table-wrapper");
    var chat_wrapper = document.getElementById("chatWrapper");


    for( var i = 0; i < msgs.length; i++)
    {
      var row = chat_wrapper.insertRow();
      row.insertCell().innerHTML = msgs[i].from + ": " + msgs[i].text;

      table_wrapper.scrollTop = table_wrapper.scrollHeight;
    }

  }

  function chat_handle_message(msgs) {
    for( var i = 0; i < msgs.length; i++)
    {
      var msg = msgs[i];
      msg.from = chat.user(msg.from);
    }

    update_chat(msgs);
  }

  function parse_lines(lines)
  {
    var msg = {};
    var msgs = [];

    for( var i = 0; i < lines.length; i++)
    {
      if(lines[i] == "")
        continue;

      var parts = lines[i].split(' ');
      var cmd = "";
      var from = "";
      var text = "";
      var target = "";

      if(parts[0].match(/PING/))
      {
        cmd = parts[0];
        target = parts[1].replace(":", "");

        msgs.push({ "command":cmd, "target":target});

        continue;
      }


      from = parts[0].replace(":", "");
      from = from.replace(/!~.+/, "");
      cmd = parts[1];
      target = parts[2];


      for(var p = 1; p < parts.length; p++)
      {
        var part = parts[p];
        var res = part.match(/:/);
        if(res)
        {
          text = parts[p].replace(":","");
          for(var n = p + 1; n < parts.length; n++)
          {
            text = text + " " + parts[n];
          }
          break;
        }
      }

      msgs.push({ "text": text, "from":from, "command":cmd, "target":target});

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
