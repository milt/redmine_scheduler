pdf.font "Helvetica"

pdf.text "Missing/Damaged Equipment Acknowledgement", :size => 24, :align => :center, :style => :bold
pdf.text "Digital Media Center | 3400 N Charles St 21218", :size => 16, :align => :center
pdf.text "digitalmedia@jhu.edu", :size => 16, :align => :center
pdf.text "410-516-3817", :size => 16, :align => :center, :style => :bold

repair_table_data = [
  [ "Item", @repair.item_number.to_s + " | " + @repair.item_desc ],
  [ "Problem/Damage", @repair.problem_desc ]
]

if @repair.patron_name.present?
  patron_table_data = [
    [ "Checkout #", @repair.checkout.to_s],
    [ "Patron Name", @repair.patron_name],
    [ "Patron Phone", @repair.patron_phone],
    [ "Patron Email", @repair.patron_email],
    [ "Patron JHED", @repair.patron_jhed],
    [ "Staff On Duty", @repair.user.name],
    [ "Ticket Number", @repair.issue_id]
  ]
  repair_table_data += patron_table_data
end

pdf.table(repair_table_data, :header => true) do
  column(0).font_style = :bold
  column(0).width = 125
  column(1).width = 415
end


agreement = "I agree to pay the repair or replacement cost of the lost/damaged \
item. The cost will be determined by the Director of the Digital Media Center, \
and I will be notified of this amount in writing, by U.S. Mail. As stated in the \
Borrower's Contract, I agree to pay the amount due to repair or replace this \
item by the last day of this academic semester, or by the date I \
withdraw/graduate from the University, whichever is earlier."

sig = "Borrower's Signature"

agreement_table_data = [[agreement,sig]]

pdf.bounding_box([0,100], :width => 540, :height => 100) do
  pdf.table(agreement_table_data) do
    column(0).width = 400
    column(1).width = 140
    column(1).style :align => :center
  end
end

pdf.bounding_box([340,0], :width => 200, :height => 10) do
  pdf.text DateTime.now.inspect, :size => 10, :align => :right
end

