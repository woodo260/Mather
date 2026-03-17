module Questions
  class SalesTaxQuestion < BaseQuestion
    EASY_RATES  = [ 5, 10, 15, 20 ].freeze
    HARD_RATES  = [ 6, 7, 8, 8.5, 9, 9.5 ].freeze

    def self.key         = "sales_tax"
    def self.label       = "Sales Tax"
    def self.description = "Calculate sales tax and final prices. Harder difficulties use realistic tax rates and reverse questions."

    private

    def generate!
      rate = if @difficulty <= 1
               EASY_RATES.sample
      else
               (EASY_RATES + HARD_RATES).sample
      end

      price = rand_amount(min: 5, max: 200)

      # At difficulty 3, sometimes ask for the pre-tax price given total
      if @difficulty == 3 && [ true, false ].sample
        total  = round_to(price * (1 + rate / 100.0))
        @prompt      = "An item costs $#{format_number(total)} after #{rate}% tax. What was the original price?"
        @answer      = round_to(price)
        @hint        = "Divide the total by (1 + #{rate}/100) = #{(1 + rate / 100.0).round(4)}"
        @explanation = "$#{format_number(total)} ÷ #{(1 + rate / 100.0).round(4)} = $#{format_number(price)}"
      else
        tax    = round_to(price * rate / 100.0)
        total  = round_to(price + tax)
        @prompt      = "Item costs $#{format_number(price)}, tax is #{format_number(rate)}%. What is the total?"
        @answer      = total
        @hint        = "Multiply $#{format_number(price)} by #{(1 + rate / 100.0).round(4)}"
        @explanation = "$#{format_number(price)} × #{(1 + rate / 100.0).round(4)} = $#{format_number(total)}"
      end
    end
  end
end
