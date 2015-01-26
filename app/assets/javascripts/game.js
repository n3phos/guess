
var GameClient = function(game_id) {
  game_id = game_id || "";

  this.url = "";
  this.chat = null;
  this.player = null;

  this.load_delay = 15000;
  this.next_theme = null;
  this.current_record = null;
  this.next_record = null;
  this.last_record = false;
  this.game_url = null;
  this.match_info = {};
  this.stage = 0;
  this.stages = [ ];
  this.started = false;
  this.record_player_img = null;

}

var game = new GameClient();

$(document).ready(function(){
  $('#game-wrapper').on("initialize", function(event, opts) {
    game.initialize(opts.game_id, opts.record_player_img);
    game.set_next_record(opts.record);
  });
});

GameClient.prototype.next = function() {

  //this.player.stop();


  console.log("user: " + this.chat.user().name + " in next: " + new Date);
  this.reset_stage();

  //this.notice("reset_complete");

}

GameClient.prototype.set_game_url = function (game_id) {
  this.game_url = $(location).attr('href') + "/games/" + game_id;
}

GameClient.prototype.show = function() {

  $.ajax({
    url: this.game_url + "/show",
    type: "GET"
  });

}


GameClient.prototype.reset_stage = function() {

  this.stage = 0;

  $('#media-img').fadeOut({ "duration": 2000,
                            "complete": function() { game.after_reset(); } });

  /*
  var image = $('img#media-img')[0];
  image.src = "";
  image.style["display"] = "none";
  */

}

GameClient.prototype.after_reset = function() {

  this.player.stop();

  this.notice("reset_complete");

}

GameClient.prototype.resolve = function() {

  this.resolve_media();

  this.resolve_theme_name();

}

GameClient.prototype.resolve_media = function() {


  $('#record-player').fadeOut(1000);
  this.show_media_img();
}

GameClient.prototype.show_media_img = function() {

  $('#record-player').fadeOut({ "duration": 1500, "complete": function() { $('#media-img').fadeIn(2000); } });
  //
  //
  //$('#media-img').fadeIn(2000);

}

GameClient.prototype.ready = function() {
  this.chat.irc_msg("!ready");
}

GameClient.prototype.play = function() {

  console.log("user: " + this.chat.user().name + " recieved play: " + new Date);

  this.current_record = this.next_record;

  $('#record-player').fadeIn(1000);

  if(!this.started) {
    this.started = true;
    this.query();
  }

  this.player.play();

}

GameClient.prototype.resolve_theme_name = function() {

}

GameClient.prototype.next_stage = function(delay) {

  delay = delay || null;

  if(this.current_record != null) {

    this.before_stage();
    this.stages[this.stage].call(this)
    this.stage = this.stage + 1;


    if(delay) {
      setTimeout(function() { game.next(); }, delay);
    }
  }



}

GameClient.prototype.before_stage = function() {

  var user = "";

  if(this.match_info.resolver != "GameServer") {
    user = this.chat.user(this.match_info.resolver);
    user = user + " - ";
  }

  var match = $('#match-answer');
  var answer = this.match_info.val;

  match.html(user + answer);

  match.fadeIn({ "duration": 2000, "complete": setTimeout(function () { game.after_stage(); }, 4000 ) });

}

GameClient.prototype.after_stage = function() {
  $('#match-answer').fadeOut({"duration": 2000, "complete": function () { game.query(); } });
}

GameClient.prototype.handle_event = function(event) {

  if(event.match(/next/)) {
    if(event.match(/next_stage/)) {
      var delay = event.match(/[0-9]+/);
      if(delay) {
       delay = parseInt(delay);
      }
      this.next_stage(delay);
      return;
    }
    this.next();
    return;
  }

  if(event.match(/play/)) {
    this.play();
    return;
  }

  if(event.match(/last/)) {
    this.last();
    return;
  }

  if(event.match(/resolve/)) {
    this.resolve();
    return;
  }

  if(event.match(/match/)) {
    var info = event.split(":");

    var match_name = info[1];
    var match_val = info[2];
    var match_resolver = info[3];

    if (typeof match_name != "undefined") {
      this.match_info["name"] = match_name;
    }

    if (typeof match_val != "undefined") {
      this.match_info["val"] = match_val;
    }

    if (typeof match_resolver != "undefined") {
      this.match_info["resolver"] = match_resolver;
    }

    this.display_match_info();

  }
}

GameClient.prototype.display_match_info = function () {

}

GameClient.prototype.query = function() {

  if (this.match_info.name) {
    $('#match-lookup-name').html(this.match_info.name);
  }

}

GameClient.prototype.last = function() {
  this.last_record = true;
}

GameClient.prototype.test = function() {


  this.player.load(this.next_theme);


}


GameClient.prototype.initialize = function(game_id, img_url) {

  this.set_game_url(game_id);

  this.record_player_img = img_url;

  this.stages = [ this.resolve_media, this.resolve_theme_name, this.resolve_theme_name ];

  this.player = new Player(this);

  this.load_iframe_api();
  this.chat = chat;

  $('#media-img').bind("load", function() { $(this).hide(); });

  $('#record-player')[0].src = img_url;
  $('#record-player').hide();



}

GameClient.prototype.on_video_cued = function() {

  this.notice("video_ready");

}

GameClient.prototype.notice = function(event) {

  switch(event) {
    case "video_ready":
      this.video_ready = true;
      break;
    case "reset_complete":
      this.reset = true;
      break;
    default:
      break;
  }

  if(this.video_ready && this.reset) {
    this.ready();
    this.video_ready = false;
    this.reset = false;
    return;
  }

  if(this.video_ready && !this.started) {
    this.ready();
    this.video_ready = false;
    return;
  }

}






GameClient.prototype.get_next_record = function () {


  $.ajax({
    url: this.game_url + "/next",
    async: false,
    type: "GET",
    dataType: "json",
    success: function(data) {
      game.set_next_record(data)
    }
  });

}

GameClient.prototype.set_next_record = function(record) {

  this.next_record = record;

  this.next_theme = {
    "videoId": record.video_id,
    "startSeconds": record.startSeconds,
    "endSeconds": record.endSeconds,
    "suggestedQuality": "small"
  }

}

GameClient.prototype.load_iframe_api = function() {
  var tag = document.createElement('script');

  tag.src = "https://www.youtube.com/iframe_api";
  var firstScriptTag = document.getElementsByTagName('script')[0];
  firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
}


function onYouTubeIframeAPIReady() {
  game.init_players();
}

GameClient.prototype.init_players = function(parray) {

  var players = {};

  players["a"] = new YT.Player('player', {
                        height: '0',
                        width: '0',
                        events: {
                          'onReady': game.player.onPlayerReady,
                          'onStateChange': game.player.onStateChange
                        }
                      });

  players["b"] = new YT.Player('playerb', {
                        height: '0',
                        width: '0',
                        events: {
                          'onReady': game.player.onPlayerReady,
                          'onStateChange': game.player.onStateChange
                        }
                      });

  this.player.set(players);
}

GameClient.prototype.on_video_play = function () {

  /*
  var record = this.get_next_record();

  if(record == null || record == "undefined") {
    return;
  }

  this.next_theme = record;

  this.player.load(record);
 */

  var image = $('img#media-img')[0];
  image.src = this.current_record.img_url;

  if(this.last_record) return;

  this.get_next_record();

  this.player.load(this.next_theme);



}



var Player = function(game) {

  this.current_player = null;
  this.players = {};
  this.ready = null;
  this.queque = [];
  this.last_load = "b";
  this.game = game;

}

var played = 0;

Player.prototype.play = function() {

  var frameID = this.last_load;
  var p = this.players[frameID];

  this.current_player = p;

  setTimeout(function() { game.on_video_play(); }, 3000);


  this.current_player.playVideo();

  //this.game.on_video_play();

}



Player.prototype.stop = function() {

  if(this.current_player != null) {
    this.current_player.pauseVideo();
  }

}

Player.prototype.set = function(players) {
  this.players = players;
}

Player.prototype.onPlayerReady = function(event) {

  if(this.ready) {

    game.test();

  } else {
    this.ready = "a";
  }

}



Player.prototype.load = function(theme) {


  if(this.last_load == "a" ) {

    this.players["b"].cueVideoById(theme);
    this.last_load = "b";
  } else if(this.last_load == "b") {
    this.players["a"].cueVideoById(theme);
    this.last_load = "a";
  }

}

Player.prototype.onStateChange = function(event) {

  var state = event.data;

  switch(state) {
    case YT.PlayerState.CUED:
      game.on_video_cued();
      break;
  }

}












