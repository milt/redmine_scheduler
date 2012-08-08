module TimeslotsHelper
  def dates(from,to)
    dates = []
    date = from
    while date <= to do
      dates << date
      date += 1.day
    end
    return dates
  end
end
