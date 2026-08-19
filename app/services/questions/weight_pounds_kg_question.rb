module Questions
  class WeightPoundsKgQuestion < UnitPairConversionQuestion
    conversion from: "pounds", to: "kg", factor: 0.453592, input_max: 50

    def self.key         = "weight_pounds_kg"
    def self.label       = "Pounds ↔ Kilograms"
    def self.description = "Convert between pounds and kilograms."
  end
end
