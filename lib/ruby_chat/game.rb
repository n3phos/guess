#$: << '/Users/nephos/.rvm/gems/ruby-2.1.4@guess/gems/rest-client-1.7.2/lib'

#$: << '/Users/nephos/.rvm/gems/ruby-2.1.4@guess/gems/netrc-0.10.2/lib'

#require '.rvm/gems/ruby-2.1.4@guess/gems/rest-client-1.7.2/lib/rest-client'
 #/gems/ruby-2.1.4@guess/gems/rest-client-1.7.2/lib'

require 'rest-client'

class Game

  attr_accessor :cli, :ready, :looping_thread, :active, :started, :game_url, :resource, :current_record, :records, :stage, :rec, :solved
  attr_accessor :channel_users

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
    self.channel_users = {}


    self.ready = Proc.new do

      puts "in ready callback"

      send_cmd("!play")

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

  def send_cmd(cmd)
    cli.message(cli.channel, cmd)
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

  def current_record_stage_name
    current_record[stage][0]
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
    match_info
  end

  def match_info(user = "")
    cr = current_record
    stage_name = cr[stage][0]
    stage_val = cr[stage][1]

    cmd = "!match #{stage_name.to_s}"

    if !user.empty?
      cmd << " #{stage_val}"
      cmd << " #{user}"
    end

    send_cmd(cmd)

  end

  def on_ready(source, data)

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
    self.channel_users
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

    send_cmd("!last") if last_record?

    send_cmd("!next") unless stop_loop

  end

  def next_stage

    puts "in next_stage"
    self.stage += 1

    send_cmd("!next_stage")

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
      self.reset
      finish
    end

    send_cmd(event)
  end

  def update_game(data)

    self.resource.patch(data)
  end

  def reset
    self.game_url = nil
    self.records = []
    self.rec = 0
    self.stage = 0
    self.started = false
    self.resource = nil
    self.started = false
    self.looping_thread.terminate
    self.looping_thread = nil
  end

  def finish

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


  def update_users(usr, remove = false)

    puts "in update users"

    return unless usr.match(/tgu/)


    if !remove
      add_user(usr)
    else
      remove_user(usr)
    end

    puts "#{self.channel_users.inspect}"

  end

  def add_user(u)
    self.channel_users.merge!({ u.to_sym => { 'ready' => false } })
  end

  def remove_user(u)
    puts "in delete user"
    self.channel_users.delete(u.to_sym)
    if self.channel_users.empty? && !self.resource.nil?
      update_game({ :started => false })
      self.reset
    end
  end

  def parse_users(usr)


    cusers = usr.split(" ")

    cusers = cusers.select do |u|
      u.match(/tgu/)
    end

    cusers

  end
end



