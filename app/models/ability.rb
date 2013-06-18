class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    user ||= User.new # guest user (not logged in)
    if user.is_admstaff?
      can :manage, Skill
      can :manage, Skillcat
      can :manage, Wage
      can :manage, Timesheet
      can :manage, Timeslot
      can :manage, Booking
      can :manage, Level
      can :manage, Repair
      can :index, :admin
      can [:index,:grab], :command
    elsif user.is_prostaff?
      can :manage, Timeslot
      can :manage, Booking
      can :manage, Level
      can :manage, Repair
      can [:index, :student_levels], :prostaff
      can [:index,:grab], :command
    elsif user.is_stustaff?
      can [:create, :read, :update, :destroy, :submit, :print], Timesheet, :user => user
      can :manage, Booking
      can [:create, :read], Repair
      can :index, :stustaff
    else

    end
    #
    # The first argument to `can` is the action you are giving the user 
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. 
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
