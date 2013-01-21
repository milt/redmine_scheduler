module TimesheetsHelper
  def render_actions(timesheet)
  	if User.current.is_admstaff?
      timesheet.actions[:admin].map {|a| 
      	if a[0] == 'Delete'; 
      		link_to(a[0], {:action => a[1], :id => timesheet}, :confirm => "Are you sure?");
      	elsif a[0] == 'Reject'; link_to(a[0], {:action => a[1], :id => timesheet}, :confirm => "Are you sure?");
      	else link_to(a[0], :action => a[1], :id => timesheet);
      	end + " "}
    elsif User.current.is_stustaff?
      timesheet.actions[:staff].map {|a| 
      	if a[0] == 'Delete'; 
      		link_to(a[0], {:action => a[1], :id => timesheet}, :confirm => "Are you sure?"); 
      	else link_to(a[0], :action => a[1], :id => timesheet); 
      	end + " "}
    else
    	"nope"
    end
  end

  # adapted from timeslot helper
  def dates(to,from)
    dates = []
    date = to
    while date >= from do
      dates << date.strftime("Week of %B %d, Year %Y")
      date -= 7.day
    end
    return dates
  end
end
