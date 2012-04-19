module CommandHelper
  def pie_url_by_attribute(user, hours, attribute)
    pie_array = []
    grouphash = user.analyze_time(hours).group_by { |t| t.send(attribute) }
    grouphash.keys.each do |key|
      pie_array << [ key, grouphash[key].inject(0) {|sum,t| t.hours + sum} ]
    end
    g = GChart.pie :data => pie_array.map {|a| a[1]},
                   :legend => pie_array.map { |a| a[0].name },
                   :height => 200,
                   :width => 450 #,
                   #:extras => { "chma" => "32,32,32,32" }

    g.to_url
  end
  
  # TODO: make this a vertical bar graph that shows hours worked on days over the specified weeks.
  def bar_url_hours_worked(user, weeks)
    bar_array = []
    grouphash = user.get_workload(weeks).group_by { |t| t.spent_on }
    grouphash.keys.each do |key|
      bar_array << [ key, grouphash[key].inject(0) {|sum,t| t.hours + sum} ]
    end
    g = GChart.bar :data => bar_array.map {|a| a[1]},
                    :height => 200,
                    :width => 800 #,
                    #:extras => { "chma" => "32,32,32,32" }
    g.to_url
  end
  
end
