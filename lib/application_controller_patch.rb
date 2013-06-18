module ApplicationControllerPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class 
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      
      def current_ability
        @current_ability ||= Ability.new(User.current)
      end

      rescue_from CanCan::AccessDenied do |exception|
        return unless require_login
        render_403
        return false
      end
    end

  end

  module ClassMethods

  end

  module InstanceMethods

  end
end