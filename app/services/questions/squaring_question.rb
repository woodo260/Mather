module Questions
  class SquaringQuestion < BaseQuestion
    def self.key         = "squaring"
    def self.label       = "Squaring"
    def self.description = "Square numbers fast: the 'ends in 5' shortcut, plus the round-number method n² = (n−d)(n+d) + d²."

    private

    def generate!
      # Two strategies: numbers ending in 5, and general "round-number" squaring.
      if @difficulty.zero? || rand < 0.5
        square_ending_in_five
      else
        square_near_round
      end
    end

    # 35² → 3×4 = 12, tack on 25 → 1225.
    def square_ending_in_five
      max_tens = [ 9, 14, 24, 40 ][@difficulty]
      n        = rand_int(1, max_tens)
      number   = n * 10 + 5
      front    = n * (n + 1)
      result   = number * number

      @prompt      = "#{number}² = ?"
      @answer      = result.to_f
      @hint        = "It ends in 5 — multiply the front part by the next number, then append 25"
      @explanation = "#{number}² = #{result}"

      step "#{number} ends in 5. Take the part before the 5: #{n}"
      step "Multiply it by the next integer: #{n} × #{n + 1} = #{front}"
      step "Tack 25 onto the end → #{front}25"
      step "So #{number}² = #{result}"
    end

    # 47² → go up and down to a round number: 44 × 50 + 3² = 2209.
    def square_near_round
      max    = [ 99, 99, 120, 200 ][@difficulty]
      number = rand_int(11, max)
      number += 1 while [ 0, 5 ].include?(number % 10) # keep the other branch's cases out
      t      = (number / 10.0).round * 10
      dist   = (number - t).abs
      low    = number - dist
      high   = number + dist
      result = number * number

      @prompt      = "#{number}² = ?"
      @answer      = result.to_f
      @hint        = "Go the same distance up and down to a round number, multiply, then add the square of that distance"
      @explanation = "#{number}² = #{low} × #{high} + #{dist}² = #{result}"

      step "Move #{dist} each way from #{number}: #{number} − #{dist} = #{low}, #{number} + #{dist} = #{high}"
      step "One side is round, so multiply easily: #{low} × #{high} = #{low * high}"
      step "Add the distance squared: #{dist}² = #{dist * dist}"
      step "#{low * high} + #{dist * dist} = #{result}"
      step "So #{number}² = #{result}"
    end
  end
end
