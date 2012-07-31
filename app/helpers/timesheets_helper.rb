module TimesheetsHelper
  def actions(timesheet)
    timesheet.actions.map {|a| link_to(a[0], :action => a[1], :id => timesheet) + " "}
  end
end
