module Questions
  class Registry
    TYPES = {
      "times_tables"        => "Questions::TimesTablesQuestion",
      "division"            => "Questions::DivisionQuestion",
      "length_miles_km"     => "Questions::LengthMilesKmQuestion",
      "length_feet_meters"  => "Questions::LengthFeetMetersQuestion",
      "length_inches_cm"    => "Questions::LengthInchesCmQuestion",
      "length_yards_meters" => "Questions::LengthYardsMetersQuestion",
      "weight_pounds_kg"    => "Questions::WeightPoundsKgQuestion",
      "weight_ounces_grams" => "Questions::WeightOuncesGramsQuestion",
      "weight_stones_kg"    => "Questions::WeightStonesKgQuestion",
      "sales_tax"           => "Questions::SalesTaxQuestion",
      "percentage"          => "Questions::PercentageQuestion",
      "temperature"         => "Questions::TemperatureQuestion",
      "tip_calculation"     => "Questions::TipQuestion",
      "speed_distance_time"  => "Questions::SpeedDistanceTimeQuestion",
      "simple_interest"      => "Questions::SimpleInterestQuestion",
      "ohms_law"             => "Questions::OhmsLawQuestion",
      "electrical_power"     => "Questions::ElectricalPowerQuestion",
      "newtons_second_law"   => "Questions::NewtonsSecondLawQuestion",
      "kinetic_energy"       => "Questions::KineticEnergyQuestion",
      "work_energy"          => "Questions::WorkEnergyQuestion"
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
