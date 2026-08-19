module Questions
  class LengthInchesCmQuestion < UnitPairConversionQuestion
    conversion from: "inches", to: "cm", factor: 2.54, input_max: 50

    def self.key         = "length_inches_cm"
    def self.label       = "Inches ↔ Centimeters"
    def self.description = "Convert between inches and centimeters."
  end
end
