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
end

pdf.table([ ["<b>Paper Type</b>", "<b>Print Dimensions</b>", "<b>Border</b>", "<b>Filesize</b>", "<b>Qty.</b>", "<b>Total</b>"],
            [@poster.paper_type, "#{@poster.print_width}\" x #{@poster.print_height}\"",
             @poster.border.to_s + "\"", @poster.issue.attachments.first.filesize,
             @poster.quantity, humanized_money_with_symbol(@poster.total)] ], :width => 540, :cell_style => {:align => :center, :inline_format => :true})
pdf.move_down 10
pdf.bounding_box([315, 480], :width => 200, :height => 100) do
  pdf.text "Deposit: #{humanized_money_with_symbol(@poster.deposit)}", :align => :right
  pdf.text "Balance Due: #{humanized_money_with_symbol(@poster.balance_due)}", :align => :right
end
pdf.move_down 10
pdf.stroke_horizontal_rule
