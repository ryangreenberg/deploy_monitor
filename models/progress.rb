class Progress < Sequel::Model
  include Resultable

  many_to_one :deploy
  many_to_one :step

  self.plugin :timestamps,
    :create => :created_at,
    :update => :updated_at,
    :update_on_create => true

  def active?
    active
  end

  def duration
    if started_at && finished_at
      finished_at - started_at
    elsif started_at
      Time.now - started_at
    else
      nil
    end
  end

  def to_hash(options = {})
    hsh = values.dup

    # Use integer timestamps
    [:created_at, :updated_at, :started_at, :finished_at].each do |ts_field|
      if hsh[ts_field]
        hsh[ts_field] = hsh[ts_field].to_i
      end
    end

    hsh
  end

  def to_json(options = {})
    to_hash(options).to_json
  end
end