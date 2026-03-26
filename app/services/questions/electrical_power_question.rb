module Questions
  class ElectricalPowerQuestion < BaseQuestion
    def self.key         = "electrical_power"
    def self.label       = "Electrical Power"
    def self.description = "Calculate power, voltage, or current using P = V × I. Covers everyday appliances and household circuits."

    APPLIANCES = [
      { name: "lamp",       voltage: 120, current_range: [0.5, 1.0] },
      { name: "toaster",    voltage: 120, current_range: [8,   10]  },
      { name: "television", voltage: 120, current_range: [1,   3]   },
      { name: "microwave",  voltage: 120, current_range: [10,  15]  },
      { name: "laptop",     voltage: 19,  current_range: [2,   5]   },
      { name: "phone charger", voltage: 5, current_range: [1,  3]   }
    ].freeze

    private

    def generate!
      appliance = APPLIANCES.sample
      voltage   = appliance[:voltage].to_f
      current   = rand_amount(min: appliance[:current_range][0], max: appliance[:current_range][1])
      power     = round_to(voltage * current)

      solve_for = if @difficulty == 0
        :power
      else
        [:power, :voltage, :current].sample
      end

      case solve_for
      when :power
        @prompt      = "A #{appliance[:name]} runs at #{format_number(voltage)} V with a current of #{format_number(current)} A. What is its power consumption in watts (W)?"
        @answer      = power
        @hint        = "P = V × I"
        @explanation = "P = #{format_number(voltage)} V × #{format_number(current)} A = #{format_number(power)} W"
      when :voltage
        @prompt      = "A #{appliance[:name]} consumes #{format_number(power)} W of power and draws #{format_number(current)} A of current. What is the voltage (V)?"
        @answer      = voltage
        @hint        = "V = P ÷ I"
        @explanation = "V = #{format_number(power)} W ÷ #{format_number(current)} A = #{format_number(voltage)} V"
      when :current
        @prompt      = "A #{appliance[:name]} consumes #{format_number(power)} W of power at #{format_number(voltage)} V. What is the current in amps (A)?"
        @answer      = round_to(current)
        @hint        = "I = P ÷ V"
        @explanation = "I = #{format_number(power)} W ÷ #{format_number(voltage)} V = #{format_number(current)} A"
      end
    end
  end
end
