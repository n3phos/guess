
class GameAnswer

  attr_accessor :mask_char, :revealed, :store, :index_pool
  attr_accessor :sample_rate
  attr_accessor :steps

  def initialize(answer)
    #@mask_char = "\u{204E}"
    @mask_char = "*"
    @revealed = []
    @store = answer.scan(/./)
    @steps = 3

    @index_pool = (0..@store.length - 1).to_a

    @store.each_with_index do |c, i|
      @revealed << i if c.match(" ")
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

    unrevealed = @index_pool.select do |i|
      !@revealed.include?(i)
    end

    @revealed += unrevealed.sample(@sample_rate)

    answer = @store.each_with_index.map do |c, i|
      if(!@revealed.include?(i))
        c = @mask_char
      end
      c
    end

    @steps -= 1

    answer.join
  end
end
