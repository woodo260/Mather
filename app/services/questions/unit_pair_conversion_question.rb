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
    end
  end
end
