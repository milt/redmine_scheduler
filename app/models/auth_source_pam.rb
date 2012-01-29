require 'rpam'
include Rpam
 
class AuthSourcePam < AuthSource
 
  def authenticate(login, password)
    logger.debug "replacement PAM auth called" if logger && logger.debug?
 
    return nil if login.blank? or password.blank? or not authpam(login, password)
 
    return {:firstname => login}
  end
 
  def auth_method_name
    "PAM"
  end
 
end
