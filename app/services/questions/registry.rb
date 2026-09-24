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
      "squaring"             => "Questions::SquaringQuestion",
      "times_eleven"         => "Questions::TimesElevenQuestion",
      "difference_of_squares" => "Questions::DifferenceOfSquaresQuestion",
      "multiply_shortcuts"   => "Questions::MultiplyShortcutsQuestion",
      "speed_distance_time"  => "Questions::SpeedDistanceTimeQuestion",
      "simple_interest"      => "Questions::SimpleInterestQuestion",
      "ohms_law"             => "Questions::OhmsLawQuestion",
      "electrical_power"     => "Questions::ElectricalPowerQuestion",
      "newtons_second_law"   => "Questions::NewtonsSecondLawQuestion",
      "kinetic_energy"       => "Questions::KineticEnergyQuestion",
      "work_energy"          => "Questions::WorkEnergyQuestion"
    }.freeze

    ALL_KEYS = TYPES.keys.freeze

    # Types enabled for a brand-new session (or after clearing all selections).
    DEFAULT_KEYS = %w[times_tables].freeze

    # Groups question types for display (e.g. collapsible sections in Settings).
    # Every key in TYPES must appear in exactly one category here.
    CATEGORIES = {
      "Everyday Math"          => %w[times_tables division sales_tax percentage tip_calculation simple_interest],
      "Mental Math Tricks"     => %w[squaring times_eleven difference_of_squares multiply_shortcuts],
      "Length Conversion"      => %w[length_miles_km length_feet_meters length_inches_cm length_yards_meters],
      "Weight Conversion"      => %w[weight_pounds_kg weight_ounces_grams weight_stones_kg],
      "Temperature Conversion" => %w[temperature],
      "Physics"                => %w[speed_distance_time newtons_second_law kinetic_energy work_energy],
      "Electrical"             => %w[ohms_law electrical_power]
    }.freeze

    def self.all_keys = ALL_KEYS

    def self.default_keys = DEFAULT_KEYS

    def self.categories = CATEGORIES

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
