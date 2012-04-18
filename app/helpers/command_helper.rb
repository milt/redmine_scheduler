module CommandHelper
  def pie_url_by_attribute(user, hours, attribute)
    pie_array = []
    grouphash = user.analyze_time(hours).group_by { |t| t.send(attribute) }
    grouphash.keys.each do |key|
      pie_array << [ key, grouphash[key].inject(0) {|sum,t| t.hours + sum} ]
    end
    g = GChart.pie :data => pie_array.map {|a| a[1]},
                   :legend => pie_array.map { |a| a[0].name },
                   :height => 256,
                   :width => 512 #,
                   #:extras => { "chma" => "32,32,32,32" }

    g.to_url
  end
end
