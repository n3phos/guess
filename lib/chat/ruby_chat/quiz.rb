
require 'hint'

class Quiz

  attr_accessor :records, :rec_index, :question_index, :hint_str

  def initialize
    self.records = []
    self.rec_index = 0
    self.question_index = 0
  end

  def feed(recs)
    puts "in feed"
    recs.each do |r|
      nr = {
        'video_id' => r['video_id'],
        'questions' => r['entries']
      }
      self.records << nr
    end

    new_hint
  end

  def hint
    hint_str.show
  end

  def reset
    self.records = []
    self.rec_index = 0
    self.question_index = 0
  end

  def info(last_play)
    "q=#{question},lastplay=#{last_play},last=#{!more_records?}"
  end

  def match(user, nrq)
    if ! nrq
      q = next_question
    else
      q = next_record_question
    end

    match = ":#{q}"

    if ! user.empty?
      match << ":#{answer}:#{user}"
      if nrq || ! more_records?
        match << ":#{video_id}"
      end
    end

    match
  end

  def question(i = question_index)
    record_questions[i]['q']
  end

  def answer
    record_questions[question_index]['a']
  end

  def next_record
    self.rec_index += 1
    self.question_index = 0
    new_hint
  end

  def next_question
    question(question_index + 1)
  end

  def next_question_entry
    self.question_index += 1
    new_hint
  end

  def more_questions?
    question_index < record_questions.length - 1
  end

  def more_records?
    rec_index < self.records.length - 1
  end

  def last_record?
    rec_index == self.records.length - 1
  end

  protected

  def new_hint
    self.hint_str = Hint.new(answer)
  end

  def current_record
    self.records[rec_index]
  end

  def video_id
    current_record['video_id']
  end

  def record_questions
    current_record["questions"]
  end

  def next_record_question
    next_record_questions[0]["q"]
  end

  def next_record_questions
    self.records[rec_index+1]['questions']
  end

end
