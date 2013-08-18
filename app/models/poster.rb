class Poster < ActiveRecord::Base
  unloadable
  monetize :total_cents, :deposit_cents
  belongs_to :user
  belongs_to :issue
  validates :user,
            :issue,
            :dropoff,
            :pickup,
            :patron_name,
            :patron_phone,
            :patron_dept,
            :patron_email,
            :affiliation,
            :doc_width,
            :doc_height,
            :print_width,
            :print_height,
            :border,
            :payment_type,
            :total_cents,
            :deposit_cents,
            :quantity, presence: true

  validate :width_and_border_limit

  validates :print_width, :print_height, numericality: { greater_than: 17.0}


      
      # :payment_reference
      # :budget_number
      # :budget_name
      # :budget_email
      # :budget_phone
      # :total_cents
      # :deposit_cents
      # :notes

  def width_and_border_limit
    if (print_width + border) > 44.0
      errors.add(:print_width, "can't exceed 44 inches.")
    end
  end

  def minimum_deposit
  end

  def balance_due
  end

  def document_ratio
  end

  def print_ratio
  end

end
