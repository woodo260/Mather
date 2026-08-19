module Questions
  class SimpleInterestQuestion < BaseQuestion
    EASY_RATES  = [ 5, 10 ].freeze
    HARD_RATES  = [ 3, 4, 6, 7, 8, 12, 15 ].freeze

    def self.key         = "simple_interest"
    def self.label       = "Simple Interest"
    def self.description = "Calculate interest earned or owed using I = P × r × t. Great for understanding savings accounts and loans."

    private

    def generate!
      rates    = @difficulty <= 1 ? EASY_RATES : EASY_RATES + HARD_RATES
      rate_pct = rates.sample
      rate     = rate_pct / 100.0

      principal = rand_amount(min: 100, max: 5000)
      years     = rand_int(1, [ 2, 3, 5, 10 ][@difficulty])

      interest = round_to(principal * rate * years)
      total    = round_to(principal + interest)

      ask_total = @difficulty >= 2 && [ true, false ].sample

      if ask_total
        @prompt      = "You invest $#{format_number(principal)} at #{rate_pct}% simple interest per year for #{years} #{years == 1 ? 'year' : 'years'}. What is the total amount?"
        @answer      = total
        @hint        = "Interest = Principal × Rate × Time; Total = Principal + Interest"
        @explanation = "I = $#{format_number(principal)} × #{rate} × #{years} = $#{format_number(interest)}; Total = $#{format_number(total)}"
      else
        @prompt      = "You invest $#{format_number(principal)} at #{rate_pct}% simple interest per year for #{years} #{years == 1 ? 'year' : 'years'}. How much interest do you earn?"
        @answer      = interest
        @hint        = "Interest = Principal × Rate × Time = $#{format_number(principal)} × #{rate} × #{years}"
        @explanation = "$#{format_number(principal)} × #{rate} × #{years} = $#{format_number(interest)}"
      end

      step "First find ONE year's interest: #{rate_pct}% of $#{fmt_step(principal)}"
      percent_of_steps(rate_pct, principal, prefix: "$")
      step "× #{years} years: $#{fmt_step(principal * rate)} × #{years} = $#{fmt_step(interest)}" if years > 1
      if ask_total
        step "Total = principal + interest: $#{fmt_step(principal)} + $#{fmt_step(interest)} = $#{format_number(total)}"
      else
        step "Interest = $#{format_number(interest)}"
      end
    end
  end
end
