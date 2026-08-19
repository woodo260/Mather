module Questions
  class TipQuestion < BaseQuestion
    EASY_RATES = [ 10, 15, 20 ].freeze
    ALL_RATES  = [ 10, 12, 15, 18, 20, 22, 25 ].freeze

    def self.key         = "tip_calculation"
    def self.label       = "Tip Calculation"
    def self.description = "Calculate tips and total restaurant bills. Great for real-world dining math."

    private

    def generate!
      rate  = (@difficulty <= 1 ? EASY_RATES : ALL_RATES).sample
      bill  = rand_amount(min: 10, max: 120)
      tip   = round_to(bill * rate / 100.0)
      total = round_to(bill + tip)

      # Difficulty 2-3: sometimes ask for the total instead of just the tip
      ask_total = @difficulty >= 2 && [ true, false ].sample

      if ask_total
        @prompt      = "Restaurant bill is $#{format_number(bill)}. What is the total with a #{rate}% tip?"
        @answer      = total
        @hint        = "Tip = $#{format_number(bill)} × #{rate}%, then add to bill"
        @explanation = "$#{format_number(bill)} + $#{format_number(tip)} tip = $#{format_number(total)}"
      else
        @prompt      = "Restaurant bill is $#{format_number(bill)}. How much is a #{rate}% tip?"
        @answer      = tip
        @hint        = "#{rate}% of $#{format_number(bill)}: multiply by #{rate / 100.0}"
        @explanation = "$#{format_number(bill)} × #{rate / 100.0} = $#{format_number(tip)}"
      end

      percent_of_steps(rate, bill, prefix: "$")
      if ask_total
        step "Add tip to bill: $#{fmt_step(bill)} + $#{fmt_step(tip)} = $#{format_number(total)}"
      else
        step "Tip = $#{format_number(tip)}"
      end
    end
  end
end
