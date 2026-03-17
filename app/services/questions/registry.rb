module Questions
  class Registry
    TYPES = {
      "times_tables"        => "Questions::TimesTablesQuestion",
      "division"            => "Questions::DivisionQuestion",
      "length_conversion"   => "Questions::LengthConversionQuestion",
      "weight_conversion"   => "Questions::WeightConversionQuestion",
      "sales_tax"           => "Questions::SalesTaxQuestion",
      "percentage"          => "Questions::PercentageQuestion",
      "temperature"         => "Questions::TemperatureQuestion",
      "tip_calculation"     => "Questions::TipQuestion",
      "speed_distance_time" => "Questions::SpeedDistanceTimeQuestion",
      "simple_interest"     => "Questions::SimpleInterestQuestion"
    }.freeze

    ALL_KEYS = TYPES.keys.freeze

    def self.all_keys = ALL_KEYS

    def self.[](key)
      class_name = TYPES[key]
      class_name ? class_name.constantize : nil
    end

    def self.fetch(key)
      class_name = TYPES.fetch(key)
      class_name.constantize
    end

    def self.key?(key)
      TYPES.key?(key)
    end

    def self.each(&block)
      TYPES.each_key do |key|
        block.call(key, self[key])
      end
    end
  end
end
