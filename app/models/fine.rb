class Fine < ActiveRecord::Base
  unloadable
  belongs_to :repair
  monetize :amount_cents
  validates :patron_name, :patron_phone, :patron_email, presence: true
  validates :payment_method, presence: true, if: 'paid.present?'

  def self.search(search)
    where("patron_name LIKE ? OR patron_phone LIKE ? OR patron_email LIKE ? OR patron_jhed LIKE ? OR notes LIKE ?", "%#{search}%", "%#{search}%", "%#{search}%", "%#{search}%", "%#{search}%")
  end

  def self.unpaid
  	where("paid IS NULL")
  end

  def self.paid
  	where("paid IS NOT NULL")
  end
end
