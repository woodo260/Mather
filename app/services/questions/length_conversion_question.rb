module Questions
  class LengthConversionQuestion < BaseQuestion
    CONVERSIONS = [
      { from: "inches",  to: "cm",     factor: 2.54,    reverse_factor: 1.0 / 2.54 },
      { from: "feet",    to: "meters", factor: 0.3048,  reverse_factor: 1.0 / 0.3048 },
      { from: "miles",   to: "km",     factor: 1.60934, reverse_factor: 1.0 / 1.60934 },
      { from: "yards",   to: "meters", factor: 0.9144,  reverse_factor: 1.0 / 0.9144 }
    ].freeze

    def self.key         = "length_conversion"
    def self.label       = "Length Conversion"
    def self.description = "Convert between imperial and metric lengths (inches/cm, feet/meters, miles/km, yards/meters)."

    private

    def generate!
      conv    = CONVERSIONS.sample
      reverse = [ true, false ].sample

      if reverse
        from_unit  = conv[:to]
        to_unit    = conv[:from]
        factor     = conv[:reverse_factor]
        input_max  = from_unit == "km" ? 100 : 50
      else
        from_unit  = conv[:from]
        to_unit    = conv[:to]
        factor     = conv[:factor]
        input_max  = from_unit == "miles" ? 100 : 50
      end

      input  = rand_amount(min: 1, max: input_max)
      result = round_to(input * factor)

      @prompt      = "#{format_number(input)} #{from_unit} = ? #{to_unit}"
      @answer      = result
      @hint        = build_hint(from_unit, to_unit, factor)
      @explanation = "#{format_number(input)} × #{factor.round(4)} = #{format_number(result)} #{to_unit}"
    end

    def build_hint(from, to, factor)
      nice_factor = factor.round(4)
      "Multiply #{from} by #{nice_factor} to get #{to}"
    end
  end
end
