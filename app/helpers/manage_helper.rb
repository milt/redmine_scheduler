module ManageHelper
  def generate_timesheet_pdf(name, wage, current, beginning, mon, tue, wed, thu, fri, sat, sun)
    beginning = Date.parse(beginning)
    Prawn::Document.new do
  	font_size(16)
  	text "DMC Student Employee Timesheet", :style => :bold, :align => :center
  	font_size(12)
  	pad_top(15){ text "Student Name:<b> " + name + "</b>       Student Hourly Wage: $" + wage, :align => :center, :inline_format => true }
  	pad_top(10){ text "Pay period for this timesheet:   From -<b> " + beginning.to_s + "</b>  To -<b> " + (beginning + 6.days).to_s  + "</b>", :align => :center, :inline_format => true }
	font_size(14)
	pad_top(10){ text "Report of hours worked", :style => :bold}
	font_size(12)
	table([	["Day", "Date", "# Hours Worked"] ], :column_widths => [108, 216, 216], :cell_style => {:height => 21})
	table([	["Monday", beginning, mon],
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
		["", "", "Total Hours: " + (mon.to_i + tue.to_i + wed.to_i + thu.to_i + fri.to_i + sat.to_i + sun.to_i).to_s]], :column_widths => [108, 216, 216], :cell_style => {:height => 21})
	pad_top(30) { table([[" "],["*Student's signature                                                      Date"]], :column_widths=> [360]) } 

	pad_top(20) { text "*NOTE: Your signature certifies that this document reflects actual hours worked in accordance with wage and hours laws" }
	pad_top(10) { dash(7, :space => 7, :phase => 0) }
	stroke_horizontal_line 0, 540
	pad_top(10) { text "For Processing Dept Use Only:", :style => :bold }
	pad_top(15) {dash(1, :space => 0, :phase => 0) }
	pad_top(15) { table([[" "],["Processed By                                                                Date"]], :column_widths=> [360]) }
    end.render
  end
end
