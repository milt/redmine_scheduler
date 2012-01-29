#load some defaults for the DMC plugin

#load authentication method for PAM

pam = AuthSource.new(:name => "PAM", :host => "localhost", :port => 1, :account => "user", :account_password => "pass", :base_dn => "app", :attr_login => "name", :attr_firstname => "firstname", :attr_lastname => "lastname", :attr_mail => "email", :onthefly_register => 1, :tls => 0)
pam.type = "AuthSourcePam"
pam.save