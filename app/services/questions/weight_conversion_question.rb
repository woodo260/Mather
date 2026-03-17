module Questions
  class WeightConversionQuestion < BaseQuestion
    CONVERSIONS = [
      { from: "pounds", to: "kg",     factor: 0.453592, reverse_factor: 1.0 / 0.453592 },
      { from: "ounces", to: "grams",  factor: 28.3495,  reverse_factor: 1.0 / 28.3495 },
      { from: "stones", to: "kg",     factor: 6.35029,  reverse_factor: 1.0 / 6.35029 },
      { from: "kg",     to: "pounds", factor: 2.20462,  reverse_factor: 1.0 / 2.20462 }
    ].freeze

    def self.key         = "weight_conversion"
    def self.label       = "Weight Conversion"
    def self.description = "Convert between imperial and metric weights (pounds/kg, ounces/grams, stones/kg)."

    private

    def generate!
      conv       = CONVERSIONS.sample
      input_max  = { "ounces" => 32, "stones" => 20 }.fetch(conv[:from], 50)
      input      = rand_amount(min: 1, max: input_max)
      result     = round_to(input * conv[:factor])

      @prompt      = "#{format_number(input)} #{conv[:from]} = ? #{conv[:to]}"
      @answer      = result
      @hint        = "Multiply by #{conv[:factor].round(4)}"
      @explanation = "#{format_number(input)} × #{conv[:factor].round(4)} = #{format_number(result)} #{conv[:to]}"
    end
  end
end
