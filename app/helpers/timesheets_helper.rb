module TimesheetsHelper
  
  def weeks_for_select
    weeks = []
    (Date.today - 52.weeks).step(Date.today, 7) {|d| weeks << d.beginning_of_week }
    return weeks
  end

  def days_in_week
    (@weekof.to_date..(@weekof.to_date + 6.days)).to_a
  end

end
