class System < Sequel::Model
  one_to_many :steps
  one_to_many :deploys

  def active_deploy
    Deploy.filter(:system => self, :active => true).first
  end

  def to_hash(options = {})
    values
  end

  def to_json(options = {})
    to_hash(options).to_json
  end
end