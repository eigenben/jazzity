class Changes
  attr_reader :sections

  def initialize(data)
    @sections = data.map { |s| Changes::Section.new(s) }
  end

  def bars
    sections.map(&:expanded).inject([]) do |b, s|
      b += s.bars
      b
    end
  end

  def form
    sections.map(&:letter).join("-")
  end


  class Grouping
    attr_accessor :time
  end

  class Section < Grouping
    attr_accessor :letter
    attr_accessor :time
    attr_accessor :repeat
    attr_accessor :bars

    def initialize(data)
      data.symbolize_keys!

      @letter = data[:section]
      @time = data[:time]
      @repeat = data[:repeat]
      @bars = normalize_bars(data[:bars])
    end

    def normalize_bars(raw_bars)
      raw_bars.map do |raw_bar|
        raw_bar.is_a?(Array) && raw_bar.size == 1 ? raw_bar.first : raw_bar
      end
    end

    # Expands this section by processing repeats out into actual bars and converting "%" into the previous chord:
    def expanded
      @expanded ||= self.clone.tap do |copy|
        copy.repeat = nil
        copy.bars = bars * (repeat || 0 + 1)

        last_bar = nil
        copy.bars.each_with_index do |bar, i|
          copy.bars[i] = last_bar if bar == "%"
          copy.bars[i] = last_bar if bar == ["%"]
          last_bar = bar
        end
      end
    end
  end
end
