class Game < ActiveRecord::Base

  has_many :gamerecords
  has_many :themes, through: :gamerecords

  
  def self.joining_theme
    Theme.find_by(theme_name: "tristram_join")
  end

  def self.dummy_theme
    Theme.find_by(theme_name: "dummy_theme")
  end

  def next_record_theme
    next_record(current.id).theme
  end


  def update_current

    c = current

    c.update(:active => false)

    nextr = next_record(c.id)

    if(nextr)
      nextr.update(:active => true)
    end

  end

  def generate_wordlist
    wordlist = []

    gamerecords.order("id ASC").each do |r|
      wordlist << r.theme.generate_record
    end

    wordlist
  end

  def current
    gamerecords.find_by(active: true)
  end

  def next_record(id)
    gamerecords.where("id > ?", id).first
  end

  def update_history(history)

  end

  def mark_active
    first = gamerecords.order("id ASC").first
    first.update(:active => true)

    puts "mark_active first record: #{first.inspect}"

    first.theme
  end


end
