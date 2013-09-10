class PosterObserver < ActiveRecord::Observer

  def after_create(poster)
    #send notification to poster team and patron
    Mailer.poster_add_staff(poster).deliver
    Mailer.poster_add_patron(poster).deliver

    #send notification to our admin and budget admin if the poster was paid for with a budget.
    if poster.payment_type == "budget"
      Mailer.poster_add_admin(poster).deliver
      Mailer.poster_add_budget_admin(poster).deliver
    end
  end

end