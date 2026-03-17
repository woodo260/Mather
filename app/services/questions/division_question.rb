module Questions
  class DivisionQuestion < BaseQuestion
    def self.key         = "division"
    def self.label       = "Division"
    def self.description = "Division practice. At low difficulty answers are always whole numbers; harder levels introduce remainders."

    private

    def generate!
      if @difficulty == 0
        # Always produce whole-number quotients
        b      = rand_int(2, 12)
        result = rand_int(2, 12)
        a      = b * result

        @prompt      = "#{a} ÷ #{b} = ?"
        @answer      = result.to_f
        @hint        = "How many times does #{b} go into #{a}?"
        @explanation = "#{a} ÷ #{b} = #{result}"
      else
        # Potentially non-integer quotients
        max_dividend = [ 12, 50, 100, 200 ][@difficulty]
        b = rand_int(2, 12)
        a = rand_int(b, max_dividend)
        result = round_to(a.to_f / b)

        @prompt      = "#{a} ÷ #{b} = ?"
        @answer      = result
        @hint        = "#{b} goes into #{a} approximately #{(a / b.to_f).floor} times"
        @explanation = "#{a} ÷ #{b} = #{format_number(result)}"
      end
    end
  end
end
