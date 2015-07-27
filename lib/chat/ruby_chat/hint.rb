
class Hint

  attr_accessor :mask_char, :revealed, :store, :index_pool
  attr_accessor :sample_rate
  attr_accessor :steps
  attr_accessor :unrevealed

  def initialize(answer)
    @mask_char = "*"
    @store = answer.scan(/./)
    @steps = 4
    @unrevealed = []

    @store.each_with_index do |c, i|
      @unrevealed << i unless c.match(" ")
    end

    if(@store.length > 20)
      @sample_rate = 3
    elsif(@store.length > 10)
      @sample_rate = 2
    else
      @sample_rate = 1
    end
  end

  def show
    if(steps == 0)
      answer = ""
      return answer
    end

    # remove x character indexes from the unrevealed array
    @unrevealed -= @unrevealed.sample(sample_rate)

    answer = store.each_with_index.map do |c, i|
      @unrevealed.include?(i) ? mask_char : c
    end

    @steps -= 1
    answer.join
  end
end
