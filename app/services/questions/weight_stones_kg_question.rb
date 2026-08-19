module Questions
  class WeightStonesKgQuestion < UnitPairConversionQuestion
    conversion from: "stones", to: "kg", factor: 6.35029, input_max: 20

    def self.key         = "weight_stones_kg"
    def self.label       = "Stones ↔ Kilograms"
    def self.description = "Convert between stones and kilograms."
  end
end
