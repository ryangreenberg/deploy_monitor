class Progress < Sequel::Model
  many_to_one :deploy
  many_to_one :step

  self.plugin :timestamps,
    :create => :created_at,
    :update => :updated_at,
    :update_on_create => true

  def to_hash(options = {})
    values
  end

  def to_json(options = {})
    to_hash(options).to_json
  end
end