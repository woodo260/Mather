module Questions
  class BaseQuestion
    attr_reader :prompt, :answer, :hint, :explanation, :steps

    def self.key   = raise NotImplementedError
    def self.label = raise NotImplementedError
    def self.description = raise NotImplementedError

    def initialize(difficulty: 0)
      @difficulty = difficulty.to_i.clamp(0, 3)
      @steps = []
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

    # Append one line to the mental-math walkthrough.
    def step(text)
      @steps << text
    end

    # Number formatting for step text. Intentionally NOT format_number:
    # format_number truncates decimals at difficulty 0, which would render
    # intermediates like "10% of 137 = 13.7" as "13". Shows up to 2 decimals,
    # trims trailing zeros.
    def fmt_step(value)
      v = value.to_f.round(2)
      whole?(v) ? v.to_i.to_s : v.to_s
    end

    def whole?(value)
      value.to_f == value.to_f.to_i
    end

    # Mental-math steps for x × y. Place-value partial products when both are
    # whole numbers and the larger factor is > 12; otherwise one compute line.
    def multiplication_steps(x, y)
      if whole?(x) && whole?(y)
        big, small = [ x.to_i, y.to_i ].minmax.reverse
        if big > 12 && small > 1
          tens = (big / 10) * 10
          ones = big % 10
          if ones.zero?
            step "#{big} × #{small}: do #{big / 10} × #{small} = #{(big / 10) * small}, add a zero → #{big * small}"
          else
            step "Break #{big} into #{tens} + #{ones}"
            step "#{tens} × #{small} = #{tens * small}"
            step "#{ones} × #{small} = #{ones * small}"
            step "#{tens * small} + #{ones * small} = #{big * small}"
          end
          return
        end
      end
      step "#{fmt_step(x)} × #{fmt_step(y)} = #{fmt_step(x.to_f * y)}"
    end

    # Steps for dividend ÷ divisor = quotient, framed as reverse multiplication.
    def division_steps(dividend, divisor, quotient)
      step "Ask: #{fmt_step(divisor)} × ? = #{fmt_step(dividend)}"
      step "#{fmt_step(divisor)} × #{fmt_step(quotient)} = #{fmt_step(dividend)}, so it's #{fmt_step(quotient)}"
    end

    # 10%-anchor steps for "pct% of whole". prefix is "$" or "".
    def percent_of_steps(pct, whole, prefix: "")
      f      = ->(v) { "#{prefix}#{fmt_step(v)}" }
      ten    = whole / 10.0
      one    = whole / 100.0
      amount = whole * pct / 100.0
      p_txt  = fmt_step(pct)

      case pct
      when 10
        step "10% of #{f.(whole)}: shift the decimal left → #{f.(ten)}"
      when 5
        step "10% of #{f.(whole)} = #{f.(ten)}"
        step "5% = half of 10%: #{f.(ten)} ÷ 2 = #{f.(amount)}"
      when 15
        step "10% of #{f.(whole)} = #{f.(ten)}"
        step "Half of that (5%) = #{f.(ten / 2)}"
        step "15% = #{f.(ten)} + #{f.(ten / 2)} = #{f.(amount)}"
      when 20
        step "10% of #{f.(whole)} = #{f.(ten)}"
        step "20% = double it: #{f.(ten)} × 2 = #{f.(amount)}"
      when 25
        step "25% = a quarter: #{f.(whole)} ÷ 4 = #{f.(amount)}"
      when 50
        step "50% = half: #{f.(whole)} ÷ 2 = #{f.(amount)}"
      when 75
        step "25% = #{f.(whole)} ÷ 4 = #{f.(whole / 4.0)}"
        step "75% = three quarters: 3 × #{f.(whole / 4.0)} = #{f.(amount)}"
      else
        if pct < 10
          step "1% of #{f.(whole)} = #{f.(one)} (shift decimal twice)"
          step "#{p_txt}% = #{p_txt} × 1%: #{p_txt} × #{f.(one)} = #{f.(amount)}"
        elsif (pct % 10).zero?
          step "10% of #{f.(whole)} = #{f.(ten)}"
          step "#{p_txt}% = #{(pct / 10).to_i} × 10%: #{(pct / 10).to_i} × #{f.(ten)} = #{f.(amount)}"
        else
          tens = (pct.to_i / 10) * 10
          rem  = pct - tens
          step "10% of #{f.(whole)} = #{f.(ten)}"
          step "#{tens}% = #{tens / 10} × #{f.(ten)} = #{f.(whole * tens / 100.0)}" if tens > 10
          step "#{fmt_step(rem)}% more = #{fmt_step(rem)} × #{f.(one)} (1%) = #{f.(whole * rem / 100.0)}"
          step "Add: #{f.(whole * tens / 100.0)} + #{f.(whole * rem / 100.0)} = #{f.(amount)}"
        end
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
