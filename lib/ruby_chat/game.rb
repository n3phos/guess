#$: << '/Users/nephos/.rvm/gems/ruby-2.1.4@guess/gems/rest-client-1.7.2/lib'

#$: << '/Users/nephos/.rvm/gems/ruby-2.1.4@guess/gems/netrc-0.10.2/lib'

#require '.rvm/gems/ruby-2.1.4@guess/gems/rest-client-1.7.2/lib/rest-client'
 #/gems/ruby-2.1.4@guess/gems/rest-client-1.7.2/lib'

require 'rest-client'

class Game

  attr_accessor :cli, :ready, :looping_thread, :active, :started, :game_url, :resource, :current_record, :records, :stage, :rec, :solved

  def initialize(cli)

    puts "init game"

    self.cli = cli
    self.looping_thread = nil
    self.active = true
    self.started = false
    self.game_url = nil
    self.resource = nil
    self.stage = 0
    self.rec = 0
    self.records = []
    self.solved = false


    self.ready = Proc.new do

      puts "in ready callback"

      ret = looping?

      puts "thread loop bolean: #{ret}"

      if !ret

        loop

        if !started?
          self.start
        end

      end

    end

  end

  def build_records(wordlist)

    wordlist.each do |r|
      stages = []

      r.each do |k, v|
        stage = []

        stage << k
        stage << v

        stages << stage
      end

      self.records << stages

    end

    puts self.records.inspect

  end

  def current_record
    self.records[rec]
  end

  def current_record_stage
    current_record[stage][1]
  end

  def more_stages?
    stage < current_record.length - 1
  end

  def more_records?
    rec < self.records.length - 1
  end


  def started?
    self.started
  end

  def guess_theme(guess)

    s = current_record_stage

    puts "current stage: #{s}"

    if(guess.eql?(s))
      on_record_match("mcfake")
    end

  end

  def start
    self.started = true

    update_game({ :started => true })

    cli.message("#tg-room#1", "!next")
  end

  def on_video_ready(source, data)

    puts "received video_ready"

    set_user_ready(source)

    ready_check

  end

  def on_guess(source, data)
    guess_theme(data)
  end

  def active?
    self.active
  end

  def setup(game_opts)

    self.game_url = game_opts['game_url']
    self.resource = RestClient::Resource.new(game_url)

    self.build_records(game_opts['wordlist'])


  end

  def loop(delay = 50)
    self.looping_thread = Thread.new do

      puts "in looping thread"

      sleep(delay)

      solve

      next_record if more_records?

    end
  end

  def looping?
    if self.looping_thread.nil?
      return false
    end

    self.looping_thread.alive?
  end

  def solve

  end

  def ready_check

    puts "in ready_check"
    all_ready = false

    all_ready = users.all? do |k, v|
      ready?(v)
    end


    puts "all_ready: #{all_ready}"

    if all_ready

      self.ready.call

      reset_users
    end

  end

  def ready?(u)
    u['ready']
  end

  def reset_users
    users.each do |k,v|
      reset_user(v)
    end
  end

  def reset_user(u)
    u['ready'] = false
  end

  def set_user_ready(u)
    users[u.to_sym]['ready'] = true
  end

  def users
    cli.channel_users
  end

  def last_record?
    rec == self.records.length - 1
  end

  def next_record(stop_loop = false)

    puts "in next"

    if(stop_loop)
      self.looping_thread.terminate
    end

    puts "current rec: #{self.rec}"

    update_game({ :current_record => true })

    self.rec += 1
    self.stage = 0

    cli.message("#tg-room#1", "!last") if last_record?

    cli.message("#tg-room#1", "!next") unless stop_loop

  end

  def next_stage

    puts "in next_stage"
    self.stage += 1

    cli.message("#tg-room#1", "!next_stage")

  end


  def on_record_match(user)

    puts "guess matches current record"

    if more_stages?
      next_stage
      return
    else
      resolve
    end

  end

  def resolve

    event = "!next_stage"

    if more_records?
      event << " 3000"
      next_record(true)
    else
      update_game({ :started => false })
    end

    cli.message("#tg-room#1", event)
  end

  def update_game(data)

    self.resource.patch(data)
  end

  def dispatch_event(event)

    puts "in dispatch_event"

    trigger = event['trigger']
    source = event['source']
    data = event['data']

    handler = "on_#{trigger}"

    if self.respond_to?(handler)
      self.send(handler, source, data)
    end

  end


end



