module Questions
  class MultiplyShortcutsQuestion < BaseQuestion
    def self.key         = "multiply_shortcuts"
    def self.label       = "Multiplication Shortcuts"
    def self.description = "Round-number shortcuts: ×5 (×10÷2), ×25 (×100÷4), ×9 (×10−n), and doubling-and-halving."

    private

    def generate!
      case %i[times5 times25 times9 double_halve].sample
      when :times5       then times5
      when :times25      then times25
      when :times9       then times9
      when :double_halve then double_halve
      end
    end

    # ×5 = ×10 ÷ 2
    def times5
      n      = rand_int(2, [ 20, 50, 120, 400 ][@difficulty])
      result = n * 5
      standard_prompt(n, 5, result, "×5 is ×10 then halve")
      step "×5 = ×10 ÷ 2"
      step "#{n} × 10 = #{n * 10}"
      step "#{n * 10} ÷ 2 = #{result}"
      step "So #{n} × 5 = #{result}"
    end

    # ×25 = ×100 ÷ 4
    def times25
      n      = rand_int(2, [ 12, 24, 48, 99 ][@difficulty])
      result = n * 25
      standard_prompt(n, 25, result, "×25 is ×100 then divide by 4")
      step "×25 = ×100 ÷ 4"
      step "#{n} × 100 = #{n * 100}"
      step "#{n * 100} ÷ 4 = #{result}"
      step "So #{n} × 25 = #{result}"
    end

    # ×9 = ×10 − n
    def times9
      n      = rand_int(2, [ 12, 24, 48, 99 ][@difficulty])
      result = n * 9
      standard_prompt(n, 9, result, "×9 is ×10 minus the number itself")
      step "×9 = ×10 − 1 of them"
      step "#{n} × 10 = #{n * 10}"
      step "#{n * 10} − #{n} = #{result}"
      step "So #{n} × 9 = #{result}"
    end

    # Halve one factor and double the other to reach a round number.
    def double_halve
      even_max = [ 12, 20, 40, 80 ][@difficulty]
      a        = rand_int(2, even_max / 2) * 2                 # even factor
      b        = rand_int(1, [ 5, 7, 9, 11 ][@difficulty]) * 2 - 1 # odd number...
      b       *= 5                                             # ...times 5 → e.g. 5, 15, 25
      ha       = a / 2
      db       = b * 2                                         # multiple of 10
      result   = a * b

      standard_prompt(a, b, result, "Halve one factor and double the other")
      step "Halve one, double the other: #{a} × #{b} → #{ha} × #{db}"
      step "#{db} is round now, so #{ha} × #{db} = #{result}"
      step "So #{a} × #{b} = #{result}"
    end

    def standard_prompt(x, y, result, hint)
      @prompt      = "#{x} × #{y} = ?"
      @answer      = result.to_f
      @hint        = hint
      @explanation = "#{x} × #{y} = #{result}"
    end
  end
end
