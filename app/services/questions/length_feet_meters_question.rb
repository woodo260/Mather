module Questions
  class LengthFeetMetersQuestion < UnitPairConversionQuestion
    conversion from: "feet", to: "meters", factor: 0.3048, input_max: 50

    def self.key         = "length_feet_meters"
    def self.label       = "Feet ↔ Meters"
    def self.description = "Convert between feet and meters."
  end
end
