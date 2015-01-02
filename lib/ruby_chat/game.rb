
class Game

  attr_accessor :cli, :ready, :looping_thread, :active, :started

  def initialize(cli)

    puts "init game"

    self.cli = cli
    self.looping_thread = nil
    self.active = true
    self.started = false
    self.game_url = nil

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

  def started?
    self.started
  end

  def start
    self.started = true
    next_record
  end

  def on_video_ready(source)

    puts "received video_ready"

    set_user_ready(source)

    ready_check

  end

  def active?
    self.active
  end

  def loop(delay = 30)
    self.looping_thread = Thread.new do

      puts "in looping thread"

      sleep(delay)

      solve

      next_record

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

  def next_record(stop_loop = false)

    puts "in next"

    if(stop_loop)
      self.looping_thread.terminate
    end

    cli.message("#tg-room#1", "!next")

  end

  def next_stage

  end

  def on_record_match(user)

    update_game
  end

  def update_game

  end

  def dispatch_event(event, source)
    handler = "on_#{event}"

    if self.respond_to?(handler)
      self.send(handler, source)
    end

  end


end
