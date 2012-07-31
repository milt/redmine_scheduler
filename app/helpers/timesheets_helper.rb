module TimesheetsHelper
  def render_actions(timesheet)
  	if User.current.is_admstaff?
      timesheet.actions[:admin].map {|a| link_to(a[0], :action => a[1], :id => timesheet) + " "}
    elsif User.current.is_stustaff?
      timesheet.actions[:staff].map {|a| link_to(a[0], :action => a[1], :id => timesheet) + " "}
    else
    	"nope"
    end
  end
end
