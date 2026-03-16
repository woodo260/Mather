module Questions
  class BaseQuestion
    attr_reader :prompt, :answer, :hint, :explanation

    def self.key   = raise NotImplementedError
    def self.label = raise NotImplementedError
    def self.description = raise NotImplementedError

    def initialize(difficulty: 0)
      @difficulty = difficulty.to_i.clamp(0, 3)
      generate!
    end

    private

    def generate! = raise NotImplementedError

    def decimal_places
      @difficulty
    end

    def round_to(value)
      value.round(decimal_places).to_f
    end

    def format_number(value)
      if decimal_places == 0
        value.to_i.to_s
      else
        format("%.#{decimal_places}f", value)
      end
    end

    def rand_int(min, max)
      rand(min..max)
    end

    # Returns a float with the configured decimal precision
    def rand_float(min, max)
      return rand_int(min.to_i, max.to_i).to_f if decimal_places == 0
      (rand * (max - min) + min).round(decimal_places)
    end

    # Choose a "nice" number appropriate to difficulty
    def rand_amount(min:, max:)
      if decimal_places == 0
        rand_int(min.ceil, max.floor)
      elsif decimal_places == 1
        (rand(min.ceil * 10..max.floor * 10) / 10.0)
      else
        (rand * (max - min) + min).round(decimal_places)
      end
    end
  end
end
