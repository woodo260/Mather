module Questions
  class TimesElevenQuestion < BaseQuestion
    def self.key         = "times_eleven"
    def self.label       = "Multiply by 11"
    def self.description = "The ×11 digit-insertion trick for two-digit numbers; larger numbers via shift-and-add."

    private

    def generate!
      if @difficulty <= 1
        two_digit_insert
      else
        shift_and_add
      end
    end

    # 34 × 11 → 3_(3+4)_4 = 374, carrying when the middle digit is two digits.
    def two_digit_insert
      a      = rand_int(1, 9)
      b      = @difficulty.zero? ? rand_int(0, 9 - a) : rand_int(0, 9)
      number = a * 10 + b
      middle = a + b
      result = number * 11

      @prompt      = "#{number} × 11 = ?"
      @answer      = result.to_f
      @hint        = "Split the two digits and drop their sum in the middle"
      @explanation = "#{number} × 11 = #{result}"

      step "Split #{number} into its digits: #{a} and #{b}"
      if middle < 10
        step "Add them for the middle digit: #{a} + #{b} = #{middle}"
        step "Slot it between the digits: #{a}_#{middle}_#{b} → #{result}"
      else
        step "Middle digit: #{a} + #{b} = #{middle} — two digits, so carry the 1"
        step "Carry into the left digit: #{a} + 1 = #{a + 1}, keep #{middle - 10} in the middle"
        step "Result: #{a + 1} #{middle - 10} #{b} → #{result}"
      end
      step "So #{number} × 11 = #{result}"
    end

    # For bigger numbers: ×11 = ×10 + ×1.
    def shift_and_add
      digits = @difficulty == 2 ? 3 : 4
      number = rand_int(10**(digits - 1), 10**digits - 1)
      result = number * 11

      @prompt      = "#{number} × 11 = ?"
      @answer      = result.to_f
      @hint        = "×11 is just ×10 plus the number itself"
      @explanation = "#{number} × 11 = #{result}"

      step "×11 = ×10 + ×1"
      step "#{number} × 10 = #{number * 10}"
      step "#{number * 10} + #{number} = #{result}"
    end
  end
end
