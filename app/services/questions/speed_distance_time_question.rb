module Questions
  class SpeedDistanceTimeQuestion < BaseQuestion
    def self.key         = "speed_distance_time"
    def self.label       = "Speed / Distance / Time"
    def self.description = "Solve for speed, distance, or time using D = R × T. Covers driving, running, and cycling scenarios."

    SCENARIOS = [
      { vehicle: "car", speed_unit: "mph", distance_unit: "miles", speed_min: 25, speed_max: 75 },
      { vehicle: "bicycle", speed_unit: "mph", distance_unit: "miles", speed_min: 8, speed_max: 20 },
      { vehicle: "runner", speed_unit: "mph", distance_unit: "miles", speed_min: 4, speed_max: 10 },
    ].freeze

    private

    def generate!
      scenario = SCENARIOS.sample
      solve_for = [ :distance, :time, :speed ].sample
      # At difficulty 0, keep solve_for simple — distance or time only
      solve_for = [ :distance, :time ].sample if @difficulty == 0

      speed    = rand_amount(min: scenario[:speed_min], max: scenario[:speed_max])
      time_hrs = rand_amount(min: 1, max: [ 2, 4, 6, 8 ][@difficulty])
      distance = round_to(speed * time_hrs)

      case solve_for
      when :distance
        @prompt      = "A #{scenario[:vehicle]} travels at #{format_number(speed)} #{scenario[:speed_unit]} for #{format_number(time_hrs)} hours. How many #{scenario[:distance_unit]} does it cover?"
        @answer      = distance
        @hint        = "Distance = Speed × Time"
        @explanation = "#{format_number(speed)} × #{format_number(time_hrs)} = #{format_number(distance)} #{scenario[:distance_unit]}"
      when :time
        @prompt      = "A #{scenario[:vehicle]} travels #{format_number(distance)} #{scenario[:distance_unit]} at #{format_number(speed)} #{scenario[:speed_unit]}. How many hours does the trip take?"
        @answer      = round_to(time_hrs)
        @hint        = "Time = Distance ÷ Speed"
        @explanation = "#{format_number(distance)} ÷ #{format_number(speed)} = #{format_number(time_hrs)} hours"
      when :speed
        @prompt      = "A #{scenario[:vehicle]} covers #{format_number(distance)} #{scenario[:distance_unit]} in #{format_number(time_hrs)} hours. What is its speed in #{scenario[:speed_unit]}?"
        @answer      = round_to(speed)
        @hint        = "Speed = Distance ÷ Time"
        @explanation = "#{format_number(distance)} ÷ #{format_number(time_hrs)} = #{format_number(speed)} #{scenario[:speed_unit]}"
      end
    end
  end
end
