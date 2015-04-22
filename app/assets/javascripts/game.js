

$(document).ready(function(){
  $('#game-wrapper').on("initialize", function(event, opts) {
    if(!game.initialized) {
      game.initialize(opts);
    } else {
      game.reload(opts);
    }
  });
});

function onYouTubeIframeAPIReady() {
  game.setup_player();
}

var GameClient = function(chat) {
  this.chat = chat;
  this.game_url = null;
  this.player = null;
  this.categories = "";

  // booleans
  this.initialized = false;
  this.started = false;
  this.finished = false;
  this.last_record = false;
  this.stage_reset = false;
  this.joining = false;

  // record
  this.next_theme = null;
  this.current_record = null;
  this.next_record = null;
  this.match_info = {};
  this.record_player_img = null;

  // stage
  this.progress = 0;
  this.progress_steps = [20, 40, 60, 80, 100];
  this.after_stage_callback = null;
  this.stage = 0;
  this.stages = [ ];

  this.rids = 1;
  this.rhistory = null;
}

var game = new GameClient(chat);

GameClient.prototype.initialize = function(opts) {
  this.record_player_img = opts.record_player_img;

  // resolve media in first stage
  this.stages = [ this.resolve_media ];

  this.player = new Player(this);

  // embed youtube player api
  this.load_iframe_api();

  this.initialized = true;

  $('#record-player')[0].src = opts.record_player_img;
  $('#record-player').hide();

  var rec = opts.record;

  if(rec.video_id !== "not_defined") {
    this.set_next_record(rec);
  }

}

GameClient.prototype.load_iframe_api = function() {
  var tag = document.createElement('script');

  tag.src = "https://www.youtube.com/iframe_api";
  var firstScriptTag = document.getElementsByTagName('script')[0];
  firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
}

GameClient.prototype.setup_player = function() {
  this.player.setup();
}

GameClient.prototype.new = function(event) {
  $.ajax({
    "url": $(location).attr('href') + "/games",
    "type": "POST",
    "data": { "categories": game.categories,
              "load_next": this.initialized }
  });

  if($('#btn-movie').hasClass('active')) {
    $('#btn-movie').button('toggle');
  }

  if($('#btn-game').hasClass('active')) {
    $('#btn-game').button('toggle');
  }

  if($('#btn-series').hasClass('active')) {
    $('#btn-series').button('toggle');
  }
}

GameClient.prototype.reload = function(opts) {
  this.set_next_record(opts.record);
  this.stage_reset = false;
  this.run();

  $('#game-controls').css("visibility", "hidden")
}

/* game state */

GameClient.prototype.ready = function() {
  this.chat.irc.msg("!ready");
}

GameClient.prototype.play = function() {

  console.log("user: " + this.chat.user().name + " recieved play: " + new Date);

  this.current_record = this.next_record;

  $('#record-player').fadeIn(1000);

  if(!this.started) {
    $('#game-status').css("visibility", "hidden");
    $('#status-text').css("visibility", "hidden");

    this.started = true;
    this.query();

  }

  this.player.play();

}

GameClient.prototype.run = function() {
  this.player.init_volume();
  this.new_rec_history();

  if(this.next_theme != null) {
    this.player.load(this.next_theme);
  }

  if(this.joining) {
    this.play();
    this.joining = false;
  }
}

GameClient.prototype.finish = function() {

  this.after_stage_callback = function() {
    game.reset();

    $('#match-question').html("Finished");
    $('#game-controls').css("visibility", "visible");

    game.finished = true;
  }

  this.before_stage();
  this.stages[this.stage].call(this)
}

GameClient.prototype.reset = function() {
    this.rids = 1;
    this.rhistory = null;
    this.started = false;
    this.current_record = null;
    this.next_record = null;
    this.last_record = false;
    this.stage = 0;
    this.game_url = null;
    this.next_theme = null;
    this.after_stage_callback = null;
    this.stage_reset = false;
    this.categories = "";
}

GameClient.prototype.load_new = function(game_id) {
  var load_next = null;

  if(!this.initialized) {
    load_next = false;
  } else {
    load_next = true;
    this.load_and_reset();
  }

  this.set_game_url(game_id);
  this.show(load_next);

}

GameClient.prototype.load_and_reset = function() {
  $('#game-controls').css("visibility", "hidden");
  $('#match-question').html("");
  $('#status-text').html("loading game...").css("visibility","visible");
  $('#game-status').css("visibility", "visible");

  if(this.finished) {
    this.reset_stage(false);
  }
}

GameClient.prototype.show = function(load_next) {
  load_next = typeof load_next !== 'undefined' ? load_next : false;

  $.ajax({
    url: this.game_url + "/show",
    type: "GET",
    data: { "load_next": load_next }
  });

}

GameClient.prototype.set_category = function(event) {
  var cat = event.data;
  var b = "#" + this.id

  if(game.categories.indexOf(cat) != -1) {
    game.categories = game.categories.replace(cat + ",", "");
    $(b).blur();
  } else {
    game.categories += cat + ",";
  }

  $(b).button('toggle');
}

GameClient.prototype.set_game_url = function (game_id) {
  this.game_url = $(location).attr('href') + "/games/" + game_id;
}


/* game history */

GameClient.prototype.update_history = function() {
  this.update_record_history();
}

GameClient.prototype.new_rec_history = function() {
  var id = this.rids;
  this.rids = this.rids + 1;

  var wrapper = document.createElement("div");

  var table = document.createElement("table");
  var tbody = document.createElement("tbody");
  var tr = document.createElement("tr");
  var td = document.createElement("td");

  tr.appendChild(td);

  table.id = "record_" + id;
  table.appendChild(tbody);

  wrapper.appendChild(table);
  wrapper.className += " record-history";
  wrapper.id = "rw_" + id;

  td.appendChild(wrapper);

  $('#records').prepend(tr);

  this.rhistory = id;

  $("#record_" + this.rhistory).css("width", "100%");

}

GameClient.prototype.update_record_history = function() {
  var match = this.match_info;
  var content = ""

  content = "<div> " + match.last_q + " - " + match.answer;
  if(match.resolver != "GameServer") {
    content = content + " - " + this.chat.user(match.resolver);
  }
  content = content + "</div>";

  var rw = "#rw_" + this.rhistory;

  if(! $(rw).hasClass("record-divider")) {
      $(rw).addClass("record-divider");
  }

  this.add_rhistory_entry(content);

  if(typeof match.video_id != "undefined") {
    var url = "https://www.youtube.com/watch?v=" + match.video_id;
    content = "<a href=\"" + url + "\">" + "youtube link" + "</a>";
    this.add_rhistory_entry(content);

    this.rhistory = null;
    this.match_info.video_id = undefined;

    this.new_rec_history();
  }

}

GameClient.prototype.add_rhistory_entry = function(content) {
  var e = null;
  var trow = document.createElement("tr");
  var tdata = document.createElement("td");

  var entry = $(content)[0];

  if(typeof entry != "undefined") {
    tdata.appendChild(entry);
  }

  trow.appendChild(tdata);
  var record = "#record_" + this.rhistory;

  //$("#record_" + this.rhistory).css("width", "100%");
  $(record).prepend(trow);

}


/* record */

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
    "startSeconds": record.start_seconds,
    "endSeconds": record.end_seconds,
    "suggestedQuality": "small"
  }

}

GameClient.prototype.last = function() {
  this.last_record = true;
}


/* stage stuff */

GameClient.prototype.next_stage = function(delay) {
  delay = delay || null;

  if(this.current_record != null) {
      this.before_stage();
      stage_callback = this.stages[this.stage];

      if(stage_callback != undefined) {
        stage_callback.call(this)
      }
      this.stage = this.stage + 1;

      if(delay) {
        setTimeout(function() { game.next(); }, delay);
      }
  }

}

GameClient.prototype.next = function() {
  console.log("user: " + this.chat.user().name + " in next: " + new Date);
  this.reset_stage();
}

GameClient.prototype.reset_stage = function(notice) {
  notice = typeof notice !== 'undefined' ? notice : true;
  this.stage = 0;

  $('#media-img').fadeOut({ "duration": 2500,
                            "progress": function(anim, prog, remainingMs) { game.fade_out_progress(anim, prog, remainingMs); },
                            "complete": function() { game.stage_reset_complete(notice); } });

}

GameClient.prototype.fade_out_progress = function(anim, prog, remainingMs) {
  var perc = Math.round(prog * 100);

  if(perc == this.progress) {
    //console.log("progress: " + prog + "current_vol: " + this.player.current_player.getVolume());
    this.player.lower_volume();
    this.progress = this.progress_steps.shift();
  }
}


GameClient.prototype.before_stage = function(callback) {
  var user = "";

  if(this.match_info.resolver != "GameServer") {
    user = this.chat.user(this.match_info.resolver);
    user = user + " - ";
  }

  var match = $('#match-answer');
  var answer = this.match_info.answer;

  match.html(user + answer);
  match.fadeIn({ "duration": 2000, "complete": setTimeout(function () { game.after_stage(); }, 4000 ) });
}

GameClient.prototype.after_stage = function() {
  $('#match-answer').fadeOut({"duration": 2000, "complete": function () { game.after_stage_complete(); } });
}

GameClient.prototype.after_stage_complete = function() {
  this.query();
  this.update_history();

  if(typeof this.after_stage_callback == "function") {
    this.after_stage_callback.call();
  }

}

GameClient.prototype.stage_reset_complete = function(notice) {
  this.player.stop();

  this.progress = 0;
  this.progress_steps = [20, 40, 60, 80, 100];
  this.player.reset_volume();

  if(notice) {
    this.notice("stage_reset_complete");
  }
}

GameClient.prototype.resolve = function() {
  this.resolve_media();
}

GameClient.prototype.resolve_media = function() {
  this.show_media_img();
}

GameClient.prototype.show_media_img = function() {
  $('#record-player').fadeOut({ "duration": 1500, "complete": function() { $('#media-img').fadeIn(2000); } });
}

GameClient.prototype.print_hint = function(hint) {
  new_hint = '<span class="hint">' + hint + '</span> ';
  this.chat.append("Apollo: ~ " + new_hint);
}

GameClient.prototype.set_match_info = function(info) {
  var question = info[1];
  var answer = info[2];
  var resolver = info[3];
  var video_id = info[4];

  if (typeof question != "undefined") {
    this.match_info["last_q"] = this.match_info.question;
    this.match_info["question"] = question;
  }

  if (typeof answer != "undefined") {
    this.match_info["answer"] = answer;
  }

  if (typeof resolver != "undefined") {
    this.match_info["resolver"] = resolver;
  }

  if (typeof video_id != "undefined") {
    this.match_info["video_id"] = video_id;
  }
  return;
}

GameClient.prototype.query = function() {
  if (this.match_info.question) {
    $('#match-question').html(this.match_info.question);
  }
}

GameClient.prototype.notice = function(event) {
  switch(event) {
    case "video_ready":
      this.video_ready = true;
      break;
    case "stage_reset_complete":
      this.stage_reset = true;
      break;
    default:
      break;
  }

  if(this.video_ready && this.stage_reset) {
    this.ready();
    this.video_ready = false;
    this.stage_reset = false;
    return;
  }

  if(this.video_ready && !this.started) {
    this.ready();
    this.video_ready = false;
    return;
  }
}


GameClient.prototype.handle_event = function(event_msg) {
  var event = event_msg.text.match(/([^\s]+)/)[0];
  var msg = event_msg.text;

  if(event_msg.from == this.chat.room_op()) {

    switch(true) {
      case /next/.test(event):

        if(event.match(/next_stage/)) {
          var delay = msg.match(/[0-9]+/);
          if(delay) {
            delay = parseInt(delay);
          }
          this.next_stage(delay);
        } else {
          this.next();
        }
        break;

      case /hint/.test(event):
        var hint = msg.split(":");
        this.print_hint(hint[1]);
        break;

      case /play/.test(event):
        if(this.joining) {
          return;
        }
        this.play();
        break;

      case /last/.test(event):
        this.last();
        break;

      case /resolve/.test(event):
        this.resolve();
        break;

      case /match/.test(event):
        var info = msg.split(":");
        this.set_match_info(info);
        break;

      case /finish/.test(event):
        this.finish();
        return;

      case /new_game/.test(event):
        var game_id = msg.split(" ")[1];
        this.load_new(game_id);
        break;
    }
  }
}

/* handlers */

/* start when both players are ready */
GameClient.prototype.on_player_ready = function() {
  this.run();
}

GameClient.prototype.on_video_cued = function() {
  this.notice("video_ready");
}

GameClient.prototype.on_video_play = function () {
  var image = $('#media-img')[0];
  image.src = this.current_record.img_url;
  $('#media-img').hide();

  if(this.last_record) return;

  this.get_next_record();
  this.player.load(this.next_theme);
}

/* Player class */

var Player = function(game) {
  this.current_player = null;
  this.players = {};
  this.ready = null;
  this.queque = [];
  this.last_load = "b";
  this.game = game;
  this.current_volume = 75;
}

Player.prototype.setup = function() {

  this.players["a"] = new YT.Player('player', {
                        height: '0',
                        width: '0',
                        events: {
                          'onReady': this.onPlayerReady,
                          'onStateChange': this.onStateChange
                        }
                      });

  this.players["b"] = new YT.Player('playerb', {
                        height: '0',
                        width: '0',
                        events: {
                          'onReady': this.onPlayerReady,
                          'onStateChange': this.onStateChange
                        }
                      });

}

Player.prototype.onPlayerReady = function(event) {
  if(this.ready) {
    this.game.on_player_ready();
  } else {
    this.ready = "a";
  }
}

Player.prototype.play = function() {
  var frameID = this.last_load;
  var p = this.players[frameID];

  this.current_player = p;
  setTimeout(function() { game.on_video_play(); }, 3000);

  this.current_player.playVideo();
}

Player.prototype.init_volume = function () {
  this.players["a"].setVolume(this.current_volume);
}

Player.prototype.stop = function() {
  if(this.current_player != null) {
    this.current_player.pauseVideo();
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
      this.game.on_video_cued();
      break;
  }
}

Player.prototype.lower_volume = function() {
  var vol = this.current_volume - 12;

  this.current_player.setVolume(vol)

  this.current_volume = vol;
}

Player.prototype.reset_volume = function() {
  this.current_volume = 75;
  this.current_player.setVolume(this.current_volume);
}

