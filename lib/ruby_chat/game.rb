#$: << '/Users/nephos/.rvm/gems/ruby-2.1.4@guess/gems/rest-client-1.7.2/lib'

#$: << '/Users/nephos/.rvm/gems/ruby-2.1.4@guess/gems/netrc-0.10.2/lib'

#require '.rvm/gems/ruby-2.1.4@guess/gems/rest-client-1.7.2/lib/rest-client'
 #/gems/ruby-2.1.4@guess/gems/rest-client-1.7.2/lib'

require 'rest-client'

class Game

  attr_accessor :cli, :ready, :looping_thread, :active, :started, :game_url, :resource, :current_record, :records, :entry_index, :rec_index, :solved
  attr_accessor :channel_users
  attr_accessor :blocked

  def initialize(cli)

    puts "init game"

    self.cli = cli
    self.looping_thread = nil
    self.active = true
    self.started = false
    self.game_url = nil
    self.resource = nil
    self.entry_index = 0
    self.rec_index = 0
    self.records = []
    self.solved = false
    self.channel_users = {}
    self.blocked = false


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


      send_cmd("!play")

    end

  end

  def send_cmd(cmd)
    cli.message(cli.channel, cmd)
  end

  def current_record
    self.records[rec_index]
  end

  def current_record_entries
    current_record["entries"]
  end

  def next_record_question
    self.records[rec_index+1]["entries"][0]["q"]
  end

  def current_question
    current_entry["q"]
  end

  def current_answer
    current_entry["a"]
  end

  def current_entry
    current_record_entries[entry_index]
  end

  def more_entries?
    entry_index < current_record_entries.length - 1
  end

  def more_records?
    rec_index < self.records.length - 1
  end


  def started?
    self.started
  end

  def blocked?
    self.blocked
  end

  def lock_guess
    puts "loking guess"
    self.blocked = true
  end

  def unlock_guess
    puts "unlocking guess"
    self.blocked = false
  end

  def guess_theme(guess, user)
    blocked = blocked?
    puts "blocked res: #{blocked}"
    if(!blocked)
      a = current_answer

      puts "guess: #{guess} answer: #{a}"

      if(guess.eql?(a))
        on_record_match(user)
      end
    else
      puts "guess was blocked"
    end
  end

  def start
    self.started = true
    update_game({ :started => true })
    match_info("", false, entry_index)
  end

  def match_info(user = "", nrq = false, entry = entry_index + 1, last = false)
    cr = current_record
    entries = cr["entries"]

    if !nrq
      question = entries[entry]["q"]
    else
      question = next_record_question
    end

    answer = entries[entry_index]["a"]

    cmd = "!match :#{question}"

    if !user.empty?
      cmd << ":#{answer}"
      cmd << ":#{user}"
      if nrq || last
        cmd << ":#{cr["video_id"]}"
      end
    end

    send_cmd(cmd)

  end

  def on_ready(source, data)

    puts "received video_ready"

    set_user_ready(source)

    ready_check

  end

  def on_guess(source, data)
    if started
      guess_theme(data, source)
    end
  end

  def active?
    self.active
  end

  def setup(game_opts)
    self.game_url = game_opts['game_url']
    self.resource = RestClient::Resource.new(game_url)

    self.records = game_opts['wordlist']

    puts self.records.inspect
  end

  def loop(delay = 70)
    self.looping_thread = Thread.new do

      puts "in looping thread"

      sleep(delay)

      lock_and_release_guess

      resolve("GameServer", false)

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
    rec_index == self.records.length - 1
  end

  def next_record(stop_loop = false)

    puts "in next"

    if(stop_loop)
      self.looping_thread.terminate
    end

    update_game({ :current_record => true })

    self.rec_index += 1
    self.entry_index = 0

    send_cmd("!last") if last_record?

    #send_cmd("!next") unless stop_loop

  end

  def next_stage(user)

    puts "in next_stage"

    match_info(user, false)

    self.entry_index += 1

    send_cmd("!next_stage")

  end


  def on_record_match(user)

    puts "guess matches current record"


    if more_entries?
      next_stage(user)
    else
      resolve(user)
    end

    lock_and_release_guess
  end

  def lock_and_release_guess
    if !blocked?
      Thread.new do 
        lock_guess

        sleep(5)

        unlock_guess
      end
    end
  end

  def resolve(user, stop_loop = true)

    event = "!next_stage"


    if more_records?
      match_info(user, true)
      event << " 3000"
      next_record(stop_loop)
    else
      last = true
      match_info(user, false, entry_index, last)
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
    self.rec_index = 0
    self.entry_index = 0
    self.started = false
    self.resource = nil
    self.started = false
    self.looping_thread.terminate
    self.looping_thread = nil
  end

  def finish
    send_cmd("!finish")
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



