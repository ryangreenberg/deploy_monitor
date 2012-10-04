class Step < Sequel::Model
  many_to_one :system

  def self.renumber_overlapping_steps(system, number)
    overlapping_steps = Step.filter(:system => system).
      where { |o| o.number >= number }
    overlapping_steps.each do |step|
      step.number += 1
      step.save
    end
  end

  def to_hash(options = {})
    values
  end

  def to_json(options = {})
    to_hash(options).to_json
  end
end