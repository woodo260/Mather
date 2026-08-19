module Questions
  class LengthYardsMetersQuestion < UnitPairConversionQuestion
    conversion from: "yards", to: "meters", factor: 0.9144, input_max: 50

    def self.key         = "length_yards_meters"
    def self.label       = "Yards ↔ Meters"
    def self.description = "Convert between yards and meters."
  end
end
