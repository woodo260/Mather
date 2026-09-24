module Questions
  class DifferenceOfSquaresQuestion < BaseQuestion
    def self.key         = "difference_of_squares"
    def self.label       = "Difference of Squares"
    def self.description = "Multiply two numbers straddling a round midpoint: 48 × 52 = 50² − 2²."

    private

    # a × b where a and b sit the same distance d either side of a round
    # midpoint m, so a × b = m² − d².
    def generate!
      max_mid = [ 50, 90, 150, 300 ][@difficulty]
      max_off = [ 4, 5, 8, 12 ][@difficulty]

      m    = rand_int(2, max_mid / 10) * 10
      d    = rand_int(1, [ max_off, m - 1 ].min)
      low  = m - d
      high = m + d
      a, b = [ low, high ].shuffle
      result = m * m - d * d

      @prompt      = "#{a} × #{b} = ?"
      @answer      = result.to_f
      @hint        = "They're the same distance from a round number — use m² − d²"
      @explanation = "#{a} × #{b} = #{m}² − #{d}² = #{result}"

      step "#{low} and #{high} are both #{d} away from #{m}"
      step "Use (m − d)(m + d) = m² − d²"
      step "#{m}² = #{m * m}"
      step "#{d}² = #{d * d}"
      step "#{m * m} − #{d * d} = #{result}"
      step "So #{a} × #{b} = #{result}"
    end
  end
end
