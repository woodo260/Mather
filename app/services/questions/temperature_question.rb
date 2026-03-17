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
        else
          fahr    = LANDMARKS_F.sample
          celsius = ((fahr - 32) * 5.0 / 9).round(0)
          @prompt      = "#{fahr}°F = ?°C"
          @answer      = celsius.to_f
          @hint        = "Subtract 32, then multiply by 5/9"
          @explanation = "(#{fahr} − 32) × 5/9 = #{celsius}°C"
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
        else
          fahr    = rand_amount(min: -4, max: range * 1.8 + 32)
          celsius = round_to((fahr - 32) * 5.0 / 9)
          @prompt      = "#{format_number(fahr)}°F = ?°C"
          @answer      = celsius
          @hint        = "Subtract 32, then multiply by 0.556 (5/9)"
          @explanation = "(#{format_number(fahr)} − 32) × 5/9 = #{format_number(celsius)}°C"
        end
      end
    end
  end
end
