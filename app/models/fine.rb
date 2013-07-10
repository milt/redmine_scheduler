class Fine < ActiveRecord::Base
  unloadable
  belongs_to :repair
  monetize :amount_cents
  validates :patron_name, :patron_phone, :patron_email, presence: true


  def self.unpaid
  	where("paid IS NULL")
  end

  def self.paid
  	where("paid IS NOT NULL")
  end
end
