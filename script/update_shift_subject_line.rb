# script retrieves all lab coach/front desk issues of date later than today
# the subject line of all retrieved issues will be update to display the correct date (use only after bug fix on shift subject off by 1 day)

fd_tracker = Tracker.fdshift_track.first
lc_tracker = Tracker.lcshift_track.first
fd_issues = Issue.all.select {|i| i.tracker == fd_tracker}
lc_issues = Issue.all.select {|i| i.tracker == lc_tracker}
fd_issues_future_date = fd_issues.select {|i| i.start_date >= Date.today}
lc_issues_future_date = lc_issues.select {|i| i.start_date >= Date.today}

fd_issues_future_date.map {|i| i.refresh_shift_subject; i.save}
lc_issues_future_date.map {|i| i.refresh_shift_subject; i.save}