module Questions
  class WorkEnergyQuestion < BaseQuestion
    def self.key         = "work_energy"
    def self.label       = "Work & Energy"
    def self.description = "Solve for work, force, or distance using W = F × d. Understand how energy is transferred by forces."

    SCENARIOS = [
      { action: "pushing a box",    force_range: [10,  200]  },
      { action: "lifting a crate",  force_range: [50,  500]  },
      { action: "pulling a sled",   force_range: [20,  150]  },
      { action: "dragging a log",   force_range: [100, 800]  },
      { action: "moving a bookcase", force_range: [30, 300]  }
    ].freeze

    private

    def generate!
      scenario = SCENARIOS.sample
      force    = rand_amount(min: scenario[:force_range][0], max: scenario[:force_range][1])
      distance = rand_amount(min: 1, max: [5, 10, 20, 50][@difficulty])
      work     = round_to(force * distance)

      solve_for = if @difficulty == 0
        :work
      else
        [:work, :force, :distance].sample
      end

      case solve_for
      when :work
        @prompt      = "You are #{scenario[:action]} with a force of #{format_number(force)} N over a distance of #{format_number(distance)} m. How much work is done in Joules (J)?"
        @answer      = work
        @hint        = "W = F × d"
        @explanation = "W = #{format_number(force)} N × #{format_number(distance)} m = #{format_number(work)} J"

        step "W = F × d"
        multiplication_steps(force, distance)
        step "W = #{format_number(work)} J"
      when :force
        @prompt      = "#{format_number(work)} J of work is done #{scenario[:action]} over a distance of #{format_number(distance)} m. What force was applied in Newtons (N)?"
        @answer      = round_to(force)
        @hint        = "F = W ÷ d"
        @explanation = "F = #{format_number(work)} J ÷ #{format_number(distance)} m = #{format_number(force)} N"

        step "F = W ÷ d"
        division_steps(work, distance, force)
        step "F = #{format_number(force)} N"
      when :distance
        @prompt      = "#{format_number(work)} J of work is done #{scenario[:action]} with a constant force of #{format_number(force)} N. What distance was covered in meters (m)?"
        @answer      = round_to(distance)
        @hint        = "d = W ÷ F"
        @explanation = "d = #{format_number(work)} J ÷ #{format_number(force)} N = #{format_number(distance)} m"

        step "d = W ÷ F"
        division_steps(work, force, distance)
        step "d = #{format_number(distance)} m"
      end
    end
  end
end
