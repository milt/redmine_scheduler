pdf.font "Helvetica"
pdf.default_leading -6

pdf.text "DMC Poster Print Order #" + @poster.issue.id.to_s, :size => 24, :align => :left, :style => :bold
pdf.stroke_horizontal_rule

address = "Mattin Arts Center\n
           Offit Building Suite 226"

pdf.bounding_box([0, 690], :width => 200, :height => 100) do
  pdf.text address
end

contact =  "digitalmedia@jhu.edu\n
           410-516-3817"

pdf.bounding_box([340, 690], :width => 200, :height => 100) do
  pdf.text contact, :align => :right
end

pdf.default_leading 0
pdf.move_up 55
pdf.stroke_horizontal_rule


pdf.bounding_box([0, 640], :width => 200, :height => 100) do
  pdf.text "Order Information", style: :bold
  pdf.text "Name: #{@poster.patron_name}"
  pdf.text "Phone: #{@poster.patron_phone}"
  pdf.text "Email: #{@poster.patron_email}"
  pdf.text "Dept.: #{@poster.patron_dept}"
end

pdf.bounding_box([340, 640], :width => 200, :height => 100) do
  pdf.text "<b>Order Date:</b> #{@poster.dropoff.strftime("%m/%d/%Y %l:%M %p")}", :align => :right, :inline_format => true
  pdf.text "<b>Filename:</b> #{@poster.file_name}", :align => :right, :inline_format => true
  pdf.text "<b>Staff Entering:</b> #{@poster.user.name}", :align => :right, :inline_format => true
end

pdf.table([ ["<b>Paper Type</b>", "<b>Print Dimensions</b>", "<b>Border</b>", "<b>Filesize</b>", "<b>Qty.</b>", "<b>Total</b>"],
            [@poster.paper_type, "#{@poster.print_width}\" x #{@poster.print_height}\"",
             @poster.border.to_s + "\"", @poster.issue.attachments.first.filesize,
             @poster.quantity, humanized_money_with_symbol(@poster.total)] ], :width => 540, :cell_style => {:align => :center, :inline_format => :true})
pdf.move_down 10
pdf.bounding_box([315, 480], :width => 210, :height => 80) do
  pdf.text "Deposit: #{humanized_money_with_symbol(@poster.deposit)}", :align => :right
  pdf.text "Balance Due: #{humanized_money_with_symbol(@poster.balance_due)}", :align => :right
end

pdf.bounding_box([0, 480], :width => 200, :height => 80) do
  pdf.text "Payment Method: #{@poster.payment_type.capitalize}", :align => :left

  case @poster.payment_type
  when "check"
    pdf.text "Reference No.: #{@poster.payment_reference}", :align => :left
  when "budget"
    pdf.text "Budget Number: #{@poster.budget_number}", :align => :left
    pdf.text "Budget Admin: #{@poster.budget_name}", :align => :left
    pdf.text "Budget Email: #{@poster.budget_email}", :align => :left
    pdf.text "Budget Phone: #{@poster.budget_phone}", :align => :left
  end
end
pdf.stroke_horizontal_rule

pdf.bounding_box([0, 385], :width => 300, :height => 80) do
  pdf.text "<b>PLEASE READ AND CHECK THE FOLLOWING:</b>", :align => :left, :inline_format => true
  pdf.text "- I have submitted the file as a PDF"
  pdf.text "- I have checked with a DMC staff person that my file is the correct print dimensions and resolution."
end

pdf.bounding_box([310, 385], :width => 230, :height => 80) do
  pdf.text "Customer Signature:", :align => :left
  pdf.text " "
  pdf.text "X________________", :size => 24, :align => :right
end

pdf.bounding_box([0,285], :width => 540, :height => 245) do
  pdf.transparent(0.5) { pdf.stroke_bounds }
  pdf.text "<b>Pickup Information</b>", :inline_format => true, :size => 18
end

pdf.bounding_box([10,225], :width => 270, :height => 185) do
  pdf.pad(10) {
    pdf.text "Pickup no earlier than:"
    pdf.text "<b>#{@poster.pickup.strftime("%m/%d/%Y at %l:%M %p")}</b>", :inline_format => true
    pdf.text "<i>Note: Normal DMC hours are Sunday­ - Thursday noon ­- midnight; Saturday & Sunday, noon­ - 10pm</i>", :size => 8, :inline_format => true
  }
  pdf.pad(10) {
    pdf.text "Staff Name:______________"
  }
  pdf.pad(10) {
    pdf.text "Date & Time Picked Up:______________"
  }
end


pdf.bounding_box([310,180], :width => 225, :height => 55) do
  pdf.transparent(1.0) { pdf.stroke_bounds }
  pdf.pad(20) {
    pdf.text "Total Paid:  $", :align => :left
  }
end

pdf.bounding_box([310,80], :width => 230, :height => 40) do
  pdf.text "Customer Signature:", :align => :left
  pdf.text "X________________", :size => 24, :align => :right
end

pdf.bounding_box([0,30], :width => 540, :height => 30) do
  pdf.text "A $10 handling fee is included in the price of each print. For payment by check or J­Cash, a deposit of half the material cost and the entire service fee is required at the time the order is placed. The balance must be paid at the time of pickup. For payment with budget numbers, full payment is due upon ordering.", :size => 8, :align => :justify
end

