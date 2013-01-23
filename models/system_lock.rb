class SystemLock < Sequel::Model
  many_to_one :system

  def to_hash(options = {})
    values
  end

  def to_json(options = {})
    to_hash(options).to_json
  end
end