module Questions
  class TimesTablesQuestion < BaseQuestion
    def self.key         = "times_tables"
    def self.label       = "Times Tables"
    def self.description = "Multiplication practice. Higher difficulty expands the range of numbers."

    private

    def generate!
      max = case @difficulty
      when 0 then 12
      when 1 then 20
      when 2 then 30
      else        50
      end

      a = rand_int(2, max)
      b = rand_int(2, max)
      result = a * b

      @prompt      = "#{a} × #{b} = ?"
      @answer      = result.to_f
      @hint        = "Think of #{a} groups of #{b}"
      @explanation = "#{a} × #{b} = #{result}"

      if a <= 12 && b <= 12
        big, small = [ a, b ].minmax.reverse
        step "Times-table fact: #{a} × #{b} = #{result}"
        step "Check: #{small} × #{big - 1} = #{small * (big - 1)}, add one more #{small} → #{result}"
      else
        multiplication_steps(a, b)
        step "So #{a} × #{b} = #{result}"
      end
    end
  end
end
