module BookingsHelper
  def render_timeslot_data(slot)
      {
        coach_name: slot.coach.name,
        coach_skills: slot.skills.skills.map(&:name).join(","),
        coach_auths: slot.skills.auths.map(&:name).join(","),
        time: slot.start_time.strftime('%l:%M %p') + ", " + slot.start_time.strftime('%b %d, %Y')
      }
  end
end
