module Questions
  class NewtonsSecondLawQuestion < BaseQuestion
    def self.key         = "newtons_second_law"
    def self.label       = "Newton's Second Law"
    def self.description = "Solve for force, mass, or acceleration using F = m × a. Core concept in classical mechanics."

    SCENARIOS = [
      { subject: "a car",          mass_range: [500, 2000] },
      { subject: "a bicycle",      mass_range: [10,  30]   },
      { subject: "a ball",         mass_range: [1,   10]   },
      { subject: "a box",          mass_range: [5,   100]  },
      { subject: "a shopping cart", mass_range: [10,  50]  }
    ].freeze

    private

    def generate!
      scenario     = SCENARIOS.sample
      mass         = rand_amount(min: scenario[:mass_range][0], max: scenario[:mass_range][1])
      acceleration = rand_amount(min: 1, max: [5, 10, 20, 30][@difficulty])
      force        = round_to(mass * acceleration)

      solve_for = if @difficulty == 0
        :force
      else
        [:force, :mass, :acceleration].sample
      end

      case solve_for
      when :force
        @prompt      = "#{scenario[:subject].capitalize} has a mass of #{format_number(mass)} kg and accelerates at #{format_number(acceleration)} m/s². What is the net force in Newtons (N)?"
        @answer      = force
        @hint        = "F = m × a"
        @explanation = "F = #{format_number(mass)} kg × #{format_number(acceleration)} m/s² = #{format_number(force)} N"

        step "F = m × a"
        multiplication_steps(mass, acceleration)
        step "F = #{format_number(force)} N"
      when :mass
        @prompt      = "A net force of #{format_number(force)} N causes #{scenario[:subject]} to accelerate at #{format_number(acceleration)} m/s². What is its mass in kg?"
        @answer      = round_to(mass)
        @hint        = "m = F ÷ a"
        @explanation = "m = #{format_number(force)} N ÷ #{format_number(acceleration)} m/s² = #{format_number(mass)} kg"

        step "m = F ÷ a"
        division_steps(force, acceleration, mass)
        step "m = #{format_number(mass)} kg"
      when :acceleration
        @prompt      = "A net force of #{format_number(force)} N acts on #{scenario[:subject]} with a mass of #{format_number(mass)} kg. What is its acceleration in m/s²?"
        @answer      = round_to(acceleration)
        @hint        = "a = F ÷ m"
        @explanation = "a = #{format_number(force)} N ÷ #{format_number(mass)} kg = #{format_number(acceleration)} m/s²"

        step "a = F ÷ m"
        division_steps(force, mass, acceleration)
        step "a = #{format_number(acceleration)} m/s²"
      end
    end
  end
end
