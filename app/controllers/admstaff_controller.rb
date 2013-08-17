class AdmstaffController < ApplicationController
  unloadable

  def index
    authorize! :index, :admin

    notification_check

    @reminders = Reminder.all
  end

  private

  def notification_check
    @notifications = {}

    if Booking.orphaned.present?
      @notifications["Orphaned bookings detected. Please resolve them."] = bookings_path
    end

    if Fine.unpaid.present?
      @notifications["There are unpaid fines."] = fines_path
    end

    if Timesheet.is_submitted.is_not_approved.present?
      @notifications["There are submitted timesheets awaiting your approval!"] = timesheets_path
    end
  end
end
