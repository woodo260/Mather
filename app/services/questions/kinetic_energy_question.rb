module Questions
  class KineticEnergyQuestion < BaseQuestion
    def self.key         = "kinetic_energy"
    def self.label       = "Kinetic Energy"
    def self.description = "Calculate kinetic energy using KE = ½mv². Explore how mass and speed affect the energy of moving objects."

    SCENARIOS = [
      { subject: "a car",     mass_range: [800, 2000], speed_range: [5,  30]  },
      { subject: "a bicycle", mass_range: [10,  30],   speed_range: [3,  15]  },
      { subject: "a runner",  mass_range: [50,  100],  speed_range: [2,  10]  },
      { subject: "a ball",    mass_range: [1,   5],    speed_range: [5,  40]  },
      { subject: "a train",   mass_range: [10000, 50000], speed_range: [10, 50] }
    ].freeze

    private

    def generate!
      scenario = SCENARIOS.sample
      mass     = rand_amount(min: scenario[:mass_range][0], max: scenario[:mass_range][1])
      speed    = rand_amount(min: scenario[:speed_range][0], max: scenario[:speed_range][1])
      ke       = round_to(0.5 * mass * speed * speed)

      # At all difficulties, solve for KE (finding mass/speed requires square roots)
      @prompt      = "#{scenario[:subject].capitalize} has a mass of #{format_number(mass)} kg and is moving at #{format_number(speed)} m/s. What is its kinetic energy in Joules (J)?"
      @answer      = ke
      @hint        = "KE = ½ × m × v²"
      @explanation = "KE = 0.5 × #{format_number(mass)} kg × (#{format_number(speed)} m/s)² = #{format_number(ke)} J"
    end
  end
end
