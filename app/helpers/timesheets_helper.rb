module TimesheetsHelper
  def render_actions(timesheet)
  	if User.current.is_admstaff?
      timesheet.actions[:admin].map {|a| if a[0] == 'Delete'; link_to(a[0], {:action => a[1], :id => timesheet}, :confirm => "Are you sure?"); else link_to(a[0], :action => a[1], :id => timesheet); end}
    elsif User.current.is_stustaff?
      timesheet.actions[:staff].map {|a| if a[0] == 'Delete'; link_to(a[0], {:action => a[1], :id => timesheet}, :confirm => "Are you sure?"); else link_to(a[0], :action => a[1], :id => timesheet); end + " "}
    else
    	"nope"
    end
  end
end
