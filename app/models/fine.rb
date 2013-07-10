class Fine < ActiveRecord::Base
  unloadable
  belongs_to :repair
  monetize :amount_cents

  def self.unpaid
  	where("paid IS NULL")
  end

  def self.paid
  	where("paid IS NOT NULL")
  end
end
