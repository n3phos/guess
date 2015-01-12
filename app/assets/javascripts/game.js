
var GameClient = function(game_id) {
  this.url = "";
  this.chat = null;
  this.player = new Player(this);

  this.load_delay = 15000;
  this.next_theme = null;
  this.current_record = null;
  this.next_record = null;
  this.last_record = false;
  this.game_url = $(location).attr('href') + "/games/" + game_id;
  this.stage = 0;
  this.stages = [ this.resolve_media, this.resolve_theme_name ];

}

var game = null;

$(document).ready(function(){
  $('#game-wrapper').on("initialize", function(event, opts) {
    game = new GameClient(opts.game_id);
    game.initialize();
    game.set_next_record(opts.record);
  });
});

GameClient.prototype.next = function() {

  this.player.stop();

  this.reset_stage();

  this.current_record = this.next_record;

  this.player.play();

}

GameClient.prototype.reset_stage = function() {

  this.stage = 0;
  var image = $('img#media-img')[0];
  image.src = "";
  image.style["display"] = "none";

}

GameClient.prototype.resolve_media = function() {

  this.show_media_img();
}

GameClient.prototype.show_media_img = function() {

  var image = $('img#media-img')[0];
  image.src = this.current_record.img_url;

}

GameClient.prototype.resolve_theme_name = function() {

}

GameClient.prototype.next_stage = function() {


  this.stages[this.stage].call(this)


  this.stage = this.stage + 1;
}

GameClient.prototype.handle_event = function(event) {

  if(event.match(/next/)) {
    if(event.match(/next_stage/)) {
      this.next_stage();
      return;
    }
    this.next();
    return;
  }

  if(event.match(/last/)) {
    this.last();
    return;
  }


}

GameClient.prototype.last = function() {
  this.last_record = true;
}

GameClient.prototype.test = function() {


  this.player.load(this.next_theme);


}


GameClient.prototype.initialize = function() {

  this.load_iframe_api();
  this.chat = chat;

  $('#media-img').bind("load", function() { $(this).fadeIn(3000); });

}

GameClient.prototype.on_video_cued = function() {

  this.chat.irc_msg("!video_ready");

}


  var theme1 = {
    "videoId": "ygNuRpwZqRU",
    "startSeconds": 0,
    "suggestedQuality": "small"
  }

 var theme2 = {
    "videoId": "ygNuRpwZqRU",
    "startSeconds": 0,
    "suggestedQuality": "small"
  }

  var theme3 = {
    "videoId": "Ii1tc493bZM",
    "startSeconds": 0,
    "suggestedQuality": "small"
  }

var records = [ theme1, theme2, theme3 ];

GameClient.prototype.get_next_record = function () {


  $.ajax({
    url: this.game_url,
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

  this.current_player.playVideo();

  this.game.on_video_play();

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












