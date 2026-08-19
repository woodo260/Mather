module Questions
  class WeightOuncesGramsQuestion < UnitPairConversionQuestion
    conversion from: "ounces", to: "grams", factor: 28.3495, input_max: 32

    def self.key         = "weight_ounces_grams"
    def self.label       = "Ounces ↔ Grams"
    def self.description = "Convert between ounces and grams."
  end
end
