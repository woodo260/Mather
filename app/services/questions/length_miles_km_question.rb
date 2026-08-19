module Questions
  class LengthMilesKmQuestion < UnitPairConversionQuestion
    conversion from: "miles", to: "km", factor: 1.60934, input_max: 100

    def self.key         = "length_miles_km"
    def self.label       = "Miles ↔ Kilometers"
    def self.description = "Convert between miles and kilometers."
  end
end
