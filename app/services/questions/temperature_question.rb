module Questions
  class TemperatureQuestion < BaseQuestion
    # Landmark temps produce clean answers at low difficulty
    LANDMARKS_C = [ 0, 20, 25, 37, 100 ].freeze
    LANDMARKS_F = [ 32, 68, 77, 98.6, 212 ].freeze

    def self.key         = "temperature"
    def self.label       = "Temperature Conversion"
    def self.description = "Convert between Celsius and Fahrenheit. Low difficulty uses landmark temperatures (0°C, 100°C, etc.)."

    private

    def generate!
      to_f = [ true, false ].sample

      if @difficulty == 0
        if to_f
          celsius = LANDMARKS_C.sample
          fahr    = (celsius * 9.0 / 5 + 32).round(0)
          @prompt      = "#{celsius}°C = ?°F"
          @answer      = fahr.to_f
          @hint        = "Multiply by 9/5, then add 32"
          @explanation = "(#{celsius} × 9/5) + 32 = #{fahr}°F"
          c_to_f_steps(celsius, fahr)
        else
          fahr    = LANDMARKS_F.sample
          celsius = ((fahr - 32) * 5.0 / 9).round(0)
          @prompt      = "#{fahr}°F = ?°C"
          @answer      = celsius.to_f
          @hint        = "Subtract 32, then multiply by 5/9"
          @explanation = "(#{fahr} − 32) × 5/9 = #{celsius}°C"
          f_to_c_steps(fahr, celsius)
        end
      else
        range = [ 50, 100, 150, 200 ][@difficulty]
        if to_f
          celsius = rand_amount(min: -20, max: range)
          fahr    = round_to(celsius * 9.0 / 5 + 32)
          @prompt      = "#{format_number(celsius)}°C = ?°F"
          @answer      = fahr
          @hint        = "Multiply by 1.8 (9/5), then add 32"
          @explanation = "(#{format_number(celsius)} × 1.8) + 32 = #{format_number(fahr)}°F"
          c_to_f_steps(celsius, fahr)
        else
          fahr    = rand_amount(min: -4, max: range * 1.8 + 32)
          celsius = round_to((fahr - 32) * 5.0 / 9)
          @prompt      = "#{format_number(fahr)}°F = ?°C"
          @answer      = celsius
          @hint        = "Subtract 32, then multiply by 0.556 (5/9)"
          @explanation = "(#{format_number(fahr)} − 32) × 5/9 = #{format_number(celsius)}°C"
          f_to_c_steps(fahr, celsius)
        end
      end
    end

    def c_to_f_steps(celsius, fahr)
      doubled = celsius * 2.0
      step "°F = °C × 1.8 + 32. Trick for ×1.8: double, then subtract 10%"
      step "Double: #{fmt_step(celsius)} × 2 = #{fmt_step(doubled)}"
      step "Minus 10%: #{fmt_step(doubled)} − #{fmt_step(doubled / 10)} = #{fmt_step(doubled * 0.9)}"
      step "Add 32: #{fmt_step(doubled * 0.9)} + 32 = #{format_number(fahr)}°F"
    end

    def f_to_c_steps(fahr, celsius)
      diff = fahr - 32.0
      step "°C = (°F − 32) × 5/9"
      step "Subtract 32: #{fmt_step(fahr)} − 32 = #{fmt_step(diff)}"
      step "Estimate 5/9 ≈ 0.55: half of #{fmt_step(diff)} plus a tenth of that ≈ #{fmt_step(diff * 0.55)}"
      step "Exact: #{fmt_step(diff)} × 5 ÷ 9 = #{format_number(celsius)}°C"
    end
  end
end
