
require 'rest-client'
require 'time'
require 'users'
require 'quiz'

class Game

  attr_accessor :cli, :ready, :looping_thread, :active, :started, :game_url, :resource, :quiz
  attr_accessor :users, :events
  attr_accessor :delayed_start, :delay_duration
  attr_accessor :last_ready, :created_at, :last_play

  def initialize(cli)
    self.cli = cli
    self.looping_thread = nil
    self.active = true
    self.started = false
    self.game_url = nil
    self.resource = nil
    self.quiz = Quiz.new
    self.users = Users.new(self)

    self.delayed_start = false
    self.last_ready = nil
    self.delay_duration = 4
    self.created_at = nil
    self.last_play = nil

    self.events = {
      "skip" => { "blocked" => false },
      "guess" => { "blocked" => false },
      "ready" => { "blocked" => false }
    }

    # callback when all clients have loaded the youtube video and are
    # ready
    self.ready = Proc.new do

      # start the game loop if not looping already
      if ! looping?
        loop

        if ! started?
          self.start
        end
      end

      # instruct clients to play theme
      play
    end
  end

  def setup(game_opts)
    self.game_url = game_opts['game_url']
    # resource like http://themeguess.com/room/lobby/game/4
    self.resource = RestClient::Resource.new(game_url)

    # prepare the quiz
    quiz.feed(game_opts['wordlist'])

    if(game_opts['load_next'])
      self.delayed_start = true
      self.created_at = Time.parse(game_opts['created_at'])
    end

    # notify clients
    new_game(game_opts['game_id'])
  end


  def handle_message(source, target, message)
    begin
      e = parse_event(source, message)
      puts "dispatching event: #{e.inspect}"
      dispatch_event(e)
    rescue Exception => e
      puts e.message
      puts e.backtrace.inspect
    end
  end

  # if all users left during the game, finish it
  def no_users
    if ! self.resource.nil?
      update_game({ :started => false })
      self.reset(true)
    end
  end

  def info
    quiz.info(last_play.to_s)
  end

  def active?
    self.active
  end

  def block_event(e, duration)
    event = events[e]
    if ! event['blocked']
      Thread.new do
        event['blocked'] = true

        sleep(duration)

        event['blocked'] = false
      end
    end
  end

  def hint
    h = quiz.hint
    cmd = "!hint :#{h}"
    send_cmd(cmd) unless h.empty?
  end

  def send_cmd(cmd)
    cli.message(cli.channel, cmd)
  end

  def started?
    self.started
  end

  def blocked?(e)
    events[e]['blocked']
  end

  def guess_theme(guess, user)
    a = quiz.answer.downcase
    guess.downcase!

    if(guess.eql?(a))
      on_match(user)
    end
  end

  def start
    self.started = true
    update_game({ :started => true })
    first_question
  end

  def match_info(user = "", nrq = false)
    m = quiz.match(user, nrq)
    # send the match to clients
    match(m)
  end

  def on_ready(source, data)
    u = source.to_sym

    # user is ready
    users[u].ready
    self.last_ready = Time.now.utc

    # check if all clients have loaded the video
    ready_check
  end

  def on_guess(source, data)
    if started
      guess_theme(data, source)
    end
  end

  def on_skip(source, data)
    resolve("GameServer", true)
    block_event("skip", 6)
  end

  # loops for 68 seconds and resolves the current question if no one
  # wrote the right answer in chat. writes periodical hints
  def loop(delay = 12)
    self.looping_thread = Thread.new do
      puts "in looping thread"

      sleep(8)

      hint

      loops = 5

      while(loops != 0)
        sleep(delay)
        hint

        loops -= 1
      end

      block_event("guess", 5)
      resolve("GameServer", false)
    end
  end

  def looping?
    if self.looping_thread.nil?
      return false
    end

    self.looping_thread.alive?
  end

  def ready_check
    if users.are_ready?

      if(delayed_start)
        diff = last_ready - created_at

        if(diff > delay_duration)
          self.ready.call
        else
          sleep_duration = delay_duration - diff

          Thread.new do
            puts "sleeping : #{sleep_duration}"
            sleep(sleep_duration)
            self.ready.call
            self.delayed_start = false
          end
        end

      else
        self.ready.call
      end

      # reset each user
      users.reset
    end
  end


  # updates the game model to mark the next theme record as
  # active
  def next_record(stop_loop = false)
    if(stop_loop)
      self.looping_thread.terminate
    end

    update_game({ :current_record => true })
    quiz.next_record

    # notify clients if this is the last record
    last if quiz.last_record?
  end

  def next_question(user)
    match_info(user)
    quiz.next_question_entry
    # prepare clients for next question
    next_stage
  end

  def on_match(user)
    if quiz.more_questions?
      next_question(user)
    else
      resolve(user)
    end

    block_event("guess", 5)
  end

  def resolve(user, stop_loop = true)
    if quiz.more_records?
      match_info(user, true)
      # update the game and stop the loop
      next_record(stop_loop)

      next_stage(true)
    else
      match_info(user)
      update_game({ :started => false })

      # reset the game
      reset(stop_loop)

      finish
    end
  end

  # http patch request
  def update_game(data)
    self.resource.patch(data)
  end

  def reset(stop_loop)
    self.game_url = nil
    self.resource = nil
    self.started = false

    quiz.reset

    if(stop_loop)
      self.looping_thread.terminate unless self.looping_thread.nil?
    end

    self.looping_thread = nil
    self.delayed_start = false
    self.last_ready = nil
    self.created_at = nil
  end

  def parse_event(s, m)
    event = {
      'trigger' => "",
      'source' => "",
      'data' => ""
    }

    if m.match(/^!/)
        event['trigger'] = m.gsub(/^!/, "")
        event['source'] = s
    end

    if event['trigger'].empty?
      event['trigger'] = "guess"
      event['source'] = s
      event['data'] = m
    end

    return event
  end

  def new_game(id)
    send_cmd("!new_game #{id}")
  end

  def play
    send_cmd("!play")
    self.last_play = Time.now.utc
  end

  def last
    send_cmd("!last")
  end

  def finish
    send_cmd("!finish")
  end

  def match(m)
    send_cmd("!match #{m}")
  end

  def next_stage(with_delay = false)
    if with_delay
      send_cmd("!next_stage 3000")
    else
      send_cmd("!next_stage")
    end
  end

  def first_question
    send_cmd("!match :#{quiz.question}")
  end

  def dispatch_event(event)
    trigger = event['trigger']
    source = event['source']
    data = event['data']

    handler = "on_#{trigger}"

    if self.respond_to?(handler) && ! blocked?(trigger)
      self.send(handler, source, data)
    else
      puts "#{trigger} was blocked"
    end
  end

end

