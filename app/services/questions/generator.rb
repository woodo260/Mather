module Questions
  class Generator
    def self.call(types:, difficulty: 0)
      valid_types = Array(types).select { |t| Questions::Registry.key?(t) }
      valid_types = Questions::Registry.all_keys if valid_types.empty?

      key   = valid_types.sample
      klass = Questions::Registry.fetch(key)
      klass.new(difficulty: difficulty)
    end
  end
end
