module Questions
  class UnitPairConversionQuestion < BaseQuestion
    class << self
      attr_reader :from_unit, :to_unit, :conversion_factor, :max_input

      def conversion(from:, to:, factor:, input_max:)
        @from_unit         = from
        @to_unit           = to
        @conversion_factor = factor
        @max_input         = input_max
      end
    end

    # Mental-math approximation strategy per direction, keyed [from, to].
    # Lambdas are instance_exec'd so they can call step/fmt_step. The exact
    # closing step (with before/after rounding) is appended in generate!.
    STRATEGIES = {
      %w[miles km] => ->(x) {
        step "km ≈ miles + 60%: half of #{fmt_step(x)} is #{fmt_step(x * 0.5)}, a tenth is #{fmt_step(x * 0.1)}"
        step "#{fmt_step(x)} + #{fmt_step(x * 0.5)} + #{fmt_step(x * 0.1)} = #{fmt_step(x * 1.6)}"
      },
      %w[km miles] => ->(x) {
        step "miles ≈ km × 5/8"
        step "#{fmt_step(x)} ÷ 8 = #{fmt_step(x / 8.0)}, × 5 = #{fmt_step(x * 5 / 8.0)}"
      },
      %w[feet meters] => ->(x) {
        step "meters ≈ feet × 0.3, plus a shade"
        step "#{fmt_step(x)} × 3 = #{fmt_step(x * 3)}, shift decimal → #{fmt_step(x * 0.3)}"
      },
      %w[meters feet] => ->(x) {
        step "feet ≈ meters × 3.3: triple it, add a tenth of that"
        step "#{fmt_step(x)} × 3 = #{fmt_step(x * 3)}, + #{fmt_step(x * 0.3)} ≈ #{fmt_step(x * 3.3)}"
      },
      %w[inches cm] => ->(x) {
        step "cm = inches × 2.54: double it, then add half of the original"
        step "#{fmt_step(x)} × 2 = #{fmt_step(x * 2)}, + #{fmt_step(x * 0.5)} = #{fmt_step(x * 2.5)}"
      },
      %w[cm inches] => ->(x) {
        step "inches ≈ cm × 0.4, then shave a little (÷ 2.54)"
        step "#{fmt_step(x)} × 4 = #{fmt_step(x * 4)}, shift decimal → #{fmt_step(x * 0.4)}"
      },
      %w[yards meters] => ->(x) {
        step "meters ≈ yards − 10% (a yard is just under a meter)"
        step "#{fmt_step(x)} − #{fmt_step(x * 0.1)} = #{fmt_step(x * 0.9)}"
      },
      %w[meters yards] => ->(x) {
        step "yards ≈ meters + 10%"
        step "#{fmt_step(x)} + #{fmt_step(x * 0.1)} = #{fmt_step(x * 1.1)}"
      },
      %w[pounds kg] => ->(x) {
        step "kg ≈ half the pounds, minus 10% of that"
        step "Half: #{fmt_step(x / 2.0)}; minus #{fmt_step(x / 20.0)} → #{fmt_step(x * 0.45)}"
      },
      %w[kg pounds] => ->(x) {
        step "pounds ≈ double the kg, plus 10% of that"
        step "Double: #{fmt_step(x * 2)}; plus #{fmt_step(x * 0.2)} → #{fmt_step(x * 2.2)}"
      },
      %w[ounces grams] => ->(x) {
        step "grams ≈ ounces × 28: do × 30, then subtract × 2"
        step "#{fmt_step(x)} × 30 = #{fmt_step(x * 30)}, − #{fmt_step(x * 2)} = #{fmt_step(x * 28)}"
      },
      %w[grams ounces] => ->(x) {
        step "ounces ≈ grams ÷ 28"
        step "Ask: 28 × ? = #{fmt_step(x)} → about #{fmt_step(x / 28.0)}"
      },
      %w[stones kg] => ->(x) {
        step "kg ≈ stones × 6.35: × 6, then add a third of the original"
        step "#{fmt_step(x)} × 6 = #{fmt_step(x * 6)}, + #{fmt_step(x / 3.0)} ≈ #{fmt_step(x * 6 + x / 3.0)}"
      },
      %w[kg stones] => ->(x) {
        step "stones ≈ kg ÷ 6.35 (roughly ÷ 6, then shade down)"
        step "Ask: 6 × ? = #{fmt_step(x)} → about #{fmt_step(x / 6.0)}"
      }
    }.freeze

    private

    def generate!
      reverse = [ true, false ].sample

      if reverse
        from_unit = self.class.to_unit
        to_unit   = self.class.from_unit
        factor    = 1.0 / self.class.conversion_factor
      else
        from_unit = self.class.from_unit
        to_unit   = self.class.to_unit
        factor    = self.class.conversion_factor
      end

      input  = rand_amount(min: 1, max: self.class.max_input)
      result = round_to(input * factor)

      @prompt      = "#{format_number(input)} #{from_unit} = ? #{to_unit}"
      @answer      = result
      @hint        = "Multiply #{from_unit} by #{factor.round(4)} to get #{to_unit}"
      @explanation = "#{format_number(input)} × #{factor.round(4)} = #{format_number(result)} #{to_unit}"

      strategy = STRATEGIES[[ from_unit, to_unit ]]
      if strategy
        instance_exec(input, &strategy)
      else
        step "1 #{from_unit} ≈ #{fmt_step(factor)} #{to_unit}"
        step "#{fmt_step(input)} × #{fmt_step(factor)} ≈ #{fmt_step(input * factor)}"
      end
      step "Exact: #{fmt_step(input)} × #{factor.round(4)} = #{exact_result(input * factor, result)} #{to_unit}"
    end
  end
end
