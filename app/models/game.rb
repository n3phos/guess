class Game < ActiveRecord::Base

  has_many :gamerecords
  has_many :themes, through: :gamerecords

  


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

    themes.each do |t|
      record = {}
      media_name = t.media_name
      theme_name = t.theme_name
      theme_int = t.theme_interpret

      record[:media_name] = media_name unless media_name.empty?
      record[:theme_name] = theme_name unless theme_name.empty?
      record[:theme_int] = theme_int unless theme_int.empty?

      wordlist << record
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
    puts "in mark active"
    first = gamerecords.first
    first.update(:active => true)
    first.theme
  end


end
