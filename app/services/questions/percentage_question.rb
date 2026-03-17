module Questions
  class PercentageQuestion < BaseQuestion
    def self.key         = "percentage"
    def self.label       = "Percentages"
    def self.description = "Three sub-types: find a percentage of a number, find what percentage one number is of another, or find the whole given a part and percent."

    private

    def generate!
      # Higher difficulty unlocks harder sub-types
      max_type = [ 0, 1, 2, 2 ][@difficulty]
      type     = rand(0..max_type)

      pct_options = @difficulty <= 1 ? [ 10, 20, 25, 50, 75 ] : [ 5, 12, 15, 18, 30, 35, 40, 60, 70 ]
      pct         = pct_options.sample
      whole       = rand_amount(min: 10, max: 500)
      part        = round_to(whole * pct / 100.0)

      case type
      when 0
        @prompt      = "What is #{pct}% of #{format_number(whole)}?"
        @answer      = part
        @hint        = "Move the decimal: #{pct}% = #{pct / 100.0}, then multiply"
        @explanation = "#{format_number(whole)} × #{pct / 100.0} = #{format_number(part)}"
      when 1
        @prompt      = "#{format_number(part)} is what percent of #{format_number(whole)}?"
        @answer      = round_to(pct.to_f)
        @hint        = "Divide #{format_number(part)} by #{format_number(whole)}, then multiply by 100"
        @explanation = "(#{format_number(part)} ÷ #{format_number(whole)}) × 100 = #{pct}%"
      when 2
        @prompt      = "#{format_number(part)} is #{pct}% of what number?"
        @answer      = round_to(whole.to_f)
        @hint        = "Divide #{format_number(part)} by #{pct / 100.0}"
        @explanation = "#{format_number(part)} ÷ #{pct / 100.0} = #{format_number(whole)}"
      end
    end
  end
end
