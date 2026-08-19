module Questions
  class OhmsLawQuestion < BaseQuestion
    def self.key         = "ohms_law"
    def self.label       = "Ohm's Law"
    def self.description = "Solve for voltage, current, or resistance using V = I × R. Fundamental to understanding electrical circuits."

    CONTEXTS = [
      "a simple circuit",
      "a resistor in a circuit",
      "an LED circuit",
      "a motor circuit"
    ].freeze

    private

    def generate!
      # Difficulty-scaled ranges
      resistance = rand_int(1, [10, 50, 100, 1000][@difficulty])
      current    = rand_amount(min: 1, max: [5, 10, 20, 20][@difficulty])
      voltage    = round_to(current * resistance)
      context    = CONTEXTS.sample

      solve_for = if @difficulty == 0
        :voltage
      else
        [:voltage, :current, :resistance].sample
      end

      case solve_for
      when :voltage
        @prompt      = "In #{context}, the current is #{format_number(current)} A and the resistance is #{resistance} Ω. What is the voltage (V)?"
        @answer      = voltage
        @hint        = "V = I × R"
        @explanation = "V = #{format_number(current)} A × #{resistance} Ω = #{format_number(voltage)} V"

        step "V = I × R"
        multiplication_steps(current, resistance)
        step "V = #{format_number(voltage)} V"
      when :current
        @prompt      = "In #{context}, the voltage is #{format_number(voltage)} V and the resistance is #{resistance} Ω. What is the current in amps (A)?"
        @answer      = round_to(current)
        @hint        = "I = V ÷ R"
        @explanation = "I = #{format_number(voltage)} V ÷ #{resistance} Ω = #{format_number(current)} A"

        step "I = V ÷ R"
        division_steps(voltage, resistance, current)
        step "I = #{format_number(current)} A"
      when :resistance
        @prompt      = "In #{context}, the voltage is #{format_number(voltage)} V and the current is #{format_number(current)} A. What is the resistance in ohms (Ω)?"
        @answer      = resistance.to_f
        @hint        = "R = V ÷ I"
        @explanation = "R = #{format_number(voltage)} V ÷ #{format_number(current)} A = #{resistance} Ω"

        step "R = V ÷ I"
        division_steps(voltage, current, resistance)
        step "R = #{resistance} Ω"
      end
    end
  end
end
