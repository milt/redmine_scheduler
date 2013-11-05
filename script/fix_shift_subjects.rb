# fix off-by-one-day for shift subjects

Issue.shifts.each do |shift| #all lab coach and front desk shifts
  if shift.assigned_to && shift.start_time && shift.end_time && shift.start_date
    subject = shift.assigned_to.name + shift.start_time.strftime(' %I:%M:%S %p - ') + shift.end_time.strftime('%I:%M:%S %p - ') + shift.start_date.to_datetime.strftime('%a, %b %d')
    shift.update_column :subject, subject
  end
end
