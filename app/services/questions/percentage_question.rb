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

        percent_of_steps(pct, whole)
        step "So #{pct}% of #{fmt_step(whole)} = #{format_number(part)}"
      when 1
        @prompt      = "#{format_number(part)} is what percent of #{format_number(whole)}?"
        @answer      = round_to(pct.to_f)
        @hint        = "Divide #{format_number(part)} by #{format_number(whole)}, then multiply by 100"
        @explanation = "(#{format_number(part)} ÷ #{format_number(whole)}) × 100 = #{pct}%"

        ten = whole / 10.0
        step "Anchor: 10% of #{fmt_step(whole)} = #{fmt_step(ten)}"
        step "How many 10%-chunks make #{fmt_step(part)}? #{fmt_step(part)} ÷ #{fmt_step(ten)} = #{fmt_step(pct / 10.0)}"
        step "#{fmt_step(pct / 10.0)} chunks of 10% → #{pct}%"
      when 2
        @prompt      = "#{format_number(part)} is #{pct}% of what number?"
        @answer      = round_to(whole.to_f)
        @hint        = "Divide #{format_number(part)} by #{pct / 100.0}"
        @explanation = "#{format_number(part)} ÷ #{pct / 100.0} = #{format_number(whole)}"

        case pct
        when 50 then step "50% is half — double it: #{fmt_step(part)} × 2 = #{format_number(whole)}"
        when 25 then step "25% is a quarter — × 4: #{fmt_step(part)} × 4 = #{format_number(whole)}"
        when 10 then step "10% is a tenth — × 10: #{fmt_step(part)} × 10 = #{format_number(whole)}"
        when 20 then step "20% is a fifth — × 5: #{fmt_step(part)} × 5 = #{format_number(whole)}"
        else
          one = part / pct.to_f
          step "#{fmt_step(part)} is #{pct}%, so 1% = #{fmt_step(part)} ÷ #{pct} = #{fmt_step(one)}"
          step "Whole = 100 × 1%: #{fmt_step(one)} × 100 = #{format_number(whole)}"
        end
      end
    end
  end
end
