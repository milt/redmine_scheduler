class PosterObserver < ActiveRecord::Observer

  def after_create(poster)
    Mailer.poster_add_staff(poster).deliver
    Mailer.poster_add_patron(poster).deliver
  end

end