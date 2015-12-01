/* class definition */

var WebChat = function() {
  this.connection = null;
  this.initialized = false;
  this._room_name = "";
  this._room = "";
  this._room_op = "";
  this._user = {};
  this._users = {};
  this.irc = new IRC();
}

/* IRC class */
var IRC = function() {

}
/* global chat instance */

var chat = new WebChat();
var from = "";

var timestamp = null;

/* SWF load callbacks */

var load_callback = function (e) {
  if(!e.success || !e.ref) { return false; }

  swfLoadEvent(function() {

    chat.init();

  },e);

}

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

/* WebChat implementation */

/* initializers */

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

  // leave the chat before a page change happens
  $(document).on("page:before-change", chat.leave);


  // register chat input event listener
  $(function() {
    $("#usermsg").keypress(function(e) {
      if(e.which == 13) {
        e.stopImmediatePropagation();
        var msg = $(this).val();
        chat.msg(msg);
        $(this).val("");

        return false;
      }
    });
  });

}

WebChat.prototype.init_flash = function() {
  var f = document.getElementById("my_flash");
  if( f == "undefined") {
    alert("undefined");
  }
  this.connection = f;
}

/* network */

/* connection callback called from flash */
WebChat.prototype.connected = function()
{
  var n = this.user().irc_nick;
  this.irc.nick(n);
  this.irc.user("guest",0,"mrnobody24");
}

WebChat.prototype.receive_data = function(data) {
  this.irc.receive_data(data);
}

WebChat.prototype.send_data = function(data) {
  this.connection.send_data(data);
}

WebChat.prototype.connect = function() {
  var host = "irc.themeguess.com"
  var port = 6667;

  this.connection.connect(host, port);
}

/* getters & setters */

WebChat.prototype.set_users = function (users)
{
  this._users = users;
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

/* chat commands */

WebChat.prototype.quit = function() {
  this.irc.quit();
}

WebChat.prototype.welcome_user = function(welcome_message)
{
  this.append(welcome_message);
}

/* send a chat message */
WebChat.prototype.msg = function(msg) {

  this.irc.msg(msg);

  this.append(chat.user().name + ": " + msg);


}
WebChat.prototype.submit_msg = function() {

  var m = $('#usermsg').val();
  this.msg(m);
  $('#usermsg').val("");

}

WebChat.prototype.leave = function(ori) {

  if(ori == "chatcontrols") {

  } else {
    ori = "";
  }

  $(document).off("page:before-change");

  var curl = $(location).attr('href');

  $.ajax({
    url: curl + "/leave",
    type: "GET",
    data: { origin: ori}
  });

}
/* UI stuff */

WebChat.prototype.update_users = function()
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


WebChat.prototype.render_new_users = function()
{
  var curl = $(location).attr('href');
  var users = chat._users;
  var user = "";
  var list = "";

  for( var u in users ) {
    user = users[u];
    list += "<li>" + user + "</li>";
  }

  $('#user-list').html(list);

}

WebChat.prototype.remove_user = function(user) {
  delete this._users[user];
}

WebChat.prototype.message_handler = function(msgs) {
  /* lookup user names */
  for( var i = 0; i < msgs.length; i++)
  {
    var msg = msgs[i];
    msg.from = chat.user(msg.from);
  }

  this.append(msgs);
}

/* appends new message to chat window, accepts string or array of
   messages object */
WebChat.prototype.append = function(msg) {
  var table_wrapper = document.getElementById("table-wrapper");
  var chat_wrapper = document.getElementById("chatWrapper");

  if(typeof msg == "string") {

    var row = chat_wrapper.insertRow();
    row.insertCell().innerHTML = msg;

    table_wrapper.scrollTop = table_wrapper.scrollHeight;

  } else if (typeof msg == "object") {

    for( var i = 0; i < msg.length; i++)
    {
      var row = chat_wrapper.insertRow();
      row.insertCell().innerHTML = msg[i].from + ": " + msg[i].text;

      table_wrapper.scrollTop = table_wrapper.scrollHeight;
    }

  } else {
    return;
  }

}

/* event handlers */

WebChat.prototype.on_user_join = function(msg)
{
  this.update_users();
  this.render_new_users();
  /*
    if(chat.user().irc_nick !== msg.from) {
      event_message = chat.user(msg.from) + " joined the room";
    }
  */
}

WebChat.prototype.on_user_left = function(msg)
{
  //event_message = chat.user(msg.from) + " has left the room";
  this.remove_user(msg.from);
  this.render_new_users();
}

WebChat.prototype.on_welcome = function() {
  // join the current room
  this.irc.join(this.room());

  seconds = $.now();
  seconds = timestamp - seconds;
  seconds = seconds / 1000;

  this.welcome_user("Welcome to the chat!");

  $('#users-wrapper').html('<ul id="user-list" class="list-users"></ul>');
  render_game();

}

function render_game() {
  var new_game_url = $(location).attr('href') + "/games/new"

  $.ajax({
    url: new_game_url,
    type: "GET",
  });

}


/* IRC implementation */

/* handle irc events */

IRC.prototype.dispatch_events = function(events)
{
  var chat_messages = [];
  for(i = 0; i < events.length; i++) {

    switch(events[i].command) {

      case "PRIVMSG":
        /* game events start with ! */
        if(events[i].text.match(/^!/)) {
          game.handle_event(events[i]);
        } else {
          /* else its a chat message */
          chat_messages.push(events[i]);
        }
        break;

      case "JOIN":
        chat.on_user_join(events[i]);
        break;

      case "PING":
        this.pong(events[i].target);
        break;

      case "QUIT":
        chat.on_user_left(events[i]);
        break;

      case "001":
        chat.on_welcome(events[i]);
        break;

      default:
        break;
    }
  }

  if(chat_messages.length > 0)
  {
    chat.message_handler(chat_messages);
  }
}

/* Commands */

IRC.prototype.quit = function() {
  var cmd = "QUIT";
  this.send_cmd(cmd);
}

IRC.prototype.nick = function(nick)
{
  var cmd = "NICK " + nick;
  this.send_cmd(cmd);
}

IRC.prototype.user = function(username, mode, realname)
{
  var cmd = "USER " + username + " " + mode + " * " + ":" + realname;
  this.send_cmd(cmd);
}

IRC.prototype.names = function()
{
  var cmd = "NAMES #tg-room#1";
  this.send_cmd(cmd);
}

IRC.prototype.join = function(channel)
{
  var cmd = "JOIN " + channel;
  current_room = channel;
  this.send_cmd(cmd);
}

IRC.prototype.msg = function(msg, target)
{
  target = target || chat.room();
  var cmd = "PRIVMSG " + target + " :" + msg;
  this.send_cmd(cmd);
}

IRC.prototype.pong = function(target)
{
  var cmd = "PONG " + target;
  this.send_cmd(cmd);
}

IRC.prototype.send_cmd = function send_cmd(cmd)
{
  cmd = cmd + "\r\n";
  chat.send_data(cmd);
}

/* data parsing */

IRC.prototype.receive_data = function(data) {
  var lines = data.split("\r\n");
  var events = this.parse_lines(lines);

  this.dispatch_events(events);
}

IRC.prototype.parse_lines = function(lines)
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
