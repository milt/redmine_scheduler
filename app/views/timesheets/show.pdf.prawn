pdf.font "Helvetica"

name      = @timesheet.user.name

pdf.text name
wage      = @timesheet.user.wage.amount.to_s
current   = Date.today
beginning = @timesheet.weekof.to_date
mon = @timesheet.hours_for_day(:monday)
tue = @timesheet.hours_for_day(:tuesday)
wed = @timesheet.hours_for_day(:wednesday)
thu = @timesheet.hours_for_day(:thursday)
fri = @timesheet.hours_for_day(:friday)
sat = @timesheet.hours_for_day(:saturday)
sun = @timesheet.hours_for_day(:sunday)
status    = @timesheet.status_string

pdf.font_size(16)
pdf.text "DMC Student Employee Timesheet", :style => :bold, :align => :center
pdf.font_size(12)
pdf.pad_top(15){ pdf.text "Student Name:<b> " + name + "</b>       Student Hourly Wage: $" + wage, :align => :center, :inline_format => true }
pdf.pad_top(10){ pdf.text "Pay period for this timesheet:   From -<b> " + beginning.strftime("%D") + "</b>  To -<b> " + (beginning + 6.days).strftime("%D")  + "</b>", :align => :center, :inline_format => true }
pdf.pad_top(10){ pdf.text "Current status: " + status}
pdf.font_size(14)
pdf.pad_top(10){ pdf.text "Report of hours worked", :style => :bold}
pdf.font_size(12)

pdf.table([ ["Day", "Date", "# Hours Worked"] ], :column_widths => [108, 216, 216], :cell_style => {:height => 21})

pdf.table([ ["Monday", beginning, mon],
  [" ", "", ""],
  ["Tuesday", beginning + 1.days, tue],
  [" ", "", ""],
  ["Wednesday", beginning + 2.days, wed],
  [" ", "", ""],
  ["Thursday",  beginning + 3.days, thu],
  [" ", "", ""],
  ["Friday",  beginning + 4.days, fri],
  [" ", "", ""],
  ["Saturday", beginning + 5.days, sat],
  [" ",  "", ""],
  ["Sunday",  beginning + 6.days, sun],
  [" ",  "", ""],
  ["", "", "Total Hours: " + (mon + tue + wed + thu + fri + sat + sun).to_s]], :column_widths => [108, 216, 216], :cell_style => {:height => 21}) do |table|
    table.column(2).style(:align => :center)
end
  
pdf.pad_top(30) { pdf.table([[" "],["*Student's signature                                                      Date"]], :column_widths=> [360]) } 

pdf.pad_top(20) { pdf.text "*NOTE: Your signature certifies that this document reflects actual hours worked in accordance with wage and hours laws" }
pdf.pad_top(10) { pdf.dash(7, :space => 7, :phase => 0) }
pdf.stroke_horizontal_line 0, 540
pdf.pad_top(10) { pdf.text "For Processing Dept Use Only:", :style => :bold }
pdf.pad_top(15) {pdf.dash(1, :space => 0, :phase => 0) }
pdf.pad_top(15) { pdf.table([[" "],["Processed By                                                                Date"]], :column_widths=> [360]) }
