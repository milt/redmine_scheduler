module ManageHelper
  def generate_timesheet_pdf(name, wage, number, current, beginning, ending, hours)
    Prawn::Document.new do
      #studentName = "Matthew Antonio DelGrosso"
      #studentWage = "12.00"
      studentName = name
      studentWage = wage
      studentNumber = number
      currentDate = current
      beginningDate = beginning
      endingDate = ending
      totalHours = hours

      font_size(16)
      text "Generic Student Employee Timesheet", :style => :bold, :align => :center
      font_size(12)
      pad_top(15){ text "Student Name: " + studentName + "       Student Hourly Wage: $" + studentWage, :align => :center }
      pad_top(10){ text "Pay period for this timesheet:   Beginning date - " + beginningDate + "  Ending date - " + endingDate, :align => :center }
      font_size(14)
      pad_top(10){ text "Report of hours worked", :style => :bold}
      font_size(12)
      table([    ["Day", "Date", "# Hours Worked"],
          ["Monday", "", ""],
          [" ", "", ""],
          ["Tuesday", "", ""],
          [" ", "", ""],
          ["Wednesday", "", ""],
          [" ", "", ""],
          ["Thursday", "", ""],
          [" ", "", ""],
          ["Friday", "", ""],
          [" ", "", ""],
          ["Saturday", "", ""],
          [" ", "", ""],
          ["Sunday", "", ""],
          [" ", "", ""],
          ["", "", "Total Hours: " + totalHours]], :column_widths => [210, 165, 165], :cell_style => {:height => 21})
      pad_top(30) { table([[" ", " "],
          ["*Student's signature                                Date", "*Supervisor's signature                             Date"]], :column_widths=> [270, 270]) }
      pad_top(10) { table([[" ", " "],
          ["SAP Cost Center or Internal Order", "Supervisor email address"]], :column_widths => [270, 270]) }
      pad_top(20) { text "*NOTE: Your signature certifies that this document reflects actual hours worked in accordance with wage and hours laws" }
      pad_top(10) { dash(7, :space => 7, :phase => 0) }
      stroke_horizontal_line 0, 540
      pad_top(10) { text "For Processing Dept Use Only:", :style => :bold }
      pad_top(20) { text "Student Personnel #" + studentNumber + "           Date Processed: " + currentDate }
      pad_top(10) { text "Processed By Deborah Buffalin" }
    end.render
  end
end
